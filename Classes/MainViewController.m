//
//  MainViewController.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ScoreViewController.h"
#import "SettingViewController.h"
#import "HelpViewController.h"
#import "RankViewController.h"
#import "QuestViewController.h"
#import "MainViewController.h"
#import <UserMessagingPlatform/UserMessagingPlatform.h>
#import <FirebaseAnalytics/FirebaseAnalytics.h>
#import "MainView.h"
#import "Locale.h"
#import "MoreGamesViewController.h"
#import "NewGameDialog.h"
#import "DailyStreak.h"       // 데일리 연속 (A468 R3)
#import "FirstSessionCard.h"  // 첫 세션 안내 (A468 R1)
#import "GameCenterUtil.h"
#ifdef USE_JMC
#import "JMC.h"
#endif
#import "KillerMap.h"
//#import "AddThis.h"
#ifdef USE_FLURRY
#import "Flurry.h"
#endif
#import "UIDevice+IdentifierAddition.h"
#import <sys/utsname.h>
#import <AdSupport/ASIdentifierManager.h>
#import <AppTrackingTransparency/ATTrackingManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

// 분석 이벤트 이름 — 공장 표준 그대로 (A463 · A464).
// 출처: factory `packages/ga_analytics/lib/src/analytics_events.dart`
//       (GaEvents · GaEventParams) 와 Flutter 6앱 `lib/ads/ga_events.dart`.
// 같은 Firebase 프로젝트(sudoku9flutter)의 Flutter 앱과 같은 자로 잰다.
static NSString *const kGaEvAdResult         = @"ad_result";
static NSString *const kGaEvAdRewardEarned   = @"ad_reward_earned";
static NSString *const kGaParPlacement       = @"placement";
static NSString *const kGaParOutcome         = @"outcome";
static NSString *const kGaParWasCached       = @"was_cached";
static NSString *const kGaParWaitMs          = @"wait_ms";
static NSString *const kGaParErrorCode       = @"error_code";
static NSString *const kGaOutcomeEarned      = @"earned";       // 보상을 받았다 · 전면을 보여 줬다
static NSString *const kGaOutcomeDismissed   = @"dismissed";    // 보상 전에 닫았다
static NSString *const kGaOutcomeUnavailable = @"unavailable";  // 못 받음 · 표시 실패
static NSString *const kGaOutcomeOffline     = @"offline";      // 망 오류로 못 받음

// 판 흐름 이벤트 (A464) — 공장 표준 game_start · game_over · level_complete.
// 모든 이벤트에 game_id(= 공장 슬러그, 타깃마다 하나) 를 싣는다. 옛 Flurry 이벤트는 그대로 둔다.
#if defined(SUDOKU6) && defined(ADMOB_FREEVERSION)
static NSString *const kGaGameId = @"sudoku6free";
#elif defined(SUDOKU6)
static NSString *const kGaGameId = @"sudoku6pro";
#elif defined(ADMOB_FREEVERSION)
static NSString *const kGaGameId = @"sudoku9free";
#else
static NSString *const kGaGameId = @"sudoku9pro";
#endif

static void GaLogEvent(NSString *name, NSDictionary *params)
{
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithObject:kGaGameId forKey:@"game_id"];
    [p addEntriesFromDictionary:params];
    [FIRAnalytics logEventWithName:name parameters:p];
}

// mode_id — 판 종류 · 난이도 (소문자 · 밑줄). 오늘의 퍼즐은 앞에 daily_.
static NSString *GaModeId(SudokuGame *g)
{
    NSString *raw = [NSString stringWithFormat:@"%@%@_%@", g.bDailyPuzzle ? @"daily_" : @"",
                     [SudokuGame getSudokuTypeNameNoop:g.sudokuType],
                     [SudokuGame getGameLevelNameNoop:g.gameLevel]];
    NSString *low = [[raw lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSMutableString *out = [NSMutableString string];
    for (NSUInteger i = 0; i < low.length; i++) {
        unichar c = [low characterAtIndex:i];
        [out appendString:((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_')
                              ? [NSString stringWithCharacters:&c length:1] : @"_"];
    }
    return out;
}

// game_start 의 from — 다음 한 번만 싣는다 (첫 세션 첫 판 = first_session, A468 R1). nil 이면 싣지 않는다.
static NSString *gGaNextStartFrom = nil;

// 첫 세션 안내 카드를 띄울 차례인가 (A468 R1) — 처음 설치해 저장된 판 · 점수가 없을 때 init 에서 켠다.
static BOOL gFirstSessionCardPending = NO;
static NSString *const kFirstSessionCardDone = @"firstSessionCard.done";

static void GaLogQuitIfUnfinished(SudokuGame *g)
{
    if (!g || g.isGameFinished) return;
    NSInteger sec = (NSInteger)g.gameTime;
    GaLogEvent(@"game_over", @{ @"mode_id": GaModeId(g), @"score": @(sec), @"cleared": @0,
                                @"how": @"quit", @"duration_sec": @(sec) });
}
static NSString *const kGaOutcomeGoodwill    = @"goodwill";     // 광고 없이 보상을 대신 줌 (하루 한도 안)

// 광고가 끝내 없을 때 보상을 대신 주는 하루 한도. Flutter FreeRewardQuota 와 같은
// 키 · 꼴("yyyy-MM-dd:n", 기기 현지 날짜)이다. 날짜가 바뀌면 0 부터 다시 센다.
static NSString *const kFreeRewardQuotaKey   = @"freeRewardQuota";
#define FREE_REWARD_LIMIT   3

// QA 메뉴 (A479) — 판정과 까닭은 파일 끝 「QA 메뉴」 절. 광고 실패 흉내는 그 메뉴로만 켜고 저장하지 않는다.
static BOOL gQAAdFail = NO;
static BOOL QAMenuEnabled(void);
#ifdef DEBUG
static NSString *QADebugArg(void);
#endif
@interface MainView (QA)
- (void) checkClearAndUpdateButton;   // MainView.m 안에 있다 — QA 「판 풀기」가 깬 판 판정을 다시 돌린다
@end
static NSString *const kGaPlacementHint         = @"rewarded_hint";
static NSString *const kGaPlacementInterstitial = @"interstitial_gameover";
#ifdef ADMOB_FREEVERSION
static NSString *const kGaPlacementBanner       = @"banner";
#endif

// AdMob 망 오류(GADErrorNetworkError = 2)거나 URL 오류면 오프라인으로 센다.
static BOOL GaIsOfflineError(NSError *error)
{
    if (error == nil) return NO;
    if ([error.domain isEqualToString:NSURLErrorDomain]) return YES;
    return [error.domain isEqualToString:GADErrorDomain] && error.code == GADErrorNetworkError;
}


@implementation MainViewController

@synthesize mainView;
@synthesize labelNewGame;
@synthesize labelTitleLevel;
@synthesize labelTitleGameTime;
@synthesize labelTitleBlank;
@synthesize labelTitleHint;
@synthesize areaPuzzleTable;
@synthesize areaNumButton;
@synthesize areaAdBanner;
@synthesize areaiAdBanner;
@synthesize labelAutoMemo;
@synthesize labelSudokuType;
@synthesize buttonCheckboxAutoMemo;
//@synthesize buttonNewGameDailyPuzzle;
@synthesize labelDailyStat;
@synthesize buttonNewGameUserInput;
@synthesize buttonNewGameVeryEasy;
@synthesize buttonNewGameEasy;
@synthesize buttonNewGameNormal;
@synthesize buttonNewGameHard;
@synthesize buttonNewGameVeryHard;
@synthesize buttonNewGameCancel;
@synthesize buttonDailyRanking;
@synthesize buttonDailyGameSudoku;
@synthesize buttonDailyGameGt;
@synthesize buttonDailyGameKiller;
@synthesize buttonDailyGameCalcu;
@synthesize buttonDailyGameSymbol;
@synthesize buttonDailyGameSudokuEasy;
@synthesize buttonDailyGameGtEasy;
@synthesize buttonDailyGameKillerEasy;
@synthesize buttonDailyGameCalcuEasy;
@synthesize buttonDailyGameSymbolEasy;
@synthesize buttonDailyGameSudokuHard;
@synthesize buttonDailyGameGtHard;
@synthesize buttonDailyGameKillerHard;
@synthesize buttonDailyGameCalcuHard;
@synthesize buttonDailyGameSymbolHard;
@synthesize buttonNickname;


//@synthesize labelDailyAutoMemo;
//@synthesize buttonDailyCheckboxAutoMemo;
@synthesize labelDailyStatSudoku;
@synthesize labelDailyStatGt;
@synthesize labelDailyStatKiller;
@synthesize labelDailyStatCalcu;
@synthesize labelDailyStatSymbol;
@synthesize labelNickname;
@synthesize buttonDailyGameCancel;

@synthesize buttonNewGame;
@synthesize buttonDailyGame;
@synthesize buttonMenu;
@synthesize buttonUndo;
@synthesize buttonRedo;
@synthesize buttonBookmark;
@synthesize buttonMemo;
@synthesize buttonScore;
@synthesize buttonQuest;
@synthesize buttonDel;
@synthesize buttonReset;
@synthesize buttonSharePuzzle;
@synthesize buttonHint;
@synthesize buttonSetting;
@synthesize buttonMenuClose;
@synthesize buttonHelp;
@synthesize buttonRank;
@synthesize buttonHistory;
@synthesize buttonFeedback;
@synthesize buttonCloseButton;
@synthesize buttonPlayNew;
@synthesize buttonPlayAgain;
@synthesize buttonSeeReplay;

@synthesize buttonRecordShare;
@synthesize buttonPuzzleShare;


@synthesize viewMenu;
@synthesize viewNewGame;
@synthesize viewDailyGame;
@synthesize imageUserLevel;
@synthesize labelUserLevel;
@synthesize labelUserName;
@synthesize labelLevel;
@synthesize labelGameTime;
@synthesize labelBlank;
@synthesize labelHint;
@synthesize timerGame;
@synthesize timerNewGame;
@synthesize timerDailyGame;
@synthesize activityIndicator;
@synthesize activityIndicatorDailyStat;
@synthesize activityIndicatorDailyGame;
@synthesize segmentType;
@synthesize labelLicense;


@synthesize gServerIP;
@synthesize gUserID;
@synthesize gUserName;
@synthesize gDeviceID;
@synthesize gVersion;

@synthesize gInterval;
@synthesize gIntervalSec;
@synthesize gRandom;
@synthesize gBonus;
@synthesize gAdBendor;
@synthesize gNowAd;
@synthesize gAdmobFailCount;

//@synthesize nowDate;
@synthesize strMsgFinish;

#ifdef ADMOB_FREEVERSION
@synthesize bNoAd;              // 광고 제거 아이템 구매
@synthesize bNoAdRestarted;     // 광고 제거된 xib으로 load됨
#endif // ADMOB_FREEVERSION

- (void) initScore
{
	DLog(@"initScore");
        
	for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int i=0; i<MAX_SCORE_TYPE; i++)
        {
            score.scoreGames[type][i] = 0;
            score.scoreClears[type][i] = 0;
            score.scoreBestTime[type][i] = 0;
            score.scoreClearTimeSum[type][i] = 0;
            score.scoreRankLevel[type][i] = 0;
        }
	}
    score.scoreTotal = 0;
    score.scoreRankTotal = 0;
}
#ifdef SUDOKU16
#define kScoreGames			@"score16Games"
#define kScoreClears		@"score16Clears"
#define kScoreBestTime		@"score16BestTime"
#define kScoreClearTimeSum	@"score16ClearTimeSum"
#define kScoreRankLevel     @"score16RankLevel"
#define kScoreRankTotal     @"score16RankTotal"
#define kScoreTotal         @"score16Total"
#elif defined(SUDOKU12)
#define kScoreGames			@"score12Games"
#define kScoreClears		@"score12Clears"
#define kScoreBestTime		@"score12BestTime"
#define kScoreClearTimeSum	@"score12ClearTimeSum"
#define kScoreRankLevel     @"score12RankLevel"
#define kScoreRankTotal     @"score12RankTotal"
#define kScoreTotal         @"score12Total"
#elif defined(SUDOKU9)
#define kScoreGames			@"scoreGames"
#define kScoreClears		@"scoreClears"
#define kScoreBestTime		@"scoreBestTime"
#define kScoreClearTimeSum	@"scoreClearTimeSum"
#define kScoreRankLevel     @"scoreRankLevel"
#define kScoreRankTotal     @"scoreRankTotal"
#define kScoreTotal         @"scoreTotal"
#elif defined(SUDOKU7)
#define kScoreGames			@"score7Games"
#define kScoreClears		@"score7Clears"
#define kScoreBestTime		@"score7BestTime"
#define kScoreClearTimeSum	@"score7ClearTimeSum"
#define kScoreRankLevel     @"score7RankLevel"
#define kScoreRankTotal     @"score7RankTotal"
#define kScoreTotal         @"score7Total"
#else   // SUDOKU6
#define kScoreGames			@"score6Games"
#define kScoreClears		@"score6Clears"
#define kScoreBestTime		@"score6BestTime"
#define kScoreClearTimeSum	@"score6ClearTimeSum"
#define kScoreRankLevel     @"score6RankLevel"
#define kScoreRankTotal     @"score6RankTotal"
#define kScoreTotal         @"score6Total"
#endif
#define kScoreTotalSec      @"scoreTotalSec"

- (void) setButtonMode:(UIButton *)button  mode:(BOOL)mode
{
    if (mode == YES) {
        button.enabled = YES;
        button.alpha = 1.0f;
    } else {
        button.enabled = NO;
        button.alpha = 0.3f;
    }
}

- (void) saveTotalSecData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setInteger:score.spendTotalSec forKey:kScoreTotalSec];
    //DLog(@"spendTotalSec=%ld", (unsigned long)score.spendTotalSec);
    [defaults synchronize];
}


- (void) saveScoreData
{
	DLog(@"saveScoreData");
    int num;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int i=0; i<MAX_SCORE_TYPE; i++)
        {
            if (i < 10)
                num = i+type*10;
            else
                num = 100 + i+type*10;  // 하위 호환을 위해서 어쩔 수 없음
            
            [defaults setInteger:score.scoreGames[type][i] forKey:[kScoreGames stringByAppendingFormat:@"%d", num]];
            [defaults setInteger:score.scoreClears[type][i] forKey:[kScoreClears stringByAppendingFormat:@"%d", num]];
            [defaults setInteger:score.scoreBestTime[type][i] forKey:[kScoreBestTime stringByAppendingFormat:@"%d", num]];
            [defaults setInteger:score.scoreClearTimeSum[type][i] forKey:[kScoreClearTimeSum stringByAppendingFormat:@"%d", num]];
            [defaults setInteger:score.scoreRankLevel[type][i] forKey:[kScoreRankLevel stringByAppendingFormat:@"%d", num]];
        }
    }
    [defaults setInteger:score.scoreTotal forKey:kScoreTotal];
    [defaults setInteger:score.scoreRankTotal forKey:kScoreRankTotal];
    [defaults setInteger:score.spendTotalSec forKey:kScoreTotalSec];
    DLog(@"scoreRankTotal=%ld", (long)score.scoreRankTotal);
	[defaults synchronize];
    
    [self setUserLevel];
}

- (NSInteger) getGameResultScore:(NSInteger)level sec:(NSInteger)sec
{
    NSInteger scoreTemp = MIN(sec/60+1, 10);
    
	if (scoreTemp < 5)
		scoreTemp = (5-level) * (10 - scoreTemp + 1) * 3;	// Original은 3배의 점수를 준다.
    else
		scoreTemp = (10-level) * (10 - scoreTemp + 1);
		
#ifdef SUDOKU16  // zzz 나중에는 size 넘겨줘서 계산 해야 한다.
    scoreTemp = scoreTemp * (SIZE_16*SIZE_16)/100;
#elif defined(SUDOKU12)
    scoreTemp = scoreTemp * (SIZE_12*SIZE_12)/100;
#elif defined(SUDOKU9)
    scoreTemp = scoreTemp * (SIZE_9*SIZE_9)/100;
#else
    scoreTemp = scoreTemp * (SIZE_6*SIZE_6)/100;
#endif
    scoreTemp = MAX(scoreTemp, 1);

    DLog(@"getGameResultScore(%ld,%ld) => %ld", (long)level, (long)sec, (long)scoreTemp);
    
    return scoreTemp;
}

- (void) loadScoreData
{
	DLog(@"loadScoreData");	
    int num;
    unsigned int guessTotalSec=0;
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int i=0; i<MAX_SCORE_TYPE; i++)
        {
            if (i < 10)
                num = i+type*10;
            else
                num = 100 + i+type*10;
            
            score.scoreGames[type][i] = [defaults integerForKey:[kScoreGames stringByAppendingFormat:@"%d", num]];
            score.scoreClears[type][i] = [defaults integerForKey:[kScoreClears stringByAppendingFormat:@"%d", num]];
            score.scoreBestTime[type][i] = [defaults integerForKey:[kScoreBestTime stringByAppendingFormat:@"%d", num]];
            score.scoreClearTimeSum[type][i] = [defaults integerForKey:[kScoreClearTimeSum stringByAppendingFormat:@"%d", num]];
            score.scoreRankLevel[type][i] = [defaults integerForKey:[kScoreRankLevel stringByAppendingFormat:@"%d", num]];
            
            guessTotalSec += (unsigned int) score.scoreClearTimeSum[type][i];
            if (score.scoreClears[type][i] > 0)
                guessTotalSec += (unsigned int) score.scoreClearTimeSum[type][i] * score.scoreGames[type][i] / score.scoreClears[type][i];

            DLog(@"Score[%d][%d]:%d,%d,%d,%d,%d,%ud", type, num,
                 (int)score.scoreGames[type][i],
                 (int)score.scoreClears[type][i],
                 (int)score.scoreBestTime[type][i],
                 (int)score.scoreClearTimeSum[type][i],
                 (int)score.scoreRankLevel[type][i],
                 guessTotalSec);
        }
    }
    
    score.spendTotalSec = [defaults integerForKey:kScoreTotalSec];
    
    if (score.spendTotalSec == 0)
        score.spendTotalSec = (NSUInteger) guessTotalSec;
        
    
    score.scoreTotal = [defaults integerForKey:kScoreTotal];
	if (score.scoreTotal == 0)
    {
        // need to migration
        for (int i=0; i<10; i++)
        {
            score.scoreTotal += score.scoreGames[0][i];    // 게임 시작하면 무조건 1점씩 추가 됨
            if (score.scoreClears[0][i] > 0)
                score.scoreTotal += score.scoreClears[0][i] *
                [self getGameResultScore:i sec:score.scoreClearTimeSum[0][i]/score.scoreClears[0][i]];
        }
	}
    score.scoreRankTotal = [defaults integerForKey:kScoreRankTotal];

    DLog(@"scoreTotal = %ld", (long)score.scoreTotal);
    
    [self setUserLevel];
    
}

#define kAdStateShow		@"AdStateShow"
#define kAdStateFail		@"AdStateFail"
#define kAdStateLastError	@"AdStateLastError"


- (void) loadAdState
{
    DLog(@"loadAdState");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (int i=0; i<eAdStateMax; i++)
    {
        gAdState[i].show = [defaults integerForKey:[kAdStateShow stringByAppendingFormat:@"%d", i]];
        gAdState[i].fail = [defaults integerForKey:[kAdStateFail stringByAppendingFormat:@"%d", i]];
        gAdState[i].lasterror = nil;
        if ([defaults objectForKey:[kAdStateLastError stringByAppendingFormat:@"%d", i]]) {
            NSString *str = [defaults stringForKey:[kAdStateLastError stringByAppendingFormat:@"%d", i]];
            if (str)
                gAdState[i].lasterror = [[NSString alloc] initWithString:str];
        }
        DLog(@"load gAdState[%d] = %d,%d,%@", i, (int)gAdState[i].show, (int)gAdState[i].fail, gAdState[i].lasterror);
    }
}

- (void) saveAdState
{
    DLog(@"saveAdState");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (int i=0; i<eAdStateMax; i++)
    {
        [defaults setInteger:gAdState[i].show forKey:[kAdStateShow stringByAppendingFormat:@"%d", i]];
        [defaults setInteger:gAdState[i].fail forKey:[kAdStateFail stringByAppendingFormat:@"%d", i]];
        [defaults setObject:gAdState[i].lasterror forKey:[kAdStateLastError stringByAppendingFormat:@"%d", i]];
        DLog(@"save gAdState[%d] = %d,%d,%@", i, (int)gAdState[i].show, (int)gAdState[i].fail, gAdState[i].lasterror);
    }
    [defaults synchronize];
}


- (void) alertMessageButton:(NSString*)title msg:(NSString*) msg button:(NSString*)button
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:button
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}



- (void) alertMessageOk:(NSString*)title msg:(NSString*) msg
{
    [self alertMessageButton:title msg:msg button:gettext(@"Ok", nil)];
}

- (void) alertFinish
{
    if (mainView.sudokuGame.bFinishAlert == YES)    // to prevent repeat
        return;
    
    mainView.sudokuGame.bFinishAlert = YES;
        
    DLog(@"strMsgFinish=%@", strMsgFinish);

//    [self alertMessageOk:gettext(@"Congratulations!", nil) msg:strMsgFinish];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:gettext(@"Congratulations!", nil)
                                  message:strMsgFinish
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:gettext(@"Ok", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
#ifdef ADMOB_FREEVERSION
                             if (self.interstitial != nil && bNoAd == NO)
//                             if (self.interstitial != nil)
                                 [self showInterstitial];
#endif // ADMOB_FREEVERSION
                         }];

    [alert addAction:ok];

    // More Games: 누르면 앱 안 More Games 화면(MoreGamesViewController)을 연다. OK 의 전면 광고 흐름은 그대로이고,
    // 이 단추를 고르면 그 판의 전면 광고는 보이지 않는다(광고 흐름은 바꾸지 않았다).
    UIAlertAction* more = [UIAlertAction
                           actionWithTitle:gettext(@"More Games", nil)
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               [Locale openMoreGames];
                           }];
    [alert addAction:more];
    alert.preferredAction = ok;

    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger) levelToWriteScore:(SudokuGame*)sudokuGame
{
    NSInteger level;
    
    if (sudokuGame.gameLevel == GAMELEVEL_USERINPUT) {
        level = sudokuGame.bAutoMemo ? MAX_SCORE_TYPE-1 : MAX_SCORE_TYPE-2; // 12:11
    } else {
        level = sudokuGame.gameLevel + (sudokuGame.bAutoMemo ? 5 : 0);
    }

    return level;
}


- (void) writeScoreAfterFinishGame:(SudokuGame*)sudokuGame
{
	// button diable
    
    if (sudokuGame.bDailyPuzzle) {  // check quest
        switch (sudokuGame.sudokuType) {
            case SUDOKUTYPE_SUDOKU  : [self DoneQuest:eQuestClearDaily0]; break;
            case SUDOKUTYPE_GT      : [self DoneQuest:eQuestClearDaily1]; break;
            case SUDOKUTYPE_KILLER  : [self DoneQuest:eQuestClearDaily2]; break;
            case SUDOKUTYPE_CALCU   : [self DoneQuest:eQuestClearDaily3]; break;
            default: break;
        }
    } else  {
        switch (sudokuGame.gameLevel) {
            case GAMELEVEL_VERYHARD : [self DoneQuest:eQuestClearLevel0]; break;
            case GAMELEVEL_HARD     : [self DoneQuest:eQuestClearLevel1]; break;
            case GAMELEVEL_NORMAL   : [self DoneQuest:eQuestClearLevel2]; break;
            case GAMELEVEL_EASY     : [self DoneQuest:eQuestClearLevel3]; break;
            case GAMELEVEL_VERYEASY : [self DoneQuest:eQuestClearLevel4]; break;
            default: break;
        }
    }
    
    
//#ifdef ADMOB_FREEVERSION
    //if (bNoAd == NO)
        [self loadInterstitial];
//#endif
	DLog(@"writeScoreAfterFinishGame");	
    {   // 분석 (A464): 판을 깼다 — game_over(how=finished, cleared=1) + level_complete.
        NSInteger gaSec = (NSInteger)sudokuGame.gameTime;
        GaLogEvent(@"game_over", @{ @"mode_id": GaModeId(sudokuGame), @"score": @(gaSec), @"cleared": @1,
                                    @"how": @"finished", @"duration_sec": @(gaSec) });
        GaLogEvent(@"level_complete", @{ @"mode_id": GaModeId(sudokuGame), @"score": @(gaSec) });
    }
    BOOL bNewBest = NO;
    NSInteger level = [self levelToWriteScore:sudokuGame];
    
	score.scoreClears[sudokuGame.sudokuType][level] += 1;
    
	if (score.scoreBestTime[sudokuGame.sudokuType][level] == 0 ||                     // 최초는 무조건 Best time
		sudokuGame.gameTime < score.scoreBestTime[sudokuGame.sudokuType][level])
    {
        if (score.scoreBestTime[sudokuGame.sudokuType][level] != 0)
        {
            if (sudokuGame.gameLevel != GAMELEVEL_USERINPUT)    // user input은 best 고려 안함
                bNewBest = YES;
        }
		score.scoreBestTime[sudokuGame.sudokuType][level] = sudokuGame.gameTime;      // best time 갱신
        
	}
    
    strMsgFinish = [[NSString alloc] initWithString:gettext(@"You cleared this game.", nil)];
    if (sudokuGame.bDailyPuzzle)
    {   // 데일리 연속 (A468 R3) — 하루 한 번 센다. 마일스톤(3 · 7 · 14 · 30일, 평생 한 번)은 힌트로 준다.
        DSClearResult sr = [DailyStreak recordClearOn:[self getNowYYYYMMDD]];
        if (sr.rewardHints > 0) {
            mainView.paidHintCount += sr.rewardHints;
            [self saveSetting];
            [self updateHintCount];
        }
        GaLogEvent(@"daily_clear", @{ @"mode_id": GaModeId(sudokuGame), @"streak": @(sr.streak), @"best": @(sr.best),
                                      @"first_today": @(sr.counted ? 1 : 0), @"milestone": @(sr.milestone),
                                      @"hints": @(sr.rewardHints) });
        if (sr.brokenFrom > 0)
            GaLogEvent(@"streak_broken", @{ @"was": @(sr.brokenFrom) });
        if (sr.counted) {
            strMsgFinish = [strMsgFinish stringByAppendingFormat:@"\n%@",
                            [NSString stringWithFormat:gettext(@"streak.clear.msg", nil), (int)sr.streak]];
            if (sr.milestone > 0)
                strMsgFinish = [strMsgFinish stringByAppendingFormat:@"\n%@",
                                [NSString stringWithFormat:gettext(@"streak.milestone.msg", nil),
                                 (int)sr.milestone, (int)sr.rewardHints]];
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            // 작업이 오래 걸리는 API를 백그라운드 스레드에서 실행한다.
            NSInteger total=0, grade=0;
            NSString* strMsgRanking = NULL;
            
            if ([self uploadDailyPuzzleResult:@"addresult"
                                    spendTime:sudokuGame.gameTime
                                   sudokuType:sudokuGame.sudokuType
                                    gameLevel:sudokuGame.gameLevel
                                    bAutoMemo:false // 무조건 false다.
                                       pTotal:&total
                                       pGrade:&grade] == YES &&
                total > 0 &&
                grade > 0 &&
                grade <= total)
            {
                strMsgRanking = [[NSString alloc] initWithFormat:gettext(@"Your ranking of daily puzzle:#%d/%d", nil), grade, total];
                
                //[self alertMessageOk:gettext(@"Ranking", nil) msg:strMsgRanking];
                
                // 알수 없는 버그 : Noti 창이 사라지지 않는 경우가 1번 발생했다. 재현이 어렵고 주요한 정보가 아니니 삭제하자.
                /*[[GKAchievementHandler defaultHandler]
                 notifyAchievementTitle:gettext(@"Ranking", nil)
                 andMessage:strMsgRanking];*/
                 
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // do nothing
            });
            [strMsgRanking release];
        });
    } else {
        // timer -> adduserresult send
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            // 작업이 오래 걸리는 API를 백그라운드 스레드에서 실행한다.
            BOOL res = [self sendNormalPuzzleResult:sudokuGame];
            DLog(@"[self sendNormalPuzzleResult] => %d", (int)res);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // do nothing
            });
        });

    }

    
    if (bNewBest)
    {
        strMsgFinish = [strMsgFinish stringByAppendingString:@"\n"];
        strMsgFinish = [strMsgFinish stringByAppendingString:gettext(@"You broke your best time.", nil)];
    }
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        strMsgFinish = [strMsgFinish stringByAppendingString:@"\n"];
        strMsgFinish = [strMsgFinish stringByAppendingFormat:
                  gettext(@"If you share this puzzle or result on Facebook, you can get %d more hints in next game.", nil),
                  NUM_HINTBONUS];
    }
    
    DLog(@"strMsgFinish = %@", strMsgFinish);

    if (bLoadInterstitialAds)
        [strMsgFinish retain];
    else
        [self alertFinish];

