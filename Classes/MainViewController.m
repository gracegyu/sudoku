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
#import "MainViewController.h"
#import "MainView.h"
#import "Locale.h"
#import "GameCenterUtil.h"
#ifdef USE_JMC
#import "JMC.h"
#endif
#import "KillerMap.h"
//#import "AddThis.h"
#import "Flurry.h"
#import "UIDevice+IdentifierAddition.h"



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
@synthesize buttonNickname;


//@synthesize labelDailyAutoMemo;
//@synthesize buttonDailyCheckboxAutoMemo;
@synthesize labelDailyStatSudoku;
@synthesize labelDailyStatGt;
@synthesize labelDailyStatKiller;
@synthesize labelDailyStatCalcu;
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
@synthesize nowDate;
@synthesize strMsgFinish;



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
    DLog(@"scoreRankTotal=%ld", (long)score.scoreRankTotal);
	[defaults synchronize];
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
            DLog(@"Score[%d][%d]:%d,%d,%d,%d,%d", type, num,
                 (int)score.scoreGames[type][i],
                 (int)score.scoreClears[type][i],
                 (int)score.scoreBestTime[type][i],
                 (int)score.scoreClearTimeSum[type][i],
                 (int)score.scoreRankLevel[type][i]);
        }
    }
    
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
    
}


- (void) alertFinish
{
    DLog(@"strMsgFinish=%@", strMsgFinish);

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:gettext(@"Congratulations!", nil)
                                                    message:strMsgFinish
                                                   delegate:self
                                          cancelButtonTitle:gettext(@"Ok", nil)
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
//    [strMsgFinish release];
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
    
#ifdef ADMOB_FREEVERSION
    [self loadInterstitial];
#endif
	DLog(@"writeScoreAfterFinishGame");	
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
    {
        NSInteger total=0, grade=0;
        
        if ([self uploadDailyPuzzleResult:sudokuGame.gameTime pTotal:&total pGrade:&grade] == YES &&
            total > 0 &&
            grade > 0 &&
            grade <= total)
        {
            strMsgFinish = [strMsgFinish stringByAppendingString:@"\n"];
            strMsgFinish = [strMsgFinish stringByAppendingFormat:
                      gettext(@"Your ranking of daily puzzle:#%d/%d", nil),
                      grade, total];
        }
    }

    
    if (bNewBest)
    {
        strMsgFinish = [strMsgFinish stringByAppendingString:@"\n"];
        strMsgFinish = [strMsgFinish stringByAppendingString:gettext(@"You broke your best time.", nil)];
    }
    strMsgFinish = [strMsgFinish stringByAppendingString:@"\n"];
    strMsgFinish = [strMsgFinish stringByAppendingFormat:
              gettext(@"If you share this puzzle or result on Facebook, you can get %d more hints in next game.", nil),
              NUM_HINTBONUS];
    
    DLog(@"strMsgFinish = %@", strMsgFinish);
    
#ifdef ADMOB_FREEVERSION
    // do nothing
    [strMsgFinish retain];
#else
    [self alertFinish];
#endif
	
    
    
    score.scoreClearTimeSum[sudokuGame.sudokuType][level] += sudokuGame.gameTime;
	
    // add current game score to Total Score
    score.scoreTotal += [self getGameResultScore:level sec:sudokuGame.gameTime];
    score.scoreTotal += sudokuGame.countHint*3;   // 남은 힌트 점수 추가
    
	[self saveScoreData];
    

    [self sendDataToGameCenter:sudokuGame];
	[self updateButtons];
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
    
    for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)   // SUDOKUTYPE_MAX => auto
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
	
    labelLicense.text = STR_LICENSE;

    
    [buttonNewGame		setTitle:gettext(@"New game", nil) forState:UIControlStateNormal];
    [buttonDailyGame	setTitle:gettext(@"daily puzzle", nil) forState:UIControlStateNormal];
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
#ifndef USE_JMC
    [self setButtonMode:buttonFeedback.alpha mode:NO];
