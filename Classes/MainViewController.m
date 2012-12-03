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
#import "MainViewController.h"
#import "MainView.h"
#import "Locale.h"
#import "GameCenterUtil.h"
#import "JMC.h"
#import "KillerMap.h"
#import "AddThis.h"


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
@synthesize buttonCheckboxAutoMemo;
@synthesize buttonNewGameVeryEasy;
@synthesize buttonNewGameEasy;
@synthesize buttonNewGameNormal;
@synthesize buttonNewGameHard;
@synthesize buttonNewGameVeryHard;
@synthesize buttonNewGameCancel;
@synthesize buttonNewGame;
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
@synthesize buttonHistory;
@synthesize buttonFeedback;
@synthesize buttonPlayAgain;
@synthesize buttonSeeReplay;
@synthesize buttonFacebookRecord;
@synthesize buttonFacebookPuzzle;
@synthesize buttonTwitterRecord;
@synthesize buttonTwitterPuzzle;


@synthesize viewMenu;
@synthesize viewNewGame;
@synthesize labelLevel;
@synthesize labelGameTime;
@synthesize labelBlank;
@synthesize labelHint;
@synthesize timerGame;
@synthesize timerNewGame;
@synthesize activityIndicator;
@synthesize segmentType;
@synthesize labelLicense;



- (void) initScore
{
	DLog(@"initScore");	
	for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int i=0; i<10; i++)
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

#ifdef SUDOKU9
#define kScoreGames			@"scoreGames"
#define kScoreClears		@"scoreClears"
#define kScoreBestTime		@"scoreBestTime"
#define kScoreClearTimeSum	@"scoreClearTimeSum"
#define kScoreRankLevel     @"scoreRankLevel"
#define kScoreRankTotal     @"scoreRankTotal"
#define kScoreTotal         @"scoreTotal"
#elif SUDOKU7
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

- (void) saveScoreData
{
	DLog(@"saveScoreData");	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int i=0; i<10; i++)
        {
            [defaults setInteger:score.scoreGames[type][i] forKey:[kScoreGames stringByAppendingFormat:@"%d", i+type*10]];
            [defaults setInteger:score.scoreClears[type][i] forKey:[kScoreClears stringByAppendingFormat:@"%d", i+type*10]];
            [defaults setInteger:score.scoreBestTime[type][i] forKey:[kScoreBestTime stringByAppendingFormat:@"%d", i+type*10]];
            [defaults setInteger:score.scoreClearTimeSum[type][i] forKey:[kScoreClearTimeSum stringByAppendingFormat:@"%d", i+type*10]];
            [defaults setInteger:score.scoreRankLevel[type][i] forKey:[kScoreRankLevel stringByAppendingFormat:@"%d", i+type*10]];
        
            //DLog(@"[%d][%d] %@", type, i, [kScoreRankLevel stringByAppendingFormat:@"%d", i+type*SUDOKUTYPE_MAX]);
            if (i < 5)
            {
                //DLog(@"scoreRankLevel[%d][%d]=%d", type, i, score.scoreRankLevel[type][i]);
            }
        }
    }
    [defaults setInteger:score.scoreTotal forKey:kScoreTotal];
    [defaults setInteger:score.scoreRankTotal forKey:kScoreRankTotal];
    DLog(@"scoreRankTotal=%d", score.scoreRankTotal);
	[defaults synchronize];
}

- (NSInteger) getGameResultScore:(NSInteger)level sec:(NSInteger)sec
{
    NSInteger scoreTemp = MIN(sec/60+1, 10);
    
	if (scoreTemp < 5)
		scoreTemp = (5-level) * (10 - scoreTemp + 1) * 3;	// Original은 3배의 점수를 준다.
    else
		scoreTemp = (10-level) * (10 - scoreTemp + 1);
		
#ifdef SUDOKU9  // zzz 나중에는 size 넘겨줘서 계산 해야 한다.
    scoreTemp = scoreTemp * (SIZE_9*SIZE_9)/100;
#else
    scoreTemp = scoreTemp * (SIZE_6*SIZE_6)/100;
#endif
    scoreTemp = MAX(scoreTemp, 1);

    DLog(@"getGameResultScore(%d,%d) => %d", level, sec, scoreTemp);
    
    return scoreTemp;
}