/*
#ifdef ADMOB_FREEVERSION__________
    // do nothing
    if (bLoadInterstitialAds)
        [strMsgFinish retain];
    else
        [self alertFinish];
#else
    [self alertFinish];
#endif
*/
//    [self alertFinish];
    
    
    score.scoreClearTimeSum[sudokuGame.sudokuType][level] += sudokuGame.gameTime;
	
    // add current game score to Total Score
    score.scoreTotal += [self getGameResultScore:level sec:sudokuGame.gameTime];
    score.scoreTotal += sudokuGame.countHint*3;   // 남은 힌트 점수 추가
    
	[self saveScoreData];
    

    [self sendDataToGameCenter:sudokuGame];
	[self updateButtons];
}

-(BOOL) sendNormalPuzzleResult:(SudokuGame*)sudokuGame // spend
{
    NSInteger total=0, grade=0;
    
    BOOL bRet = [self uploadDailyPuzzleResult:@"adduserresult"
                                    spendTime:sudokuGame.gameTime
                                   sudokuType:sudokuGame.sudokuType
                                    gameLevel:sudokuGame.gameLevel
                                    bAutoMemo:sudokuGame.bAutoMemo
                                       pTotal:&total
                                       pGrade:&grade];    // 이부분을 수정
    if (!bRet)
    {
        // 전송 할 때까지 반복할 것인가?
        return NO;
    }
    return YES;
}


- (void) OnTimerGetRanking:(NSTimer *)timer
{
    DLog(@"OnTimerGetRanking");
    [self getRankingFromGameCenter];
}

- (void) sendDataToGameCenter:(SudokuGame*)sudokuGame
{
    DLog(@"sendDataToGameCenter");
    [GameCenterUtil sendScoreToGameCenter:score.scoreTotal];                    // 총점 보내기
    [GameCenterUtil sendAchievementClearGame:[self getScoreTotalClears]];       // achievement 보내기
    
    // 이렇게 하면 사람들이 어떤 게임을 많이 즐기는지 알 수 없다.
    /*for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int level=0; level<5; level++)
        {
            if (score.scoreBestTime[type][level] > 0)
                [GameCenterUtil sendBestTimeToGameCenter:type level:level besttime:score.scoreBestTime[type][level]];
        }
    }*/
    // 게임을 끝낸 종류와 Level의 Best time을 무조건 보냄으로써 사람들이 즐기는 게임의 종류와 레벨을 알 수 있다.
    
    
    // best time이 아니고 현재 게임 시간을 보낸다. 금주/오늘의 성적에 반영된다.
    if (mainView.sudokuGame.bAutoMemo == NO)
    {
        [GameCenterUtil sendBestTimeToGameCenter:sudokuGame.sudokuType
                                           level:sudokuGame.gameLevel
                                        besttime:sudokuGame.gameTime];  //score.scoreBestTime[sudokuGame.sudokuType][sudokuGame.gameLevel]];
    } else if (mainView.sudokuGame.sudokuType == SUDOKUTYPE_SUDOKU) {
        [GameCenterUtil sendBestTimeToGameCenter:sudokuGame.sudokuType     // auto
                                           level:sudokuGame.gameLevel+5
                                        besttime:sudokuGame.gameTime];  //score.scoreBestTime[sudokuGame.sudokuType][sudokuGame.gameLevel]];
    } else {    // Original과 Auto중에서 작은 숫자를 보낸다.
//        NSInteger iMin = MIN(score.scoreBestTime[sudokuGame.sudokuType][sudokuGame.gameLevel],
//                             score.scoreBestTime[sudokuGame.sudokuType][sudokuGame.gameLevel+5]);
        [GameCenterUtil sendBestTimeToGameCenter:sudokuGame.sudokuType
                                           level:sudokuGame.gameLevel
                                        besttime:sudokuGame.gameTime];  //iMin];
    }
    [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(OnTimerGetRanking:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) getRankingFromGameCenter
{
    int iMaxRanking = 0;
    DLog(@"getRankingFromGameCenter");
    [GameCenterUtil getTotalScoreRanking:&(score.scoreRankTotal) value:&(score.scoreTotal)];
    
    for (SUDOKUTYPE type=0; type<SUDOKUTYPE_GK_MAX; type++)   // SUDOKUTYPE_MAX => auto
    {
        iMaxRanking = ((type==SUDOKUTYPE_SUDOKU) ? NUM_RANK_BESTTIME*2 : NUM_RANK_BESTTIME);
        for (int level=0; level<iMaxRanking; level++)
        {
            if (type==SUDOKUTYPE_SUDOKU)    // best time sync는 original sudoku만 지원
            {
                [GameCenterUtil getRanking:[GameCenterUtil getLevelCategory:type level:level]
                                      rank:&(score.scoreRankLevel[type][level])
                                     value:&(score.scoreBestTime[type][level])];
            } else {
                [GameCenterUtil getRanking:[GameCenterUtil getLevelCategory:type level:level]
                                      rank:&(score.scoreRankLevel[type][level])
                                     value:NULL];
            }
        }
    }
    
    [self setUserLevel];
    
    [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(OnTimerScoreRanking:)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (void) OnTimerScoreRanking:(NSTimer *)timer
{
    DLog(@"OnTimerScoreRanking");
    [self saveScoreData];
}

- (NSInteger) getScoreTotalClears
{
	NSInteger num = 0;
	
    for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int i=0; i<10; i++)
        {
            num += score.scoreClears[type][i];
        }
    }
	return num;
}

#define SETTING_VERSION                 1
#define kSettingSavedVersion            @"settingSavedVersion"
#define kSettingSoundEffect             @"settingSoundEffect"
#define kSettingGuideline               @"settingGuideline"
#define kSettingDuplicationWarning      @"settingDuplicationWarning"
#define kSettingMarkingEqual            @"settingMarkingEqual"
#define kSettingDefMap                  @"settingDefMap"
#define kSettingAutoMemo                @"settingAutoMemo"
#define kSettingSudokuType              @"settingSudokuType"
#define kSettingNewGameLevel            @"settingNewGameLevel"   // 새 게임 창에서 마지막에 고른 난이도 (A478)
#define kSettingSkin                    @"settingSkin"
#define kSharedThisOnFacebook           @"sharedThisOnFacebook"
#define kPaidHintCount                  @"paidHintCount"

- (void) loadSetting
{
	DLog(@"loadSetting");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    NSInteger settingVersion = [defaults integerForKey:kSettingSavedVersion];
    if (settingVersion == 0)    // 처음에는 저장된 setting이 없다.
    {
        [self saveSetting];
        return;
    }    
    
    mainView.nSettingSoundOff = [defaults integerForKey:kSettingSoundEffect];
    mainView.bSettingGuideline = [defaults boolForKey:kSettingGuideline];
    mainView.bSettingDuplicationWarning = [defaults boolForKey:kSettingDuplicationWarning];
    mainView.bSettingMarkingEqual = [defaults boolForKey:kSettingMarkingEqual];
    mainView.bSettingAutoMemo = [defaults boolForKey:kSettingAutoMemo];
    mainView.nSettingSudokuType = (SUDOKUTYPE) [defaults integerForKey:kSettingSudokuType];
    mainView.skin = [defaults integerForKey:kSettingSkin];
    mainView.bSharedThisOnFacebook = [defaults boolForKey:kSharedThisOnFacebook];
    
    mainView.paidHintCount = [defaults integerForKey:kPaidHintCount];
}

- (void) saveSetting
{
	DLog(@"saveSetting");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:SETTING_VERSION forKey:kSettingSavedVersion];
    [defaults setInteger:mainView.nSettingSoundOff forKey:kSettingSoundEffect];
    [defaults setBool:mainView.bSettingGuideline forKey:kSettingGuideline];
    [defaults setBool:mainView.bSettingDuplicationWarning forKey:kSettingDuplicationWarning];
    [defaults setBool:mainView.bSettingMarkingEqual forKey:kSettingMarkingEqual];
    [defaults setBool:mainView.bSettingAutoMemo forKey:kSettingAutoMemo];
    [defaults setInteger:mainView.nSettingSudokuType forKey:kSettingSudokuType];
    [defaults setInteger:mainView.skin forKey:kSettingSkin];
    [defaults setBool:mainView.bSharedThisOnFacebook forKey:kSharedThisOnFacebook];

    [defaults setInteger:mainView.paidHintCount forKey:kPaidHintCount];
    
    
	[defaults synchronize];
}

- (void) setLocalizedMessage
{
	DLog(@"setLocalizedMessage");
#ifdef ADMOB_FREEVERSION
    labelLicense.text = @"";
#else
    labelLicense.text = [NSString stringWithFormat:STR_LICENSEFormat, [self getNowYYYY]];
#endif
    
    [buttonNewGame		setTitle:gettext(@"New game", nil) forState:UIControlStateNormal];
    [buttonDailyGame	setTitle:gettext(@"daily puzzle", nil) forState:UIControlStateNormal];
    [buttonQuest		setTitle:gettext(@"Quest", nil) forState:UIControlStateNormal];
    [buttonScore		setTitle:gettext(@"Score", nil) forState:UIControlStateNormal];
    [buttonSetting		setTitle:gettext(@"Setting", nil) forState:UIControlStateNormal];
    [buttonReset		setTitle:gettext(@"reset", nil) forState:UIControlStateNormal];
    [buttonReset		setTitle:gettext(@"reset", nil) forState:UIControlStateDisabled];
    [buttonSharePuzzle  setTitle:gettext(@"Puzzle share", nil) forState:UIControlStateNormal];
	[buttonHelp			setTitle:gettext(@"Help", nil) forState:UIControlStateNormal];
    [buttonRank			setTitle:gettext(@"Ranking", nil) forState:UIControlStateNormal];
	[buttonFeedback		setTitle:gettext(@"Feedback", nil) forState:UIControlStateNormal];
	[buttonFeedback		setTitle:gettext(@"Feedback", nil) forState:UIControlStateDisabled];
    DLog(@"gettext(@\"Feedback\", nil)) => %@", gettext(@"Feedback", nil));
	[buttonMenuClose	setTitle:gettext(@"Close", nil) forState:UIControlStateNormal];
	[buttonMoreGames	setTitle:gettext(@"More Games", nil) forState:UIControlStateNormal];

    [buttonMenu			setTitle:gettext(@"menu", nil) forState:UIControlStateNormal];
    [buttonMemo			setTitle:gettext(@"memo", nil) forState:UIControlStateNormal];
    [buttonMemo			setTitle:gettext(@"memo", nil) forState:UIControlStateDisabled];
    [buttonDel			setTitle:gettext(@"del", nil) forState:UIControlStateNormal];
    [buttonDel			setTitle:gettext(@"del", nil) forState:UIControlStateDisabled];
    
    
    [buttonHint			setTitle:gettext(@"hint", nil) forState:UIControlStateNormal];
    [buttonHint			setTitle:gettext(@"hint", nil) forState:UIControlStateDisabled];
    [buttonCloseButton  setTitle:@"" forState:UIControlStateNormal];
    [buttonPlayNew      setTitle:[@"    " stringByAppendingString:gettext(@"New game", nil)] forState:UIControlStateNormal];
    [buttonPlayAgain    setTitle:[@"    " stringByAppendingString:gettext(@"Play again", nil)] forState:UIControlStateNormal];
    [buttonSeeReplay    setTitle:[@"    " stringByAppendingString:gettext(@"Watch replay", nil)] forState:UIControlStateNormal];
    [buttonPuzzleShare    setTitle:[@"    " stringByAppendingString:gettext(@"Puzzle share", nil)] forState:UIControlStateNormal];
    [buttonRecordShare    setTitle:[@"    " stringByAppendingString:gettext(@"Record share", nil)] forState:UIControlStateNormal];
    

    [buttonUndo setTitle:@"" forState:UIControlStateNormal];
    [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_n"] forState:UIControlStateNormal];
    [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_h"] forState:UIControlStateHighlighted];
    [buttonRedo setTitle:@"" forState:UIControlStateNormal];
    [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_n"] forState:UIControlStateNormal];
    [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_h"] forState:UIControlStateHighlighted];
    [buttonBookmark setTitle:@"" forState:UIControlStateNormal];
    [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkoff_n"] forState:UIControlStateNormal];
    [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkoff_h"] forState:UIControlStateHighlighted];
    
    labelTitleLevel.text = gettext(@"level", nil);
    //labelTitleGameTime.text = gettext(@"game time", nil);
    [self updateClockTime];
    labelTitleBlank.text = gettext(@"blank", nil);
    labelTitleHint.text = gettext(@"hint", nil);
    DLog(@"labelTitleHint.frame.size.height = %f", labelTitleHint.frame.size.height);
    DLog(@"[UIScreen mainScreen].bounds.size.height = %f", [UIScreen mainScreen].bounds.size.height);
    //labelNewGame.text = gettext(@"New Game", nil);
    
    DLog(@"labelTitleHint.font.pointSize = %f", labelTitleHint.font.pointSize);
    
    //labelTitleHint.font=[labelTitleHint.font fontWithSize: labelTitleHint.font.pointSize*[UIScreen mainScreen].bounds.size.height/568];
    
	[buttonCheckboxAutoMemo setTitle:@"" forState:UIControlStateNormal];
	labelAutoMemo.text = gettext(@"auto memo", nil);
	labelDailyStat.text = @"";  // 초기화
/*#ifdef DAILYSENDER
    [buttonNewGameDailyPuzzle setTitle:@"send daily puzzle" forState:UIControlStateNormal];
#else
    [buttonNewGameDailyPuzzle setTitle:gettext(@"daily puzzle", nil) forState:UIControlStateNormal];
#endif*/
    [buttonNewGameUserInput setTitle:gettext(@"user input", nil) forState:UIControlStateNormal];
    [self setButtonMode:buttonNewGameUserInput mode:mainView.nSettingSudokuType == SUDOKUTYPE_SUDOKU];
    
    [buttonNewGameVeryEasy setTitle:gettext(@"very easy", nil) forState:UIControlStateNormal];
    [buttonNewGameEasy setTitle:gettext(@"easy", nil) forState:UIControlStateNormal];
    [buttonNewGameNormal setTitle:gettext(@"normal", nil) forState:UIControlStateNormal];
    [buttonNewGameHard setTitle:gettext(@"hard", nil) forState:UIControlStateNormal];
    [buttonNewGameVeryHard setTitle:gettext(@"very hard", nil) forState:UIControlStateNormal];
    [buttonNewGameCancel setTitle:gettext(@"cancel", nil) forState:UIControlStateNormal];

    
//	[buttonDailyCheckboxAutoMemo setTitle:@"" forState:UIControlStateNormal];
//    labelDailyAutoMemo.text = gettext(@"auto memo", nil);

    [buttonNickname setTitle:gettext(@"Nickname", nil) forState:UIControlStateNormal];
    [buttonDailyRanking setTitle:gettext(@"Ranking", nil) forState:UIControlStateNormal];
    [buttonDailyGameSudoku setTitle:gettext(@"sudoku", nil) forState:UIControlStateNormal];
    [buttonDailyGameGt setTitle:gettext(@"greater sudoku", nil) forState:UIControlStateNormal];
    [buttonDailyGameKiller setTitle:gettext(@"sumdoku", nil) forState:UIControlStateNormal];
    [buttonDailyGameCalcu setTitle:gettext(@"calcudoku", nil) forState:UIControlStateNormal];
    [buttonDailyGameSymbol setTitle:gettext(@"symbol sudoku", nil) forState:UIControlStateNormal];

    [buttonDailyGameSudokuEasy setTitle:gettext(@"easy", nil) forState:UIControlStateNormal];
    [buttonDailyGameGtEasy setTitle:gettext(@"easy", nil) forState:UIControlStateNormal];
    [buttonDailyGameKillerEasy setTitle:gettext(@"easy", nil) forState:UIControlStateNormal];
    [buttonDailyGameCalcuEasy setTitle:gettext(@"easy", nil) forState:UIControlStateNormal];
    [buttonDailyGameSymbolEasy setTitle:gettext(@"easy", nil) forState:UIControlStateNormal];

    [buttonDailyGameSudokuHard setTitle:gettext(@"hard", nil) forState:UIControlStateNormal];
    [buttonDailyGameGtHard setTitle:gettext(@"hard", nil) forState:UIControlStateNormal];
    [buttonDailyGameKillerHard setTitle:gettext(@"hard", nil) forState:UIControlStateNormal];
    [buttonDailyGameCalcuHard setTitle:gettext(@"hard", nil) forState:UIControlStateNormal];
    [buttonDailyGameSymbolHard setTitle:gettext(@"hard", nil) forState:UIControlStateNormal];

    
    [buttonDailyGameCancel setTitle:gettext(@"cancel", nil) forState:UIControlStateNormal];
    
    
    
    if (mainView.sudokuGame)
        [self setGameLevel];
    
    [self setUserLevel];
    [self setUserName];

}


#define kLocale     @"locale"

- (void) decideLocale
{
	DLog(@"decideLocale");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *strLocale = [defaults stringForKey:kLocale];  // 저장된 locale 가져오기
                           
    if (strLocale)
    {
        [Locale setLocale:strLocale];
        return;
    } else {    // 아직 Locale이 저장된 적이 없다. 여기서 최초로 저장한다.
        strLocale = gettext(@"locale", nil);      // 현재 1st locale 가져오기
        
        [Locale setLocale:strLocale];
    }
}

- (void) setUserName:(NSString*) newname
{
    DLog(@"setUserName:%@", newname);
    
    [gUserName release];
    if ([newname length] > 60) {
#ifdef USE_FLURRY
        [Flurry logEvent:@"ChangeNickNameDialog Too Long name"];
#endif
        newname = [newname substringWithRange:NSMakeRange(0, 60)];
    }
    gUserName = [[NSString stringWithString:newname] retain];
    DLog(@"setUserName:%@ => %@", newname, gUserName);
    
    [self setUserName];
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	BOOL firstRun = NO;
	
 	DLog(@"initWithNibName");	
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
   {
#ifdef ADMOB_FREEVERSION
       bNoAd = [[AppDelegate sharedAppDelegate] getNoAdSetting];
#endif
       
       gUserID = cDefaultUserID;
       gUserName = [[NSString stringWithFormat:@"%d", (int)gUserID] retain];
       
       gInterval = INTERSTITIALINTERVAL;
       gIntervalSec = INTERSTITIALINTERVALSEC;
       gRandom = INTERSTITIALRANDOM;
       gBonus = ADCLICKBONUS;
       gAdBendor = ADBENDER_ADMOB;
       gNowAd = ADBENDER_ADMOB;
       
       [self decideLocale];
       
       [self loadServerData];
	   
        mainView = (MainView*) self.view;
 	    frameMainViewOrg = mainView.frame;
	   DLog(@"frameMainViewOrg = %f,%f", frameMainViewOrg.size.width, frameMainViewOrg.size.height);

	   
	   //[mainView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg3.png"]]];
       [self loadSetting];  // loadSetting need mainView

	   areaPuzzleTable.hidden = YES;
	   areaNumButton.hidden = YES;
       areaAdBanner.hidden = YES;
       areaiAdBanner.hidden = YES;
       [self setLocalizedMessage];
       [mainView initSkinColorData];
       [mainView initRainbowColorData];
       [mainView initBiggerSmallerColorData];
       [self initScore];
       [self loadScoreData];
       [Quest loadQuestData];
       [self loadAdState];
       [self updateClockTime];

	   if ([mainView loadGame] == YES) {
			[self setGameLevel];
            [self updateGameTime:mainView.sudokuGame.gameTime];
            [self startGameTimer];          // load 했을 때만 Timer를 시작한다.
		} else {
			levelNewGame = GAMELEVEL_NORMAL;	// normal로 새로운 게임을 무조건 생성한다.
            // 첫 세션 (A468 R1): 처음 설치(저장된 판도 점수도 없음)면 첫 판은 매우 쉬움 + 안내 카드.
            // 판이 없어도 점수가 있으면(예전 사용자) 예전처럼 보통이고 카드도 없다.
            if (score.scoreTotal == 0 &&
                ![[NSUserDefaults standardUserDefaults] boolForKey:kFirstSessionCardDone]) {
                levelNewGame = GAMELEVEL_VERYEASY;
                gGaNextStartFrom = @"first_session";
                gFirstSessionCardPending = YES;
            }
			[self makeNewGameData];
			
			[self setGameLevel];
            [self startGameTimer];

			firstRun = YES;
		}
	    [self updateButtons];
	    [self showHintButton];
	   
	   if (firstRun)
	   {
		 //  [self showHelpView];
	   }
       
//       [self connectToServerInit]; // connect to server
       
       
        [NSTimer scheduledTimerWithTimeInterval:5
        target:self
        selector:@selector(OnTimerconnectToServerInit:)
        userInfo:nil
        repeats:NO];
       

       
    }
    return self;
}


- (void) viewDidDisappear:(BOOL)animated
{
    DLog(@"MainViewController:viewDidDisappear");
    [super viewDidDisappear:animated];
}

#ifdef DEBUG
/// 디버그 빌드 전용 실행 인자 -DebugPointsBanner: 뜨고 1초 뒤 점수 띠(Game Center 「Points」 꼴, 앱이 그린다)를
/// 세 번 잇달아 띄운다. 시뮬레이터는 Game Center 로그인이 없어 띠가 저절로 뜨지 않아 위치를 찍을 수 없다.
/// 이때 Game Center 접속 · ATT 는 하지 않는다. Release 에는 없다.
static BOOL DebugPointsBannerOnLaunch(void)
{
    return [[NSProcessInfo processInfo].arguments containsObject:@"-DebugPointsBanner"];
}
// -DebugNewGameDialog: 새 게임 창 촬영용 (A478). 띠와 같이 Game Center 접속 · ATT 를 건너뛴다.
static BOOL DebugNewGameDialogOnLaunch(void)
{
    return [[NSProcessInfo processInfo].arguments containsObject:@"-DebugNewGameDialog"];
}
// -DebugDailyDialog: 데일리 퍼즐 창 촬영용. 이름 묻기 · Game Center · ATT 를 건너뛰고 창을 연다.
// -DebugDailyPlayed 를 같이 주면 「오늘 했음」 몇 칸을 (저장하지 않고) 켜고, Release 처럼 다시 시작을 막는다.
static BOOL DebugDailyDialogOnLaunch(void)
{
    return [[NSProcessInfo processInfo].arguments containsObject:@"-DebugDailyDialog"];
}
// -DebugSettings: 설정 화면 촬영용. 뜨고 1.5초 뒤 설정을 열고 SettingViewController 가 Documents/settings.png 를 남긴다.
static BOOL DebugSettingsOnLaunch(void)
{
    return [[NSProcessInfo processInfo].arguments containsObject:@"-DebugSettings"];
}
static BOOL DebugDailyPlayedOnLaunch(void)
{
    return [[NSProcessInfo processInfo].arguments containsObject:@"-DebugDailyPlayed"];
}
// -DebugFirstSession: 첫 세션 안내 카드 촬영용 (A468 R1). 카드를 억지로 띄우지는 않는다 — 앱 데이터를 지운
// 첫 실행에서만 뜬다. 이 인자는 Game Center · ATT 를 건너뛰고(시스템 창이 가리지 않게) 카드가 뜨면
// Documents/first_session.png 를, -DebugFirstSessionAutoStart 를 같이 주면 [시작하기] 뒤 판을 first_board.png 로 남긴다.
static BOOL DebugFirstSessionOnLaunch(void)
{
    return [[NSProcessInfo processInfo].arguments containsObject:@"-DebugFirstSession"];
}
// -DebugStreak <n>: 데일리 연속 상태를 써 넣는다 (A468 R3 촬영 · 시험용). 어제까지 n일, 최고 max(n, 기존).
// -DebugStreakDone 을 같이 주면 마지막 날이 오늘(오늘 이미 셈). n 이하 마일스톤은 받은 것으로 둔다.
static void DebugSeedStreakIfAsked(NSString *today)
{
    NSString *v = [[NSUserDefaults standardUserDefaults] stringForKey:@"DebugStreak"];
    if (v == nil) return;
    NSInteger n = MAX(0, [v integerValue]);
    BOOL done = [[NSProcessInfo processInfo].arguments containsObject:@"-DebugStreakDone"];
    NSInteger mask = 0;
    for (int i = 0; i < DS_MILESTONE_COUNT; i++) if (kDailyStreakMilestones[i] <= n) mask |= (1 << i);
    [DailyStreak debugSetStreak:n best:MAX(n, [DailyStreak best]) lastDay:(n > 0 ? (done ? today : [DailyStreak dayBefore:today]) : nil)
                     earnedMask:mask];
}
static void DebugSnapshotWindow(UIWindow *w, NSString *name)
{
    if (!w) return;
    UIGraphicsImageRenderer *r = [[[UIGraphicsImageRenderer alloc] initWithBounds:w.bounds] autorelease];
    UIImage *img = [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [w drawViewHierarchyInRect:w.bounds afterScreenUpdates:YES];
    }];
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    [UIImagePNGRepresentation(img) writeToFile:[dir stringByAppendingPathComponent:name] atomically:YES];
}
#endif

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (gFirstSessionCardPending) {   // 첫 세션 안내 (A468 R1) — 한 번만
        gFirstSessionCardPending = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showFirstSessionCard];
        });
    }
#ifdef DEBUG
    // -DebugNewGameDialog: 뜨고 1.5초 뒤 새 게임 창을 연다 (시뮬레이터 촬영용, A478). Release 에 없다.
    static BOOL debugNewGameShown = NO;
    if (DebugNewGameDialogOnLaunch() && !debugNewGameShown) {
        debugNewGameShown = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showNewGame];
        });
    }
    static BOOL debugSettingsShown = NO;
    if (DebugSettingsOnLaunch() && !debugSettingsShown) {
        debugSettingsShown = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showSettingView];
        });
    }
    static BOOL debugDailyShown = NO;
    if (DebugDailyDialogOnLaunch() && !debugDailyShown) {
        debugDailyShown = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showDailyGame];
        });
    }
    // -DebugQA <menu|solve|solve1|hint|quota|adfail|consent>: 뜨고 2초 뒤 QA 메뉴를 열거나 그 항목을
    // 누른 것처럼 돈다 (시뮬레이터는 입력을 못 넣는다, A479). Release 에 없다.
    static BOOL debugQADone = NO;
    if (QADebugArg() && !debugQADone) {
        debugQADone = YES;
        // -DebugQADelay <초>: 다른 촬영 인자(데일리 창 → [시작])가 판을 연 뒤에 누르게 (A468)
        double qaDelay = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DebugQADelay"];
        if (qaDelay <= 0) qaDelay = 2.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(qaDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self runQAItem:QADebugArg()];
        });
    }
    static BOOL debugBannerShown = NO;
    if (DebugPointsBannerOnLaunch() && !debugBannerShown) {
        debugBannerShown = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (int i = 0; i < 3; i++)
                [[GKAchievementHandler defaultHandler]
                    notifyAchievementTitle:@"Points"
                    andMessage:[NSString stringWithFormat:gettext(@"You got %d points", nil), 21945]];
        });
    }
#endif
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
    }
    // Share puzzle용
    //[self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.3];
    if (SUPPORT_ROTATION)
        self.view.frame = [[UIScreen mainScreen] bounds];
//      self.view.frame = [[UIScreen mainScreen] applicationFrame];

    //[self willRotateToInterfaceOrientation:[UIDevice currentDevice].orientation duration:0.3];
}



-(void)Swipe4ScrollViews:(UIPanGestureRecognizer *)sender
{
   
}
- (void)handleLeftSwipe:(UISwipeGestureRecognizer *)recognizer
{
    DLog(@"handleLeftSwipe called");
}

- (void)handleRightSwipe:(UISwipeGestureRecognizer *)recognizer
{
    DLog(@"handleRightSwipe called");
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UISlider class]]) {
        // prevent recognizing touches on the slider
        return NO;
    }
    return YES;
}

#ifdef ADMOB_FREEVERSION	
// 서버 ADBENDER 값이 바뀌면 부른다. iAd 로 갈아타던 분기(IADCHANGE)는 iAd 가
// 2016 년에 끝나 켤 수 없는 죽은 코드라 지웠다 — 지금은 AdMob 하나라 할 일이 없다.
- (void) reloadBanner
{
}

- (void)removeAd
{
    if (adMobBanner) {
        adMobBanner.hidden = YES;
        adMobBanner.delegate = nil;
        [adMobBanner removeFromSuperview];
        [adMobBanner release];
        adMobBanner = nil;
    }
}

- (void)initBanner
{
    [self initGADBanner];
}


- (void)initGADBanner
{
    if (bNoAd) {
        DLog(@"No Ad");
        return;
    }
    
    DLog(@"areaAdBanner.frame(%f,%f,%f,%f)", areaAdBanner.frame.origin.x, areaAdBanner.frame.origin.y, areaAdBanner.frame.size.width, areaAdBanner.frame.size.height);
    
    gNowAd = ADBENDER_ADMOB;

    // AdMob Banner
    adMobBanner = [[GADBannerView alloc] initWithFrame:areaAdBanner.frame];
    [adMobBanner setDelegate:self];
    adMobBanner.adUnitID = MY_BANNER_UNIT_ID;
    adMobBanner.rootViewController = self;
    [self.view addSubview:adMobBanner];
    
    [adMobBanner loadRequest:[GADRequest request]];
}


- (void) requestGADagain
{
    if (bNoAd) {
        DLog(@"No Ad");
        return;
    }

    [adMobBanner loadRequest:[GADRequest request]];
}