#endif
	[buttonMenuClose	setTitle:gettext(@"Close", nil) forState:UIControlStateNormal];

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
    labelTitleGameTime.text = gettext(@"game time", nil);
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
    [buttonDailyGameCancel setTitle:gettext(@"cancel", nil) forState:UIControlStateNormal];
    
    
    
    if (mainView.sudokuGame)
        [self setGameLevel];

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
        [Flurry logEvent:@"ChangeNickNameDialog Too Long name"];
        newname = [newname substringWithRange:NSMakeRange(0, 60)];
    }
    gUserName = [[NSString stringWithString:newname] retain];
    DLog(@"setUserName:%@ => %@", newname, gUserName);
    
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	BOOL firstRun = NO;
	
 	DLog(@"initWithNibName");	
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
   {
	   
	   
        mainView = (MainView*) self.view;
 	    frameMainViewOrg = mainView.frame;
	   DLog(@"frameMainViewOrg = %f,%f", frameMainViewOrg.size.width, frameMainViewOrg.size.height);

	   
	   //[mainView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg3.png"]]];

	   areaPuzzleTable.hidden = YES;
	   areaNumButton.hidden = YES;
	   areaAdBanner.hidden = YES;
       gUserID = cDefaultUserID;
       gUserName = [[NSString stringWithFormat:@"%d", (int)gUserID] retain];
	   
       [self decideLocale];
       
       [self loadServerData];
       [self loadSetting];
       [self setLocalizedMessage];
       [mainView initSkinColorData];
       [mainView initRainbowColorData];
       [mainView initBiggerSmallerColorData];
       [self initScore];
       [self loadScoreData];

	   if ([mainView loadGame] == YES) {
			[self setGameLevel];
            [self updateGameTime:mainView.sudokuGame.gameTime];
            [self startGameTimer];          // load 했을 때만 Timer를 시작한다.
		} else {
			levelNewGame = GAMELEVEL_NORMAL;	// normal로 새로운 게임을 무조건 생성한다.
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
       
       /*
        [NSTimer scheduledTimerWithTimeInterval:5
        target:self
        selector:@selector(OnTimerconnectToServerInit:)
        userInfo:nil
        repeats:NO];
       */

       
    }
    return self;
}


- (void) viewDidDisappear:(BOOL)animated
{
    DLog(@"MainViewController:viewDidDisappear");
}

- (void)viewDidAppear:(BOOL)animated
{
/*    DLog(@"MainViewController:viewDidAppear(nAddThisWait=%ld)", (long)nAddThisWait);
    if (nAddThisWait > 0)
    {
        nAddThisWait++;
        return;
    } else {*/
        if (mainView.bMenuMode)
        {
            [self hideMenuView:NO];
        }
        // Share puzzle용
        //[self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.3];
        if (SUPPORT_ROTATION)
            self.view.frame = [[UIScreen mainScreen] applicationFrame];

        //[self willRotateToInterfaceOrientation:[UIDevice currentDevice].orientation duration:0.3];

//    }
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



     
#ifdef ADMOB_FREEVERSION	 
     // Create a view of the standard size at the bottom of the screen.
     
     DLog(@"areaAdBanner.frame(%f,%f,%f,%f)", areaAdBanner.frame.origin.x, areaAdBanner.frame.origin.y, areaAdBanner.frame.size.width, areaAdBanner.frame.size.height);
     
     bannerView_ = [[GADBannerView alloc] initWithFrame:areaAdBanner.frame];
     [bannerView_ setDelegate:self];
     bannerView_.adUnitID = MY_BANNER_UNIT_ID;
     
     bannerView_.rootViewController = self;
     [self.view addSubview:bannerView_];
     
     [bannerView_ loadRequest:[GADRequest request]];     
#endif
     bAd = NO;
     bReplay = NO;
     nowDate = nil;
	 
     
     [GameCenterUtil connectGameCenter:self];       //게임센터 접속~
     
     
     
     if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
     {
         buttonPuzzleShare.enabled = NO;
         buttonRecordShare.enabled = NO;
         buttonSharePuzzle.enabled = NO;
     }
         
     
     if ([SKPaymentQueue canMakePayments]) {	// 스토어가 사용 가능하다면
         NSLog(@"Start Shop!");
         
         [[SKPaymentQueue defaultQueue] addTransactionObserver:self];	// Observer를 등록한다.
     } else {
         NSLog(@"Failed Shop!");
     }

     productHint50 = nil;
     bBuyingHint50 = NO;
     SKProductsRequest *productRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:
                                          [NSSet setWithObject:kHint50Item]];
     productRequest.delegate = self;
     
     [productRequest start];
     
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
        NSString *strOldServerIP = [[NSString alloc] initWithString:gServerIP];
        
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
	
	NSString* strURI = [[NSString alloc] initWithFormat:
						@"act=%@&locale=%@&deviceid=%@&userid=%ld&username=%@&appversion=%@&latitude=%d&longitude=%d&version=%d&devicetype=%d&ostype=%@&osversion=%4.2f&languagecode=%@&countrycode=%@&countryname=%@&manufacturer=%@&cs=%ld",
						@"start",
                        @"en_US",
						gDeviceID,
                        (long)gUserID,
                        [self percentEscapeString:gUserName],
                        APPVERSION,
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
//	DLog(@"strURI = %@", strURI);
	NSString* strData = [self GetHTTPData:strURI	timeoutInterval:cDefaultHTTPTimeOut];
	[strURI release];
	
	// zzz error handling, if gUserID is 1 still ...
	if (!strData) {
		//		[self alertLocalizedAlertViewUTF8];
		return;
	}
    NSLog(@"strData = %@", strData);
	NSArray *listItems = [strData componentsSeparatedByString:@"\n"];
	NSInteger count = listItems.count;
	NSString *item;
	
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
#ifdef DEBUG
                gUserID = cDebugUserID;
#else
				gUserID = [value integerValue];
#endif
			else if ([name caseInsensitiveCompare:@"UserName"] == NSOrderedSame)
                [self setUserName:value];
		}
	}
	
	[strData release];
    [self saveServerData];
}