- (void) loadScoreData
{
	DLog(@"loadScoreData");	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int i=0; i<10; i++)
        {
            score.scoreGames[type][i] = [defaults integerForKey:[kScoreGames stringByAppendingFormat:@"%d", i+type*10]];
            score.scoreClears[type][i] = [defaults integerForKey:[kScoreClears stringByAppendingFormat:@"%d", i+type*10]];
            score.scoreBestTime[type][i] = [defaults integerForKey:[kScoreBestTime stringByAppendingFormat:@"%d", i+type*10]];
            score.scoreClearTimeSum[type][i] = [defaults integerForKey:[kScoreClearTimeSum stringByAppendingFormat:@"%d", i+type*10]];
            score.scoreRankLevel[type][i] = [defaults integerForKey:[kScoreRankLevel stringByAppendingFormat:@"%d", i+type*10]];
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

    DLog(@"scoreTotal = %d", score.scoreTotal);
    
}



- (void) writeScoreAfterFinishGame:(SudokuGame*)sudokuGame
{
	// button diable
	
	DLog(@"writeScoreAfterFinishGame");	
    BOOL bNewBest = NO;
	NSInteger level = sudokuGame.gameLevel + (sudokuGame.bAutoMemo ? 5 : 0);
    
	score.scoreClears[sudokuGame.sudokuType][level] += 1;
    
	if (score.scoreBestTime[sudokuGame.sudokuType][level] == 0 ||                     // 최초는 무조건 Best time
		sudokuGame.gameTime < score.scoreBestTime[sudokuGame.sudokuType][level])
    {
        if (score.scoreBestTime[sudokuGame.sudokuType][level] != 0)
        {
            bNewBest = YES;
        }
		score.scoreBestTime[sudokuGame.sudokuType][level] = sudokuGame.gameTime;      // best time 갱신
        
	}
    
    
    
    NSString* strMsg = [NSString stringWithString:gettext(@"You cleared this game.", nil)];
    if (bNewBest)
    {
        strMsg = [strMsg stringByAppendingString:@"\n"];
        strMsg = [strMsg stringByAppendingString:gettext(@"You broke your best time.", nil)];
    }
    strMsg = [strMsg stringByAppendingString:@"\n"];
    strMsg = [strMsg stringByAppendingFormat:
              gettext(@"If you share this puzzle or result on Facebook, you can get %d more hints in next game.", nil),
              NUM_HINTBONUS];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:gettext(@"Congratulations!", nil)
                                                    message:strMsg
                                                   delegate:self
                                          cancelButtonTitle:gettext(@"Ok", nil)
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];

    
	
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
    [GameCenterUtil sendBestTimeToGameCenter:sudokuGame.sudokuType
                                       level:sudokuGame.gameLevel
                                    besttime:score.scoreBestTime[sudokuGame.sudokuType][sudokuGame.gameLevel]];
    [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(OnTimerGetRanking:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) getRankingFromGameCenter
{
    DLog(@"getRankingFromGameCenter");
    [GameCenterUtil getTotalScoreRanking:&(score.scoreRankTotal) value:&(score.scoreTotal)];
    
    for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int level=0; level<NUM_RANK_BESTTIME; level++)
        {
            if (1)//score.scoreBestTime[type][level] > 0)
            {
                [GameCenterUtil getRanking:[GameCenterUtil getLevelCategory:type level:level]
                                      rank:&(score.scoreRankLevel[type][level])
                                     value:&(score.scoreBestTime[type][level])];
            } else {
                score.scoreRankLevel[type][level] = 0;  // best time이 없음
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
    mainView.nSettingSudokuType = [defaults integerForKey:kSettingSudokuType];
    mainView.skin = [defaults integerForKey:kSettingSkin];
    
    mainView.bSharedThisOnFacebook = [defaults boolForKey:kSharedThisOnFacebook];

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
    
	[defaults synchronize];
}

- (void) setLocalizedMessage
{
	DLog(@"setLocalizedMessage");
	
    labelLicense.text = STR_LICENSE;

    
    [buttonNewGame		setTitle:gettext(@"New game", nil) forState:UIControlStateNormal];
    [buttonScore		setTitle:gettext(@"Score", nil) forState:UIControlStateNormal];
    [buttonSetting		setTitle:gettext(@"Setting", nil) forState:UIControlStateNormal];
    [buttonReset		setTitle:gettext(@"reset", nil) forState:UIControlStateNormal];
    [buttonSharePuzzle  setTitle:gettext(@"Share puzzle", nil) forState:UIControlStateNormal];
	[buttonHelp			setTitle:gettext(@"Help", nil) forState:UIControlStateNormal];
	[buttonFeedback		setTitle:gettext(@"Feedback", nil) forState:UIControlStateNormal];
	[buttonMenuClose	setTitle:gettext(@"Close", nil) forState:UIControlStateNormal];

    [buttonMenu			setTitle:gettext(@"menu", nil) forState:UIControlStateNormal];
    [buttonMemo			setTitle:gettext(@"memo", nil) forState:UIControlStateNormal];
    [buttonDel			setTitle:gettext(@"del", nil) forState:UIControlStateNormal];
    [buttonHint			setTitle:gettext(@"hint", nil) forState:UIControlStateNormal];
    [buttonPlayAgain    setTitle:gettext(@"Play again", nil) forState:UIControlStateNormal];
    [buttonSeeReplay    setTitle:gettext(@"Watch replay", nil) forState:UIControlStateNormal];
    [buttonFacebookRecord    setTitle:gettext(@"Share record on Facebook", nil) forState:UIControlStateNormal];
    [buttonFacebookPuzzle    setTitle:gettext(@"Share puzzle on Facebook", nil) forState:UIControlStateNormal];
    [buttonTwitterRecord    setTitle:gettext(@"Share record on Twitter", nil) forState:UIControlStateNormal];
    [buttonTwitterPuzzle    setTitle:gettext(@"Share puzzle on Twitter", nil) forState:UIControlStateNormal];
    

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
    //labelNewGame.text = gettext(@"New Game", nil);
    
	
	[buttonCheckboxAutoMemo setTitle:@"" forState:UIControlStateNormal];
	labelAutoMemo.text = gettext(@"auto memo", nil);
	
    [buttonNewGameVeryEasy setTitle:gettext(@"very easy", nil) forState:UIControlStateNormal];
    [buttonNewGameEasy setTitle:gettext(@"easy", nil) forState:UIControlStateNormal];
    [buttonNewGameNormal setTitle:gettext(@"normal", nil) forState:UIControlStateNormal];
    [buttonNewGameHard setTitle:gettext(@"hard", nil) forState:UIControlStateNormal];
    [buttonNewGameVeryHard setTitle:gettext(@"very hard", nil) forState:UIControlStateNormal];
    [buttonNewGameCancel setTitle:gettext(@"cancel", nil) forState:UIControlStateNormal];

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
	   
       [self decideLocale];
       
       [self loadSetting];
       [self setLocalizedMessage];
       [mainView initSkinColorData];
       [mainView initRainbowColorData];

	   if ([mainView loadGame] == YES) {
			[self setGameLevel];
			[self updateBlankCellCount];
			[self updateHintCount];
            [self startGameTimer];          // load 했을 때만 Timer를 시작한다.
		} else {
			levelNewGame = GAMELEVEL_NORMAL;	// normal로 새로운 게임을 무조건 생성한다.
			[self makeNewGameData];
			
			[self setGameLevel];
			[self updateBlankCellCount];
			[self updateHintCount];
            [self startGameTimer];

			firstRun = YES;
		}
		[self initScore];
		[self loadScoreData];
	    [self updateButtons];
	    [self showHintButton];
	   
	   if (firstRun)
	   {
		 //  [self showHelpView];
	   }
    }
    return self;
}


- (void) viewDidDisappear:(BOOL)animated
{
    DLog(@"MainViewController:viewDidDisappear");
}

- (void)viewDidAppear:(BOOL)animated
{
    DLog(@"MainViewController:viewDidAppear(nAddThisWait=%d)", nAddThisWait);
    if (nAddThisWait > 0)
    {
        nAddThisWait++;
        return;
    } else {
        if (mainView.bMenuMode)
        {
            [self hideMenuView:NO];
        }
        // Share puzzle용
        //[self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.3];
        if (SUPPORT_ROTATION)
            self.view.frame = [[UIScreen mainScreen] applicationFrame];

        //[self willRotateToInterfaceOrientation:[UIDevice currentDevice].orientation duration:0.3];

    }
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


	 [viewMenu setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg6.png"]]];
	 viewMenu.layer.cornerRadius = viewMenu.frame.size.width/12;
	 viewMenu.layer.masksToBounds = YES;
	 [viewNewGame setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg6.png"]]];
	 viewNewGame.layer.cornerRadius = viewNewGame.frame.size.width/12;
	 viewNewGame.layer.masksToBounds = YES;
	 [self hideAwayView:viewMenu];
	 [self hideAwayView:viewNewGame];



     
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
     nAddThisWait = 0;
	 
     
     //configure addthis -- (this step is optional)
     [AddThisSDK setNavigationBarColor:[UIColor lightGrayColor]];
     [AddThisSDK setToolBarColor:[UIColor lightGrayColor]];
     [AddThisSDK setSearchBarColor:[UIColor lightGrayColor]];
     
     //Facebook connect settings
     //CHANGE THIS FACEBOOK API KEY TO YOUR OWN!!
     [AddThisSDK setFacebookAPIKey:FACEBOOK_SMARTONE_ID];
//     [AddThisSDK setFacebookAuthenticationMode:ATFacebookAuthenticationTypeDefault];
     [AddThisSDK setFacebookAuthenticationMode:ATFacebookAuthenticationTypeFBConnect];

     [AddThisSDK setAddThisPubId:ADDTHIS_MYPUBID];
     [AddThisSDK setAddThisApplicationId:ADDTHIS_MYAPPID];
     
     
     //CHANGE THIS TWITTER API KEYS TO YOUR OWN!!
     [AddThisSDK setTwitterConsumerKey:@"Oz2ldTCKZwlPFULDBHYg"];
     [AddThisSDK setTwitterConsumerSecret:@"UE2ELTkz3Gmvav2PYLsNOYHDOSMi0pbg9uAhEPdo"];
     [AddThisSDK setTwitterCallBackURL:@"http://gracegyu.zendesk.com"];
     
     [AddThisSDK setTwitPicAPIKey:@"deec47835aadb6e6b68a5d1015e4666b"];
     [AddThisSDK setTwitterAuthenticationMode:ATTwitterAuthenticationTypeOAuth];
     [AddThisSDK setTwitterViaText:@"smartone3929 "];
     
     
     [AddThisSDK canUserEditServiceMenu:YES];
     [AddThisSDK canUserReOrderServiceMenu:YES];
     [AddThisSDK setDelegate:self];
     
     
     
     [GameCenterUtil connectGameCenter:self];       //게임센터 접속~
     
     
     
     if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
     {
         buttonTwitterPuzzle.enabled = NO;
         buttonTwitterRecord.enabled = NO;
         buttonSharePuzzle.enabled = NO;
     }
         
     

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
    DLog(@"self.interfaceOrientation=%d", self.interfaceOrientation);
    DLog(@"[UIDevice currentDevice].orientation=%d", [UIDevice currentDevice].orientation);
    DLog(@"[UIApplication sharedApplication].statusBarOrientation=%d", [UIApplication sharedApplication].statusBarOrientation);
    
    
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
	label.text = [NSString stringWithFormat:@"%d", num];
}

- (void) setTime:(UILabel*)label num:(NSInteger)num
{
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

}

- (IBAction) showScoreView
{
	[self hideMenuView:NO];
    [self getRankingFromGameCenter];    // 최신 랭킹으로 update

	ScoreViewController *controller = [[ScoreViewController alloc] initWithNibName:
										  cDeviceType == DEVICETYPE_IPAD ? @"ScoreView4iPad" : 
										  @"ScoreView" bundle:nil];
    controller.mainViewController = self;
	[controller setScoreData:&score];
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;//UIModalTransitionStylePartialCurl;
	[self presentModalViewController:controller animated:YES];

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
	[self updateBlankCellCount];
	[self updateHintCount];
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

	[mainView playSoundClick];
	[mainView runUndo];
	[self updateBlankCellCount];
	[self updateHintCount];
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

	[mainView playSoundClick];
	[mainView runRedo];
	[self updateBlankCellCount];
	[self updateHintCount];
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

	[mainView runBookmark];
	
	[self updateBlankCellCount];
	[self updateHintCount];
	[self updateButtons];

}


- (void)updateButtonMemo
{
	if (mainView.bMemoMode)
	{
		buttonMemo.alpha = 1.f;	
	} else {
		buttonMemo.alpha = 0.5f;	
	}
	
	BOOL bLock = mainView.bMenuMode || (mainView.sudokuGame && mainView.sudokuGame.isGameFinished);
	
	buttonMemo.enabled = bLock ? NO : YES;
}

- (IBAction) memoOnOff
{
	if (mainView.bMenuMode || !mainView.sudokuGame)
		return;

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
	
	[mainView clearNumbers];	// memo모드에서 실행하는 메뉴임
    
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
        bReplay = NO;
        [self updateButtons];
    }
}

- (IBAction)seeReplay
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
    }


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

- (IBAction) playAgain
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
    }

    
    // see Replay 중이면 멈춰야 한다. timer 멈춘다.
    bReplay = NO;
    
    
    [mainView.sudokuGame replayGames];

    [self increaseScoreGames];  // 게임 시작 점수 추가
	[self saveScoreData];
	
	[self updateGameTime:0];
    [self updateBlankCellCount];
    [self updateHintCount];

    [self updateButtons];

    //[mainView playSoundClick];
    [mainView.sudokuGame saveData];
    
    [mainView setNeedsDisplay];

    [self startGameTimer];
}