#endif

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void) viewDidLoad {
	 DLog(@"viewDidLoad");	
     [super viewDidLoad];
     
#ifdef LOCATIONTRACK
     if (locationManager == nil) {
         locationManager= [[CLLocationManager alloc] init];
     }
     locationManager.delegate = self;
     locationManager.desiredAccuracy= kCLLocationAccuracyBest;
     [locationManager startUpdatingLocation];
#endif

     
     [viewMenu setBackgroundColor:[mainView getSkinColor:SC_BACKGROUND_VIEW]];
     [self installMoreGamesMenuButton];
     [self installQAButton];   // TestFlight · 디버그 빌드만 (A479)
     [MoreGamesViewController attachNewDotToView:buttonMenu afterTitleOfButton:NO];   // 메뉴 단추 안에 숨은 More Games 를 알린다
     [viewNewGame setBackgroundColor:[mainView getSkinColor:SC_BACKGROUND_VIEW]];
     [viewDailyGame setBackgroundColor:[mainView getSkinColor:SC_BACKGROUND_VIEW]];
     
	 //[viewMenu setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg6.png"]]];
	 viewMenu.layer.cornerRadius = viewMenu.frame.size.width/12;
	 viewMenu.layer.masksToBounds = YES;
     viewMenu.alpha = 1.0f;
	 //[viewNewGame setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg6.png"]]];
	 viewNewGame.layer.cornerRadius = viewNewGame.frame.size.width/12;
	 viewNewGame.layer.masksToBounds = YES;
     viewNewGame.alpha = 1.0f;
	 viewDailyGame.layer.cornerRadius = viewDailyGame.frame.size.width/12;
	 viewDailyGame.layer.masksToBounds = YES;
     viewDailyGame.alpha = 1.0f;
	 [self hideAwayView:viewMenu];
	 [self hideAwayView:viewNewGame];
	 [self hideAwayView:viewDailyGame];
     
     
     // versionNumber 는 NSString 이 아니라 GADVersionNumber 구조체다. %@ 로 찍으면 EXC_BAD_ACCESS 가 난다.
     DLog(@"Google Mobile Ads SDK version: %@",
          GADGetStringFromVersionNumber([GADMobileAds sharedInstance].versionNumber));

     // 광고를 켜는 순서는 아래 하나뿐이다:
     //
     //   ① UMP 동의  →  ② ATT  →  ③ SDK 시작  →  ④ 광고 로드
     //
     // ② 가 ③ 보다 **앞**이어야 한다. Apple 은 추적에 쓰일 수 있는 데이터를
     // 모으기 전에 프롬프트가 뜨기를 요구한다 (Guideline 2.1).
     //
     // 1초 뒤에 ATT 를 띄우던 예전 코드는 여기서 없앴다. UMP 폼이 닫힌 뒤에
     // 부르므로 화면은 이미 준비돼 있다 — 지연이 필요 없다.
     [self requestConsentThenStartAds];

     bAd = NO;
     bReplay = NO;
     nowDate[0] = '\0';
	 
     
#ifdef DEBUG
     if (!DebugPointsBannerOnLaunch() && !DebugNewGameDialogOnLaunch() && !DebugDailyDialogOnLaunch() && !DebugSettingsOnLaunch() && !DebugFirstSessionOnLaunch() && QADebugArg() == nil)   // 촬영 인자를 주면 Game Center 로그인 창이 가리므로 접속하지 않는다
#endif
     [GameCenterUtil connectGameCenter:self];       //게임센터 접속~
     
     
     
     if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
     {
         buttonPuzzleShare.enabled = NO;
         buttonRecordShare.enabled = NO;
         buttonSharePuzzle.enabled = NO;
     }

     
     if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
     {  // for iPhone and iPad
         CGRect frame= segmentType.frame;
         [segmentType setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 30)];
         
         [segmentType setImage:[UIImage imageNamed:@"type_0_24.png"] forSegmentAtIndex:0];
         [segmentType setImage:[UIImage imageNamed:@"type_1_24.png"] forSegmentAtIndex:1];
         [segmentType setImage:[UIImage imageNamed:@"type_2_24.png"] forSegmentAtIndex:2];
         [segmentType setImage:[UIImage imageNamed:@"type_3_24.png"] forSegmentAtIndex:3];
     } else {
         segmentType.tintColor = [UIColor colorWithRed:0.055f green:0.27f blue:0.55f alpha:1.0f];
     }

     /*
     if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
     {
         buttonSharePuzzle.enabled = NO;
     }*/
     
     if ([SKPaymentQueue canMakePayments]) {	// 스토어가 사용 가능하다면
         NSLog(@"Start Shop!");
         
         [[SKPaymentQueue defaultQueue] addTransactionObserver:self];	// Observer를 등록한다.
     } else {
         NSLog(@"Failed Shop!");
     }

     productHint50 = nil;
     bBuyingHint50 = NO;
     bReadyHintRewardVideo = NO;
     
     productRequestHint50 = [[SKProductsRequest alloc]
                             initWithProductIdentifiers:
                             [NSSet setWithObject:kHint50Item]];
     productRequestHint50.delegate = self;
     [productRequestHint50 start];


     
}

- (void)requestTrackingAuthorization {
#ifdef DEBUG
    if (MGDebugMoreGamesOnLaunch() || MGDebugNewDotDemo() || DebugPointsBannerOnLaunch() || DebugNewGameDialogOnLaunch() || DebugDailyDialogOnLaunch() || DebugSettingsOnLaunch() || DebugFirstSessionOnLaunch() || QADebugArg() != nil) return; // 시뮬레이터 촬영용 (Release 에 없다)
#endif
    if (@available (iOS 14.0, *)) {
        // 24.3.22 IDFA는 더이상 취득을 못한다.
        // 사용자 사용권 전에 한 번 IDFA의 취득을 시도합니다
//        ASIdentifierManager *identifierManager = [ASIdentifierManager sharedManager];
//        if ([identifierManager isAdvertisingTrackingEnabled]) {
//            NSLog(@"[idfa] isAdvertisingTrackingEnabled enabled");
//        } else {
//            NSLog(@"[idfa] isAdvertisingTrackingEnabled disabled");
//        }
//        NSString *idfa = identifierManager.advertisingIdentifier.UUIDString;
//        NSLog(@"[idfa] %@", idfa);

        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            NSLog(@"in requestTrackingAuthorizationWithCompletionHandler");
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                NSLog(@"[requestTrackingAuthorization] authorized");
            } else if (status == ATTrackingManagerAuthorizationStatusDenied) {
                NSLog(@"[requestTrackingAuthorization] denied");
            } else if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {
                NSLog(@"[requestTrackingAuthorization] not determined");
            }  else if (status == ATTrackingManagerAuthorizationStatusRestricted) {
                NSLog(@"[requestTrackingAuthorization] restricted");
            } else {
                NSLog(@"[requestTrackingAuthorization] something else");
            }

            // 사용자 사용권 후에 IDFA의 취득을 시도합니다
//            if ([identifierManager isAdvertisingTrackingEnabled]) {
//                NSLog(@"[idfa] isAdvertisingTrackingEnabled enabled");
//            } else {
//                NSLog(@"[idfa] isAdvertisingTrackingEnabled disabled");
//            }
//            NSString *idfa = identifierManager.advertisingIdentifier.UUIDString;
//            NSLog(@"[idfa] %@", idfa);

            // 프롬프트가 닫힌 **뒤에** 광고를 켠다. 콜백이 메인 스레드로 온다는
            // 보장이 없어서 옮겨 준다.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startMobileAdsIfAllowed];
            });
        }];
    } else {
       if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
           NSString *idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
           NSLog(@"%@",idfa);
       } else {
           NSLog(@"Settings-Privacy-Ads에서 광고 추적 기능을 켜십시오.");
       }
       [self startMobileAdsIfAllowed];
    }

}

#pragma mark UMP (GDPR 동의)

// EEA·영국·스위스 사용자에게 개인 맞춤 광고를 내보내려면 IAB TCF 에 등록된
// 인증 CMP 를 거쳐야 한다. 콘솔에 GDPR 메시지를 만들어 두어도 **앱이 UMP 를
// 부르지 않으면** 광고 요청에 TC 문자열이 붙지 않는다 — AdMob 정책 센터가
// 「동의 요건: CMP 없음」으로 잡던 것이 이것이다.
//
// 동의를 못 받으면 **광고를 요청하지 않는다.** 게임은 광고 없이도 돌아가야
// 한다.
- (void) requestConsentThenStartAds
{
#ifdef DEBUG
    if (MGDebugNewDotDemo()) return; // 새 앱 점 촬영: 동의 창(UMP·ATT)이 화면을 가린다 (Release 에 없다)
#endif
    UMPRequestParameters *params = [[[UMPRequestParameters alloc] init] autorelease];
    params.tagForUnderAgeOfConsent = NO;

    [UMPConsentInformation.sharedInstance
        requestConsentInfoUpdateWithParameters:params
                             completionHandler:^(NSError *_Nullable error) {
        if (error) {
            DLog(@"UMP 동의 정보 갱신 실패: %@", [error localizedDescription]);
        }
        // 갱신이 실패해도 폼 표시는 시도한다. 캐시된 동의가 있을 수 있고,
        // 최종 판단은 canRequestAds 가 한다.
        [UMPConsentForm loadAndPresentIfRequiredFromViewController:self
                                                completionHandler:^(NSError *_Nullable formError) {
            if (formError) {
                DLog(@"UMP 동의 폼 실패: %@", [formError localizedDescription]);
            }
            [self requestTrackingAuthorization];
        }];
    }];
}

// 동의를 받았을 때만 SDK 를 켜고 광고를 읽는다.
//
// canRequestAds 를 우리가 계산하지 않고 **SDK 에 묻는다.** 캐시된 동의와
// 실제 지역을 아는 쪽은 SDK 다. 여기서 NO 로 못 박으면 동의가 필요 없는
// 지역에서 일시적 오류 한 번에 그 실행 내내 광고가 끊긴다.
- (void) startMobileAdsIfAllowed
{
    if (bStartedMobileAds) return;   // ATT 경로가 둘이라 한 번만 돌게 막는다

    if (!UMPConsentInformation.sharedInstance.canRequestAds) {
        DLog(@"동의를 받지 못했다 — 광고를 요청하지 않는다");
        return;
    }
    bStartedMobileAds = YES;

    // 앱 ID 는 **Info.plist 의 GADApplicationIdentifier** 에서 읽는다.
    // configureWithApplicationID: 는 SDK 8.0 에서 사라졌다.
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status) {
        DLog(@"GADMobileAds started");
#ifdef ADMOB_FREEVERSION
        [self initBanner];
#endif
        [self loadHintRewardedAd];
#ifdef DEBUG
        // 시뮬레이터는 입력을 못 넣는다 — 실행 인자 -AdHintTapTest 면 「광고 보고
        // 힌트」를 앱이 스스로 누른다 (1초 뒤 · 70초 뒤). Release 에 없다.
        // 네 번 누른다 — -AdFailTest 와 함께면 세 번은 대신 지급, 네 번째는 거절.
        // 70초 자리는 백오프로 쉬던 적재를 누름이 깨우는지도 본다.
        // -FreeRewardReset 이면 오늘 쓴 대신 지급 횟수를 먼저 지운다.
        if ([[NSProcessInfo processInfo].arguments containsObject:@"-FreeRewardReset"]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFreeRewardQuotaKey];
            DLog(@"[ad] test: free reward quota reset");
        }
        if ([[NSProcessInfo processInfo].arguments containsObject:@"-AdHintTapTest"]) {
            for (NSNumber *sec in @[ @1, @20, @45, @70 ]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec.doubleValue * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                    DLog(@"[ad] test: auto tap hint reward (t=%@s)", sec);
                    [self stopGameTimer];
                    [self PushHintButton:0];
                });
            }
        }
#endif
    }];
}

- (void)OnTimerconnectToServerInit:(NSTimer *)timer
{
	DLog(@"OnTimerconnectToServerInit");
	[self connectToServerInit];
}

- (void) connectToServerInit
{
/*    if (gUserID != cDefaultUserID) {
        [self loadServerData];
        return;
    }
    [self loadServerData];
*/
    
	// should move to after starting to show screen fastly when it starts.
    for (int i=0; i<3; i++) {
        NSString *strOldServerIP = [NSString stringWithString:gServerIP];
        
        [self serverActStart];
        if ([gServerIP isEqualToString:strOldServerIP] == YES) {
            break;
        } else {
            DLog(@"Should connect to different server!!!!!!!!!!!!!");
            continue;
        }
    }

	[self saveServerData];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR(":/?#[]@!$&)*+,;="), kCFStringEncodingUTF8);
	return [result autorelease];
}

- (void) serverActStart
{
    NSLocale *locale = [NSLocale currentLocale];
	NSString *languageCode = [locale objectForKey: NSLocaleLanguageCode];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
	DLog(@"Country Code = %@", countryCode);
	
	NSLocale *gbLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"] autorelease];
    NSString *countryName = [gbLocale displayNameForKey: NSLocaleCountryCode value:countryCode];
	DLog(@"Country Name = %@", countryName);

    
	
	NSString* strURI = [NSString stringWithFormat:
						@"act=%@&locale=%@&deviceid=%@&userid=%ld&username=%@&userlevel=%d&appversion=%@&free=%d&totalscore=%lud&totalsec=%lud&latitude=%d&longitude=%d&version=%d&devicetype=%d&ostype=%@&osversion=%4.2f&languagecode=%@&countrycode=%@&countryname=%@&manufacturer=%@&cs=%ld",
						@"start",
                        [Locale getFullLocale:gettext(@"locale", nil)],
						gDeviceID,
                        (long)gUserID,
                        [self percentEscapeString:gUserName],
                        (int)[self getMyLevel],
                        APPVERSION,
                        freeMode,
                        score.scoreTotal,
                        score.spendTotalSec,
#ifdef LOCATIONTRACK
                        (NSInteger) (currentLatitude*1000000.0+0.5),
                        (NSInteger) (currentLongtitude*1000000.0+0.5),
#else
                        0,
                        0,
#endif
						cProtocolVersion,
						cDeviceType,
						cOSType,
						cOSVersion,
						languageCode,
						countryCode,
						[self urlEncodeValue:countryName],
						@"Apple",
						(long)[self getCheckSum]];
#ifdef ADMOB_FREEVERSION______________________________ // disabled
    for (int i=0; i<eAdStateMax; i++) {
        NSString *str;
        if (gAdState[i].show > 0) {
            str = [NSString stringWithFormat:@"adshow%d", i];
            strURI = [strURI stringByAppendingFormat:@"&%@=%d", str, (int)gAdState[i].show];
        }
        if (gAdState[i].fail > 0) {
            str = [NSString stringWithFormat:@"adfail%d", i];
            strURI = [strURI stringByAppendingFormat:@"&%@=%d", str, (int)gAdState[i].fail];
        }
        if (gAdState[i].lasterror && ![gAdState[i].lasterror isEqual: @""]) {
            str = [NSString stringWithFormat:@"aderror%d", i];
            strURI = [strURI stringByAppendingFormat:@"&%@=%@", str, [self percentEscapeString:gAdState[i].lasterror]];
        }
    }
#endif
	DLog(@"strURI = %@", strURI);
    _connStart = [self GetHTTPDataAsync:strURI timeoutInterval:cDefaultHTTPTimeOut];

}

- (void) TreateActStart:(NSData *)theResponseData
{
    NSString* strData = [[NSString alloc] initWithData:theResponseData encoding:NSUTF8StringEncoding];
    
    if (!strData) {
        //		[self alertLocalizedAlertViewUTF8];
        return;
    }
    NSLog(@"strData = %@", strData);
    NSArray *listItems = [strData componentsSeparatedByString:@"\n"];
    NSInteger count = listItems.count;
    NSString *item;
    
#ifdef ADMOB_FREEVERSION
    BOOL bPaid = false;
    if (bNoAd) bPaid = true;
#else
    BOOL bPaid = true;
#endif
    
    NSString *name;
    NSString *value;
    NSString *error = nil;
    for(int idx = 0; idx < count; idx++)
    {
        item = [listItems objectAtIndex:idx];
        
        NSArray *rawData = [item componentsSeparatedByString:@"\t"];
        if (rawData.count >= 2)
        {
            name = [rawData objectAtIndex:0];
            value = [rawData objectAtIndex:1];
            
            if ([name caseInsensitiveCompare:kResultStatus] == NSOrderedSame) {
                error = value;
                if ([error caseInsensitiveCompare:kSuccess] != NSOrderedSame) {
                    //[self alertLocalizedAlertView:error];
                }
            } else if ([name caseInsensitiveCompare:@"ServerIP"] == NSOrderedSame)
                gServerIP = [[NSString alloc] initWithString:value];
            else if ([name caseInsensitiveCompare:@"UserID"] == NSOrderedSame)
#if defined(DEBUG______) && defined(APPLY_DEBUGID_______)
                gUserID = cDebugUserID;
#else
            gUserID = [value integerValue];
#endif
            else if ([name caseInsensitiveCompare:@"UserName"] == NSOrderedSame)
                [self setUserName:value];
            else if ([name caseInsensitiveCompare:@"ITV"] == NSOrderedSame)
            {
                if (!bPaid) gInterval = [value integerValue];
            }
            else if ([name caseInsensitiveCompare:@"ITVSEC"] == NSOrderedSame)
            {
                if (!bPaid)
#ifdef DEBUG
                    gIntervalSec = 10;
#else
                    gIntervalSec = [value integerValue];
#endif
            }
            else if ([name caseInsensitiveCompare:@"RND"] == NSOrderedSame)
            {
                if (!bPaid) gRandom = [value integerValue];
            }
            else if ([name caseInsensitiveCompare:@"BNS"] == NSOrderedSame)
            {
                if (!bPaid) gBonus = [value integerValue];
            }
            else if ([name caseInsensitiveCompare:@"PAID_ITV"] == NSOrderedSame)
            {
                if (bPaid)
#ifdef DEBUG_____
                    gInterval = 3;
#else
                    gInterval = [value integerValue];
#endif
                
            }
            else if ([name caseInsensitiveCompare:@"PAID_ITVSEC"] == NSOrderedSame)
            {
                if (bPaid)
#ifdef DEBUG_____
                    gIntervalSec = 100;
#else
                    gIntervalSec = [value integerValue];
#endif
            }
            else if ([name caseInsensitiveCompare:@"PAID_RND"] == NSOrderedSame)
            {
                if (bPaid) gRandom = [value integerValue];
            }
            else if ([name caseInsensitiveCompare:@"PAID_BNS"] == NSOrderedSame)
            {
                if (bPaid) gBonus = [value integerValue];
            }
#ifdef ADMOB_FREEVERSION
            else if ([name caseInsensitiveCompare:@"ADBENDOR"] == NSOrderedSame) {
                NSInteger oldAdBendor = gAdBendor;
                gAdBendor = [value integerValue];
                if (gAdBendor != oldAdBendor) {
                    [self reloadBanner];
                }
            }
#endif
        }
    }
    
    [strData release];
    [self saveServerData];
}


#define kServerIP                   @"serverIP"
#define kUserDefault				@"gUserDefault"
#define kUserID						@"gUserID"
#define kUserName					@"gUserName"
#define kInterval                   @"gInterval"
#define kIntervalSec                @"gIntervalSec"
#define kRandom                     @"gRandom"
#define kBonus                      @"gBonus"
#define kAdBendor                   @"gAdBendor"


- (void) loadServerData
{
    NSString *name;
    
    gServerIP = cServerHostName;
//    gDeviceID = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    gDeviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    DLog(@"gDeviceID=%@", gDeviceID);
    
    [gDeviceID retain];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *strUserDefault = [defaults stringForKey:kUserDefault];
	if (strUserDefault == nil)	// It hasn't saved.
		return;
    
    // redirection은 어떻게 할 것인가?
    gServerIP = [defaults stringForKey:kServerIP];
	name = [defaults stringForKey:kUserName];
	gUserID	  = [defaults integerForKey:kUserID];

    if (!gServerIP || [gServerIP length] < 3)   // something wrong
        gServerIP = cServerHostName;
    
    gServerIP = cServerHostName;    // 저장된 데이터 무시
    
    if (name == nil || [name isEqualToString:@"(null)"] == YES)
        name = [NSString stringWithFormat:@"%d", (int)gUserID];
    
    [self setUserName:name];

    if ([defaults objectForKey:kInterval]) {
        gInterval = [defaults integerForKey:kInterval];
        gRandom = [defaults integerForKey:kRandom];
        gBonus = [defaults integerForKey:kBonus];
        gAdBendor = [defaults integerForKey:kAdBendor];
        DLog(@"ITV:RND:BNS:ADBENDOR=%d:%d:%d:%d", (int)gInterval, (int)gRandom, (int)gBonus, (int)gAdBendor);
    } else {
        DLog(@"Not saved");
    }

    if ([defaults objectForKey:kIntervalSec]) {
        gIntervalSec = [defaults integerForKey:kIntervalSec];
        DLog(@"ITVSEC:%d", (int)gIntervalSec);
    }
}


- (void) saveServerData
{
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
    [defaults setObject:@"Yes"		forKey:kUserDefault];
	[defaults setObject:gUserName	forKey:kUserName];
    DLog(@"Save User Name:%@", gUserName);
	[defaults setInteger:gUserID	forKey:kUserID];
    [defaults setObject:gServerIP   forKey:kServerIP];

    [defaults setInteger:gInterval	forKey:kInterval];
    [defaults setInteger:gIntervalSec	forKey:kIntervalSec];
    [defaults setInteger:gRandom	forKey:kRandom];
    [defaults setInteger:gBonus     forKey:kBonus];
    [defaults setInteger:gAdBendor     forKey:kAdBendor];
    DLog(@"ITV:ITVSEC:RND:BNS:ADBENDER=%d:%d:%d:%d:%d", (int)gInterval, (int)gIntervalSec, (int)gRandom, (int)gBonus, (int)gAdBendor);

    
    [defaults synchronize];
}


/*
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        // Do some stuff
    } else {
        // Do some other stuff
    }
}

-(void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation duration: (NSTimeInterval) duration
{
    DLog(@"willAnimateRotationToInterfaceOrientation:%d", interfaceOrientation);
    //[self updateLayoutForNewOrientation: interfaceOrientation];
}
*/


- (void)viewWillAppear:(BOOL)animated
{
    
    DLog(@"MainViewController:viewWillAppear");
    [super viewWillAppear:animated];
    DLog(@"self.interfaceOrientation=%d", (int) self.interfaceOrientation);
    DLog(@"[UIDevice currentDevice].orientation=%d", (int) [UIDevice currentDevice].orientation);
    DLog(@"[UIApplication sharedApplication].statusBarOrientation=%d", (int)[UIApplication sharedApplication].statusBarOrientation);
    
    
    //self.view.frame = [[UIScreen mainScreen] applicationFrame];
    // above ios5 && Paid
    //[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationPortrait];
    if (SUPPORT_ROTATION)
        [self willRotateToInterfaceOrientation:[UIDevice currentDevice].orientation duration:0.3];
    //[self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.3];
#ifdef ADMOB_FREEVERSION
    DLog(@"areaAdBanner.frame(%f,%f,%f,%f)", areaAdBanner.frame.origin.x, areaAdBanner.frame.origin.y, areaAdBanner.frame.size.width, areaAdBanner.frame.size.height);
    //DLog(@"areaiAdBanner.frame(%f,%f,%f,%f)", areaiAdBanner.frame.origin.x, areaiAdBanner.frame.origin.y, areaiAdBanner.frame.size.width, areaiAdBanner.frame.size.height);
    if (bNoAd) {
        DLog(@"No Ad");
    } else {
        if (adMobBanner) {
            adMobBanner.frame = areaAdBanner.frame;
            adMobBanner.hidden = NO;
        }
    }
#endif
}


- (SUDOKUSCORE*) getScore
{
    return &score;
}


- (void) setInteger:(UILabel*)label num:(NSInteger)num
{
	label.text = [NSString stringWithFormat:@"%ld", (long)num];
}

- (NSString*) getTimeString:(NSInteger)num
{
    NSString *str;
    
	if (num >= 60*60*100)
		num = 60*60*100 - 1;
	
	if (num >= 60*60)
		str = [NSString stringWithFormat:@"%02d:%02d:%02d",
			   (int) num / (60*60),
			   (int) num / (60) % (60),
			   (int) num % (60)];
	else if (num > 0) 
		str = [NSString stringWithFormat:@"%02d:%02d",
			   (int) num / (60),
			   (int) num % (60)];
	else 
		str = [NSString stringWithFormat:@"-"];

    return str;
}

- (void) setTime:(UILabel*)label num:(NSInteger)num
{
    label.text = [self getTimeString:num];
    /*
	if (num >= 60*60*100)
		num = 60*60*100 - 1;
	
	if (num >= 60*60)
		label.text = [NSString stringWithFormat:@"%2d:%02d:%02d",
                      num / (60*60),
                      num / (60) % (60),
                      num % (60)];
	else if (num > 0)
		label.text = [NSString stringWithFormat:@"%02d:%02d",
                      num / (60),
                      num % (60)];
	else 
		label.text = [NSString stringWithFormat:@"-"];
    */
}

// Internal name
// iPhoneX  : iPhone10,6
// iPhoneXR : iPhone11,8
// iPhoneXS : iPhone11,2
// iPhoneX Max : iPhone11,4

BOOL IsiPhoneX3(void)
{
     BOOL iPhoneX = NO;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.top > 24.0) {
            iPhoneX = YES;
        }
    }
    return iPhoneX;
}


- (IBAction) showScoreView
{
#ifdef USE_FLURRY
    [Flurry logEvent:@"ShowScoreView"];
#endif
	[self hideMenuView:NO];
    [self getRankingFromGameCenter];    // 최신 랭킹으로 update

    // if 1136 : iphone 5, 6
    DLog(@"[UIScreen mainScreen].bounds.size.width = %f", [UIScreen mainScreen].bounds.size.width);
    DLog(@"[UIScreen mainScreen].bounds.size.height = %f", [UIScreen mainScreen].bounds.size.height);
    DLog(@"[[UIScreen mainScreen] scale] = %f", [[UIScreen mainScreen] scale]);
    
	ScoreViewController *controller = [[ScoreViewController alloc] initWithNibName:
										  cDeviceType == DEVICETYPE_IPAD ? @"ScoreView4iPad" : 
                                          (IsiPhoneX3() ? @"ScoreView4iPhoneX" :
                                           (isLongIphone ? @"ScoreView4iPhone5" : @"ScoreView"))
                                          bundle:nil];
    controller.mainViewController = self;
	[controller setScoreData:&score];
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;//UIModalTransitionStylePartialCurl;
    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
	[self presentViewController:controller animated:YES completion:nil];

	controller.bAuto = mainView.sudokuGame.bAutoMemo ? YES : NO;
	[controller setAutoSegment];		
	[controller displayScore];
//    [controller setTotalScoreRank];
	[controller release];
}


- (IBAction)showQuestView
{
#ifdef USE_FLURRY
    [Flurry logEvent:@"ShowQuestView"];
#endif
    [self hideMenuView:NO];
    
    QuestViewController *controller = [[QuestViewController alloc] initWithNibName:
                                       cDeviceType == DEVICETYPE_IPAD ? @"QuestView4iPad" :
                                       (IsiPhoneX3() ? @"QuestView4iPhoneX" :
                                       (isLongIphone ? @"QuestView4iPhone5" : @"QuestView"))
                                                                            bundle:nil];
    
    
    
    controller.mainViewController = self;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:controller animated:YES completion:nil];
    
    [controller release];
    
    
}

- (void) updateButtonUndo
{
	BOOL bLock = mainView.bMenuMode || (mainView.sudokuGame && mainView.sudokuGame.isGameFinished);
	
	if ([mainView.sudokuGame.sudokuUndo countUndo] > 0 && mainView.sudokuGame.isGameFinished == NO)
    {
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_n"] forState:UIControlStateNormal];
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_h"] forState:UIControlStateHighlighted];
        [buttonUndo setEnabled:(bLock ? NO : YES)]; // SDSDKNINEF-14429 Crash report
//		buttonUndo.enabled = bLock ? NO : YES;
	} else {
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_d"] forState:UIControlStateNormal];
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_h"] forState:UIControlStateHighlighted];
        [buttonUndo setEnabled:NO]; // SDSDKNINEF-14429 Crash report
//		buttonUndo.enabled = NO;
	}
    
	if ([mainView.sudokuGame.sudokuUndo countRedo] > 0 && mainView.sudokuGame.isGameFinished == NO)
    {
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_n"] forState:UIControlStateNormal];
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_h"] forState:UIControlStateHighlighted];
        [buttonRedo setEnabled:(bLock ? NO : YES)]; // SDSDKNINEF-14429 Crash report
//		buttonRedo.enabled = bLock ? NO : YES;
	} else {
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_d"] forState:UIControlStateNormal];
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_h"] forState:UIControlStateHighlighted];
        [buttonRedo setEnabled:NO]; // SDSDKNINEF-14429 Crash report
//		buttonRedo.enabled = NO;
	}
}