#define kServerIP                   @"serverIP"
#define kUserDefault				@"gUserDefault"
#define kUserID						@"gUserID"
#define kUserName					@"gUserName"

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
    
}







- (void) saveServerData
{
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
    [defaults setObject:@"Yes"		forKey:kUserDefault];
	[defaults setObject:gUserName	forKey:kUserName];
    DLog(@"Save User Name:%@", gUserName);
	[defaults setInteger:gUserID	forKey:kUserID];
    [defaults setObject:gServerIP   forKey:kServerIP];

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
    bannerView_.frame = areaAdBanner.frame;
    bannerView_.hidden = NO;
#endif
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


- (IBAction) showScoreView
{
    [Flurry logEvent:@"ShowScoreView"];

	[self hideMenuView:NO];
    [self getRankingFromGameCenter];    // 최신 랭킹으로 update

    
    DLog(@"[UIScreen mainScreen].bounds.size.height = %f", [UIScreen mainScreen].bounds.size.height);
    DLog(@"[[UIScreen mainScreen] scale] = %f", [[UIScreen mainScreen] scale]);
    
	ScoreViewController *controller = [[ScoreViewController alloc] initWithNibName:
										  cDeviceType == DEVICETYPE_IPAD ? @"ScoreView4iPad" : 
										  (isIphone5or6 ? @"ScoreView4iPhone5" : @"ScoreView")
                                          bundle:nil];
    controller.mainViewController = self;
	[controller setScoreData:&score];
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;//UIModalTransitionStylePartialCurl;
	[self presentViewController:controller animated:YES completion:nil];

	controller.bAuto = mainView.sudokuGame.bAutoMemo ? YES : NO;
	[controller setAutoSegment];		
	[controller displayScore];
//    [controller setTotalScoreRank];
	[controller release];

}

- (void) updateButtonUndo
{
	BOOL bLock = mainView.bMenuMode || (mainView.sudokuGame && mainView.sudokuGame.isGameFinished);
	
	if ([mainView.sudokuGame.sudokuUndo countUndo] > 0 && mainView.sudokuGame.isGameFinished == NO)
    {
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_n"] forState:UIControlStateNormal];
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_h"] forState:UIControlStateHighlighted];
		buttonUndo.enabled = bLock ? NO : YES;
	} else {
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_d"] forState:UIControlStateNormal];
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_h"] forState:UIControlStateHighlighted];
		buttonUndo.enabled = NO;
	}
    
	if ([mainView.sudokuGame.sudokuUndo countRedo] > 0 && mainView.sudokuGame.isGameFinished == NO)
    {
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_n"] forState:UIControlStateNormal];
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_h"] forState:UIControlStateHighlighted];
		buttonRedo.enabled = bLock ? NO : YES;
	} else {
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_d"] forState:UIControlStateNormal];
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_h"] forState:UIControlStateHighlighted];
		buttonRedo.enabled = NO;
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
    [Flurry logEvent:@"RunUndoRedoRepeat"];

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

    [Flurry logEvent:@"RunUndo"];
    
	[mainView playSoundClick];
	[mainView runUndo];

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

    [Flurry logEvent:@"RunRedo"];

	[mainView playSoundClick];
	[mainView runRedo];

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

    [Flurry logEvent:@"RunBookmark"];

    
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
	
    [Flurry logEvent:@"RunReset"];

    
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

    [Flurry logEvent:@"RunSeeReplay"];

    
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
        [Flurry logEvent:@"RankingCheck"];
        [self gotoRankingWebView:YES];
    } else {
        [Flurry logEvent:@"RunPalyAgain"];

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
    
    APActivityProvider *ActivityProvider = [[APActivityProvider alloc] init];
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
             NSString* str = [NSString stringWithFormat:@"Share(%@) done", act];
             [Flurry logEvent:str];
             
             NSLog(@"The selected activity was %@", act);
             NSRange range = [act rangeOfString:@"PostTo"];
             if (range.location != NSNotFound) {
                 mainView.bSharedThisOnFacebook = YES;
             }
         } else {
             NSString* str = [NSString stringWithFormat:@"Share(%@) cancel", act];
             [Flurry logEvent:str];
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

    [Flurry logEvent:@"SharePuzzle"];

    [self callPuzzleShare:YES];
    
    
    
    
}

- (IBAction)openShareRecord
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
    }

    [Flurry logEvent:@"ShareRecord"];
    

    [self callPuzzleShare:NO];
}



- (void)showHintButton
{
	[self updateButtonHint];
}

- (void)OnTimerSetFinishByuingHint50:(NSTimer *)timer
{
    bBuyingHint50 = NO;
    [self updateButtonHint];
}