- (void) OnTimerSharePuzzleFacebook:(NSTimer *)timer
{
    if (nAddThisWait >= 3)  
    {
        [self callAddThisShareImage:@"facebook"];
    }
    nAddThisWait = 0;
}

- (IBAction)sharePuzzleFacebook
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
    }

    
    [self callAddThisShareImage:@"facebook"];

    static BOOL isFirst = YES;
    nAddThisWait = 0;
    
    if (isFirst)
    {
        isFirst = NO;
        nAddThisWait = 1;
        [NSTimer scheduledTimerWithTimeInterval:2       // 2초안에 저절로 닫히면 재실행한다.
                                         target:self
                                       selector:@selector(OnTimerSharePuzzleFacebook:)
                                       userInfo:nil
                                        repeats:NO];
    }
}


- (void) callAddThisShareImage:(NSString*) service
{
    NSString *appName = gettexttable(@"CFBundleDisplayName", @"InfoPlist");
    NSString *strTitle = [NSString stringWithFormat:@"%@(%@)", appName, SHORTENURL];
    NSString *strDesc;
    
    if (mainView.sudokuGame.isGameFinished)
    {
        strDesc = [NSString stringWithFormat:gettext(@"I cleared this puzzle. Why don't you try to solve it.", nil)];
    } else {
        strDesc = [NSString stringWithFormat:gettext(@"I'm solving this puzzle now.", nil)];
    }
    
    NSString *strAdd = [NSString stringWithFormat:@"%@ %@", strDesc, strTitle];
    
    UIGraphicsBeginImageContext(CGSizeMake(DRAWONIMAGE_W,DRAWONIMAGE_H));
    
	// draw original image into the context
	//[image drawAtPoint:CGPointZero];
    
	// get the context for CoreGraphics
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [mainView drawOnImage:ctx strTime:labelGameTime.text];
    
    
	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
	// free the context
	UIGraphicsEndImageContext();
    
    
	[AddThisSDK shareImage:retImage
               withService:service
                     title:strAdd
               description:@""];

    mainView.bSharedThisOnFacebook = YES;
    [self saveSetting];
}