- (void) updateButtonBookmark
{
	BOOL bLock = mainView.bMenuMode || (mainView.sudokuGame && mainView.sudokuGame.isGameFinished);

	if ([mainView.sudokuGame.sudokuUndo getIndex] <= 0)		// 맨 앞에 위치해 있을 때는 bookmark를 잠근다.
	{
		[buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkoff_d"] forState:UIControlStateNormal];
        [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkoff_d"] forState:UIControlStateHighlighted];
		buttonBookmark.enabled = NO;
	}
    else if ([mainView.sudokuGame.sudokuUndo countBookmarked] > 0)
    {
        [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkon_n"] forState:UIControlStateNormal];
        [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkon_h"] forState:UIControlStateHighlighted];
		buttonBookmark.enabled = bLock ? NO : YES;
	} else {
        [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkoff_n"] forState:UIControlStateNormal];
        [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkoff_h"] forState:UIControlStateHighlighted];
		buttonBookmark.enabled = bLock ? NO : YES;
	}
}

- (IBAction)stopUndoRedoRepeat
{
	if (timerUndoRepeat)
	{
		[timerUndoRepeat invalidate];
		timerUndoRepeat = nil;
		//[mainView playSoundClick];
	}
}

- (void) OnTimerUndoRepeat:(NSTimer *)timer
{
	if (bUndoRepeat)
		[mainView runUndo];
	else
		[mainView runRedo];

	[self updateButtons];
	
	if ((bUndoRepeat && [mainView.sudokuGame.sudokuUndo countUndo] <=0) ||
		(!bUndoRepeat && [mainView.sudokuGame.sudokuUndo countRedo] <=0))
	{
		DLog(@"####### Finish OnTimerUndoRepeat");
		[timerUndoRepeat invalidate];
		timerUndoRepeat = nil;
		//[mainView playSoundClick];
	} else {
		timerUndoRepeat = [NSTimer scheduledTimerWithTimeInterval:TIME_UNDOINTERVAL
														   target:self
														 selector:@selector(OnTimerUndoRepeat:)
														 userInfo:nil
														  repeats:NO];
	}
}

- (void) OnTimerStartUndoRepeat:(NSTimer *)timer
{
#ifdef USE_FLURRY
    [Flurry logEvent:@"RunUndoRedoRepeat"];
#endif
	timerUndoRepeat = [NSTimer scheduledTimerWithTimeInterval:TIME_UNDOINTERVAL
													   target:self
                       
													 selector:@selector(OnTimerUndoRepeat:)
													 userInfo:nil
													  repeats:NO];
}

- (IBAction)runUndo
{
	if (mainView.bMenuMode)
		return;

#ifdef USE_FLURRY
    [Flurry logEvent:@"RunUndo"];
#endif
	[mainView playSoundClick];
	[mainView runUndo];
    [self DoneQuest:eQuestUndo];


	[self updateButtons];
	bUndoRepeat = TRUE;
	timerUndoRepeat = [NSTimer scheduledTimerWithTimeInterval:TIME_UNDOREPEATE
													   target:self
													 selector:@selector(OnTimerStartUndoRepeat:)
													 userInfo:nil
													  repeats:NO];
}


- (IBAction)runRedo
{
	if (mainView.bMenuMode)
		return;

#ifdef USE_FLURRY
    [Flurry logEvent:@"RunRedo"];
#endif
	[mainView playSoundClick];
	[mainView runRedo];
    [self DoneQuest:eQuestRedo];


	[self updateButtons];
	bUndoRepeat = FALSE;
	timerUndoRepeat = [NSTimer scheduledTimerWithTimeInterval:TIME_UNDOREPEATE
													   target:self
													 selector:@selector(OnTimerStartUndoRepeat:)
													 userInfo:nil
													  repeats:NO];

}

- (IBAction)runBookmark
{
	if (mainView.bMenuMode)
		return;

#ifdef USE_FLURRY
    [Flurry logEvent:@"RunBookmark"];
#endif
    
	[mainView runBookmark];

	[self updateButtons];

}


- (void)updateButtonMemo
{
    if (mainView.sudokuGame && mainView.sudokuGame.gameLevel == GAMELEVEL_USERINPUT && mainView.sudokuGame.bUserInputStart == NO) {
        BOOL bLock = mainView.bMenuMode;
        
        buttonMemo.enabled = bLock ? NO : YES;
        buttonMemo.alpha = bLock ? 0.5f : 1.f;

        [buttonMemo	setTitle:gettext(@"start", nil) forState:UIControlStateNormal];
        [buttonMemo	setTitle:gettext(@"start", nil) forState:UIControlStateDisabled];
        
        return;
    }
    
    if (mainView.bMemoMode)
	{
		buttonMemo.alpha = 1.f;	
	} else {
		buttonMemo.alpha = 0.5f;	
	}
	
	BOOL bLock = mainView.bMenuMode || (mainView.sudokuGame && mainView.sudokuGame.isGameFinished);
	
	buttonMemo.enabled = bLock ? NO : YES;
    

    [buttonMemo	setTitle:gettext(@"memo", nil) forState:UIControlStateNormal];
    [buttonMemo	setTitle:gettext(@"memo", nil) forState:UIControlStateDisabled];
}

- (IBAction) memoOnOff
{

    
    
    
	if (mainView.bMenuMode || !mainView.sudokuGame)
		return;

    if (mainView.sudokuGame.gameLevel == GAMELEVEL_USERINPUT && mainView.sudokuGame.bUserInputStart == NO) {
        // user input game start
        // fix num => puzzle num
        [mainView.sudokuGame StartUserInputPuzzle];
        
        // undo 초기화 - TBD       
        [mainView.sudokuGame initUndo];
        
        // 시간 초기화
        [mainView.sudokuGame initGameTime];
        
        [self updateButtonMemo];
        [mainView.sudokuGame saveData];
        
        // update undo button
        [self updateButtonUndo];
        
        [mainView setNeedsDisplay];
        
        return;
    }
    
    
	[mainView memoOnOff];
    [self updateButtonMemo];
   
}

- (IBAction) delNumber
{
	if (mainView.bMenuMode)
		return;

	
	[mainView delNumber];
}

- (IBAction) clearNumbers
{
	[self hideMenuView:NO];	
	
#ifdef USE_FLURRY
    [Flurry logEvent:@"RunReset"];
#endif
    
	[mainView clearNumbers];	// memo모드에서 실행하는 메뉴임
    [self startGameTimer];
    
}


- (void) OnTimerFinshedSeeReplay:(NSTimer *)timer
{
    bReplay = NO;
    [self updateButtons];
    [mainView setNeedsDisplay];
}

- (void) OnTimerSeeReplay:(NSTimer *)timer
{
    if (bReplay == NO)
    {
        [self updateButtons];
        return; // 중단 된 것임.
    }
    
    BOOL bRet = [mainView runRedo4Replay];

    if (bRet == YES)
    {
        [NSTimer scheduledTimerWithTimeInterval:REPLAY_FRAME_INTERVAL
                                         target:self
                                       selector:@selector(OnTimerSeeReplay:)
                                       userInfo:nil
                                        repeats:NO];
    } else {    // 끝
        [NSTimer scheduledTimerWithTimeInterval:1.5
                                         target:self
                                       selector:@selector(OnTimerFinshedSeeReplay:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (IBAction)seeReplay
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
        [self newgameCancel];
    }

#ifdef USE_FLURRY
    [Flurry logEvent:@"RunSeeReplay"];
#endif
    
    bReplay = YES;
    [self updateButtons];
    
    [mainView.sudokuGame readyToReplay];    // 게임을 첫번째로 되도롤린다.
    [mainView setNeedsDisplay];
    
    
    [NSTimer scheduledTimerWithTimeInterval:REPLAY_FRAME_INTERVAL*10
									 target:self
								   selector:@selector(OnTimerSeeReplay:)
								   userInfo:nil
									repeats:NO];
    
}

- (IBAction)closeButton
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
        [self newgameCancel];
    }
    mainView.sudokuGame.isCloseButton = YES;
    
    [self updateButtons];
    [mainView setNeedsDisplay];
}


- (IBAction) playAgain
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
        [self newgameCancel];
    }
    
    if (mainView.sudokuGame.bDailyPuzzle) {
#ifdef USE_FLURRY
        [Flurry logEvent:@"RankingCheck"];
#endif
        [self gotoRankingWebView:YES];
    } else {
#ifdef USE_FLURRY
        [Flurry logEvent:@"RunPalyAgain"];
#endif
        // see Replay 중이면 멈춰야 한다. timer 멈춘다.
        bReplay = NO;
        
        
        [mainView.sudokuGame replayGames];

        [self increaseScoreGames];  // 게임 시작 점수 추가
        [self saveScoreData];
        
        [self updateGameTime:0];

        [self updateButtons];

        //[mainView playSoundClick];
        [mainView.sudokuGame saveData];
        
        [mainView setNeedsDisplay];

        [self startGameTimer];
    }
}




- (void) callPuzzleShare:(BOOL) bImg
{
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        return;
    }

    if (bImg)
        [self DoneQuest:eQuestPuzzleShare];
    else
        [self DoneQuest:eQuestRecordShare];
    
    
    NSString *strURL = [NSString stringWithFormat:@"https://itunes.apple.com/%@/app/id%@", gettext(@"us", nil), APPSHARE_ID];
    NSString *strDesc;
    NSString *strMsg;
    NSString *strMsgTwitter;
    
    if (mainView.sudokuGame.isGameFinished)
    {
        if (bImg) {  // Puzzle share
            strMsg = gettext(@"I cleared this puzzle. Why don't you try to solve it.", nil);
        } else {        // Record share
            strDesc = [NSString stringWithFormat:gettext(@"I solved a %@ sudoku puzzle.", nil),
                       STR_MATRIXSIZE];
            strMsg = [NSString stringWithFormat:@"%@ (%@:%@, %@:%@)",
                      strDesc,
                      gettext(@"level", nil),
                      labelLevel.text,
                      gettext(@"time", nil),
                      labelGameTime.text];
        }

    } else {
        // only Puzzle share?
        strMsg = [NSString stringWithFormat:@"%@",
                  gettext(@"I'm solving this puzzle now.", nil)];
    }
    strMsgTwitter = [NSString stringWithFormat:@"%@ via %@",
                     strMsg,
                     TWITTER_ID];
    
//    NSString *strAdd = [NSString stringWithFormat:@"%@ %@", strDesc, strTitle];
    
    UIImage *retImage = nil;
    
    if (bImg) {
        UIGraphicsBeginImageContext(CGSizeMake(DRAWONIMAGE_W,DRAWONIMAGE_H));
        
        // draw original image into the context
        //[image drawAtPoint:CGPointZero];
        
        // get the context for CoreGraphics
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        [mainView drawOnImage:ctx strTime:labelGameTime.text];
        
        
        // make image out of bitmap context
        retImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // free the context
        UIGraphicsEndImageContext();
    }
    
    APActivityProvider *ActivityProvider = [[APActivityProvider alloc] initWithPlaceholderItem:@"Default text"];
    ActivityProvider.strMsg = strMsg;
    ActivityProvider.strMsgTwitter = strMsgTwitter;
    NSArray *Items;
    if (bImg)
        Items = @[ActivityProvider, strURL, retImage];
    else
        Items = @[ActivityProvider, strURL];
    [ActivityProvider release];
    

    UIActivityViewController *ActivityView = [[[UIActivityViewController alloc]
                                               initWithActivityItems:Items
                                               applicationActivities:nil] autorelease];
    // for ipad & ios8.1 (bugs)
    if (isIpad && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        ActivityView.modalInPopover = YES;
        ActivityView.popoverPresentationController.sourceView = self.view;
        if (bImg) {
            [ActivityView setExcludedActivityTypes:
             @[UIActivityTypeAssignToContact,
               UIActivityTypeMail,
               UIActivityTypeAddToReadingList]];
        } else {
            [ActivityView setExcludedActivityTypes:
             @[UIActivityTypePrint,
               UIActivityTypeMail,
               UIActivityTypeCopyToPasteboard,
               UIActivityTypeAssignToContact,
               UIActivityTypeSaveToCameraRoll,
               UIActivityTypeAddToReadingList,
               UIActivityTypeAirDrop]];
            
        }
    } else {
        if (bImg) {
            [ActivityView setExcludedActivityTypes:
             @[UIActivityTypeAssignToContact,
               UIActivityTypeAddToReadingList]];
        } else {
            [ActivityView setExcludedActivityTypes:
             @[UIActivityTypePrint,
               UIActivityTypeCopyToPasteboard,
               UIActivityTypeAssignToContact,
               UIActivityTypeSaveToCameraRoll,
               UIActivityTypeAddToReadingList,
               UIActivityTypeAirDrop]];
            
        }
    }
    
    [ActivityView setCompletionHandler:^(NSString *act, BOOL done)
     {
         if (done) {
#ifdef USE_FLURRY
             NSString* str = [NSString stringWithFormat:@"Share(%@) done", act];
             [Flurry logEvent:str];
#endif
             NSLog(@"The selected activity was %@", act);
             NSRange range = [act rangeOfString:@"PostTo"];
             if (range.location != NSNotFound) {
                 mainView.bSharedThisOnFacebook = YES;
                 [self saveSetting];
             }
         } else {
#ifdef USE_FLURRY
             NSString* str = [NSString stringWithFormat:@"Share(%@) cancel", act];
             [Flurry logEvent:str];
#endif
         }
     }];
    
    
    [self presentViewController:ActivityView animated:YES completion:nil];

    [self saveSetting];
    [self startGameTimer];
}


- (IBAction)openSharePuzzle
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
    }
#ifdef USE_FLURRY
    [Flurry logEvent:@"SharePuzzle"];
#endif
    [self callPuzzleShare:YES];
    
    
    
    
}

- (IBAction)openShareRecord
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
    }

#ifdef USE_FLURRY
    [Flurry logEvent:@"ShareRecord"];
#endif

    [self callPuzzleShare:NO];
}



- (void)showHintButton
{
	[self updateButtonHint];
}

- (void)OnTimerSetFinishByuingHint50:(NSTimer *)timer
{
    bBuyingHint50 = NO;    // 적어도 60초 후에는 구매가 완료되었을 것이다.
    [self updateButtonHint];
}

#ifdef DEBUG
#define BUYHINTTEST______________________________
#endif



- (void) PushHintButton:(NSInteger) buttonIndex
{
    if (buttonIndex == 0) {    // 비디오 보고 힌트 5개 얻기
        // 예전에는 광고가 없으면 말없이 타이머만 다시 돌렸다 (A463).
        // 지금은 받는 중인 적재에 붙어 최대 8초 기다리고, 끝내 없으면 하루 3번까지
        // 보상을 대신 주고 안내한다 (Flutter 6종 _grantFreeOrDecline 과 같다 ·
        // 사람 결정 2026-11-08). 다 쓰면 안내만 한다.
        [self beginHintAttempt:(self.hintRewardedAd != nil)];
        if (self.hintRewardedAd) {
            [self presentHintRewardedAd];
        } else {
            [self waitForHintRewardedAd];
        }
    } else if (buttonIndex == 1) {  // 힌트 50개 구매하기
        if (productHint50) { // buy hint
            paymentHint50 = [SKPayment paymentWithProduct:productHint50];
            [[SKPaymentQueue defaultQueue] addPayment:paymentHint50];
            bBuyingHint50 = YES;
            [self updateButtonHint];
            
            [NSTimer scheduledTimerWithTimeInterval:60.0f
                                             target:self
                                           selector:@selector(OnTimerSetFinishByuingHint50:)
                                           userInfo:nil
                                            repeats:NO];
        } else {
            [self startGameTimer];
        }
    } else if (buttonIndex == 2) {              // cancel
        [self startGameTimer];
    }
}



- (IBAction) doHint
{
	if (mainView.bMenuMode)
		return;
    
    
    if (
#ifdef BUYHINTTEST
        NO
#else
        mainView.sudokuGame.countHint + mainView.paidHintCount > 0
#endif
        ) // && 유료 힌트도 0
    {
#ifdef USE_FLURRY
        [Flurry logEvent:@"RunHint"];
#endif
        [mainView doHint];
        [self DoneQuest:eQuestHint];
        
        [self saveSetting];
    } else {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:nil
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        // 받아 둔 게 없어도 광고를 켤 수 있으면 보인다 — 누르면 받는 중인
        // 적재에 붙거나 쉬던 받기를 깨운다 (A463). 예전에는 시작 때 한 번
        // 실패하면 다음 앱 시작까지 이 줄이 아예 안 보였다.
        if (bReadyHintRewardVideo || [self canOfferHintRewardedAd]) {
            UIAlertAction* rewardhint = [UIAlertAction
                                         actionWithTitle:gettext(@"Get 5 hints after seeing an ad", nil)
//                                         actionWithTitle:gettext(@"광고 보고 힌트5개 얻기", nil)
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [self PushHintButton:0];
                                             
                                         }];
            [alert addAction:rewardhint];
        }
        if (productHint50) { // buy hint
            UIAlertAction* buyhint = [UIAlertAction
                                      actionWithTitle:gettext(@"Buy 50 hints", nil)
//                                      actionWithTitle:gettext(@"힌트 50개 구매하기", nil)
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [self PushHintButton:1];
                                      
                                  }];
            [alert addAction:buyhint];
        }
        
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:gettext(@"Cancel", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self PushHintButton:2];
                                     
                                 }];
        [alert addAction:cancel];
        [self stopGameTimer];

        [self presentViewController:alert animated:YES completion:nil];
    }
}



- (IBAction)showSettingView
{
#ifdef USE_FLURRY
    [Flurry logEvent:@"ShowSettingView"];
#endif
    
	[self hideMenuView:NO];
    
#ifdef ADMOB_FREEVERSION
    if ([SKPaymentQueue canMakePayments]) {	// 스토어가 사용 가능하다면
        NSLog(@"Start Shop!");
        
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];	// Observer를 등록을 해지한다.
    } else {
        NSLog(@"Failed Shop!");
    }
#endif
    

    DLog(@"showSettingView");
    SettingViewController *controller = [[SettingViewController alloc] initWithNibName:
                                       cDeviceType == DEVICETYPE_IPAD ? @"SettingView4iPad" :
                                         (IsiPhoneX3() ? @"SettingView4iPhoneX" :
                                        (isLongIphone ? @"SettingView4iPhone5" : @"SettingView"))
                                        bundle:nil];
    controller.mainViewController = self;
//	controller.title = gettext(@"Setting", nil);
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;//UIModalTransitionStylePartialCurl;
    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
	[self presentViewController:controller animated:YES completion:nil];
    // UIModalTransitionStyleCrossDissolve for newgame
	
	
//	controller.title = gettext(@"Setting", nil);
    
	
	[controller release];

    
}

- (IBAction)showHelpView
{
#ifdef USE_FLURRY
    [Flurry logEvent:@"ShowHelpView"];
#endif
	[self hideMenuView:NO];
	
    DLog(@"showHelpView");
    HelpViewController *controller = [[HelpViewController alloc] initWithNibName:
                                      cDeviceType == DEVICETYPE_IPAD ? @"HelpView4iPad" :
                                      (IsiPhoneX3() ? @"HelpView4iPhoneX" :
                                      (isLongIphone ? @"HelpView4iPhone5" : @"HelpView"))
                                      bundle:nil];


    
    controller.mainViewController = self;
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[controller setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:controller animated:YES completion:nil];
	
	[controller release];
}

- (void) gotoRankingWebView:(BOOL)bMyRanking
{
//    NSString *nibName = cDeviceType == DEVICETYPE_IPAD ? @"RankView4iPad" :
//    (IsiPhoneX3() ? @"RankView4iPhoneX" :
//     (isLongIphone ? @"RankView4iPhone5" : @"RankView"));
    
    DLog(@"showRankView");
    RankViewController *controller = [[RankViewController alloc] initWithNibName:
                                      cDeviceType == DEVICETYPE_IPAD ? @"RankView4iPad" :
                                      (IsiPhoneX3() ? @"RankView4iPhoneX" :
                                      (isLongIphone ? @"RankView4iPhone5" : @"RankView"))
                                                                          bundle:nil];
    controller.bMyRankCheck = bMyRanking;
    controller.mainViewController = self;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:controller animated:YES completion:nil];
    
    [controller release];
    
}


- (IBAction)showRankView
{
#ifdef USE_FLURRY
    [Flurry logEvent:@"ShowRankView"];
#endif
	//[self hideMenuView:NO];
    [self hideDailyGameView];
    [self gotoRankingWebView:NO];
}


#pragma mark - More Games