- (IBAction) doHint
{
	if (mainView.bMenuMode)
		return;

    
    if (mainView.sudokuGame.countHint + mainView.paidHintCount > 0) // && 유료 힌트도 0
    {
        [Flurry logEvent:@"RunHint"];
        [mainView doHint];
        
        [self saveSetting];
    } else if (productHint50) { // buy hint
        SKPayment *payment = [SKPayment paymentWithProduct:productHint50];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        bBuyingHint50 = YES;
        [self updateButtonHint];
        
        [NSTimer scheduledTimerWithTimeInterval:60.0f
                                         target:self
                                       selector:@selector(OnTimerSetFinishByuingHint50:)
                                       userInfo:nil
                                        repeats:NO];
/*
        NSString *msg = [NSString stringWithFormat:@"%@\n%@:%@\n%@: %@",
                         gettext(@"Do you want to buy this item?", nil),
                         productHint50.localizedTitle,
                         productHint50.localizedDescription,
                         gettext(@"Price", nil),
                         productHint50.price];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:gettext(@"Buy hint", nil)
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:gettext(@"No", nil)
                                              otherButtonTitles:gettext(@"Yes", nil), nil];
        [alert show];
        [alert release];
 */
    }
}



- (IBAction)showSettingView
{
    [Flurry logEvent:@"ShowSettingView"];

	[self hideMenuView:NO];

    DLog(@"showSettingView");
    SettingViewController *controller = [[SettingViewController alloc] initWithNibName:
                                       cDeviceType == DEVICETYPE_IPAD ? @"SettingView4iPad" :
                                        (isIphone5or6 ? @"SettingView4iPhone5" : @"SettingView")
                                        bundle:nil];
    controller.mainViewController = self;
//	controller.title = gettext(@"Setting", nil);
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;//UIModalTransitionStylePartialCurl;
	[self presentViewController:controller animated:YES completion:nil];
    // UIModalTransitionStyleCrossDissolve for newgame
	
	
//	controller.title = gettext(@"Setting", nil);
    
	
	[controller release];

    
}

- (IBAction)showHelpView
{
    [Flurry logEvent:@"ShowHelpView"];

	[self hideMenuView:NO];
	
    DLog(@"showSettingView");
    HelpViewController *controller = [[HelpViewController alloc] initWithNibName:
                                      cDeviceType == DEVICETYPE_IPAD ? @"HelpView4iPad" :
                                      (isIphone5or6 ? @"HelpView4iPhone5" : @"HelpView")
                                      bundle:nil];
    controller.mainViewController = self;
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:controller animated:YES completion:nil];
	
	[controller release];
	
    
}

- (void) gotoRankingWebView:(BOOL)bMyRanking
{
    DLog(@"showRankView");
    RankViewController *controller = [[RankViewController alloc] initWithNibName:
                                      cDeviceType == DEVICETYPE_IPAD ? @"RankView" :
                                      (isIphone5or6 ? @"RankView4iPhone5" : @"RankView")
                                                                          bundle:nil];
    controller.bMyRankCheck = bMyRanking;
    controller.mainViewController = self;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:controller animated:YES completion:nil];
    
    [controller release];
    
}


- (IBAction)showRankView
{
    [Flurry logEvent:@"ShowRankView"];
    
	//[self hideMenuView:NO];
    [self hideDailyGameView];
    [self gotoRankingWebView:NO];
}


- (IBAction)showFeedbackView
{
    [self hideMenuView:NO];

#ifdef USE_JMC
    [Flurry logEvent:@"ShowFeedbackView"];

	//[self hideMenuView:NO];
	
	UIViewController *controller = [[JMC sharedInstance] viewController];
    [self presentViewController:controller animated:YES completion:nil];
#endif
    [self startGameTimer];
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
    
#ifdef ADMOB_FREEVERSION
    [bannerView_ release];
#endif    
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	DLog(@"dealloc");
#ifdef ADMOB_FREEVERSION
    bannerView_.delegate = nil;
    [bannerView_ release];
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





- (void)OnTimerShowMenu:(NSTimer *)timer
{
	CGRect frameOld = viewMenu.frame;
    frameOld.origin.x -= intervalX;
    viewMenu.frame = frameOld;
	
	if (viewMenu.frame.origin.x >= 0)
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
	intervalX = (viewMenu.frame.origin.x)/25;
	
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
	
	if (viewNewGame.frame.origin.x >= 0)
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
	intervalX2 = (viewNewGame.frame.origin.x)/20;
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
	
	if (viewDailyGame.frame.origin.x >= 0)
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
	intervalX2 = (viewDailyGame.frame.origin.x)/20;
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
	}
}

- (void) makeNewGameData
{
	if (mainView.sudokuGame)
		[mainView.sudokuGame release];

	[mainView newGame:levelNewGame size:DEFPUZZLESIZE];
    
    
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
	
	return csInt;
}