- (IBAction)sharePuzzleTwitter
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
    }

    
    [self callAddThisShareImage:@"twitter"];
    
}

- (IBAction)shareRecordFacebook
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
    }
    
    [self callAddThisShareURL:@"facebook"];
}

- (void) callAddThisShareURL:(NSString*) service
{
    NSString *strURL = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", APP_ID];
    NSString *appName = gettexttable(@"CFBundleDisplayName", @"InfoPlist");
    NSString *strTitle = [NSString stringWithFormat:gettext(@"I cleared %@ %@ puzzle.", nil),
                          STR_MATRIXSIZE,
                          appName];
    NSString *strDesc = [NSString stringWithFormat:gettext(@"%@:%@, %@:%@", nil),
                         gettext(@"level", nil),
                         labelLevel.text,
                         gettext(@"time", nil),
                         labelGameTime.text];
    NSString *strAdd = [NSString stringWithFormat:@"%@ (%@)", strTitle, strDesc];
    
	[AddThisSDK shareURL:strURL
			 withService:service
				   title:strAdd
			 description:@""];
    
    mainView.bSharedThisOnFacebook = YES;
    [self saveSetting];
}
- (IBAction)shareRecordTwitter
{
    if (mainView.bMenuMode)
    {
        [self hideMenuView:NO];
    }

    
    [self callAddThisShareURL:@"twitter"];
}