/// 메뉴 맨 위에 More Games 를 끼운다.
///
/// 메뉴는 xib 가 여럿(기종별)이고 줄 사이 틈이 기종마다 달라서 xib 를 고치지 않는다.
/// 맨 위 단추를 복제해 글꼴·색을 그대로 물려받고, 아래 단추들은 간격을 조금씩
/// 줄여 Close 위에 한 줄이 들어갈 자리를 만든다. 메뉴 틀 크기는 바꾸지 않는다.
- (void) installMoreGamesMenuButton
{
    if (buttonMoreGames != nil || viewMenu == nil || buttonMenuClose == nil)
        return;

    NSMutableArray *items = [NSMutableArray array];
    for (UIView *v in viewMenu.subviews) {
        if ([v isKindOfClass:[UIButton class]] && v != buttonMenuClose && !v.hidden)
            [items addObject:v];
    }
    if ([items count] == 0)
        return;
    [items sortUsingComparator:^NSComparisonResult(UIView *a, UIView *b) {
        CGFloat ya = a.frame.origin.y, yb = b.frame.origin.y;
        return ya < yb ? NSOrderedAscending : (ya > yb ? NSOrderedDescending : NSOrderedSame);
    }];

    UIButton *top = [items objectAtIndex:0];
    UIButton *last = [items lastObject];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:top requiringSecureCoding:NO error:nil];
    UIButton *btn = nil;
    if (data) {
        NSKeyedUnarchiver *un = [[[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil] autorelease];
        un.requiresSecureCoding = NO;
        btn = [un decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    }
    if (![btn isKindOfClass:[UIButton class]])
        return;
    btn.tag = 0;

    NSUInteger count = [items count];
    CGFloat topY = top.frame.origin.y;
    CGFloat avail = buttonMenuClose.frame.origin.y - 8 - topY;
    CGFloat oldPitch = count > 1 ? (last.frame.origin.y - topY) / (count - 1) : top.frame.size.height + 8;
    CGFloat pitch = MIN(oldPitch, (avail - last.frame.size.height) / count);
    if (pitch < 24)     // 자리가 이만큼도 없으면 넣지 않는다. 기존 메뉴가 깨지는 것보다 낫다.
        return;

    // 메뉴 항목 왼쪽의 그림(UIImageView)은 줄을 따라 같이 옮긴다. 단추와 가장 가까운 줄이 짝이다.
    NSMutableArray *icons = [NSMutableArray array];
    for (UIView *v in viewMenu.subviews) {
        if ([v isKindOfClass:[UIImageView class]] && !v.hidden && v.frame.size.width > 8)
            [icons addObject:v];
    }
    for (UIView *icon in icons) {
        UIView *near = nil;
        CGFloat best = CGFLOAT_MAX;
        for (UIView *b in items) {
            CGFloat d = fabs(CGRectGetMidY(b.frame) - CGRectGetMidY(icon.frame));
            if (d < best) { best = d; near = b; }
        }
        if (near != nil && best < 40) {
            NSUInteger idx = [items indexOfObject:near];
            CGRect fr = icon.frame;
            fr.origin.y += (topY + (idx + 1) * pitch) - near.frame.origin.y;   // 단추가 옮겨 갈 만큼
            icon.frame = fr;
        }
    }
    UIImageView *refIcon = [icons count] > 0 ? [icons objectAtIndex:0] : nil;

    CGRect f = top.frame;
    f.origin.y = topY;
    f.size.height = MIN(f.size.height, pitch - 2);
    btn.frame = f;
    for (NSUInteger i = 0; i < count; i++) {
        UIView *v = [items objectAtIndex:i];
        CGRect r = v.frame;
        r.origin.y = topY + (i + 1) * pitch;
        r.size.height = MIN(r.size.height, pitch - 2);
        v.frame = r;
    }

    [btn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [btn addTarget:self action:@selector(showMoreGames) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:gettext(@"More Games", nil) forState:UIControlStateNormal];
    [viewMenu addSubview:btn];
    buttonMoreGames = btn;
    [MoreGamesViewController attachNewDotToView:btn afterTitleOfButton:YES];   // 새 앱 출시 표시
    if (refIcon != nil) {
        UIImage *img = [UIImage systemImageNamed:@"square.grid.2x2.fill"];
        UIImageView *iv = [[[UIImageView alloc] initWithImage:img] autorelease];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.tintColor = [UIColor blackColor];
        CGRect ir = refIcon.frame;
        ir.origin.y = CGRectGetMidY(btn.frame) - ir.size.height / 2;
        iv.frame = ir;
        [viewMenu addSubview:iv];
    }
}

- (IBAction)showMoreGames
{
    [self hideMenuView:NO];
#ifdef USE_FLURRY
    [Flurry logEvent:@"ShowMoreGames"];
#endif
    // More Games 가 떠 있는 동안은 게임 시간이 흐르지 않는다(기록 경쟁). 메뉴를 닫으면 타이머가 다시 돌므로
    // 그 상태를 기억해 두고 멈췄다가, 화면이 닫히면(dismiss 완료) 원래대로 되살린다. 원래 멈춰 있었으면 그대로 둔다.
    BOOL wasRunning = [timerGame isValid];
    [self stopGameTimer];
    [Locale openMoreGamesOnDismiss:^{
        if (wasRunning)
            [self startGameTimer];
    }];
}

- (IBAction)showFeedbackView
{
    [self hideMenuView:NO];

#ifdef USE_FLURRY
    [Flurry logEvent:@"ShowFeedbackView"];
#endif
    [self openFeedbackPortal];
    [self startGameTimer];
    [self DoneQuest:eQuestSendfeedback];
}

/// 쿼리 값을 퍼센트 인코딩한다 — **공백은 %20** 이다 (`+` 가 아니다).
///
/// 허용 글자는 `A-Za-z0-9-._~` 뿐이다. 지원 페이지(JS `URLSearchParams`)가
/// 그대로 되돌려 읽는다. `percentEscapeString:` 은 공백을 `+` 로 바꾸므로
/// 여기에는 쓰지 않는다.
static NSString *SupportQueryEscape(NSString *string)
{
    if (string == nil) {
        return @"";
    }
    static NSCharacterSet *allowed = nil;
    if (allowed == nil) {
        allowed = [[NSCharacterSet characterSetWithCharactersInString:
                    @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"] retain];
    }
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowed] ?: @"";
}

/// 지원 페이지 주소의 앱 slug. 앱별 번들 ID 가 아니라 빌드 매크로로 가른다.
///
/// 정본은 factory 저장소 `_docs/strategies/STORE_URLS.md` §6 의 slug 표다.
/// 반환값: sudoku9free · sudoku9pro · sudoku6free · sudoku6pro
- (NSString *)supportSlug
{
#ifdef SUDOKU9
#ifdef ADMOB_FREEVERSION
    return @"sudoku9free";
#else
    return @"sudoku9pro";
#endif
#elif defined(SUDOKU6)
#ifdef ADMOB_FREEVERSION
    return @"sudoku6free";
#else
    return @"sudoku6pro";
#endif
#else
    return @"sudoku9pro";
#endif
}

/// 지원(문의) 페이지를 브라우저로 연다.
///
/// `https://go.smartoneinc.com/<slug>/support?os=iOS&osv=…&app=…&device=…&lang=…&userid=…&nickname=…`
/// 페이지가 이 쿼리로 Jira 서비스 데스크 양식을 채워 넘긴다.
/// 기기 이름(사용자가 붙인 이름) 대신 모델 식별자(iPhone15,4)를 보낸다.
/// UserId 는 항상, 닉네임은 아이디와 다른 이름을 정했을 때만 넣는다.
///
/// 반환값: 없음
- (void)openFeedbackPortal
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"] ?: @"";
    NSString *build = [info objectForKey:@"CFBundleVersion"] ?: @"";
    NSString *appVer = [NSString stringWithFormat:@"%@ (%@)", version, build];

    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *device = [NSString stringWithUTF8String:systemInfo.machine] ?: @"";
    NSString *osv = [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion] ?: @""];
    NSString *lang = [[NSLocale preferredLanguages] firstObject] ?: @"";
    NSString *userIdStr = [NSString stringWithFormat:@"%ld", (long)gUserID];
    NSString *realName = [self getUserName];

    NSMutableString *urlStr = [NSMutableString stringWithFormat:
                               @"https://go.smartoneinc.com/%@/support?os=iOS&osv=%@&app=%@&device=%@&lang=%@&userid=%@",
                               [self supportSlug],
                               SupportQueryEscape(osv),
                               SupportQueryEscape(appVer),
                               SupportQueryEscape(device),
                               SupportQueryEscape(lang),
                               SupportQueryEscape(userIdStr)];
    if ([realName length] > 0) {
        [urlStr appendFormat:@"&nickname=%@", SupportQueryEscape(realName)];
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url != nil) {
        // iOS 18부터 deprecated openURL: 은 무조건 NO를 돌려 아무 화면도 안 연다.
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	DLog(@"viewDidUnload");
    [super viewDidUnload];
    
#ifdef ADMOB_FREEVERSION
    if (bNoAd) {
        DLog(@"No Ad");
    } else {
        if (adMobBanner) {
            [adMobBanner release];
            adMobBanner = nil;
        }
    }
#endif
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	DLog(@"dealloc");
#ifdef ADMOB_FREEVERSION
    if (bNoAd) {
        DLog(@"No Ad");
    } else {
        if (adMobBanner) {
            adMobBanner.delegate = nil;
            [adMobBanner release];
            adMobBanner = nil;
        }
    }
#endif
    [super dealloc];
}

- (void) allButtonLock
{
//	buttonNewGameDailyPuzzle.enabled = NO;
    buttonNewGameUserInput.enabled = NO;
    buttonNewGameVeryEasy.enabled = NO;
	buttonNewGameEasy.enabled = NO;
	buttonNewGameNormal.enabled = NO;	
	buttonNewGameHard.enabled = NO;	
	buttonNewGameVeryHard.enabled = NO;	
	buttonNewGameCancel.enabled = NO;
    
    buttonDailyRanking.enabled = NO;

    buttonDailyGameSudoku.enabled = NO;
	buttonDailyGameGt.enabled = NO;
	buttonDailyGameKiller.enabled = NO;
    buttonDailyGameCalcu.enabled = NO;
    buttonDailyGameSymbol.enabled = NO;

    buttonDailyGameSudokuEasy.enabled = NO;
    buttonDailyGameGtEasy.enabled = NO;
    buttonDailyGameKillerEasy.enabled = NO;
    buttonDailyGameCalcuEasy.enabled = NO;
    buttonDailyGameSymbolEasy.enabled = NO;

    buttonDailyGameSudokuHard.enabled = NO;
    buttonDailyGameGtHard.enabled = NO;
    buttonDailyGameKillerHard.enabled = NO;
    buttonDailyGameCalcuHard.enabled = NO;
    buttonDailyGameSymbolHard.enabled = NO;

    buttonDailyGameCancel.enabled = NO;
}

- (void) allButtonUnLock
{
    // zzz dailpuzzle 잠금 기능 필요
    
//	buttonNewGameDailyPuzzle.enabled = YES;
    buttonNewGameUserInput.enabled = YES;
    buttonNewGameVeryEasy.enabled = YES;
	buttonNewGameEasy.enabled = YES;
	buttonNewGameNormal.enabled = YES;	
	buttonNewGameHard.enabled = YES;	
	buttonNewGameVeryHard.enabled = YES;	
	buttonNewGameCancel.enabled = YES;	

    buttonDailyRanking.enabled = YES;
    
    buttonDailyGameSudoku.enabled = YES;
	buttonDailyGameGt.enabled = YES;
	buttonDailyGameKiller.enabled = YES;
    buttonDailyGameCalcu.enabled = YES;
    buttonDailyGameSymbol.enabled = YES;

    buttonDailyGameSudokuEasy.enabled = YES;
    buttonDailyGameGtEasy.enabled = YES;
    buttonDailyGameKillerEasy.enabled = YES;
    buttonDailyGameCalcuEasy.enabled = YES;
    buttonDailyGameSymbolEasy.enabled = YES;

    buttonDailyGameSudokuHard.enabled = YES;
    buttonDailyGameGtHard.enabled = YES;
    buttonDailyGameKillerHard.enabled = YES;
    buttonDailyGameCalcuHard.enabled = YES;
    buttonDailyGameSymbolHard.enabled = YES;

    buttonDailyGameCancel.enabled = YES;
}

- (void) setGameLevel
{
    if (mainView.sudokuGame.bDailyPuzzle)
    {
        labelLevel.text = gettext(@"daily", nil);
        return;
    }
        
	switch (mainView.sudokuGame.gameLevel) {
        case GAMELEVEL_USERINPUT:
            labelLevel.text = gettext(@"user input", nil);
            break;
		case GAMELEVEL_VERYEASY:
			labelLevel.text = gettext(@"very easy", nil);
			break;
		case GAMELEVEL_EASY:
			labelLevel.text = gettext(@"easy", nil);
			break;
		case GAMELEVEL_NORMAL:
			labelLevel.text = gettext(@"normal", nil);
			break;
		case GAMELEVEL_HARD:
			labelLevel.text = gettext(@"hard", nil);
			break;
		case GAMELEVEL_VERYHARD:
			labelLevel.text = gettext(@"very hard", nil);
			break;
		default:
			break;
	}
}

- (void) setUserLevel
{
    NSInteger userLevel = [self getMyLevel];
    
    imageUserLevel.image = [UIImage imageNamed:[NSString stringWithFormat:@"level_%02d.png", (int)userLevel]];
    NSString *strLevel = [NSString stringWithFormat:gettext(@"level %d", nil), (int)userLevel];
//    NSString *strScore = [NSString stringWithFormat:gettext(@"%d points", nil), [self getTotalScore]];
//    labelUserLevel.text = [NSString stringWithFormat:@"%@ (%@)", strLevel, strScore];
    labelUserLevel.text = [NSString stringWithFormat:@"%@ (%ld)", strLevel, [self getTotalScore]];
    /*
     if (score.scoreRankTotal > 0) {
     labelUserLevel.text = [NSString stringWithFormat:@"%@ (%@, #%ld)", strLevel, strScore, (long)score.scoreRankTotal];
     } else {
     labelUserLevel.text = [NSString stringWithFormat:@"%@ (%@)", strLevel, strScore];
     }
     */
}

- (NSString *) getUserName
{
    if ([gUserName isEqualToString:[NSString stringWithFormat:@"%d", (int)gUserID]] != YES) {
        return gUserName;
    } else {
        return @"";
    }
}

- (void) setUserName
{
    labelNickname.text = [self getUserName];
    labelUserName.text = [self getUserName];
}


- (void)OnTimerShowMenu:(NSTimer *)timer
{
	CGRect frameOld = viewMenu.frame;
    frameOld.origin.x -= intervalX;
    viewMenu.frame = frameOld;
	
	if (viewMenu.frame.origin.x >= areaPuzzleTable.frame.origin.x - 0.1)
	{
		[timer invalidate];
	}
}

- (void) hideAwayView:(UIView*) v
{
	CGRect frameOld = v.frame;
    frameOld.origin.x = 0 - v.frame.size.width*3;
    v.frame = frameOld;
//	v.hidden = YES;
}


- (void) readySlideView:(UIView*) v
{
//	v.hidden = NO;

	CGRect frameOld = v.frame;
    frameOld.origin.x = 0 - v.frame.size.width;
    v.frame = frameOld;
	
	if (mainView.bMenuMode)
	{
		mainView.bMenuMode = NO;
		//[self startGameTimer];
	}
}

- (void) showMenuView
{

	
	if (mainView.bMenuMode)
		return;
	
	[mainView setBlur:YES];
	[self readySlideView:viewMenu];
	mainView.bMenuMode = YES;
	[self stopGameTimer];
	intervalX = (viewMenu.frame.origin.x - areaPuzzleTable.frame.origin.x)/20;
	
	[NSTimer scheduledTimerWithTimeInterval:0.01f
									 target:self
								   selector:@selector(OnTimerShowMenu:)
								   userInfo:nil
									repeats:YES];
	[self updateButtons];
}

- (void)OnTimerHideMenu:(NSTimer *)timer
{
	CGRect frameOld = viewMenu.frame;
    frameOld.origin.x -= intervalX;
    viewMenu.frame = frameOld;
	
	if ((viewMenu.frame.origin.x + viewMenu.frame.size.width) <= 0)
	{
		[timer invalidate];
		[self hideAwayView:viewMenu];
	}
}

- (void) hideMenuView:(BOOL) blur
{
	if (blur == NO)
	{
		[mainView setBlur:blur];
	}
	
	intervalX = (viewMenu.frame.origin.x + viewMenu.frame.size.width)/25;
	// 버튼 disable
	
	[NSTimer scheduledTimerWithTimeInterval:0.01f
									 target:self
								   selector:@selector(OnTimerHideMenu:)
								   userInfo:nil
									repeats:YES];

	mainView.bMenuMode = NO;
	//[self startGameTimer];
	[self updateButtons];
}


- (void)OnTimerShowNewGame:(NSTimer *)timer
{
	CGRect frameOld = viewNewGame.frame;
    frameOld.origin.x -= intervalX2;
    viewNewGame.frame = frameOld;
	
	if (viewNewGame.frame.origin.x >= areaPuzzleTable.frame.origin.x - 0.1)
	{
		[timer invalidate];
	}
}


- (void) showNewGameView
{
	if (mainView.bMenuMode)
		return;

	[self readySlideView:viewNewGame];
	mainView.bMenuMode = YES;
	[self stopGameTimer];
	intervalX2 = (viewNewGame.frame.origin.x - areaPuzzleTable.frame.origin.x)/20;
	buttonNewGameCancel.hidden = (mainView.sudokuGame == nil);
	
	[NSTimer scheduledTimerWithTimeInterval:0.01f
									 target:self
								   selector:@selector(OnTimerShowNewGame:)
								   userInfo:nil
									repeats:YES];
	[self updateButtons];
}

- (void) OnTimerHideNewGame:(NSTimer *)timer
{
	CGRect frameOld = viewNewGame.frame;
    frameOld.origin.x -= intervalX2;
    viewNewGame.frame = frameOld;
	
	if ((viewNewGame.frame.origin.x + viewNewGame.frame.size.width) <= 0)
	{
		[timer invalidate];
		[self hideAwayView:viewNewGame];
	}
}

- (void) hideNewGameView
{
	[mainView setBlur:NO];
	intervalX2 = (viewNewGame.frame.origin.x + viewNewGame.frame.size.width)/25;
	// 버튼 disable
	
	[NSTimer scheduledTimerWithTimeInterval:0.01f
									 target:self
								   selector:@selector(OnTimerHideNewGame:)
								   userInfo:nil
									repeats:YES];
	
	mainView.bMenuMode = NO;
	[self startGameTimer];
	[self setGameLevel];

	[self updateButtons];
	
}

- (void)OnTimerShowDailyGame:(NSTimer *)timer
{
	CGRect frameOld = viewDailyGame.frame;
    frameOld.origin.x -= intervalX2;
    viewDailyGame.frame = frameOld;
	
	if (viewDailyGame.frame.origin.x >= areaPuzzleTable.frame.origin.x - 0.1)
	{
		[timer invalidate];
	}
}

- (void) showDailyGameView
{
	if (mainView.bMenuMode)
		return;
    
	[self readySlideView:viewDailyGame];
	mainView.bMenuMode = YES;
	[self stopGameTimer];
	intervalX2 = (viewDailyGame.frame.origin.x - areaPuzzleTable.frame.origin.x)/20;
	// zzzzzzz
    buttonDailyGameCancel.hidden = (mainView.sudokuGame == nil);
	
	[NSTimer scheduledTimerWithTimeInterval:0.01f
									 target:self
								   selector:@selector(OnTimerShowDailyGame:)
								   userInfo:nil
									repeats:YES];
	[self updateButtons];
}

- (void) OnTimerHideDailyGame:(NSTimer *)timer
{
	CGRect frameOld = viewDailyGame.frame;
    frameOld.origin.x -= intervalX2;
    viewDailyGame.frame = frameOld;
	
	if ((viewDailyGame.frame.origin.x + viewDailyGame.frame.size.width) <= 0)
	{
		[timer invalidate];
		[self hideAwayView:viewDailyGame];
	}
}

- (void) hideDailyGameView
{
	[mainView setBlur:NO];
	intervalX2 = (viewDailyGame.frame.origin.x + viewDailyGame.frame.size.width)/25;
	// 버튼 disable
	
	[NSTimer scheduledTimerWithTimeInterval:0.01f
									 target:self
								   selector:@selector(OnTimerHideDailyGame:)
								   userInfo:nil
									repeats:YES];
	
	mainView.bMenuMode = NO;
	[self startGameTimer];
	[self setGameLevel];
    
	[self updateButtons];
	
}


- (void) updateGameTime:(NSInteger) time
{
	NSString *str;
	
	if (time >= 60*60*100)
		time = 60*60*100 - 1;
	
	if (time >= 60*60)
		str = [NSString stringWithFormat:@"%02d:%02d:%02d",
			   (int) time / (60*60),
			   (int) time / (60) % (60),
			   (int) time % (60)];
	else 
		str = [NSString stringWithFormat:@"%02d:%02d",
			   (int) time / (60),
			   (int) time % (60)];
	
	labelGameTime.text = str; 
	
}

- (void) updateClockTime
{
    NSDateFormatter *formatter;
    NSString        *timeString;
    
    formatter = [[NSDateFormatter alloc] init];
    
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:gettext(@"locale", nil)];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    timeString = [formatter stringFromDate:[NSDate date]];
    
    [formatter release];
    
#ifdef DEBUG
    NSString        *timeStringD;
    
    timeStringD = [NSString stringWithFormat:@"%@%@", timeString, @"D"];
    labelTitleGameTime.text = timeStringD;

#else
    labelTitleGameTime.text = timeString;
#endif
    
    
}


- (IBAction)showMenu
{
    bReplay = NO;   // 혹시 replay 중이면 멈춘다.
    
	//[mainView playSoundClick];
	
	if (mainView.bMenuMode)
	{
		[self hideMenuView:NO];
	} else {
		[self allButtonUnLock];
		[self showMenuView];
	}
}



- (void) increaseScoreGames
{
	if (mainView.sudokuGame)
	{
        NSInteger level = [self levelToWriteScore:mainView.sudokuGame];
        
		score.scoreGames[mainView.sudokuGame.sudokuType][level] += 1;     // 게임 수 1 증가
		score.scoreTotal += 1;                                    // 1게임 시도당 1점 추가
        {   // 분석 (A464). from 은 첫 세션 첫 판만 (A468 R1)
            NSMutableDictionary *gp = [NSMutableDictionary dictionaryWithObject:GaModeId(mainView.sudokuGame) forKey:@"mode_id"];
            if (gGaNextStartFrom) { gp[@"from"] = gGaNextStartFrom; gGaNextStartFrom = nil; }
            GaLogEvent(@"game_start", gp);
        }
        
        [self saveScoreData];
        [self setUserLevel];
	}
}

- (void) makeNewGameData
{
    GaLogQuitIfUnfinished(mainView.sudokuGame);   // 분석 (A464): 안 끝난 판을 두고 새 판 = 그만둠
	if (mainView.sudokuGame)
		[mainView.sudokuGame release];

	[mainView newGame:levelNewGame size:DEFPUZZLESIZE];
    
    [self loadSetting];
    if (mainView.bSharedThisOnFacebook)
    {
        mainView.sudokuGame.countHint += NUM_HINTBONUS;
        
        mainView.bSharedThisOnFacebook = NO;
        [self saveSetting];
    }
    bBuyingHint50 = NO;

	[self increaseScoreGames];
	[self saveScoreData];
	[self updateGameTime:0];
	[self updateButtons];
    
    if (mainView.sudokuGame.bAutoMemo)
        [self DoneQuest:eQuestAutomemo];
    
#ifndef DAILYSENDER
    // timer -> getuserpuzzle send
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        // 작업이 오래 걸리는 API를 백그라운드 스레드에서 실행한다.
        BOOL res = [self sendNormalPuzzleStart];
        DLog(@"[self sendNormalPuzzleStart] => %d", (int)res);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // do nothing
        });
    });
#endif
    
}

-(BOOL) sendNormalPuzzleStart
{
    NSString* strRet = [self downloadDailyPuzzle:@"getuserpuzzle"
                                      sudokuType:mainView.sudokuGame.sudokuType
                                       gameLevel:mainView.sudokuGame.gameLevel
                                       bAutoMemo:mainView.sudokuGame.bAutoMemo];
    // 이부분을 수정
    if (!strRet)
    {
        // 전송 할 때까지 반복할 것인가?
        return NO;
    }
    return YES;
}



- (void)OnTimerNewGame:(NSTimer *)timer
{
	DLog(@"OnTimerNewGame");	
	
	[self makeNewGameData];
	
	[activityIndicator stopAnimating];
	
	[self hideNewGameView];	// 
	
}

- (void) makeNewGame:(NSInteger)level
{
	DLog(@"makeNewGame");
	
	[self allButtonLock];

	[activityIndicator startAnimating];
	levelNewGame = level;
    mainView.nSettingGameLevel = (GAMELEVEL)level;

#ifdef DAILYSENDER
	[self makeNewGameData];
#else
	timerNewGame = [NSTimer scheduledTimerWithTimeInterval:0 
												target:self
											  selector:@selector(OnTimerNewGame:)
											  userInfo:nil
											   repeats:NO];	
#endif
}

- (NSInteger) getCheckSum	// forVersion2
{
	NSTimeInterval sec = [[NSDate date]timeIntervalSince1970];	// seconds from 1970
	
	NSInteger secInt = (NSInteger)(sec / 43);
	
	char strInt[8+1];
	sprintf(strInt, "%08ld", (long)secInt);
	
	char strScramble[8+1];
	sprintf(strScramble, "%c%c%c%c%c%c%c%c",
			strInt[7],
			strInt[5],
			strInt[6],
			strInt[4],
			strInt[3],
			strInt[0],
			strInt[2],
			strInt[1]);
	
	NSInteger csInt = (NSInteger) atoi(strScramble);
    
    DLog(@"getCheckSum %ld -> %ld -> %ld", (long)sec, (long)secInt, (long)csInt);
	
	return csInt;
}


- (void) alertLocalizedOkayView:(NSString*)aTitle message:(NSString*)aMessage
{
    [self alertMessageOk:gettext(aTitle, nil) msg:gettext(aMessage, nil)];
}

- (void) alertLocalizedAlertView:(NSString*)aMessage
{
	[self alertLocalizedOkayView:@"Alert" message:aMessage];
}


- (void) alertLocalizedAlertViewUTF8
{
	[self alertLocalizedAlertView:@"Wrong UTF8 format data was received"];
}


- (NSMutableURLRequest *) GetTheRequest:(NSString *)strURI timeoutInterval:(NSTimeInterval)timeout
{
    NSString *strURL = [NSString stringWithFormat: @"http://%@/%@?%@",
#ifdef DAILYSENDER
                        @"www.abcswcon.com",
#else
                        gServerIP,
#endif
                        cServerScript,
                        strURI];
    DLog(@"strURL* = \n%@", strURL);
    NSURL *theURL = [NSURL URLWithString:strURL];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:timeout];
    return theRequest;
}