- (void) alertLocalizedOkayView:(NSString*)aTitle message:(NSString*)aMessage
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:gettext(aTitle, nil)
						  message:gettext(aMessage, nil)
						  delegate:self
						  cancelButtonTitle:gettext(@"Ok", nil)
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void) alertLocalizedAlertView:(NSString*)aMessage
{
	[self alertLocalizedOkayView:@"Alert" message:aMessage];
}


- (void) alertLocalizedAlertViewUTF8
{
	[self alertLocalizedAlertView:@"Wrong UTF8 format data was received"];
}

- (NSString *) GetHTTPData:(NSString *)strURI timeoutInterval:(NSTimeInterval)timeout
{
	NSString *strURL = [[NSString alloc] initWithFormat: @"http://%@/%@?%@",
#ifdef DAILYSENDER
                        @"10.211.55.10:88",
#else
						gServerIP,
#endif
                        cServerScript,
						strURI];
    DLog(@"strURL* = \n%@", strURL);
	NSURL *theURL = [NSURL URLWithString:strURL];
	[strURL release];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];
	
	NSURLResponse *theResponse;
	NSError *theError;
	NSData *theResponseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&theError];
	
	if (theResponseData)
	{
		char str[3000+1];
		
		memcpy(&str, theResponseData.bytes, MIN(theResponseData.length, 3000));
		str[theResponseData.length] = '\0';
		DLog(@"char* = %s", str);
		
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
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    
    
    //[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //DLog(@"DateTime=%@", [formatter stringFromDate:today]);
    
    
    
    [formatter setDateFormat:@"yyyyMMdd"];
    
    NSString *str = [formatter stringFromDate:today];
    //[str retain];
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

- (NSString*) downloadDailyPuzzle
{
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];

	DLog(@"Country Code = %@", countryCode);
    
    [self connectToServerInit];
    
    DLog(@"AppVersion = %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
     
    NSString* strURI = [NSString stringWithFormat:
						@"act=%@&userid=%ld&username=%@&appversion=%@&latitude=%d&longitude=%d&version=%d&cs=%ld&size=%d&type=%d&date=%@&automemo=%d&countrycode=%@",
                        @"getdailypuzzle",
                        (long)gUserID,
                        [self percentEscapeString:gUserName],
                        APPVERSION,
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
                        mainView.nSettingSudokuType,
                       [self getNowYYYYMMDD],
                        mainView.bSettingAutoMemo ? 1 : 0,
                        countryCode];
    
    NSString* strData = [self GetHTTPData:strURI	timeoutInterval:cDefaultHTTPTimeOut];
    return strData;
}

- (BOOL) uploadDailyPuzzleResult:(NSTimeInterval)gameTime pTotal:(NSInteger*)pTotal pGrade:(NSInteger*)pGrade
{
    [self connectToServerInit];
    
    NSString* strURI = [NSString stringWithFormat:
						@"act=%@&userid=%ld&username=%@&latitude=%d&longitude=%d&version=%d&cs=%ld&size=%d&type=%d&date=%@&spend=%lu&automemo=%d",
                        @"addresult",
                        (long)gUserID,
                        [self percentEscapeString:gUserName],
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
                        mainView.nSettingSudokuType,
                        [self getNowYYYYMMDD],
                        (unsigned long)gameTime,
                        mainView.bSettingAutoMemo ? 1 : 0];
    
    NSString* strData = [self GetHTTPData:strURI	timeoutInterval:cDefaultHTTPTimeOut];
    
    if (!strData) {
		return NO;
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
    
    NSString* strDailyPuzzle = [self downloadDailyPuzzle];
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
    
    dailyStat[mainView.nSettingSudokuType].played = YES;
    [self saveDailyStat];

}

- (void)OnTimerNewGameDailyPuzzle:(NSTimer *)timer
{
	DLog(@"OnTimerNewGameDailyPuzzle");
#ifdef DAILYSENDER
    [self newgameDailyPuzzle];
#endif
    
    
	[self makeNewGameDataFromServer];
	
	[activityIndicatorDailyGame stopAnimating];
	
	[self hideDailyGameView];
	
}

- (void) makeNewGameDailyPuzzle
{
	DLog(@"makeNewGameDailyPuzzle");
	
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
    for (int i=0; i<4; i++) {
        dailyStat[i].total = 0;
        dailyStat[i].besttime = 0;
    }
    
    [self connectToServerInit];
    
    NSString* strURI = [NSString stringWithFormat:
						@"act=%@&userid=%ld&username=%@&latitude=%d&longitude=%d&version=%d&cs=%ld&size=%d&date=%@",
                        @"getdailystat",
                        (long)gUserID,
                        [self percentEscapeString:gUserName],
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
				dailyStat[0].total = [value integerValue];
			else if ([name caseInsensitiveCompare:@"Besttime0"] == NSOrderedSame)
				dailyStat[0].besttime = [value integerValue];
            else if ([name caseInsensitiveCompare:@"Total1"] == NSOrderedSame)
				dailyStat[1].total = [value integerValue];
			else if ([name caseInsensitiveCompare:@"Besttime1"] == NSOrderedSame)
				dailyStat[1].besttime = [value integerValue];
            else if ([name caseInsensitiveCompare:@"Total2"] == NSOrderedSame)
				dailyStat[2].total = [value integerValue];
			else if ([name caseInsensitiveCompare:@"Besttime2"] == NSOrderedSame)
				dailyStat[2].besttime = [value integerValue];
            else if ([name caseInsensitiveCompare:@"Total3"] == NSOrderedSame)
				dailyStat[3].total = [value integerValue];
			else if ([name caseInsensitiveCompare:@"Besttime3"] == NSOrderedSame)
				dailyStat[3].besttime = [value integerValue];
		}
	}
	
	[strData release];
    
    if (bError == NO)
        bReadyDownloadDailyPuzzle = YES;
    
    return;
}


- (NSString*) getDailyStatString:(SUDOKUTYPE) type
{
    NSString *str;
    
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
    return str;
}

- (void) setDailyButton:(UIButton*) button played:(BOOL) bPlayed
{
    if (bReadyDownloadDailyPuzzle) {
#ifdef DAILYSENDER
        [self setButtonMode:button mode:YES];
#else
        [self setButtonMode:button mode:!bPlayed];
#endif
    } else {
        [self setButtonMode:button mode:NO];
    }
}

- (void) setDailyStat
{
    [self setDailyButton:buttonDailyGameSudoku  played:dailyStat[SUDOKUTYPE_SUDOKU].played];
    [self setDailyButton:buttonDailyGameGt      played:dailyStat[SUDOKUTYPE_GT].played];
    [self setDailyButton:buttonDailyGameKiller  played:dailyStat[SUDOKUTYPE_KILLER].played];
    [self setDailyButton:buttonDailyGameCalcu   played:dailyStat[SUDOKUTYPE_CALCU].played];
    if ([gUserName isEqualToString:[NSString stringWithFormat:@"%d", (int)gUserID]] != YES)
        labelNickname.text = gUserName;
    else
        labelNickname.text = @"";

    if (bReadyDownloadDailyPuzzle)
    {
        labelDailyStat.text = @"";
        
        buttonDailyRanking.enabled = YES;
        buttonDailyRanking.alpha = 1.0f;
        labelDailyStatSudoku.text = [self getDailyStatString:SUDOKUTYPE_SUDOKU];
        labelDailyStatGt.text =     [self getDailyStatString:SUDOKUTYPE_GT];
        labelDailyStatKiller.text = [self getDailyStatString:SUDOKUTYPE_KILLER];
        labelDailyStatCalcu.text =  [self getDailyStatString:SUDOKUTYPE_CALCU];
    } else  {
        labelDailyStat.text = gettext(@"Not connected to a server.", nil);

        buttonDailyRanking.enabled = NO;
        buttonDailyRanking.alpha = 0.3;
        labelDailyStatSudoku.text = @"...";
        labelDailyStatGt.text = @"...";
        labelDailyStatKiller.text = @"...";
        labelDailyStatCalcu.text = @"...";
    }
    
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
    nowDate = [[self getNowYYYYMMDD] retain];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *str = (NSString*)[defaults stringForKey:kDailyStat];
	if (str)
    {
        NSArray *listItems = [str componentsSeparatedByString:@","];

        NSString *strDate = [listItems objectAtIndex:0];
        if ([strDate isEqualToString:nowDate])
        {
            dailyStat[0].played = [[listItems objectAtIndex:1] integerValue] == 1 ? YES : NO;
            dailyStat[1].played = [[listItems objectAtIndex:2] integerValue] == 1 ? YES : NO;
            dailyStat[2].played = [[listItems objectAtIndex:3] integerValue] == 1 ? YES : NO;
            dailyStat[3].played = [[listItems objectAtIndex:4] integerValue] == 1 ? YES : NO;
            return;
        }
    }
    // another day or 1st try or error
    
    dailyStat[0].played = NO;
    dailyStat[1].played = NO;
    dailyStat[2].played = NO;
    dailyStat[3].played = NO;
    
    [self saveDailyStat];
}

- (void) saveDailyStat
{
    NSString *newNowDate = [self getNowYYYYMMDD];
    if ([newNowDate isEqualToString:nowDate])
    {
        // 그사이에 날짜가 바뀌지 않았음
    } else {
        // 그사이에 날짜가 바뀌었음
        
        nowDate = newNowDate;
        dailyStat[0].played = NO;
        dailyStat[1].played = NO;
        dailyStat[2].played = NO;
        dailyStat[3].played = NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* str = [NSString stringWithFormat:@"%@,%d,%d,%d,%d",
                     nowDate,
                     dailyStat[0].played ? 1 : 0,
                     dailyStat[1].played ? 1 : 0,
                     dailyStat[2].played ? 1 : 0,
                     dailyStat[3].played ? 1 : 0];
    
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

//    [self readyToDownloadDailyPuzzle];
    //[self getDailyStat];
    //[self setDailyStat];
//    [activityIndicatorDailyStat startAnimating];

    
    [self setSudokuTypeSegment];
    
	[self allButtonUnLock];
	[self hideMenuView:YES];	// 메뉴가 사라지고, newgame이 나온다.
	[self showNewGameView];

	
}


- (IBAction)showDailyGame
{
    DLog(@"gUserName:%@", gUserName);
    if ([gUserName isEqualToString:[NSString stringWithFormat:@"%d", (int)gUserID]] == YES ||
        [gUserName length] < 1) {
        
        [self allButtonUnLock];
        [self hideMenuView:NO];	// 메뉴가 사라지고, newgame이 나온다.

        
        [self openChangeNickNameDialog];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0
                                         target:self
                                       selector:@selector(OnTimerIndicatorDailyGame:)
                                       userInfo:nil
                                        repeats:NO];
        
        [self readyToDownloadDailyPuzzle];
        [activityIndicatorDailyStat startAnimating];

        [self allButtonUnLock];
        [self hideMenuView:YES];	// 메뉴가 사라지고, newgame이 나온다.
        [self showDailyGameView];
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
						@"act=%@&version=%d&cs=%ld&size=%d&type=%d&date=%@&file=%@",
                        @"adddailypuzzle",
                        cProtocolVersion,
                        (long)[self getCheckSum],
                        DEFPUZZLESIZE,
                        mainView.nSettingSudokuType,
                        puzzleDate,
                        [self urlEncodeValue:dataFile]];
    
    DLog(@"strURI=\n%@", strURI);
    
    
    NSString* strData = [self GetHTTPData:strURI	timeoutInterval:cDefaultHTTPTimeOut];
    
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

    for (int j=0; j<SUDOKUTYPE_MAX; j++) {
        mainView.nSettingSudokuType = j;
        [com setYear:2015];
        [com setMonth:1];
        [com setDay:1];
        
        date = [[NSCalendar currentCalendar] dateFromComponents:com];
        
        for (int i=0; i<366; i++)
        {
            DLog(@"%@", [formatter stringFromDate:date]);
            [self makeNewGame:GAMELEVEL_NORMAL];
//            [NSThread sleepForTimeInterval:0.1];
            [self sendDailyPuzzle:[formatter stringFromDate:date]];

            date = [date dateByAddingTimeInterval:60*60*24];
        }
    }
    
    [formatter release];
    
	[self hideNewGameView];
    
    
#else
	[self makeNewGameDailyPuzzle];
#endif
}


- (IBAction)newgameUserInput
{
    // only original is allowed
    [Flurry logEvent:@"GameLevel(user input try)"];
    
    [self makeNewGame:GAMELEVEL_USERINPUT];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:gettext(@"Press start button after input puzzle numbers from newspapers and books.", nil)
                          delegate:self
                          cancelButtonTitle:gettext(@"Ok", nil)
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
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

- (void) openChangeNickNameDialog
{
    [Flurry logEvent:@"ChangeNickNameDialog open"];

    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                     message:gettext(@"Please input your nickname", nil)
                                                    delegate:self
                                           cancelButtonTitle:gettext(@"Save", nil)
                                           otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    DLog(@"gUserName:%@", gUserName);
    if ([gUserName isEqualToString:[NSString stringWithFormat:@"%d", (int)gUserID]] != YES)
        textField.text = gUserName;
    else
        textField.text = @"";
    
    [alert show];
    [alert release];
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
    [self makeNewGameDailyPuzzle];
}

- (IBAction)dailygameGt
{
    mainView.nSettingSudokuType = SUDOKUTYPE_GT;
    [self makeNewGameDailyPuzzle];
}

- (IBAction)dailygameKiller
{
    mainView.nSettingSudokuType = SUDOKUTYPE_KILLER;
    [self makeNewGameDailyPuzzle];

}

- (IBAction)dailygameCalcudoku
{
    mainView.nSettingSudokuType = SUDOKUTYPE_CALCU;
    [self makeNewGameDailyPuzzle];
}



- (void) startGameTimer
{
    if (mainView.sudokuGame.isGameFinished)
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
    }
    
    // 광고를 보는 동안에도 힌트 타이머는 계속 간다.
	time = [mainView.sudokuGame updateHintElapsedTime];
	[self updateHintCount];
	
	if (time <= 0)
	{
		[mainView.sudokuGame resetHintTime];
	}

	
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
	BOOL bLock = mainView.bMenuMode ||
                (mainView.sudokuGame && mainView.sudokuGame.isGameFinished) ||
                (mainView.sudokuGame && mainView.sudokuGame.gameLevel == GAMELEVEL_USERINPUT);    
    
    if (bBuyingHint50) {
        buttonHint.alpha = 1.0f;
        buttonHint.enabled = NO;
        [buttonHint	setTitle:gettext(@"buying", nil) forState:UIControlStateNormal];
        return;
    }
    
    if ([mainView.sudokuGame countHint] + mainView.paidHintCount == 0 && productHint50)
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
    return score.scoreTotal;
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
    bannerView_.hidden = YES;
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
    bannerView_.frame = areaAdBanner.frame;
    bannerView_.hidden = NO;
#endif

    [mainView setNeedsDisplay];
    [self startGameTimer];

}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotate
{
	
#ifdef ADMOB_FREEVERSION
    if (cDeviceType != DEVICETYPE_IPAD)
        return NO;
#endif
    return YES;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
#ifdef ADMOB_FREEVERSION
    if (cDeviceType != DEVICETYPE_IPAD)
        return UIInterfaceOrientationMaskPortrait;
#endif
    return UIInterfaceOrientationMaskAll;
}


// Deprecated
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//DLog(@"shouldAutorotateToInterfaceOrientation");

	
	if (interfaceOrientation == UIInterfaceOrientationPortrait ||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)	{

	} else { 
#ifdef ADMOB_FREEVERSION
        if (cDeviceType == DEVICETYPE_IPAD)
        {
            return YES;
        } else {
            return NO;
        }
        
#endif        
	}

	
	return YES;
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:gettext(@"Information", nil)
                                                    message:gettext(@"50 hints were increased.", nil)
                                                   delegate:self
                                          cancelButtonTitle:gettext(@"Ok", nil)
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];

}