- (void)showHintButton
{
	[self updateButtonHint];
}


- (IBAction) doHint
{
	if (mainView.bMenuMode)
		return;

	//zzzzzzzzzzzzzzzz
    //[self shareToTwitter];
    
    
	[mainView doHint];
}



- (IBAction)showSettingView
{
	[self hideMenuView:NO];

    DLog(@"showSettingView");
    SettingViewController *controller = [[SettingViewController alloc] initWithNibName:
                                       cDeviceType == DEVICETYPE_IPAD ? @"SettingView4iPad" :
                                       @"SettingView" bundle:nil];
    controller.mainViewController = self;
//	controller.title = gettext(@"Setting", nil);
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;//UIModalTransitionStylePartialCurl;
	[self presentModalViewController:controller animated:YES];
    // UIModalTransitionStyleCrossDissolve for newgame
	
	
//	controller.title = gettext(@"Setting", nil);
    
	
	[controller release];

    
}

- (IBAction)showHelpView
{
	[self hideMenuView:NO];
	
    DLog(@"showSettingView");
    HelpViewController *controller = [[HelpViewController alloc] initWithNibName:
										 cDeviceType == DEVICETYPE_IPAD ? @"HelpView4iPad" :
										 @"HelpView" bundle:nil];
    controller.mainViewController = self;	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
	
    
}