- (NSURLConnection *) PostHTTPDataAsync:(NSString *)strURI bodyObject:(NSDictionary *)bodyObject timeoutInterval:(NSTimeInterval)timeout
{
    NSMutableURLRequest *theRequest = [self GetTheRequest:strURI timeoutInterval:timeout];
    
    [theRequest setHTTPMethod:@"POST"];
    
    // bodyObject의 객체가 존재할 경우 QueryString형태로 변환
    if(bodyObject)
    {
        // 임시 변수 선언
        NSMutableArray *parts = [NSMutableArray array];
        NSString *part;
        id key;
        id value;
        
        // 값을 하나하나 변환
        for(key in bodyObject)
        {
            value = [bodyObject objectForKey:key];
            part = [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]],
                    [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
            [parts addObject:part];
        }
        
        // 값들을 &로 연결하여 Body에 사용
        [theRequest setHTTPBody:[[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
}

- (NSURLConnection *) GetHTTPDataAsync:(NSString *)strURI timeoutInterval:(NSTimeInterval)timeout
{
    NSMutableURLRequest *theRequest = [self GetTheRequest:strURI timeoutInterval:timeout];
    return [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];

}

- (NSString *) GetHTTPData:(NSString *)strURI timeoutInterval:(NSTimeInterval)timeout
{
    NSMutableURLRequest *theRequest = [self GetTheRequest:strURI timeoutInterval:timeout];
	
	NSURLResponse *theResponse;
	NSError *theError;
	NSData *theResponseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&theError];
	
	if (theResponseData)
	{
#ifdef DEBUG
		char str[6000+10];   // 3000 -> 6000 fo safe
		
		memcpy(&str, theResponseData.bytes, MIN(theResponseData.length, 3000));
        //str[theResponseData.length] = '\0';     // SDSDKNINEP-3432 Crash report
        str[MIN(theResponseData.length, 3000)] = '\0';
        DLog(@"char* = %s", str);
#endif // DEBUG
        
		NSString *strData = [[NSString alloc] initWithData:theResponseData encoding:NSUTF8StringEncoding];
		
		//		NSLog(@"strData = %@", strData);
		
		if (strData == nil)
		{
			[self alertLocalizedAlertViewUTF8];
		}
		
		return strData;
	} else {
		// zzz 에러처리
        DLog(@"theError:%@", [theError localizedDescription]);
        //[self alertLocalizedAlertView:[theError localizedDescription]];
	}
	
	
	return nil;
}


- (NSString*) getNowYYYYMMDD
{
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    //formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"NZDT"];          // Pacific/Auckland
    NSCalendar *gregorian;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    } else {
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    [formatter setDateFormat:@"yyyyMMdd"];
    
    NSString *str = [formatter stringFromDate:today];
    //[str retain];
    [gregorian release];
    [formatter release];
    return str;
}

- (NSString*) getNowYYYY
{
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSCalendar *gregorian;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    } else {
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    formatter.calendar = gregorian;
    
    [formatter setDateFormat:@"yyyy"];
    
    NSString *str = [formatter stringFromDate:today];
    //[str retain];
    [gregorian release];
    [formatter release];
    return str;
}


- (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                       (CFStringRef)[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                       (CFStringRef)@" ",
                       (CFStringRef)@":/?@!$&'()*+,;=",
                       kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}


- (void) DoneQuest:(eQuest)quest
{
    NSInteger point = [Quest DoneQuest:quest];
    if (point > 0) {
        score.scoreTotal += point;

        [self saveScoreData];
        

    } else {
        // do nothing
        // aleady done
    }
}

- (NSString*) downloadDailyPuzzle:(NSString*)act
                       sudokuType:(SUDOKUTYPE)sudokuType
                        gameLevel:(GAMELEVEL)gameLevel
                        bAutoMemo:(BOOL)bAutoMemo
{
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];

	DLog(@"Country Code = %@", countryCode);
    
    [self connectToServerInit];
    
    DLog(@"AppVersion = %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
     
    NSString* strURI = [NSString stringWithFormat:
						@"act=%@&userid=%ld&username=%@&appversion=%@&free=%d&latitude=%d&longitude=%d&version=%d&cs=%ld&size=%d&type=%d&level=%d&date=%@&automemo=%d&countrycode=%@",
                        act,
                        (long)gUserID,
                        [self percentEscapeString:gUserName],
                        APPVERSION,
                        freeMode,
#ifdef LOCATIONTRACK
                        (NSInteger) (currentLatitude*1000000.0+0.5),
                        (NSInteger) (currentLongtitude*1000000.0+0.5),
#else
                        0,
                        0,
#endif
						cProtocolVersion,
                        (long)[self getCheckSum],
                        DEFPUZZLESIZE,
                        sudokuType,
                        gameLevel,         //2, // level default 2, 0 is very hard
                       [self getNowYYYYMMDD],
                        bAutoMemo ? 1 : 0,
                        countryCode];
    
    NSString* strData = [self GetHTTPData:strURI	timeoutInterval:cDefaultHTTPTimeOut];
    return strData;
}

- (BOOL) uploadDailyPuzzleResult:(NSString*)act
                       spendTime:(NSTimeInterval)gameTime
                      sudokuType:(SUDOKUTYPE)sudokuType
                       gameLevel:(GAMELEVEL)gameLevel
                       bAutoMemo:(BOOL)bAutoMemo
                          pTotal:(NSInteger*)pTotal pGrade:(NSInteger*)pGrade
{
#ifdef DEBUG
    // 디버그 빌드는 결과를 서버에 올리지 않는다 (A468) — 데일리(addresult)는 실제 랭킹에 들어가고,
    // 시뮬레이터 · QA 로 푼 시간이 남의 순위를 흔든다. Release(TestFlight 포함)는 예전 그대로 올린다.
    DLog(@"[debug] skip upload %@ type=%d level=%d spend=%lu", act, (int)sudokuType, (int)gameLevel, (unsigned long)gameTime);
    return NO;
#endif
    //[self connectToServerInit];
    
    NSString* strURI = [NSString stringWithFormat:
						@"act=%@&userid=%ld&username=%@&free=%d&latitude=%d&longitude=%d&version=%d&cs=%ld&size=%d&type=%d&level=%d&date=%@&spend=%lu&automemo=%d",
                        act,
                        (long)gUserID,
                        [self percentEscapeString:gUserName],
                        isFree,
#ifdef LOCATIONTRACK
                        (NSInteger) (currentLatitude*1000000.0+0.5),
                        (NSInteger) (currentLongtitude*1000000.0+0.5),
#else
                        0,
                        0,
#endif
						cProtocolVersion,
                        (long)[self getCheckSum],
                        DEFPUZZLESIZE,
                        sudokuType,   // 현재 type이 정확하게 전송된다.
                        gameLevel,   // 현재 level이 정확하게 전송된다.
                        //mainView.nSettingSudokuType,    // 게임도중 Seg. contrl을 한번 누르면 버그가 생길 수 있다.
                        [self getNowYYYYMMDD],
                        (unsigned long)gameTime,
                        bAutoMemo?1:0];
                        //mainView.bSettingAutoMemo ? 1 : 0];   // 게임도중 Seg. contrl을 한번 누르면 버그가 생길 수 있다.
    
    NSString* strData = [self GetHTTPData:strURI	timeoutInterval:cDefaultHTTPTimeOut];
    
    if (!strData) {
		return NO;
	}
    if ([act isEqualToString:@"adduserresult"])
        return YES;
    
    
	NSArray *listItems = [strData componentsSeparatedByString:@"\n"];
	NSInteger count = listItems.count;
	NSString *item;
    BOOL bError = NO;
	
	NSString *name;
	NSString *value;
	NSString *error = nil;
	for(int idx = 0; idx < count; idx++)
	{
		item = [listItems objectAtIndex:idx];
		
		NSArray *rawData = [item componentsSeparatedByString:@"\t"];
		if (rawData.count >= 2)
		{
			name = [rawData objectAtIndex:0];
			value = [rawData objectAtIndex:1];
			
			if ([name caseInsensitiveCompare:kResultStatus] == NSOrderedSame) {
				error = value;
				if ([error caseInsensitiveCompare:kSuccess] != NSOrderedSame) {
					[self alertLocalizedAlertView:error];
                    bError = YES;
				}
			} else if ([name caseInsensitiveCompare:@"Total"] == NSOrderedSame)
				*pTotal = [value integerValue];
			else if ([name caseInsensitiveCompare:@"Grade"] == NSOrderedSame)
				*pGrade = [value integerValue];
		}
	}
	
	[strData release];
    
    
    return bError ? NO : YES;
}


- (void) makeNewGameDataFromServer
{
    SudokuGame *oldGame = mainView.sudokuGame;
    BOOL bRet;
    
    NSString* strDailyPuzzle = [self downloadDailyPuzzle:@"getdailypuzzle"
                                              sudokuType:mainView.nSettingSudokuType
                                               gameLevel:mainView.nSettingGameLevel
                                               bAutoMemo:mainView.bSettingAutoMemo];    // 무조건 automemo는 false다.
    // 이부분을 수정
    if (!strDailyPuzzle)
    {
        [self alertLocalizedAlertView:@"Can't connect to a server."];
        return;
    }
	bRet = [mainView newGameFromServer:strDailyPuzzle];
    [strDailyPuzzle release];
    
    if (bRet == NO)
    {
        [self alertLocalizedAlertView:@"Failed to make a daily puzzle."];
        return;
    }
    GaLogQuitIfUnfinished(oldGame);   // 분석 (A464): 안 끝난 판을 두고 오늘의 퍼즐 = 그만둠
    
    [self loadSetting];
    if (mainView.bSharedThisOnFacebook)
    {
        mainView.sudokuGame.countHint += NUM_HINTBONUS;
        
        mainView.bSharedThisOnFacebook = NO;
        [self saveSetting];
    }
    
	[self increaseScoreGames];
	[self saveScoreData];
	[self updateGameTime:0];
	[self updateButtons];

	if (oldGame)
		[oldGame release];
    
    dailyStat[mainView.sudokuGame.sudokuType][mainView.sudokuGame.gameLevel].played = YES;
//    dailyStat[mainView.nSettingSudokuType].played = YES;      // bug fix
    [self saveDailyStat];

    {   // 분석 (A468 R3): 데일리를 열었다 — streak(지금 살아 있는 연속) · risk(오늘 안 깨면 끊김) · today(오늘 이미 셈)
        NSString *today = [self getNowYYYYMMDD];
        GaLogEvent(@"daily_start", @{ @"mode_id": GaModeId(mainView.sudokuGame),
                                      @"streak": @([DailyStreak aliveStreakOn:today]),
                                      @"risk": @([DailyStreak atRiskOn:today] ? 1 : 0),
                                      @"today": @([DailyStreak clearedOn:today] ? 1 : 0) });
    }

}

- (void)OnTimerNewGameDailyPuzzle:(NSTimer *)timer
{
	DLog(@"OnTimerNewGameDailyPuzzle");
#ifdef DAILYSENDER
    [self newgameDailyPuzzle];
#endif
    
    NSLog(@"nowDate = %s", nowDate);
	[self makeNewGameDataFromServer];
	
	[activityIndicatorDailyGame stopAnimating];
	
	[self hideDailyGameView];
	
}

- (void) makeNewGameDailyPuzzle
{
	DLog(@"makeNewGameDailyPuzzle");
	
    [self saveSetting];     // save nSettingSudokuType
    mainView.bSettingAutoMemo = NO; // only support original
	[self allButtonLock];
	[activityIndicatorDailyGame startAnimating];
	timerNewGame = [NSTimer scheduledTimerWithTimeInterval:0
                                                    target:self
                                                  selector:@selector(OnTimerNewGameDailyPuzzle:)
                                                  userInfo:nil
                                                   repeats:NO];	
    
    
}

- (IBAction)menuCancel
{
	[self hideMenuView:NO];
    [self startGameTimer];
}


- (void) getDailyStat
{
//    memset(&dailyStat, 0, sizeof(dailyStat));
    for (int i=0; i<SUDOKUTYPE_MAX; i++) {
        for (int j=0; j<GAMELEVEL_MAX; j++) {
            dailyStat[i][j].total = 0;
            dailyStat[i][j].besttime = 0;
        }
    }
    
    //[self connectToServerInit];
    
    NSString* strURI = [NSString stringWithFormat:
                        @"act=%@&userid=%ld&username=%@&totalsec=%ud&latitude=%d&longitude=%d&version=%d&cs=%ld&size=%d&date=%@",
                        @"getdailystat",
                        (long)gUserID,
                        [self percentEscapeString:gUserName],
                        (unsigned int) score.spendTotalSec,
#ifdef LOCATIONTRACK
                        (NSInteger) (currentLatitude*1000000.0+0.5),
                        (NSInteger) (currentLongtitude*1000000.0+0.5),
#else
                        0,
                        0,
#endif
						cProtocolVersion,
                        (long)[self getCheckSum],
                        DEFPUZZLESIZE,
                        [self getNowYYYYMMDD]];
    
    NSString* strData = [self GetHTTPData:strURI	timeoutInterval:cDefaultHTTPTimeOut];
    
    if (!strData) {
        // clear 성적 표시
		return;
	}
	NSArray *listItems = [strData componentsSeparatedByString:@"\n"];
	NSInteger count = listItems.count;
	NSString *item;
    BOOL bError = NO;
	
	NSString *name;
	NSString *value;
	NSString *error = nil;
	for(int idx = 0; idx < count; idx++)
	{
		item = [listItems objectAtIndex:idx];
		
		NSArray *rawData = [item componentsSeparatedByString:@"\t"];
        
        if (idx == 0) {  // 첫줄은 형식에 맞아야 함
            if (rawData.count != 2)
            {
                [self alertLocalizedAlertView:@"Server internal error"];
                bError = YES;
                break;
            }
			name = [rawData objectAtIndex:0];
			value = [rawData objectAtIndex:1];
            
			if ([name caseInsensitiveCompare:kResultStatus] == NSOrderedSame) {
				error = value;
				if ([error caseInsensitiveCompare:kSuccess] != NSOrderedSame) {
					[self alertLocalizedAlertView:error];
                    bError = YES;
                    break;
				}
			} else {
                [self alertLocalizedAlertView:@"Server error"];
                bError = YES;
                break;
            }
        }
        else if (rawData.count >= 2)
		{
			name = [rawData objectAtIndex:0];
			value = [rawData objectAtIndex:1];
			
            if ([name caseInsensitiveCompare:@"Total0"] == NSOrderedSame)
				dailyStat[0][GAMELEVEL_NORMAL].total = [value integerValue];
			else if ([name caseInsensitiveCompare:@"Besttime0"] == NSOrderedSame)
				dailyStat[0][GAMELEVEL_NORMAL].besttime = [value integerValue];
            else if ([name caseInsensitiveCompare:@"Total1"] == NSOrderedSame)
				dailyStat[1][GAMELEVEL_NORMAL].total = [value integerValue];
			else if ([name caseInsensitiveCompare:@"Besttime1"] == NSOrderedSame)
				dailyStat[1][GAMELEVEL_NORMAL].besttime = [value integerValue];
            else if ([name caseInsensitiveCompare:@"Total2"] == NSOrderedSame)
				dailyStat[2][GAMELEVEL_NORMAL].total = [value integerValue];
			else if ([name caseInsensitiveCompare:@"Besttime2"] == NSOrderedSame)
				dailyStat[2][GAMELEVEL_NORMAL].besttime = [value integerValue];
            else if ([name caseInsensitiveCompare:@"Total3"] == NSOrderedSame)
                dailyStat[3][GAMELEVEL_NORMAL].total = [value integerValue];
            else if ([name caseInsensitiveCompare:@"Besttime3"] == NSOrderedSame)
                dailyStat[3][GAMELEVEL_NORMAL].besttime = [value integerValue];
            else if ([name caseInsensitiveCompare:@"Total4"] == NSOrderedSame)
                dailyStat[4][GAMELEVEL_NORMAL].total = [value integerValue];
            else if ([name caseInsensitiveCompare:@"Besttime4"] == NSOrderedSame)
                dailyStat[4][GAMELEVEL_NORMAL].besttime = [value integerValue];
		}
	}
	
	[strData release];
    
    if (bError == NO)
        bReadyDownloadDailyPuzzle = YES;
    
    return;
}


- (NSString*) getDailyStatString:(SUDOKUTYPE) type
{
    NSString *str = @"test";
/*
    if (dailyStat[type].total == 0)
        str = [NSString stringWithFormat:gettext(@"not yet", nil),
               dailyStat[type].total];
    else if (dailyStat[type].total == 1)
        str = [NSString stringWithFormat:gettext(@"%d person", nil),
               dailyStat[type].total];
    else    // > 1
        str = [NSString stringWithFormat:gettext(@"%d people", nil),
               dailyStat[type].total];
    
    str = [NSString stringWithFormat:@"%@, %@:%@",
                                 str,
                                 gettext(@"best time", nil),
                                 [self getTimeString:dailyStat[type].besttime]];
 */
    return str;
}

- (void) setDailyButton:(UIButton*) button played:(BOOL) bPlayed
{
    if (bReadyDownloadDailyPuzzle) {
#if defined(DAILYSENDER)// || defined(DEBUG)
        [self setButtonMode:button mode:YES];
#else
#ifdef DEBUG
        [self setButtonMode:button mode:YES];
#else
        [self setButtonMode:button mode:!bPlayed];
#endif
#endif
    } else {
        [self setButtonMode:button mode:NO];
    }
}

- (void) setDailyStat
{

    [self setDailyButton:buttonDailyGameSudokuEasy  played:dailyStat[SUDOKUTYPE_SUDOKU][GAMELEVEL_NORMAL].played];
    [self setDailyButton:buttonDailyGameGtEasy      played:dailyStat[SUDOKUTYPE_GT][GAMELEVEL_NORMAL].played];
    [self setDailyButton:buttonDailyGameKillerEasy  played:dailyStat[SUDOKUTYPE_KILLER][GAMELEVEL_NORMAL].played];
    [self setDailyButton:buttonDailyGameCalcuEasy   played:dailyStat[SUDOKUTYPE_CALCU][GAMELEVEL_NORMAL].played];
    [self setDailyButton:buttonDailyGameSymbolEasy  played:dailyStat[SUDOKUTYPE_SYMBOL][GAMELEVEL_NORMAL].played];

    [self setDailyButton:buttonDailyGameSudokuHard  played:dailyStat[SUDOKUTYPE_SUDOKU][GAMELEVEL_VERYHARD].played];
    [self setDailyButton:buttonDailyGameGtHard      played:dailyStat[SUDOKUTYPE_GT][GAMELEVEL_VERYHARD].played];
    [self setDailyButton:buttonDailyGameKillerHard  played:dailyStat[SUDOKUTYPE_KILLER][GAMELEVEL_VERYHARD].played];
    [self setDailyButton:buttonDailyGameCalcuHard   played:dailyStat[SUDOKUTYPE_CALCU][GAMELEVEL_VERYHARD].played];
    [self setDailyButton:buttonDailyGameSymbolHard  played:dailyStat[SUDOKUTYPE_SYMBOL][GAMELEVEL_VERYHARD].played];
    
    [self setUserName];

    if (bReadyDownloadDailyPuzzle)
    {
        labelDailyStat.text = @"";
        
        buttonDailyRanking.enabled = YES;
        buttonDailyRanking.alpha = 1.0f;
        /* for daily2
        labelDailyStatSudoku.text = [self getDailyStatString:SUDOKUTYPE_SUDOKU];
        labelDailyStatGt.text =     [self getDailyStatString:SUDOKUTYPE_GT];
        labelDailyStatKiller.text = [self getDailyStatString:SUDOKUTYPE_KILLER];
        labelDailyStatCalcu.text =  [self getDailyStatString:SUDOKUTYPE_CALCU];
        labelDailyStatSymbol.text = [self getDailyStatString:SUDOKUTYPE_SYMBOL];
         */
    } else  {
        labelDailyStat.text = gettext(@"Not connected to a server.", nil);

        buttonDailyRanking.enabled = NO;
        buttonDailyRanking.alpha = 0.3;
        /* for daily2
        labelDailyStatSudoku.text = @"...";
        labelDailyStatGt.text = @"...";
        labelDailyStatKiller.text = @"...";
        labelDailyStatCalcu.text = @"...";
        labelDailyStatSymbol.text = @"...";
         */
        
    }

    // 데일리 퍼즐 창이 떠 있으면 서버 상태 · 오늘 한 판을 알려 준다
    if ([self.presentedViewController isKindOfClass:[NewGameDialog class]] &&
        ((NewGameDialog *)self.presentedViewController).isDaily)
        [(NewGameDialog *)self.presentedViewController
            setDailyServerState:(bReadyDownloadDailyPuzzle ? NGDailyServerReady : NGDailyServerOffline)];
}

- (void)OnTimerDailyState:(NSTimer *)timer
{
	DLog(@"OnTimerDailyState");
	
	[self getDailyStat];
    [self setDailyStat];
    
}

#define kDailyStat  @"kDailyStat"

- (void) loadDailyStat
{
    strncpy(nowDate, [[self getNowYYYYMMDD] UTF8String], 9);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *str = (NSString*)[defaults stringForKey:kDailyStat];
	if (str)
    {
        NSArray *listItems = [str componentsSeparatedByString:@","];

        NSString *strDate = [listItems objectAtIndex:0];
        if ([strDate isEqualToString:[NSString stringWithUTF8String: nowDate]])
        {
            DLog(@"[listItems count] = %lu", (unsigned long)[listItems count]);
            int num=0;
            for (int j=0; j<GAMELEVEL_MAX; j++) {
                for (int i=0; i<SUDOKUTYPE_MAX; i++) {
                    if ([listItems count] > num+1)
                        if ([[listItems objectAtIndex:num+1] integerValue] == 1)
                            dailyStat[i][j].played = YES;
                        else
                            dailyStat[i][j].played = NO;
                    else
                        dailyStat[i][j].played = NO;
                    num++;
                }
            }
            return;
        }
    }
    // another day or 1st try or error
    
    for (int i=0; i<SUDOKUTYPE_MAX; i++)
        for (int j=0; j<GAMELEVEL_MAX; j++)
        dailyStat[i][j].played = NO;
    
    [self saveDailyStat];
}

- (void) saveDailyStat
{
    NSString *newNowDate = [self getNowYYYYMMDD];
    if ([newNowDate isEqualToString:[NSString stringWithUTF8String: nowDate]])
    {
        // 그사이에 날짜가 바뀌지 않았음
    } else {
        // 그사이에 날짜가 바뀌었음
        strncpy(nowDate, [newNowDate UTF8String], 9);
        for (int j=0; j<GAMELEVEL_MAX; j++)
            for (int i=0; i<SUDOKUTYPE_MAX; i++)
                dailyStat[i][j].played = NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* str = [NSString stringWithUTF8String: nowDate];
    for (int j=0; j<GAMELEVEL_MAX; j++) {
        for (int i=0; i<SUDOKUTYPE_MAX; i++) {
            str = [str stringByAppendingFormat:@",%d", dailyStat[i][j].played ? 1 : 0];
        }
    }
    
    [defaults setObject:str forKey:kDailyStat];
    [defaults synchronize];
}


- (void) readyToDownloadDailyPuzzle
{
    [self loadDailyStat];
    
    bReadyDownloadDailyPuzzle = NO;
//    [self setDailyStat];
    labelDailyStat.text = gettext(@"Connecting to a server", nil);
    
    // TOBE - indicator on earth
    timerNewGame = [NSTimer scheduledTimerWithTimeInterval:0
                                                    target:self
                                                  selector:@selector(OnTimerDailyState:)
                                                  userInfo:nil
                                                   repeats:NO];
    NSLog(@"nowDate=%s", nowDate);
    
}

- (void)OnTimerIndicatorNewGame:(NSTimer *)timer
{
    [activityIndicatorDailyStat stopAnimating];
    [activityIndicatorDailyGame stopAnimating];
}

- (void)OnTimerIndicatorDailyGame:(NSTimer *)timer
{
    [activityIndicatorDailyStat stopAnimating];
    [activityIndicatorDailyGame stopAnimating];
}



- (IBAction)showNewGame
{
    [NSTimer scheduledTimerWithTimeInterval:0
                                     target:self
                                   selector:@selector(OnTimerIndicatorNewGame:)
                                   userInfo:nil
                                    repeats:NO];

    [self setSudokuTypeSegment];
    
	[self allButtonUnLock];
	[self hideMenuView:YES];	// 메뉴가 사라지고, 새 게임 창이 뜬다.
	[self showNewGameDialog];
}

// 새 게임 창 (A478). 예전의 옆에서 미끄러져 나오는 viewNewGame(그림만 있는 종류 세그먼트 +
// 누르면 곧바로 시작하는 난이도 단추) 대신 가운데 창에서 종류 · 난이도를 고르고 [시작] 한다.
// 판 만들기는 예전 길(makeNewGame: · newgameUserInput) 그대로라 game_start(mode_id) 도 그대로 나간다.
// viewNewGame 은 xib 에 남아 있지만 더는 띄우지 않는다.
- (void) showNewGameDialog
{
	if (mainView.bMenuMode || self.presentedViewController)
		return;

	mainView.bMenuMode = YES;
	[self stopGameTimer];
	[self updateButtons];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    GAMELEVEL lastLevel = [defaults objectForKey:kSettingNewGameLevel]
        ? (GAMELEVEL)[defaults integerForKey:kSettingNewGameLevel] : GAMELEVEL_NORMAL;

    NewGameDialog *dlg = [[NewGameDialog alloc] initWithType:mainView.nSettingSudokuType
                                                       level:lastLevel
                                                    autoMemo:mainView.bSettingAutoMemo
                                                   canCancel:(mainView.sudokuGame != nil)];
    dlg.onStart = ^(SUDOKUTYPE type, GAMELEVEL level, BOOL autoMemo) {
        mainView.nSettingSudokuType = type;
        mainView.bSettingAutoMemo = autoMemo;
        [self saveSetting];
        [[NSUserDefaults standardUserDefaults] setInteger:level forKey:kSettingNewGameLevel];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self setSudokuTypeSegment];
        [self updateButtonMenu];
        [self allButtonUnLock];      // bMenuMode = NO
        if (level == GAMELEVEL_USERINPUT)
            [self newgameUserInput];
        else
            [self makeNewGame:level];
    };
    dlg.onCancel = ^{
        [self newgameCancel];
    };
#ifdef DEBUG
    if (DebugNewGameDialogOnLaunch()) dlg.debugSnapshotName = @"newgame_dialog.png";
#endif
    [self presentViewController:dlg animated:YES completion:nil];
    [dlg release];
}

// 데일리 퍼즐 창. 예전의 옆에서 미끄러져 나오는 viewDailyGame(종류 이름 5줄 × Easy · Hard 단추)
// 대신 새 게임 창과 같은 카드에서 종류 · 난이도(보통 · 매우 어려움)를 고르고 [시작] 한다.
// 단추 글자는 실제로 받는 판의 난이도다 — 예전 Easy 단추가 GAMELEVEL_NORMAL, Hard 가 GAMELEVEL_VERYHARD 였다.
// 판 받기는 예전 길(makeNewGameDailyPuzzle → makeNewGameDataFromServer → increaseScoreGames)
// 그대로라 game_start(mode_id=daily_<종류>_<난이도>) 도 그대로 나간다.
// 창이 뜬 뒤 서버 상태를 읽는다(readyToDownloadDailyPuzzle → setDailyStat 이 창에 알려 준다).
// viewDailyGame 은 xib 에 남아 있지만 더는 띄우지 않는다.
- (void) showDailyDialog
{
	if (mainView.bMenuMode || self.presentedViewController)
		return;

	mainView.bMenuMode = YES;
	[self stopGameTimer];
	[self updateButtons];
    [self loadDailyStat];

    GAMELEVEL lastLevel = (mainView.nSettingGameLevel == GAMELEVEL_VERYHARD) ? GAMELEVEL_VERYHARD : GAMELEVEL_NORMAL;
#ifdef DEBUG
    static BOOL debugStreakSeeded = NO;
    if (!debugStreakSeeded) { debugStreakSeeded = YES; DebugSeedStreakIfAsked([self getNowYYYYMMDD]); }
#endif
    NewGameDialog *dlg = [[NewGameDialog alloc] initDailyWithType:mainView.nSettingSudokuType
                                                            level:lastLevel
                                                         userName:[self getUserName]];
    dlg.streakToday = [self getNowYYYYMMDD];   // 연속 띠 (A468 R3)
    dlg.dailyPlayed = ^BOOL(SUDOKUTYPE t, GAMELEVEL l) {
        if (t < 0 || t >= SUDOKUTYPE_MAX || l < 0 || l >= GAMELEVEL_MAX) return NO;
#ifdef DEBUG
        // 촬영용 — 저장하지 않는다 (readyToDownloadDailyPuzzle 이 kDailyStat 을 다시 읽어도 남게 여기서)
        if (DebugDailyPlayedOnLaunch() &&
            (t == SUDOKUTYPE_SUDOKU || (t == SUDOKUTYPE_KILLER && l == GAMELEVEL_NORMAL))) return YES;
#endif
        return dailyStat[t][l].played;
    };
#if defined(DAILYSENDER) || defined(DEBUG)
    dlg.dailyAllowReplay = YES;     // 예전 setDailyButton: 과 같은 규칙
#endif
#ifdef DEBUG
    if (DebugDailyPlayedOnLaunch()) dlg.dailyAllowReplay = NO;
    if (DebugDailyDialogOnLaunch()) {
        dlg.debugSnapshotName = @"daily_dialog.png";
        dlg.debugSnapshotDelay = 3.0;   // 서버 상태를 받은 뒤에 찍는다
    }
#endif
    dlg.onStart = ^(SUDOKUTYPE type, GAMELEVEL level, BOOL autoMemo) {
        mainView.nSettingSudokuType = type;
        mainView.nSettingGameLevel = level;
        [self setSudokuTypeSegment];
        [self makeNewGameDailyPuzzle];   // 자동 메모는 여기서 끈다 (예전과 같음)
    };
    dlg.onCancel = ^{
        [self dailygameCancel];
        if (mainView.sudokuGame == nil)   // 하던 판이 없으면 메뉴로 (빈 화면에 남지 않게)
            [self showMenu];
    };
    dlg.onNickname = ^{
        [self changeNickName];
    };
    dlg.onRanking = ^{
        [self showRankView];
    };
    [self presentViewController:dlg animated:YES completion:^{
        [self readyToDownloadDailyPuzzle];   // 창이 뜬 뒤 서버를 읽는다 → setDailyStat 이 창에 알린다
    }];
    [dlg release];
}


// 첫 세션 안내 카드 (A468 R1, LEGACY_APPS_PLAN §1-3). 처음 설치 첫 실행에만 — init 이 gFirstSessionCardPending 을 켠다.
// 카드가 떠 있는 동안 시계는 멈춘다. 닫으면(시작하기 · 규칙을 알아요) 다시는 뜨지 않는다.
// 분석: tutorial_begin(mode_id) · tutorial_complete(how=start|skip). 첫 판의 game_start 는 from=first_session.
- (void) showFirstSessionCard
{
    if (mainView.sudokuGame == nil) return;
    [self stopGameTimer];
    GaLogEvent(@"tutorial_begin", @{ @"mode_id": GaModeId(mainView.sudokuGame) });
    FirstSessionCard *card = [[[FirstSessionCard alloc] initWithFirstLevelName:
                               gettext([SudokuGame getGameLevelNameNoop:mainView.sudokuGame.gameLevel], nil)] autorelease];
    card.onClose = ^(BOOL skipped) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstSessionCardDone];
        [[NSUserDefaults standardUserDefaults] synchronize];
        GaLogEvent(@"tutorial_complete", @{ @"how": skipped ? @"skip" : @"start" });
        if (!mainView.bMenuMode && mainView.sudokuGame && !mainView.sudokuGame.isGameFinished)
            [self startGameTimer];
#ifdef DEBUG
        if (DebugFirstSessionOnLaunch())
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                DebugSnapshotWindow(self.view.window, @"first_board.png");
            });
#endif
    };
    [card showInView:self.view];
#ifdef DEBUG
    if (DebugFirstSessionOnLaunch()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            DebugSnapshotWindow(self.view.window, @"first_session.png");
            if ([[NSProcessInfo processInfo].arguments containsObject:@"-DebugFirstSessionAutoStart"])
                [card performSelector:@selector(startTapped)];
        });
    }
#endif
}

- (IBAction)showDailyGame
{
    DLog(@"gUserName:%@", gUserName);
    BOOL needName = [gUserName isEqualToString:[NSString stringWithFormat:@"%d", (int)gUserID]] == YES ||
                    [gUserName length] < 1;
#ifdef DEBUG
    if (DebugDailyDialogOnLaunch()) needName = NO;   // 촬영용
#endif
    if (needName) {
        
        [self allButtonUnLock];
        [self hideMenuView:NO];	// 메뉴가 사라지고, newgame이 나온다.

        
        [self openChangeNickNameDialog];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0
                                         target:self
                                       selector:@selector(OnTimerIndicatorDailyGame:)
                                       userInfo:nil
                                        repeats:NO];
        
        [self allButtonUnLock];
        [self hideMenuView:YES];	// 메뉴가 사라지고, 데일리 퍼즐 창이 뜬다.
        [self showDailyDialog];     // 창이 뜬 뒤 readyToDownloadDailyPuzzle
    }
    
    
    
	
}


- (void) sendDailyPuzzle:(NSString*)puzzleDate
{
    char zStrMapNum[MAXMAPSIZE*MAXMAPSIZE+1] = "";
	char zStrPuzzleNum[MAXMAPSIZE*MAXMAPSIZE+1] = "";
	char zStrAnswerNum[MAXMAPSIZE*MAXMAPSIZE+1] = "";
    
    NSString *dataFile = [NSString stringWithFormat:@"%ld\n%d\n%d\n",
                          (long)mainView.sudokuGame.size,
                          mainView.sudokuGame.sudokuType,
                          mainView.sudokuGame.gameLevel];

    [SudokuGame get9x9Nums:zStrMapNum       size:mainView.sudokuGame.size   nums:[mainView.sudokuGame getMapNumsArray]];
	[SudokuGame get9x9Nums:zStrPuzzleNum	size:mainView.sudokuGame.size   nums:[mainView.sudokuGame getPuzzleNumsArray]];
	[SudokuGame get9x9Nums:zStrAnswerNum	size:mainView.sudokuGame.size   nums:[mainView.sudokuGame getAnswerNumsArray]];

    dataFile = [dataFile stringByAppendingFormat:@"%s\n%s\n%s\n",
                zStrMapNum,
                zStrPuzzleNum,
                zStrAnswerNum];
    
    if (mainView.sudokuGame.sudokuType == SUDOKUTYPE_KILLER || mainView.sudokuGame.sudokuType == SUDOKUTYPE_CALCU)
    {
        KillerMap *kMap = mainView.sudokuGame.kmap;
        
        char zStrMap[MAXMAPSIZE*MAXMAPSIZE*4+1] = "";
        char zStrColor[MAXMAPSIZE*MAXMAPSIZE*4+1] = "";
        char zStrCage[MAXMAPSIZE*MAXMAPSIZE*4] = "";
        
        [KillerMap getNumsPipeSize:zStrMap		size:MAXMAPSIZE*MAXMAPSIZE	nums:[kMap getMapArray]];
        [KillerMap getNumsPipeSize:zStrColor	size:MAXMAPSIZE*MAXMAPSIZE	nums:[kMap getColorArray]];
        [KillerMap getNumsPipe:zStrCage		size:[kMap getCageCount]*sizeof(KillerCage)/sizeof(NSInteger)
                                        nums:(NSInteger*)[kMap getCageArray]];
        
        dataFile = [dataFile stringByAppendingFormat:@"%s\n%s\n%s\n",
                    zStrMap,
                    zStrColor,
                    zStrCage];
    }
    
    NSString* strURI = [NSString stringWithFormat:
						@"act=%@&version=%d&cs=%ld&size=%d&type=%d&level=%d&date=%@&file=%@",
                        @"adddailypuzzle",
                        cProtocolVersion,
                        (long)[self getCheckSum],
                        DEFPUZZLESIZE,
                        //mainView.nSettingSudokuType,
                        mainView.sudokuGame.sudokuType,
                        mainView.sudokuGame.gameLevel,
                        puzzleDate,
                        [self urlEncodeValue:dataFile]];
    
    DLog(@"strURI=\n%@", strURI);
    
    
    NSString* strData = [self GetHTTPData:strURI	timeoutInterval:cDefaultHTTPTimeOut];
    
    if (strData)
        [strData release];

    return;
}


// deprecated zzzzzz
- (IBAction)newgameDailyPuzzle
{
#ifdef DAILYSENDER
    NSDate *date;
    NSDateComponents *com;
    NSDateFormatter *formatter;
    
    com = [[NSDateComponents alloc] init];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    
  
/*
    [self makeNewGame:GAMELEVEL_NORMAL];
    [NSThread sleepForTimeInterval:1];
    [self sendDailyPuzzle:@"20120212"];
*/

//    for (int j=2; j<SUDOKUTYPE_MAX; j++) {
        //[com setYear:2013];
        [com setYear:2019];
        [com setMonth:1];
        [com setDay:1];
        
        date = [[NSCalendar currentCalendar] dateFromComponents:com];
        
        for (int i=0; i<366; i++)
        {
            for (int j=SUDOKUTYPE_SUDOKU; j<SUDOKUTYPE_MAX; j++) {
                mainView.nSettingSudokuType = j;
                DLog(@"%@", [formatter stringFromDate:date]);
                [self makeNewGame:GAMELEVEL_VERYHARD];
//                [self makeNewGame:GAMELEVEL_NORMAL];
//              [NSThread sleepForTimeInterval:0.1];
                [self sendDailyPuzzle:[formatter stringFromDate:date]];
            }
            date = [date dateByAddingTimeInterval:60*60*24];    // add one day
        }
//    }
    
    [formatter release];
    
	[self hideNewGameView];
    
    
#else
	[self makeNewGameDailyPuzzle];
#endif
}


- (IBAction)newgameUserInput
{
    // only original is allowed
#ifdef USE_FLURRY
    [Flurry logEvent:@"GameLevel(user input try)"];
#endif
    [self makeNewGame:GAMELEVEL_USERINPUT];
    
    [self alertMessageOk:nil msg:gettext(@"Press start button after input puzzle numbers from newspapers and books.", nil)];

}

- (IBAction)newgameVeryEasy
{
	[self makeNewGame:GAMELEVEL_VERYEASY];

}

- (IBAction)newgameEasy
{
	[self makeNewGame:GAMELEVEL_EASY];

}

- (IBAction)newgameNormal
{
	[self makeNewGame:GAMELEVEL_NORMAL];

}

- (IBAction)newgameHard
{
	[self makeNewGame:GAMELEVEL_HARD];

}

- (IBAction)newgameVeryHard
{
	[self makeNewGame:GAMELEVEL_VERYHARD];

}


- (IBAction)newgameCancel
{
	// newgameview가 조용히 물러난다.
	[self hideNewGameView];
    [self startGameTimer];
}

- (IBAction)dailygameCancel
{
	// newgameview가 조용히 물러난다.
	[self hideDailyGameView];
    [self startGameTimer];
}


- (void) alertNameIsTooShort
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:gettext(@"Alert", nil)
                                  message:gettext(@"Name is too short!", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:gettext(@"Ok", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self openChangeNickNameDialog];
                             
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void) openChangeNickNameDialog
{
#ifdef USE_FLURRY
    [Flurry logEvent:@"ChangeNickNameDialog open"];
#endif
    [self stopGameTimer];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:gettext(@"Please input your nickname", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:gettext(@"Save", nil) style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   UITextField *login = alert.textFields.firstObject;
                                                   NSString *newName = login.text;
                                                   if ([newName length] < MIN_NAME) {
                                                       // Warning
                                                       [self alertNameIsTooShort];
                                                   } else {
                                                       [self setUserName:newName];
                                                       //gUserName = newName;
                                                       [self saveServerData];
                                                       [self DoneQuest:eQuestChangeName];
                                                       [self startGameTimer];
                                                   }
                                               }];
    [alert addAction:ok];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:gettext(@"Cancel", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                             }];
    [alert addAction:cancel];

    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [self getUserName];
    }];
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)changeNickName
{
    [self openChangeNickNameDialog];
    [self hideDailyGameView];
    [self startGameTimer];
}