- (void)failedBuyHint50:(NSString*)message;
{
    bBuyingHint50 = NO;
    [self updateButtonHint];
    [self updateHintCount];
    NSString *msg = [NSString stringWithFormat:@"%@\n%@", gettext(@"Failed to buy hint item.", nil), message];

    // 실패 메시지
    // 성공 메시지
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:gettext(@"Information", nil)
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:gettext(@"Ok", nil)
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
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

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = alert.title;
    NSString *message = alert.message;
    
    if([title isEqualToString:gettext(@"Congratulations!", nil)]) {
#ifdef ADMOB_FREEVERSION
        [self showInterstitial];
#endif
    } else if([message isEqualToString:gettext(@"Please input your nickname", nil)]) {
        
        NSString *newName = [[[alert textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([newName length] < MIN_NAME) {
            [Flurry logEvent:@"ChangeNickNameDialog Short Name"];

            // Warning
            [self alertLocalizedAlertView:@"Name is too short!"];
        } else {
            [self setUserName:newName];
            //gUserName = newName;
            [self saveServerData];
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


#ifdef ADMOB_FREEVERSION

#pragma mark GADBannerViewDelegate implementation


- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    DLog(@"adViewDidReceiveAd:%@", bannerView.description);
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    DLog(@"adView didFailToReceiveAdWithError:%@", error.description);
    
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    bAd = YES;
    [mainView.sudokuGame bonusGameElapsedTime];
    //[mainView.sudokuGame bonusHintElapsedTime];
    [self updateGameTime:mainView.sudokuGame.gameTime];
    [self updateHintCount];
    
    //[self stopGameTimer];
    
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    bAd = NO;
    //[self startGameTimer];
}

- (void)adViewWillDismissScreen:(GADBannerView *)bannerView
{
    [mainView setNeedsDisplay];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    
}



#pragma mark GADInterstitialDelegate implementation

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    DLog(@"interstitialDidReceiveAd:%@", interstitial.description);
    [self alertFinish];

}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    DLog(@"interstitial didFailToReceiveAdWithError:%@", error.description);
    [self alertFinish];
 
}

#pragma mark GADRequest implementation

- (GADRequest *)request {
    GADRequest *request = [GADRequest request];
    
#ifdef __TEST__
    // Make the request for a test ad. Put in an identifier for the simulator as well as any devices
    // you want to receive test ads.
    request.testDevices = @[
                            // TODO: Add your device/simulator test identifiers here. Your device identifier is printed to
                            // the console when the app is launched.
                            GAD_SIMULATOR_ID
                            ];
#endif
    return request;
}

- (void) loadInterstitial {
    // Create a new GADInterstitial each time.  A GADInterstitial will only show one request in its
    // lifetime. The property will release the old one and set the new one.
    self.interstitial = [[GADInterstitial alloc] init];
    self.interstitial.delegate = self;
    
    // Note: Edit SampleConstants.h to update kSampleAdUnitId with your interstitial ad unit id.
    self.interstitial.adUnitID = MY_INTERSTITIAL_UNIT_ID;
    [self.interstitial loadRequest:[self request]];
}

- (void) showInterstitial {

    // Show the interstitial.
    [self.interstitial presentFromRootViewController:self];
}

#endif

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