- (IBAction)showFeedbackView
{
	//[self hideMenuView:NO];
	
	UIViewController *controller = [[JMC sharedInstance] viewController];
    [self presentModalViewController:controller animated:YES];
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
	buttonNewGameVeryEasy.enabled = NO;
	buttonNewGameEasy.enabled = NO;	
	buttonNewGameNormal.enabled = NO;	
	buttonNewGameHard.enabled = NO;	
	buttonNewGameVeryHard.enabled = NO;	
	buttonNewGameCancel.enabled = NO;	
}

- (void) allButtonUnLock
{
	buttonNewGameVeryEasy.enabled = YES;
	buttonNewGameEasy.enabled = YES;	
	buttonNewGameNormal.enabled = YES;	
	buttonNewGameHard.enabled = YES;	
	buttonNewGameVeryHard.enabled = YES;	
	buttonNewGameCancel.enabled = YES;	
}

- (void) setGameLevel
{
	switch (mainView.sudokuGame.gameLevel) {
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
	
	if (viewMenu.frame.origin.x-intervalX > 0)
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
		[self startGameTimer];
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
	[self startGameTimer];
	[self updateButtons];
}


- (void)OnTimerShowNewGame:(NSTimer *)timer
{
	CGRect frameOld = viewNewGame.frame;
    frameOld.origin.x -= intervalX2;
    viewNewGame.frame = frameOld;
	
	if (viewNewGame.frame.origin.x-intervalX2 > 0)
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
	intervalX2 = (viewNewGame.frame.origin.x)/25;
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
	[self updateBlankCellCount];
    [self updateHintCount];
	[self updateButtons];
	
}

- (void) updateGameTime:(NSInteger) time
{
	NSString *str;
	
	if (time >= 60*60*100)
		time = 60*60*100 - 1;
	
	if (time >= 60*60)
		str = [NSString stringWithFormat:@"%d:%02d:%02d",
			   time / (60*60),
			   time / (60) % (60),
			   time % (60)];
	else 
		str = [NSString stringWithFormat:@"%02d:%02d",
			   time / (60),
			   time % (60)];
	
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

#ifdef SUDOKU9
#define DEFPUZZLESIZE   SIZE_9
#elif SUDOKU8
#define DEFPUZZLESIZE   SIZE_8
#elif SUDOKU7
#define DEFPUZZLESIZE   SIZE_7
#elif SUDOKU6
#define DEFPUZZLESIZE   SIZE_6
#else
#define DEFPUZZLESIZE   SIZE_9
#endif

- (void) increaseScoreGames
{
	if (mainView.sudokuGame)
	{
		score.scoreGames[mainView.sudokuGame.sudokuType][mainView.sudokuGame.gameLevel + (mainView.sudokuGame.bAutoMemo ? 5 : 0)] += 1;     // 게임 수 1 증가
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

//	[self startIndicator];
	[activityIndicator startAnimating];
	levelNewGame = level;

	timerNewGame = [NSTimer scheduledTimerWithTimeInterval:0 
												target:self
											  selector:@selector(OnTimerNewGame:)
											  userInfo:nil
											   repeats:NO];	
	
	
}	

- (IBAction)menuCancel
{
	[self hideMenuView:NO];
}

- (IBAction)showNewGame
{
    [self setSudokuTypeSegment];
    
	[self allButtonUnLock];
	[self hideMenuView:YES];	// 메뉴가 사라지고, newgame이 나온다.
	[self showNewGameView];
	
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
}

- (IBAction)changeAutoMemo
{
	mainView.bSettingAutoMemo = !mainView.bSettingAutoMemo;
	[self updateButtonMenu];
	
	[self saveSetting];
}

- (IBAction)setSudokuType
{
    mainView.nSettingSudokuType = [segmentType selectedSegmentIndex];
    
	[self saveSetting];
}

- (void) setSudokuTypeSegment
{
    segmentType.selectedSegmentIndex = mainView.nSettingSudokuType;
}



- (void) startGameTimer
{
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
	str = [NSString stringWithFormat:@"%d", count];
	
	labelBlank.text =str;
}



- (void) updateHintCount
{
	if (!mainView.sudokuGame)
		return;
	
	NSInteger count = mainView.sudokuGame.countHint;
	NSInteger time = (NSInteger)mainView.sudokuGame.hintTime;
	labelHint.text =[NSString stringWithFormat:@"%d(%d:%02d)", count, time/60, time%60];


}


- (void) updateButtonClear
{
	if (!mainView.sudokuGame)
		return;
	
	BOOL bLock = (mainView.sudokuGame && mainView.sudokuGame.isGameFinished);
	NSInteger count = [mainView.sudokuGame countFixCells];

	if (count > 0)	{
		buttonReset.alpha = 1.0f;
		buttonReset.enabled = bLock ? NO : YES;
	} else {
		buttonReset.alpha = 0.3f;
		buttonReset.enabled = NO;		
	}
}

- (void) updateButtonDel
{
	BOOL bLock = mainView.bMenuMode || (mainView.sudokuGame && mainView.sudokuGame.isGameFinished);

	if ([mainView isSelectedCellisFixed])	{
		buttonDel.alpha = 1.0f;
		buttonDel.enabled = bLock ? NO : YES;
	} else {
		buttonDel.alpha = 0.5f;
		buttonDel.enabled = NO;		
	}
}

- (void) updateButtonHint	// TODO Hint 아이템이 남아있고 힌트 가능한 셀일경우 On;
{
	BOOL bLock = mainView.bMenuMode || (mainView.sudokuGame && mainView.sudokuGame.isGameFinished);
	
	if ([mainView isSelectedCellisableHint])	{	// AND Hint item > 0
		buttonHint.alpha = 1.0f;
		buttonHint.enabled = bLock ? NO : YES;
	} else {
		buttonHint.alpha = 0.5f;
		buttonHint.enabled = NO;		
	}
}

- (void) updateButtonMenu
{
	// 메뉴는 항상 눌릴 수 있어야 한다. -  안된다. new game 창에서 menu가 나온다.
	buttonMenu.enabled = mainView.bMenuMode ? NO : YES;
	
	if (mainView.bSettingAutoMemo)
		[buttonCheckboxAutoMemo setBackgroundImage:[UIImage imageNamed:@"checkbox_c.png"] forState:UIControlStateNormal];
	else
		[buttonCheckboxAutoMemo setBackgroundImage:[UIImage imageNamed:@"checkbox_u.png"] forState:UIControlStateNormal];
}


- (NSInteger) getBestTime:(NSInteger)level
{
    return score.scoreBestTime[mainView.sudokuGame.sudokuType][level];
}

- (NSInteger) getTotalScore
{
    return score.scoreTotal;
}


- (void) updateButtons
{
	[self updateButtonMenu];
	[self updateButtonHint];
	[self updateButtonClear];
	[self updateButtonUndo];
	[self updateButtonDel];
	[self updateButtonMemo];
    
    buttonPlayAgain.hidden = !mainView.sudokuGame.isGameFinished;
    buttonSeeReplay.hidden = !mainView.sudokuGame.isGameFinished;
    buttonSeeReplay.enabled = !bReplay;
    
    if (0)//FACEBOOK_ID == @"")
    {
        buttonFacebookRecord.hidden = YES;
        buttonFacebookPuzzle.hidden = YES;
    } else {
        buttonFacebookRecord.hidden = !mainView.sudokuGame.isGameFinished;
        buttonFacebookPuzzle.hidden = !mainView.sudokuGame.isGameFinished;
        buttonTwitterRecord.hidden = !mainView.sudokuGame.isGameFinished;
        buttonTwitterPuzzle.hidden = !mainView.sudokuGame.isGameFinished;
    }
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



#ifdef ADMOB_FREEVERSION

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{

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



#endif

- (IBAction)LeftSwipe:(id)sender
{
    DLog(@"handleLeftSwipe called");
    
}

- (NSString *)jiraIssueTypeNameFor:(JMCIssueType)type
{
    if (type == JMCIssueTypeCrash) {
        return @"Bug";
    } else if (type == JMCIssueTypeFeedback) {
        return @"Improvement";
    }
    return nil;
}
/*

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    
    [super presentViewController:self animated:flag completion:completion];
    
}
*/
@end