- (IBAction)changeAutoMemo
{
	mainView.bSettingAutoMemo = !mainView.bSettingAutoMemo;
	[self updateButtonMenu];
	
	[self saveSetting];
}

- (IBAction)changeDailyAutoMemo
{
	mainView.bSettingAutoMemo = !mainView.bSettingAutoMemo;
	[self updateButtonMenu];
	
	[self saveSetting];
}


- (IBAction)setSudokuType
{
    mainView.nSettingSudokuType = (SUDOKUTYPE)[segmentType selectedSegmentIndex];
    labelSudokuType.text = [SudokuGame getSudokuTypeName:mainView.nSettingSudokuType];
//    [self setDailyStat];
    
    [self setButtonMode:buttonNewGameUserInput mode:mainView.nSettingSudokuType == SUDOKUTYPE_SUDOKU];
    
	[self saveSetting];
}

- (void) setSudokuTypeSegment
{
    segmentType.selectedSegmentIndex = mainView.nSettingSudokuType;
    labelSudokuType.text = [SudokuGame getSudokuTypeName:mainView.nSettingSudokuType];

}


- (IBAction)dailygameSudoku
{
    mainView.nSettingSudokuType = SUDOKUTYPE_SUDOKU;
    mainView.nSettingGameLevel = GAMELEVEL_NORMAL;
    [self makeNewGameDailyPuzzle];
}

- (IBAction)dailygameGt
{
    mainView.nSettingSudokuType = SUDOKUTYPE_GT;
    mainView.nSettingGameLevel = GAMELEVEL_NORMAL;
    [self makeNewGameDailyPuzzle];
}

- (IBAction)dailygameKiller
{
    mainView.nSettingSudokuType = SUDOKUTYPE_KILLER;
    mainView.nSettingGameLevel = GAMELEVEL_NORMAL;
    [self makeNewGameDailyPuzzle];

}

- (IBAction)dailygameCalcudoku
{
    mainView.nSettingSudokuType = SUDOKUTYPE_CALCU;
    mainView.nSettingGameLevel = GAMELEVEL_NORMAL;
    [self makeNewGameDailyPuzzle];
}

- (IBAction)dailygameSymbolSudoku
{
    mainView.nSettingSudokuType = SUDOKUTYPE_SYMBOL;
    mainView.nSettingGameLevel = GAMELEVEL_NORMAL;
    [self makeNewGameDailyPuzzle];
}

- (IBAction)dailygameSudoku0
{
    mainView.nSettingSudokuType = SUDOKUTYPE_SUDOKU;
    mainView.nSettingGameLevel = GAMELEVEL_VERYHARD;
    [self makeNewGameDailyPuzzle];
}

- (IBAction)dailygameGt0
{
    mainView.nSettingSudokuType = SUDOKUTYPE_GT;
    mainView.nSettingGameLevel = GAMELEVEL_VERYHARD;
    [self makeNewGameDailyPuzzle];
}

- (IBAction)dailygameKiller0
{
    mainView.nSettingSudokuType = SUDOKUTYPE_KILLER;
    mainView.nSettingGameLevel = GAMELEVEL_VERYHARD;
    [self makeNewGameDailyPuzzle];
    
}

- (IBAction)dailygameCalcudoku0
{
    mainView.nSettingSudokuType = SUDOKUTYPE_CALCU;
    mainView.nSettingGameLevel = GAMELEVEL_VERYHARD;
    [self makeNewGameDailyPuzzle];
}

- (IBAction)dailygameSymbolSudoku0
{
    mainView.nSettingSudokuType = SUDOKUTYPE_SYMBOL;
    mainView.nSettingGameLevel = GAMELEVEL_VERYHARD;
    [self makeNewGameDailyPuzzle];
}



- (void) startGameTimer
{
    if (mainView.sudokuGame.isGameFinished)
        return;
    // More Games 화면이 떠 있는 동안(앱 복귀 등)에는 돌리지 않는다. 닫힐 때 showMoreGames 가 되살린다.
    if ([MoreGamesViewController isShowing])
        return;
    
	if ([timerGame isValid])
	{
		//DAssert(0, @"Duplicated game timer");
		return;
	}
	timerGame = [NSTimer scheduledTimerWithTimeInterval:1 
												 target:self
											   selector:@selector(OnTimer:)
											   userInfo:nil
												repeats:YES];
}

- (void) stopGameTimer
{
	if ([timerGame isValid])
	{
		[timerGame invalidate];
		timerGame = nil;
	}
}



- (void) OnTimer:(NSTimer *)timer
{
	if (!mainView.sudokuGame)
		return;
	
	NSInteger time;
	
    if (bAd == NO)      // 광고를 보는 동안에는 게임 시간이 멈춘다.
    {
        time = [mainView.sudokuGame updateGameElapsedTime];
        [self updateGameTime:time];
        
        if (!mainView.sudokuGame.isGameFinished) {
            score.spendTotalSec++;
            [self saveTotalSecData];
        }
        
    }
    
    // 광고를 보는 동안에도 힌트 타이머는 계속 간다.
	time = [mainView.sudokuGame updateHintElapsedTime];
	[self updateHintCount];
	
	if (time <= 0)
	{
		[mainView.sudokuGame resetHintTime];
        [[GKAchievementHandler defaultHandler]
         notifyAchievementTitle:gettext(@"Bonus item", nil)
         andMessage:gettext(@"You got 1 hint.", nil)];

	}
    
    // 시계를 표시한다.
    [self updateClockTime];
    

	
}

- (void) updateBlankCellCount
{
	if (!mainView.sudokuGame)
		return;
	
	NSInteger count = [mainView.sudokuGame countBlankCells];
	NSString *str;
	str = [NSString stringWithFormat:@"%ld", (long)count];
	
	labelBlank.text =str;
}



- (void) updateHintCount
{
	if (!mainView.sudokuGame)
		return;
	
	NSInteger count = mainView.sudokuGame.countHint + mainView.paidHintCount;
//	NSInteger time = (NSInteger)mainView.sudokuGame.hintTime;
    
	labelHint.text =[NSString stringWithFormat:@"%ld", (long)count];
    
    // zzz 유료 힌트 +00 표시 
    
//	labelHint.text =[NSString stringWithFormat:@"%d(%d:%02d)", count, time/60, time%60];


}


- (void) updateButtonClear
{
	BOOL bLock = (!mainView.sudokuGame || (mainView.sudokuGame && mainView.sudokuGame.isGameFinished));
    NSInteger count = 0;
    
    if (mainView.sudokuGame)
        count = [mainView.sudokuGame countFixCells];

    [self setButtonMode:buttonReset mode:(count > 0 && bLock == NO)];
	
}

- (void) updateButtonSharePuzzle
{
    BOOL bLock = (!mainView.sudokuGame || (mainView.sudokuGame.gameLevel == GAMELEVEL_USERINPUT && mainView.sudokuGame.bUserInputStart == NO));
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        bLock = YES;
    }
    
    [self setButtonMode:buttonSharePuzzle mode:(bLock == NO)];
    
}


- (void) updateButtonDel
{
	BOOL bLock = mainView.bMenuMode || (mainView.sudokuGame && mainView.sudokuGame.isGameFinished);

    [self setButtonMode:buttonDel mode:!bLock && [mainView isSelectedCellisFixed]];
/*
	if ([mainView isSelectedCellisFixed])	{
		buttonDel.alpha = 1.0f;
		buttonDel.enabled = bLock ? NO : YES;
	} else {
		buttonDel.alpha = 0.5f;
		buttonDel.enabled = NO;		
	}
 */
}



- (void) updateButtonHint	// TODO     Hint 아이템이 남아있고 힌트 가능한 셀일경우 On;
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
	BOOL bLock = mainView.bMenuMode ||
                (mainView.sudokuGame && mainView.sudokuGame.isGameFinished) ||
                (mainView.sudokuGame && mainView.sudokuGame.gameLevel == GAMELEVEL_USERINPUT);    
    
    if (bBuyingHint50) {
        buttonHint.alpha = 1.0f;
        buttonHint.enabled = NO;
        [buttonHint	setTitle:gettext(@"buying", nil) forState:UIControlStateNormal];
        return;
    }
    
    if (
#ifndef BUYHINTTEST
        [mainView.sudokuGame countHint] + mainView.paidHintCount == 0 &&
#endif
        productHint50)
    {
        buttonHint.alpha = 1.0f;
        buttonHint.enabled = bLock ? NO : YES;
        [buttonHint	setTitle:gettext(@"buy hint", nil) forState:UIControlStateNormal];
    } else if ([mainView isSelectedCellisableHint]) {
        buttonHint.alpha = 1.0f;
        buttonHint.enabled = bLock ? NO : YES;
        if ([mainView.sudokuGame countHint] + mainView.paidHintCount > 0) {		// 아직 Hint item이 남아 있다.
            [buttonHint	setTitle:gettext(@"hint", nil) forState:UIControlStateNormal];
        } else {
            buttonHint.alpha = 0.3f;
            buttonHint.enabled = NO;
        }
	} else {
		buttonHint.alpha = 0.3f;
		buttonHint.enabled = NO;		
	}
    });
}

- (void) updateButtonMenu
{
	// 메뉴는 항상 눌릴 수 있어야 한다. -  안된다. new game 창에서 menu가 나온다.
	buttonMenu.enabled = mainView.bMenuMode ? NO : YES;
	
	if (mainView.bSettingAutoMemo) {
		[buttonCheckboxAutoMemo setBackgroundImage:[UIImage imageNamed:@"checkbox_c.png"] forState:UIControlStateNormal];
//		[buttonDailyCheckboxAutoMemo setBackgroundImage:[UIImage imageNamed:@"checkbox_c.png"] forState:UIControlStateNormal];
	} else {
		[buttonCheckboxAutoMemo setBackgroundImage:[UIImage imageNamed:@"checkbox_u.png"] forState:UIControlStateNormal];
//		[buttonDailyCheckboxAutoMemo setBackgroundImage:[UIImage imageNamed:@"checkbox_u.png"] forState:UIControlStateNormal];
    }
}


- (NSInteger) getBestTime:(NSInteger)level
{
    return score.scoreBestTime[mainView.sudokuGame.sudokuType][level];
}

- (NSInteger) getTotalScore
{
    DLog(@"getTotalScore -> %d", (int)score.scoreTotal);
    return score.scoreTotal;
}

static NSInteger LEVELSCORE[] = {
    100,        // 1    토끼
    300,        // 2    팬더
    1000,       // 3    사슴
    3000,       // 4    늑대
    10000,      // 5    돌고래
    30000,      // 6    낙타
    100000,     // 7    곰
    300000,     // 8    코뿔소
    1000000,    // 9    코끼리
    3000000,    // 10   드래곤
    -1
};

- (NSInteger) getMyLevel
{
    NSInteger level = 1;    // max 10
    NSInteger myScore = [self getTotalScore];
    
    
    for (int i=0; LEVELSCORE[i] > 0; i++)
    {
        if (myScore >= LEVELSCORE[i])
            level = i+1;
        else
            break;
    }
    if (level > 10)
        level = 10;
    
    return level;
}


- (void) updateButtonFinishGame
{
    BOOL bHiddenButton = !mainView.sudokuGame.isGameFinished || bReplay || mainView.sudokuGame.isCloseButton;
    BOOL bEnable = mainView.bMenuMode ? NO : YES;
    
    
    buttonCloseButton.hidden = bHiddenButton;
    buttonCloseButton.enabled = bEnable;
    buttonPlayNew.hidden = bHiddenButton;
    buttonPlayNew.enabled = bEnable;
    if (bHiddenButton == YES) {
        buttonPlayAgain.hidden = YES;
    } else {
        buttonPlayAgain.hidden = NO;
        buttonPlayAgain.enabled = bEnable;
        if (mainView.sudokuGame.bDailyPuzzle) {
            [buttonPlayAgain setTitle:[@"    " stringByAppendingString:gettext(@"Check ranking", nil)] forState:UIControlStateNormal];
            [buttonPlayAgain setBackgroundImage:[UIImage imageNamed:@"button_big_ranking.png"] forState:UIControlStateNormal];
            [buttonPlayAgain setBackgroundImage:[UIImage imageNamed:@"button_big_ranking.png"] forState:UIControlStateHighlighted];

        } else {
            [buttonPlayAgain setTitle:[@"    " stringByAppendingString:gettext(@"Play again", nil)] forState:UIControlStateNormal];
            [buttonPlayAgain setBackgroundImage:[UIImage imageNamed:@"button_big_playagain.png"] forState:UIControlStateNormal];
            [buttonPlayAgain setBackgroundImage:[UIImage imageNamed:@"button_big_playagain.png"] forState:UIControlStateHighlighted];
        }
    }
    buttonSeeReplay.hidden = bHiddenButton;
    buttonSeeReplay.enabled = bEnable;
    
    buttonPuzzleShare.hidden = bHiddenButton;
    buttonPuzzleShare.enabled = bEnable;
    buttonRecordShare.hidden = bHiddenButton;
    buttonRecordShare.enabled = bEnable;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        buttonPuzzleShare.enabled = NO;
        buttonRecordShare.enabled = NO;
    }
}

- (void) updateButtons
{
    [self updateBlankCellCount];
    [self updateHintCount];
    
	[self updateButtonMenu];
	[self updateButtonHint];
    [self updateButtonClear];
    [self updateButtonSharePuzzle];
	[self updateButtonUndo];
	[self updateButtonBookmark];
	[self updateButtonDel];
	[self updateButtonMemo];
    [self updateButtonFinishGame];
}

- (BOOL) isReplaying
{
    return bReplay;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{ 
	//DLog(@"willRotateToInterfaceOrientation toInterfaceOrientation = %d duration = %f", toInterfaceOrientation, duration);
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
#ifdef ADMOB_FREEVERSION
    if (bNoAd == NO) {
        if (adMobBanner)
            adMobBanner.hidden = YES;
    }
#endif
	[self readySlideView:viewMenu];
	[self readySlideView:viewNewGame];
	[self readySlideView:viewDailyGame];
	[self updateButtons];
	[mainView setBlur:NO];
	

	

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
#ifdef ADMOB_FREEVERSION
    if (bNoAd == NO) {
        if (adMobBanner) {
            adMobBanner.frame = areaAdBanner.frame;
            adMobBanner.hidden = NO;
        }
    }
#endif

    [mainView setNeedsDisplay];
    [self startGameTimer];

}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotate
{
    return SUPPORT_ROTATION;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{

    
    if (SUPPORT_ROTATION)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (SUPPORT_ROTATION)
        return YES;
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




- (IBAction)LeftSwipe:(id)sender
{
    DLog(@"handleLeftSwipe called");
    
}

#ifdef USE_JMC
- (NSString *)jiraIssueTypeNameFor:(JMCIssueType)type
{
    if (type == JMCIssueTypeCrash) {
        return @"Bug";
    } else if (type == JMCIssueTypeFeedback) {
        return @"Improvement";
    }
    return nil;
}
#endif

/*

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    
    [super presentViewController:self animated:flag completion:completion];
    
}
*/


#ifdef LOCATIONTRACK

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location is changed");
    
    currentLatitude = newLocation.coordinate.latitude;
    currentLongtitude = newLocation.coordinate.longitude;
    
    [locationManager stopUpdatingLocation];
}
#endif

#pragma mark - SKPaymentTransactionObserver Protocol

- (void)successBuyHint50
{
    bBuyingHint50 = NO;
    mainView.paidHintCount += countHint50;
    
    [self updateButtonHint];
    [self updateHintCount];
    
    [self saveSetting];
    
    // 성공 메시지
    [self alertMessageOk:gettext(@"Information", nil) msg:gettext(@"Ok", nil)];
    [self startGameTimer];

}

- (void)failedBuyHint50:(NSString*)message;
{
    bBuyingHint50 = NO;
    [self updateButtonHint];
    [self updateHintCount];
    NSString *msg = [NSString stringWithFormat:@"%@\n%@", gettext(@"Failed to buy hint item.", nil), message];

    // 실패 메시지
    // 성공 메시지
    [self alertMessageOk:gettext(@"Information", nil) msg:msg];    
    [self startGameTimer];
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        NSLog(@"transaction.transactionState=%d", (int)transaction.transactionState);
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                // 구매 처리
                [self successBuyHint50];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Error:%d:%@", (int)[transaction.error code], transaction.error.localizedDescription);
                [self failedTransaction:transaction];
                // 실패 처리
                [self failedBuyHint50:transaction.error.localizedDescription];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"SKPaymentTransactionStateRestored");
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"SKPaymentTransactionStateFailed");
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	NSLog(@"SKPaymentTransactionStatePurchased");
    
	NSLog(@"Trasaction Identifier : %@", transaction.transactionIdentifier);
	NSLog(@"Trasaction Date : %@", transaction.transactionDate);
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	NSLog(@"SKProductRequest got response");
	if( [response.products count] > 0 ) {
		SKProduct *product = [response.products objectAtIndex:0];
		NSLog(@"Title : %@", product.localizedTitle);
		NSLog(@"Description : %@", product.localizedDescription);
		NSLog(@"Price : %@", product.price);
        
        productHint50 = product;
        [productHint50 retain];
        
        [self updateButtonHint];
	}
	
	if( [response.invalidProductIdentifiers count] > 0 ) {
		NSString *invalidString = [response.invalidProductIdentifiers objectAtIndex:0];
		NSLog(@"Invalid Identifiers : %@", invalidString);
	}
}

#pragma mark - Alert
/*
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = alert.title;
    NSString *message = alert.message;
    
    if([title isEqualToString:gettext(@"Congratulations!", nil)]) {
#ifdef ADMOB_FREEVERSION
        if (self.interstitial != nil && bNoAd == NO)
            [self showInterstitial];
#endif
    } else if([message isEqualToString:gettext(@"Please input your nickname", nil)]) {
        
        NSString *newName = [[[alert textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([newName length] < MIN_NAME) {
#ifdef USE_FLURRY
            [Flurry logEvent:@"ChangeNickNameDialog Short Name"];
#endif
            // Warning
            [self alertLocalizedAlertView:@"Name is too short!"];
        } else {
            [self setUserName:newName];
            //gUserName = newName;
            [self saveServerData];
            [self DoneQuest:eQuestChangeName];
        }
        
    } else if([message isEqualToString:gettext(@"Name is too short!", nil)]) {
        [self openChangeNickNameDialog];
    } else //if([title isEqualToString:@"Button 2"])
    {
        if (buttonIndex == 1) // "확인" 버튼, TODO 확인 필요
        {
            SKPayment *payment = [SKPayment paymentWithProduct:productHint50];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            NSLog(@"");
            
            [self updateButtonHint];
        } else {
            // do nothing
        }
    }

    
}
*/

- (void) logEventParam:(NSString*)event
{
#ifdef USE_FLURRY
    [Flurry logEvent:event];
#endif
    /*
    NSLocale *locale = [NSLocale currentLocale];
    NSString *languageCode = [locale objectForKey: NSLocaleLanguageCode];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];

    NSDictionary *params =
    [NSDictionary dictionaryWithObjectsAndKeys:
        @"UserID", [NSNumber numberWithInt:(int)gUserID],
        @"UserName", gUserName,
        @"Locale", locale,
        @"Language", languageCode,
        @"Country", countryCode,
        nil];

    

    
    
    [Flurry logEvent:event withParameters:params];
     */
}



#ifdef ADMOB_FREEVERSION



#pragma mark GADBannerViewDelegate implementation

static const NSTimeInterval kBannerBackoffSec[] = { 10, 30, 90 };
#define BANNER_BACKOFF_COUNT    3


- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView
{
    DLog(@"adViewDidReceiveAd:%@", bannerView.description);
    
    gAdmobFailCount = 0;
    [self logEventParam:@"2 Admob banner load success"];
    gAdState[eAdStateAdmobBanner].show += 1;
    [self saveAdState];
}

- (void) OnTimerGADRequestAgain:(NSTimer *)timer
{
    DLog(@"OnTimerGADRequestAgain");
    bannerRetryTimer = nil;
    [self requestGADagain];
}
- (void)bannerView:(GADBannerView *)view didFailToReceiveAdWithError:(NSError *)error
{
    DLog(@"adView didFailToReceiveAdWithError:%@, %@", [error localizedDescription], error);
    [self logEventParam:@"2 Admob banner load fail"];
    //NSString *str = [NSString stringWithFormat:@"2 Admob banner load fail:%@", [error localizedDescription]];
    //[self logEventParam:str];

    gAdState[eAdStateAdmobBanner].fail += 1;
    if (gAdState[eAdStateAdmobBanner].lasterror)
        [gAdState[eAdStateAdmobBanner].lasterror release];
    gAdState[eAdStateAdmobBanner].lasterror = [[NSString alloc] initWithFormat:@"%@:%@", [self getNowYYYYMMDD], [error localizedDescription]];
    [self saveAdState];

    
    if (bNoAd) {
        DLog(@"No Ad");
        [self logEventParam:@"2 Admob banner load fail:No Ad"];
        return;
    }
    
    gAdmobFailCount++;
    [self gaAdResult:kGaPlacementBanner
             outcome:(GaIsOfflineError(error) ? kGaOutcomeOffline : kGaOutcomeUnavailable)
              cached:NO waitMs:0 error:error];
    // 예전에는 10초 고정으로 끝없이 다시 받았다 (A463). 지금은 10 · 30 · 90초
    // 뒤 다시 받고 쉰다. 쉬는 것은 앱 복귀(wakeBannerIfResting)가 깨운다.
    // 받으면 gAdmobFailCount 가 0 으로 돌아가고 SDK 자동 새로고침에 맡긴다.
    if (bannerRetryTimer) return;   // 이미 대기 중 — 사슬을 둘로 만들지 않는다
    if (gAdmobFailCount > BANNER_BACKOFF_COUNT) {
        DLog(@"[ad] banner load fail #%d (%ld) — resting", (int)gAdmobFailCount, (long)error.code);
        return;
    }
    NSTimeInterval d = kBannerBackoffSec[gAdmobFailCount - 1];
    DLog(@"[ad] banner load fail #%d (%ld) — retry in %.0fs", (int)gAdmobFailCount, (long)error.code, d);
    bannerRetryTimer = [NSTimer scheduledTimerWithTimeInterval:d
                                                        target:self
                                                      selector:@selector(OnTimerGADRequestAgain:)
                                                      userInfo:nil
                                                       repeats:NO];
}

// 앱 복귀: 백오프를 다 쓰고 쉬던 배너를 다시 받는다.
- (void) wakeBannerIfResting
{
    if (bNoAd || adMobBanner == nil || bannerRetryTimer) return;
    if (gAdmobFailCount <= BANNER_BACKOFF_COUNT) return;   // 쉬는 중이 아니다
    DLog(@"[ad] foreground: wake banner (fails=%d)", (int)gAdmobFailCount);
    gAdmobFailCount = 0;
    [self requestGADagain];
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView
{
    bAd = YES;
    [mainView.sudokuGame bonusGameElapsedTime];
    //[mainView.sudokuGame bonusHintElapsedTime];
    [self updateGameTime:mainView.sudokuGame.gameTime];
    [self updateHintCount];
    
    //[self stopGameTimer];
    
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView
{
    bAd = NO;
    //[self startGameTimer];
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView
{
    [mainView setNeedsDisplay];
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView
{
    // 예전 adViewWillLeaveApplication: 자리다. 그 콜백은 SDK 에서 사라졌고,
    // 클릭 자체는 이 메서드로 온다 (앱을 떠나지 않아도 불린다).
    [self logEventParam:@"2 Admob banner click"];
    // Click Ads
    //[self isInterstitialShowTurn:0 set:(-1) * gBonus];
   /* [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(OnTimerconnectToServerInit:)
                                   userInfo:nil
                                    repeats:NO];*/
    
}

#endif // ADMOB_FREEVERSION

#pragma mark GADRequest implementation

- (GADRequest *)request {
    // 테스트 기기 지정은 **요청이 아니라 전역 설정**으로 옮겨졌다:
    //   GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers
    // 시뮬레이터는 따로 등록하지 않아도 자동으로 테스트 기기다.
    return [GADRequest request];
}


#define kINTERSTITIALSHOWTIME   @"kINTERSTITIALSHOWTIME"
#define kINTERSTITIALLASTTIME   @"kINTERSTITIALSLASTTIME"

- (NSInteger) loadInterstitialShowTurn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults integerForKey:kINTERSTITIALSHOWTIME];
}

- (NSInteger) loadInterstitialShowLastTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kINTERSTITIALLASTTIME]) {
        return [defaults integerForKey:kINTERSTITIALLASTTIME];
    } else {
        return [self saveInterstitialLastTimeNow];
    }
}

- (void) saveInterstitialShowTurn:(NSInteger) turn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:turn forKey:kINTERSTITIALSHOWTIME];
    [defaults synchronize];
}

- (NSInteger) saveInterstitialLastTimeNow
{
    NSInteger timestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:timestamp    forKey:kINTERSTITIALLASTTIME];
    [defaults synchronize];
    
    return timestamp;
}


- (BOOL) isInterstitialShowTurn:(NSInteger)delta set:(NSInteger)set
{
    //if (bNoAd) {
        //bLoadInterstitialAds = NO;
        //return NO;  // 영원히 광고를 출력하지 않는다.
    //}
    if (gInterval < 0) {
        bLoadInterstitialAds = NO;
        return NO;  // 광고를 출력하지 않는다.
    }
    static NSInteger iTurn = 0;
    NSInteger iLastTime = [self loadInterstitialShowLastTime];
    static BOOL isFirst = YES;
    BOOL bRet = NO;
    if (isFirst) {
        iTurn = [self loadInterstitialShowTurn];
        isFirst = NO;
    }
    if (delta == 0) { // set to (set)
        iTurn = set;
    } else {
        iTurn += delta;
        
        NSInteger times = gInterval + (((unsigned int)arc4random()) % (gRandom+1));
        DLog(@"iTurn=%d, times=%d", (int)iTurn, (int)times);
        if (iTurn >= times) {
            bRet = YES;
        }
        
        NSInteger timestamp = (NSInteger) [[NSDate date] timeIntervalSince1970];
        DLog(@"timestamp=%d, iLastTime=%d, (%d), gIntervalSec=%d", (int)timestamp, (int)iLastTime, (int)(timestamp - iLastTime), (int)gIntervalSec);
        if (timestamp - iLastTime >= gIntervalSec) {
            bRet = YES;
        }        
    }
    [self saveInterstitialShowTurn:iTurn];
    
    DLog(@"iTurn=%d", (int)iTurn);
    bLoadInterstitialAds = bRet;
    
    return bRet;
}

- (BOOL) loadInterstitial {
    // Check, is this turn is ad turn
    
    if (self.interstitial) {
        // [크래시 수정] MRC 환경에서 interstitial 프로퍼티는 strong(retain)이다.
        // 기존에는 [self.interstitial release] 를 직접 호출한 뒤 self.interstitial = nil 을 실행했는데,
        // nil 세터가 이미 해제된 객체를 한 번 더 release 하여 이중 해제(EXC_BAD_ACCESS)가 발생했다.
        // 세터가 release 를 대신 수행하므로 nil 대입만 한다.
        self.interstitial = nil;
    }
    
    if ([self isInterstitialShowTurn:1 set:0] == NO) {
        DLog(@"Don't show Interstitial Ads.");
        return NO;  // don't show ads
    }
    DLog(@"Show Interstitial Ads.");
    
    // Show ads only every 3 times
    
    
    // GADInterstitial 은 8.0 에서 사라졌다. 이제는 클래스 메서드로 읽고
    // 결과가 **콜백으로** 온다 — 예전 interstitialDidReceiveAd: 와
    // interstitial:didFailToReceiveAdWithError: 가 이 블록 안으로 들어왔다.
    self.interstitial = nil;
    interstitialLoadStart = CFAbsoluteTimeGetCurrent();
    [GADInterstitialAd loadWithAdUnitID:MY_INTERSTITIAL_UNIT_ID
                                request:[self request]
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
            [self logEventParam:@"2 Admob interstitial load fail"];
            [self gaAdResult:kGaPlacementInterstitial
                     outcome:(GaIsOfflineError(error) ? kGaOutcomeOffline : kGaOutcomeUnavailable)
                      cached:NO waitMs:[self msSince:interstitialLoadStart] error:error];
            DLog(@"interstitial load fail:%@", [error localizedDescription]);

            gAdState[eAdStateAdmobInterstitial].fail += 1;
            if (gAdState[eAdStateAdmobInterstitial].lasterror)
                [gAdState[eAdStateAdmobInterstitial].lasterror release];
            gAdState[eAdStateAdmobInterstitial].lasterror =
                [[NSString alloc] initWithFormat:@"%@:%@",
                 [self getNowYYYYMMDD], [error localizedDescription]];
            [self saveAdState];

            [self alertFinish];
            return;
        }

        DLog(@"interstitial loaded:%@", ad.description);
        self.interstitial = ad;
        ad.fullScreenContentDelegate = self;

        [self isInterstitialShowTurn:0 set:0];
        [self saveInterstitialLastTimeNow];
        [self logEventParam:@"2 Admob interstitial load success"];

        gAdState[eAdStateAdmobInterstitial].show += 1;
        [self saveAdState];

        [self alertFinish];
    }];

    return YES;
}

- (void) showInterstitial {

    // Show the interstitial.
    [self.interstitial presentFromRootViewController:self];
}

#pragma mark GADFullScreenContentDelegate implementation

// 전면광고와 보상형 광고가 **같은 delegate** 를 쓴다. 예전에는
// GADInterstitialDelegate 와 GADRewardBasedVideoAdDelegate 로 갈려 있었다.
// 어느 쪽인지는 전달된 ad 의 클래스로 가른다.

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    DLog(@"adWillPresentFullScreenContent");
    if ([ad isKindOfClass:[GADRewardedAd class]]) {
        bReadyHintRewardVideo = NO;
    } else {
        // 전면은 「보여 줬다」가 성공이다 (Flutter 6앱과 같은 규칙).
        [self gaAdResult:kGaPlacementInterstitial outcome:kGaOutcomeEarned cached:NO
                  waitMs:[self msSince:interstitialLoadStart] error:nil];
    }
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    DLog(@"adDidDismissFullScreenContent");
    if ([ad isKindOfClass:[GADRewardedAd class]]) {
        // 보상 전에 닫았으면 dismissed (보상 뒤면 이미 earned 로 보냈다).
        [self finishHintAttempt:kGaOutcomeDismissed error:nil];
        // 보상형은 한 번 쓰면 끝이다. 다음 것을 미리 읽어 둔다.
        [self startGameTimer];
        [self loadHintRewardedAd];
    } else {
        self.interstitial = nil;
    }
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(NSError *)error
{
    DLog(@"didFailToPresentFullScreenContent:%@", [error localizedDescription]);
    if ([ad isKindOfClass:[GADRewardedAd class]]) {
        bReadyHintRewardVideo = NO;
        // 보여 주지 못했으니 광고 없음과 같다 (Flutter 와 같다). 표시 오류는 망 오류로 보지 않는다.
        [self grantFreeOrDecline:error showFailed:YES];
        [self startGameTimer];
        [self loadHintRewardedAd];
    } else {
        [self gaAdResult:kGaPlacementInterstitial outcome:kGaOutcomeUnavailable cached:NO
                  waitMs:[self msSince:interstitialLoadStart] error:error];
        self.interstitial = nil;
    }
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
    // 예전 interstitialWillLeaveApplication: 자리다.
    if (![ad isKindOfClass:[GADRewardedAd class]]) {
        [self logEventParam:@"2 Admob interstitial click"];
    }
}

#pragma mark 보상형 광고

// 예전 GADRewardBasedVideoAd 는 싱글턴이라 [sharedInstance loadRequest:...]
// 한 줄이면 됐다. 지금은 인스턴스라 읽어서 들고 있어야 하고, 한 번 보여 준
// 광고는 버리고 다시 읽어야 한다.
//
// **힌트 유닛 하나만 읽는다.** 예전 코드는 HINT 와 CALCCANDI 를 연달아
// 싱글턴에 밀어 넣었는데, 그러면 뒤엣것이 앞엣것을 덮어써서 실제로는 하나만
// 살아 있었다. 지금 화면에서 쓰는 곳도 힌트뿐이다.
// 받기 (A463) — Flutter 6앱의 AdSlot(tenten lib/ads/ad_slot.dart)과 같은 규칙:
//  - 받아 둔 게 있거나 · 받는 중이거나 · 백오프 대기 중이면 새로 요청하지 않는다.
//  - 실패하면 2 · 8 · 30초 뒤 다시 받고, 세 번 뒤에는 **쉰다.** 받으면 카운터 0.
//  - 쉬는 받기는 앱 복귀(adsDidBecomeActive)와 힌트 누름이 깨운다.
// 예전에는 실패하면 return 만 해서, 시작 때 한 번 실패하면 다음 앱 시작까지
// 보상형이 없었다.
static const NSTimeInterval kAdBackoffSec[] = { 2, 8, 30 };
#define AD_BACKOFF_COUNT    3
#define HINT_WAIT_SEC       8.0     // 누른 자리에서 기다리는 상한
#define HINT_WAIT_ATTEMPTS  3       // 누른 자리에서 새로 내는 요청 상한

- (BOOL) hintRewardedResting
{
    return !bHintLoading && hintRetryTimer == nil && self.hintRewardedAd == nil
        && hintLoadFails > AD_BACKOFF_COUNT;
}

// 「받아 두기」. 이미 있거나 · 받는 중이거나 · 대기 중이거나 · 쉬는 중이면 아무것도 안 한다.
- (void) loadHintRewardedAd
{
    if (self.hintRewardedAd || bHintLoading || hintRetryTimer) return;
    if ([self hintRewardedResting]) {
        DLog(@"[ad] rewarded: resting after %d fails — wakes on foreground or tap", (int)hintLoadFails);
        return;
    }
    [self requestHintRewardedAd];
}

- (NSString *) hintRewardUnitID
{
#ifdef DEBUG
    // 실패 · 재시도 경로를 시뮬레이터에서 보려고 (Release 에 없다).
    // 실행 인자 -AdFailTest 면 없는 단위로 요청해서 반드시 실패한다.
    if ([[NSProcessInfo processInfo].arguments containsObject:@"-AdFailTest"])
        return @"ca-app-pub-3940256099942544/0000000000";
#endif
    if (gQAAdFail) return @"ca-app-pub-3940256099942544/0000000000";   // QA 「광고 실패 흉내」 (A479)
    return MY_HINT_REWARD_UNIT_ID;
}

- (void) requestHintRewardedAd
{
    if (!UMPConsentInformation.sharedInstance.canRequestAds) {
        DLog(@"[ad] rewarded: no consent — not requesting");
        return;
    }
    bHintLoading = YES;
    DLog(@"[ad] rewarded request (fails so far=%d)", (int)hintLoadFails);
    [GADRewardedAd loadWithAdUnitID:[self hintRewardUnitID]
                            request:[self request]
                  completionHandler:^(GADRewardedAd *ad, NSError *error) {
        bHintLoading = NO;
        if (error) {
            hintLoadFails += 1;
            [hintLastError release];
            hintLastError = [error retain];
            bReadyHintRewardVideo = NO;
            if (hintLoadFails <= AD_BACKOFF_COUNT) {
                NSTimeInterval d = kAdBackoffSec[hintLoadFails - 1];
                DLog(@"[ad] rewarded load fail #%d (%ld %@) — retry in %.0fs",
                     (int)hintLoadFails, (long)error.code, [error localizedDescription], d);
                hintRetryTimer = [NSTimer scheduledTimerWithTimeInterval:d
                                                                  target:self
                                                                selector:@selector(OnTimerHintRetry:)
                                                                userInfo:nil
                                                                 repeats:NO];
            } else {
                DLog(@"[ad] rewarded load fail #%d (%ld %@) — resting",
                     (int)hintLoadFails, (long)error.code, [error localizedDescription]);
            }
            [self hintWaitStep];
            return;
        }
        DLog(@"[ad] rewarded loaded (after %d fails)", (int)hintLoadFails);
        hintLoadFails = 0;
        [hintLastError release];
        hintLastError = nil;
        self.hintRewardedAd = ad;
        ad.fullScreenContentDelegate = self;
        bReadyHintRewardVideo = YES;
        [self hintWaitStep];
    }];
}

- (void) OnTimerHintRetry:(NSTimer *)timer
{
    hintRetryTimer = nil;
    [self loadHintRewardedAd];
}

// 힌트 창에 「광고 보고 힌트」 줄을 보일지. 받아 둔 게 없어도 SDK 가 켜져
// 있고 동의가 있으면 보인다 — 누르면 기다리거나 깨운다.
- (BOOL) canOfferHintRewardedAd
{
    return bStartedMobileAds && UMPConsentInformation.sharedInstance.canRequestAds;
}

// 앱 복귀. Flutter AdSlot.restart 와 같다 — 받아 뒀거나 받는 중이면 그대로,
// 대기 · 쉬는 중이면 카운터를 0 으로 돌리고 바로 받는다.
- (void) adsDidBecomeActive
{
    if (!bStartedMobileAds) return;   // 아직 동의 · SDK 시작 전 (첫 실행의 복귀도 여기로 온다)
    if (!UMPConsentInformation.sharedInstance.canRequestAds) return;
    if (!self.hintRewardedAd && !bHintLoading) {
        DLog(@"[ad] foreground: wake rewarded (fails=%d, waiting=%d)",
             (int)hintLoadFails, hintRetryTimer != nil);
        [hintRetryTimer invalidate];
        hintRetryTimer = nil;
        hintLoadFails = 0;
        [self requestHintRewardedAd];
    }
#ifdef ADMOB_FREEVERSION
    [self wakeBannerIfResting];
#endif
}

#pragma mark 힌트 누름 — 기다리기 · 보여 주기 · 안내

- (void) presentHintRewardedAd
{
    // 보상 지급은 **이 핸들러**로 온다. 예전 didRewardUserWithReward:
    // delegate 자리다.
    GADRewardedAd *ad = [[self.hintRewardedAd retain] autorelease];
    self.hintRewardedAd = nil;   // 한 번 보여 준 광고는 다시 못 쓴다
    bReadyHintRewardVideo = NO;
    [ad presentFromRootViewController:self
             userDidEarnRewardHandler:^{
        DLog(@"Rewarded: %@ %@", ad.adReward.type, ad.adReward.amount);
        [self finishHintAttempt:kGaOutcomeEarned error:nil];
        [self giveHintReward];
    }];
}

// 「광고 보고 힌트」 보상 — 광고를 봤을 때와 대신 줄 때가 같은 몫이다.
- (void) giveHintReward
{
    mainView.paidHintCount += countHint5;
    [self updateButtonHint];
    [self updateHintCount];
    [self saveSetting];
}

- (void) waitForHintRewardedAd
{
    DLog(@"[ad] hint tapped without ad — waiting up to %.0fs (loading=%d, fails=%d)",
         HINT_WAIT_SEC, bHintLoading, (int)hintLoadFails);
    bHintWaiting = YES;
    hintWaitAttempts = 0;
    hintWaitStart = CFAbsoluteTimeGetCurrent();
    [self showHintWaitOverlay];
    hintWaitTimer = [NSTimer scheduledTimerWithTimeInterval:HINT_WAIT_SEC
                                                     target:self
                                                   selector:@selector(OnTimerHintWaitTimeout:)
                                                   userInfo:nil
                                                    repeats:NO];
    [self hintWaitStep];
}

// 누른 자리가 기다리는 동안 받기가 끝날 때마다 부른다 (받기 콜백에서도).
// 받는 중이면 거기에 붙고, 빠른 실패 · 쉬는 중이면 그 자리에서 다시 받는다.
- (void) hintWaitStep
{
    if (!bHintWaiting) return;
    if (self.hintRewardedAd) {
        DLog(@"[ad] hint wait: ad arrived after %ldms", (long)[self msSince:hintWaitStart]);
        [self endHintWait];
        [self presentHintRewardedAd];
        return;
    }
    if (bHintLoading) return;   // 받는 중인 적재에 붙는다
    if (hintWaitAttempts >= HINT_WAIT_ATTEMPTS
        || CFAbsoluteTimeGetCurrent() - hintWaitStart >= HINT_WAIT_SEC) {
        [self hintWaitGiveUp];
        return;
    }
    // 대기 중인 백오프는 이 요청이 대신한다 — 사슬이 둘이 되지 않게.
    [hintRetryTimer invalidate];
    hintRetryTimer = nil;
    if (hintLoadFails > AD_BACKOFF_COUNT) hintLoadFails = 0;   // 쉬던 것을 깨운다
    hintWaitAttempts += 1;
    [self requestHintRewardedAd];
    if (!bHintLoading) [self hintWaitGiveUp];   // 동의가 없어 요청이 안 나갔다
}

- (void) OnTimerHintWaitTimeout:(NSTimer *)timer
{
    hintWaitTimer = nil;
    if (bHintWaiting) {
        DLog(@"[ad] hint wait: timeout %.0fs", HINT_WAIT_SEC);
        [self hintWaitGiveUp];
    }
}

// 끝내 없다: 하루 한도 안이면 보상을 대신 주고, 넘었으면 안내만 한다.
// 늦게 온 광고는 버리지 않고 받아 둔다 — 다음 누름에 바로 나간다.
- (void) hintWaitGiveUp
{
    [self endHintWait];
    [self grantFreeOrDecline:hintLastError showFailed:NO];
    [self startGameTimer];
}

#pragma mark 광고 없을 때 대신 지급 (Flutter _grantFreeOrDecline · FreeRewardQuota)

- (NSString *) freeRewardToday
{
    NSDateComponents *c = [[NSCalendar currentCalendar]
        components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%04ld-%02ld-%02ld", (long)c.year, (long)c.month, (long)c.day];
}

// 오늘 쓴 횟수. 저장된 날짜가 오늘이 아니거나 꼴이 틀리면 0.
- (NSInteger) freeRewardUsedToday
{
    NSString *v = [[NSUserDefaults standardUserDefaults] stringForKey:kFreeRewardQuotaKey];
    NSArray *p = [v componentsSeparatedByString:@":"];
    if (p.count != 2 || ![p[0] isEqualToString:[self freeRewardToday]]) return 0;
    return [p[1] integerValue];
}

// 한도 안이면 하나 쓰고 쓴 횟수(1..3)를, 넘었으면 0.
- (NSInteger) freeRewardTryConsume
{
    NSInteger n = [self freeRewardUsedToday];
    if (n >= FREE_REWARD_LIMIT) return 0;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@:%ld", [self freeRewardToday], (long)(n + 1)]
                                              forKey:kFreeRewardQuotaKey];
    return n + 1;
}

// ad_result outcome 은 Flutter 와 같다: 못 받은 까닭이 망이면 offline, 아니면
// 대신 줬을 때 goodwill · 한도를 넘었을 때 unavailable. 표시 실패는 망으로 보지 않는다.
- (void) grantFreeOrDecline:(NSError *)error showFailed:(BOOL)showFailed
{
    NSInteger n = [self freeRewardTryConsume];
    BOOL off = !showFailed && GaIsOfflineError(error);
    [self finishHintAttempt:(off ? kGaOutcomeOffline : (n == 0 ? kGaOutcomeUnavailable : kGaOutcomeGoodwill))
                      error:error];
    if (n == 0) {
        DLog(@"[ad] free reward: declined (used %d/%d today)", FREE_REWARD_LIMIT, FREE_REWARD_LIMIT);
#ifdef USE_FLURRY
        [Flurry logEvent:@"playAd failed passOnFailed:false"];
#endif
        [self showAdNoticeTitle:nil message:gettext(@"Couldn't load the ad", nil)];
        return;
    }
    DLog(@"[ad] free reward: granted %ld/%d", (long)n, FREE_REWARD_LIMIT);
#ifdef USE_FLURRY
    [Flurry logEvent:[NSString stringWithFormat:@"freeReward %ld", (long)n]];
#endif
    [self giveHintReward];
    [self showAdNoticeTitle:gettext(@"Couldn't load the ad (title)", nil)
                    message:[NSString stringWithFormat:@"%@ (%ld/%d)", gettext(@"The reward is on us!", nil),
                             (long)n, FREE_REWARD_LIMIT]];
}

- (void) endHintWait
{
    bHintWaiting = NO;
    [hintWaitTimer invalidate];
    hintWaitTimer = nil;
    [hintWaitOverlay removeFromSuperview];
    [hintWaitOverlay release];
    hintWaitOverlay = nil;
}

- (void) showHintWaitOverlay
{
    if (hintWaitOverlay) return;
    UIView *v = [[UIView alloc] initWithFrame:self.view.bounds];
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    v.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];   // 판을 덮어 누름도 막는다
    UIActivityIndicatorView *spin =
        [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge] autorelease];
    spin.color = [UIColor whiteColor];
    spin.center = CGPointMake(CGRectGetMidX(v.bounds), CGRectGetMidY(v.bounds));
    spin.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [spin startAnimating];
    [v addSubview:spin];
    [self.view addSubview:v];
    hintWaitOverlay = v;   // alloc 으로 잡은 것을 그대로 든다
}

// 「광고를 불러오지 못했어요」 — 버튼 없이 잠깐 떴다 사라진다. 힌트 창이
// 닫히는 중일 수 있어 한 박자 늦게 띄운다.
- (void) showAdNoticeTitle:(NSString *)title message:(NSString *)message
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 맨 위 화면에서 띄운다 — 다른 화면이 떠 있어도 안내가 사라지지 않게.
        UIViewController *top = self;
        while (top.presentedViewController && !top.presentedViewController.isBeingDismissed)
            top = top.presentedViewController;
        if ([top isKindOfClass:[UIAlertController class]]) {
            DLog(@"[ad] notice skipped: an alert is already up");
            return;
        }
        DLog(@"[ad] notice: %@ / %@", title, message);
        UIAlertController *note = [UIAlertController alertControllerWithTitle:title
                                                                      message:message
                                                               preferredStyle:UIAlertControllerStyleAlert];
        [top presentViewController:note animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (note.presentingViewController && !note.isBeingDismissed)
                [note dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

#pragma mark ad_result (공장 표준 이벤트)

- (NSInteger) msSince:(CFAbsoluteTime)start
{
    if (start <= 0) return 0;
    double ms = (CFAbsoluteTimeGetCurrent() - start) * 1000.0;
    return ms < 0 ? 0 : (NSInteger)ms;
}

// 보상형 시도 한 건의 시작 = 「광고 보고 힌트」를 누른 순간.
- (void) beginHintAttempt:(BOOL)cached
{
    bHintAttemptOpen = YES;
    bHintAttemptCached = cached;
    hintAttemptStart = CFAbsoluteTimeGetCurrent();
}

// 처음 부른 한 번만 보낸다 — 보상 · 닫힘 · 표시 실패 콜백이 겹쳐도 하나다.
- (void) finishHintAttempt:(NSString *)outcome error:(NSError *)error
{
    if (!bHintAttemptOpen) return;
    bHintAttemptOpen = NO;
    [self gaAdResult:kGaPlacementHint outcome:outcome cached:bHintAttemptCached
              waitMs:[self msSince:hintAttemptStart] error:error];
}

// `ad_result` (placement · outcome · was_cached · wait_ms [· error_code]).
// 동의가 없으면 보내지 않는다 — 광고 결과가 아니라서 분모를 더럽힌다 (공장과 같은 규칙).
// 기존 Flurry 문자열(logEventParam:)은 그대로 둔다.
- (void) gaAdResult:(NSString *)placement outcome:(NSString *)outcome cached:(BOOL)cached
             waitMs:(NSInteger)waitMs error:(NSError *)error
{
    if (!UMPConsentInformation.sharedInstance.canRequestAds) return;
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:@{
        kGaParPlacement: placement,
        kGaParOutcome: outcome,
        kGaParWasCached: @(cached ? 1 : 0),   // Firebase 는 bool 을 안 받는다 — 1/0
        kGaParWaitMs: @(waitMs),
    }];
    if (error) p[kGaParErrorCode] = [NSString stringWithFormat:@"%ld", (long)error.code];
    DLog(@"[ad] ad_result %@", p);
    GaLogEvent(kGaEvAdResult, p);
    if ([outcome isEqualToString:kGaOutcomeEarned] && [placement hasPrefix:@"rewarded"]) {
        GaLogEvent(kGaEvAdRewardEarned, @{ kGaParPlacement: placement });
    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    if (connection == _connStart)
        _responseDataStart = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    if (connection == _connStart)
        [_responseDataStart appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    if (connection == _connStart) {
        [self TreateActStart:_responseDataStart];
        [_responseDataStart release];
        [_connStart release];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    if (connection == _connStart) {
        [_connStart release];
    }
}





#pragma mark - QA 메뉴 (A479 · TestFlight · 디버그 빌드 전용)

// 사람 (2026-11-08): 「Native5종도 TF 디버그 메뉴 넣을 수 있어? 기능은 게임 해결 · 힌트 증가 · 등등」.
// 공장 QA 시트(factory packages/ga_core GaQaSheet)와 같은 뜻이다. 화면 오른쪽 위의 작은 「QA」 단추가 연다.
//
// 언제 보이나:
//   Debug 빌드                     늘 (#ifdef DEBUG — 컴파일 깃발)
//   Release · 시뮬레이터             안 보임
//   Release · 기기                 영수증이 sandboxReceipt(TestFlight) **이고** IDFV 가 QAAllowedIDs 에 있을 때만
//
// 왜 컴파일 깃발만으로 안 되나 — TestFlight 에 올린 그 빌드가 그대로 심사 · App Store 로 간다.
// 빌드를 갈라 올리면 사람이 본 것과 다른 것이 나간다. 그래서 iOS 는 실행 중에 가른다.
// 왜 영수증만으로 안 되나 — 심사 기기에 설치된 앱도 sandbox 영수증을 갖는다. 영수증만 보면 심사자에게
// QA 메뉴가 뜬다 (Guideline 2.1 · 2.3.1). 그래서 공장 원격 설정 qa_install_ids 와 같은 IDFV 목록을
// 같이 본다. IDFV 는 같은 개발자 팀(376QCT8NVY) 앱끼리 같다 — 공장 앱 설정 맨 아래 「QA ID」가 이
// 기기의 값이다. 목록을 바꾸려면 다시 빌드한다. 숨은 손짓으로 켜는 길은 만들지 않는다 (2.3.1).
static __attribute__((unused)) NSArray *QAAllowedIDs(void)
{
    return @[ @"959d9188-ecb3-4353-b6b9-87350c0fe1f9" ];   // factory tools/qa_ids.dart list (2026-11-08)
}

static NSString *QADeviceID(void)
{
    return [[[[UIDevice currentDevice] identifierForVendor] UUIDString] lowercaseString];
}

static BOOL QAMenuEnabled(void)
{
#ifdef DEBUG
    return YES;
#elif TARGET_OS_SIMULATOR
    return NO;
#else
    // 못 읽으면 꺼짐 — 「모르겠다」는 통과가 아니다.
    NSURL *receipt = [[NSBundle mainBundle] appStoreReceiptURL];
    if (![[receipt lastPathComponent] isEqualToString:@"sandboxReceipt"]) return NO;
    NSString *idfv = QADeviceID();
    return idfv != nil && [QAAllowedIDs() containsObject:idfv];
#endif
}

#ifdef DEBUG
static NSString *QADebugArg(void)
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"DebugQA"];
}
#endif

- (void) installQAButton
{
    if (!QAMenuEnabled()) return;   // 꺼졌으면 단추가 아예 없다 — 숨긴 단추가 아니라 없는 단추다
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:@"QA" forState:UIControlStateNormal];
    [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    b.backgroundColor = [UIColor colorWithRed:0.85 green:0.2 blue:0.2 alpha:0.75];
    b.layer.cornerRadius = 6;
    b.accessibilityIdentifier = @"qa-button";
    b.translatesAutoresizingMaskIntoConstraints = NO;
    [b addTarget:self action:@selector(showQAMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b];
    UILayoutGuide *g = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        // 오른쪽 위, 안전 영역 바로 위 띠(「레벨」 줄 오른쪽 빈자리). 아래쪽은 배너 자리라 덮으면 안 된다.
        [b.trailingAnchor constraintEqualToAnchor:g.trailingAnchor constant:-6],
        [b.bottomAnchor constraintEqualToAnchor:g.topAnchor constant:-2],
        [b.widthAnchor constraintEqualToConstant:40],
        [b.heightAnchor constraintEqualToConstant:24],
    ]];
}

- (void) showQAMenu:(id)sender
{
    NSString *src =
#ifdef DEBUG
        @"Debug";
#else
        @"TestFlight";
#endif
    NSString *title = [NSString stringWithFormat:@"QA (%@)", src];
    NSString *msg = [NSString stringWithFormat:@"hints %ld+%ld · ad fallback %ld/%d today · ad fail %@\nQA ID %@",
                     (long)mainView.sudokuGame.countHint, (long)mainView.paidHintCount,
                     (long)[self freeRewardUsedToday], FREE_REWARD_LIMIT, gQAAdFail ? @"ON" : @"off", QADeviceID()];
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:title message:msg
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *items = @[
        @[ @"solve",   @"Solve board" ],
        @[ @"solve1",  @"Solve all but one cell" ],
        @[ @"hint",    @"Hints +10" ],
        @[ @"quota",   @"Reset ad-fallback limit (3/day)" ],
        @[ @"adfail",  gQAAdFail ? @"Ad failure simulation: turn OFF" : @"Ad failure simulation: turn ON" ],
        @[ @"consent", @"Reset consent (UMP)" ],
    ];
    for (NSArray *it in items) {
        NSString *key = it[0];
        [sheet addAction:[UIAlertAction actionWithTitle:it[1] style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *a) { [self runQAItem:key]; }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    UIView *anchor = [sender isKindOfClass:[UIView class]] ? sender : self.view;
    sheet.popoverPresentationController.sourceView = anchor;   // iPad
    sheet.popoverPresentationController.sourceRect = anchor.bounds;
    [self presentViewController:sheet animated:YES completion:nil];
}

// 항목 하나. 무엇을 했는지 한 줄로 말한다 (공장 시트의 스낵바 자리).
- (void) runQAItem:(NSString *)key
{
    if (!QAMenuEnabled()) return;
    if ([key isEqualToString:@"menu"]) {
        [self showQAMenu:nil];
    } else if ([key isEqualToString:@"solve"] || [key isEqualToString:@"solve1"]) {
        [self qaSay:[self qaSolveLeavingOne:[key isEqualToString:@"solve1"]]];
    } else if ([key isEqualToString:@"hint"]) {
        mainView.paidHintCount += 10;
        [self updateButtonHint];
        [self updateHintCount];
        [self saveSetting];
        [self qaSay:[NSString stringWithFormat:@"Hints +10 (now %ld)",
                     (long)(mainView.sudokuGame.countHint + mainView.paidHintCount)]];
    } else if ([key isEqualToString:@"quota"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFreeRewardQuotaKey];
        [self qaSay:[NSString stringWithFormat:@"Ad-fallback limit reset (0/%d today)", FREE_REWARD_LIMIT]];
    } else if ([key isEqualToString:@"adfail"]) {
        gQAAdFail = !gQAAdFail;
        // 받아 둔 광고를 버린다 — 안 그러면 다음 누름이 그것을 보여 줘서 실패 길을 못 탄다.
        self.hintRewardedAd = nil;
        bReadyHintRewardVideo = NO;
        [hintRetryTimer invalidate];
        hintRetryTimer = nil;
        hintLoadFails = 0;
        if (!gQAAdFail) [self loadHintRewardedAd];
        [self qaSay:gQAAdFail ? @"Ad failure simulation ON — rewarded hint ads will fail to load"
                              : @"Ad failure simulation OFF"];
    } else if ([key isEqualToString:@"consent"]) {
        [UMPConsentInformation.sharedInstance reset];
        [self qaSay:@"Consent (UMP) reset — restart the app to see the form again (EEA only)"];
    }
}

// 정답을 판에 채운다. leaveOne 이면 빈칸 하나를 남긴다 — 사람이 마지막 수를 두어 깨는 흐름을 본다.
- (NSString *) qaSolveLeavingOne:(BOOL)leaveOne
{
    SudokuGame *g = mainView.sudokuGame;
    if (g == nil || g.isGameFinished) return @"No game in progress";
    // 데일리 퍼즐은 깨면 기록이 실제 랭킹 서버(addresult)로 간다 — QA 로 푼 시간이 남의 순위를 흔든다.
#ifndef DEBUG   // 디버그 빌드는 uploadDailyPuzzleResult 가 서버로 안 올리므로 데일리도 풀 수 있다 (연속 시험, A468)
    if (g.bDailyPuzzle) return @"Daily puzzle: QA solve is off (the time would go to the live daily ranking)";
#endif
    NSInteger open = 0;
    for (NSInteger y = 0; y < g.size; y++)
        for (NSInteger x = 0; x < g.size; x++)
            if ([g getPuzzleNums:x y:y] == 0 && [g getAnswerNums:x y:y] > 0) open++;
    if (open == 0) return @"No answer for this board (user-input puzzle?)";
    NSInteger fill = leaveOne ? open - 1 : open;
    NSInteger done = 0;
    for (NSInteger y = 0; y < g.size && done < fill; y++)
        for (NSInteger x = 0; x < g.size && done < fill; x++)
            if ([g getPuzzleNums:x y:y] == 0 && [g getAnswerNums:x y:y] > 0) {
                [g setHintNum:x y:y];
                done++;
            }
    [mainView checkClearAndUpdateButton];
    [g saveData];
    return leaveOne ? @"Solved all but one cell" : @"Board solved";
}

- (void) qaSay:(NSString *)message
{
    DLog(@"[qa] %@", message);
    UIViewController *top = self;
    while (top.presentedViewController && !top.presentedViewController.isBeingDismissed)
        top = top.presentedViewController;
    if ([top isKindOfClass:[UIAlertController class]]) return;   // 이미 창이 떠 있다 (깬 판 안내 등)
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"QA" message:message
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [top presentViewController:a animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (a.presentingViewController && !a.isBeingDismissed) [a dismissViewControllerAnimated:YES completion:nil];
    });
}

@end



@implementation APActivityProvider

@synthesize strMsg;
@synthesize strMsgTwitter;


- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
        return strMsgTwitter;
    return strMsg;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }
@end



