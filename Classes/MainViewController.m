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



@implementation MainViewController

@synthesize mainView;
@synthesize labelNewGame;
@synthesize labelRights;
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
@synthesize buttonHint;
@synthesize buttonSetting;
@synthesize buttonMenuClose;
@synthesize buttonHelp;
@synthesize buttonHistory;
@synthesize buttonFeedback;

@synthesize viewMenu;
@synthesize viewNewGame;
@synthesize labelLevel;
@synthesize labelGameTime;
@synthesize labelBlank;
@synthesize labelHint;
@synthesize timerGame;
@synthesize timerNewGame;
@synthesize activityIndicator;



- (void) initScore
{
	DLog(@"initScore");	
	
	
	for (int i=0; i<10; i++)
	{
		scoreGames[i] = 0;
		scoreClears[i] = 0;
		scoreBestTime[i] = 0;
		scoreClearTimeSum[i] = 0;
	}
    scoreTotal = 0;
}

#ifdef SUDOKU9
#define kScoreGames			@"scoreGames"
#define kScoreClears		@"scoreClears"
#define kScoreBestTime		@"scoreBestTime"
#define kScoreClearTimeSum	@"scoreClearTimeSum"
#define kScoreTotal         @"scoreTotal"
#elif SUDOKU7  
#define kScoreGames			@"score7Games"
#define kScoreClears		@"score7Clears"
#define kScoreBestTime		@"score7BestTime"
#define kScoreClearTimeSum	@"score7ClearTimeSum"
#define kScoreTotal         @"score7Total"
#else   // SUDOKU6
#define kScoreGames			@"score6Games"
#define kScoreClears		@"score6Clears"
#define kScoreBestTime		@"score6BestTime"
#define kScoreClearTimeSum	@"score6ClearTimeSum"
#define kScoreTotal         @"score6Total"
#endif

- (void) saveScoreData
{
	DLog(@"saveScoreData");	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	for (int i=0; i<10; i++)
	{
		[defaults setInteger:scoreGames[i] forKey:[kScoreGames stringByAppendingFormat:@"%d", i]];
		[defaults setInteger:scoreClears[i] forKey:[kScoreClears stringByAppendingFormat:@"%d", i]];
		[defaults setInteger:scoreBestTime[i] forKey:[kScoreBestTime stringByAppendingFormat:@"%d", i]];
		[defaults setInteger:scoreClearTimeSum[i] forKey:[kScoreClearTimeSum stringByAppendingFormat:@"%d", i]];
	}
    [defaults setInteger:scoreTotal forKey:kScoreTotal];
	[defaults synchronize];
}

- (NSInteger) getGameResultScore:(NSInteger)level sec:(NSInteger)sec
{
    NSInteger score = MIN(sec/60+1, 10);
    
	if (score < 5)
		score = (5-level) * (10 - score + 1) * 3;	// Original은 3배의 점수를 준다.
    else
		score = (10-level) * (10 - score + 1);
		
#ifdef SUDOKU9  // zzz 나중에는 size 넘겨줘서 계산 해야 한다.
    score = score * (SIZE_9*SIZE_9)/100;
#else
    score = score * (SIZE_6*SIZE_6)/100;
#endif
    score = MAX(score, 1);

    DLog(@"getGameResultScore(%d,%d) => %d", level, sec, score);
    
    return score;
}

- (void) loadScoreData
{
	DLog(@"loadScoreData");	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	for (int i=0; i<10; i++)
	{
		scoreGames[i] = [defaults integerForKey:[kScoreGames stringByAppendingFormat:@"%d", i]];
		scoreClears[i] = [defaults integerForKey:[kScoreClears stringByAppendingFormat:@"%d", i]];
		scoreBestTime[i] = [defaults integerForKey:[kScoreBestTime stringByAppendingFormat:@"%d", i]];
		scoreClearTimeSum[i] = [defaults integerForKey:[kScoreClearTimeSum stringByAppendingFormat:@"%d", i]];
	}
    
    scoreTotal = [defaults integerForKey:kScoreTotal];
	if (scoreTotal == 0)
    {
        // need to migration
        for (int i=0; i<10; i++)
        {
            scoreTotal += scoreGames[i];    // 게임 시작하면 무조건 1점씩 추가 됨
            if (scoreClears[i] > 0)
                scoreTotal += scoreClears[i] * [self getGameResultScore:i sec:scoreClearTimeSum[i]/scoreClears[i]];
        }
	}
    DLog(@"scoreTotal = %d", scoreTotal);
    
}



- (void) writeScoreAfterFinishGame:(SudokuGame*)sudokuGame
{
	// button diable
	
	DLog(@"writeScore");	
    BOOL bNewBest = NO;
	NSInteger level = sudokuGame.gameLevel + (sudokuGame.bAutoMemo ? 5 : 0);
    
	scoreClears[level] += 1;
    
	if (scoreBestTime[level] == 0 ||                     // 최초는 무조건 Best time
		sudokuGame.gameTime < scoreBestTime[level])
    {
        if (scoreBestTime[level] != 0)
        {
            bNewBest = YES;
        }
		scoreBestTime[level] = sudokuGame.gameTime;      // best time 갱신
        
	}
    
    
    
    NSString* strMsg = [NSString stringWithString:gettext(@"You cleared this game.", nil)];
    if (bNewBest)
    {
        strMsg = [strMsg stringByAppendingString:@"\n"];
        strMsg = [strMsg stringByAppendingString:gettext(@"You broke your best time.", nil)];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:gettext(@"Conglaturations!", nil)
                                                    message:strMsg
                                                   delegate:self
                                          cancelButtonTitle:gettext(@"Ok", nil)
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];

    
    
    
	if (sudokuGame.bAutoMemo == NO)
	{
		// 하위 호환을 위해서 무조건 best time을 보내기
		[GameCenterUtil sendBestTimeToGameCenter:sudokuGame.gameLevel besttime:scoreBestTime[sudokuGame.gameLevel]];
    }
	
    scoreClearTimeSum[level] += sudokuGame.gameTime;
	
    // add current game score to Total Score
    scoreTotal += [self getGameResultScore:level sec:sudokuGame.gameTime];
    scoreTotal += sudokuGame.countHint*3;   // 남은 힌트 점수 추가
    
	[self saveScoreData];
    
	if (sudokuGame.bAutoMemo == NO)
	{
		// 총점 보내기
		[GameCenterUtil sendScoreToGameCenter:scoreTotal];
		// best time 보내기
		[GameCenterUtil sendBestTimeToGameCenter:sudokuGame.gameLevel besttime:scoreBestTime[sudokuGame.gameLevel]];
		// achievement 보내기
		[GameCenterUtil sendAchievementClearGame:scoreClears[0]+scoreClears[1]+scoreClears[2]+scoreClears[3]+scoreClears[4]];
	}
	
	[self updateButtons];
}

#define SETTING_VERSION                 1
#define kSettingSavedVersion            @"settingSavedVersion"
#define kSettingSoundEffect             @"settingSoundEffect"
#define kSettingGuideline               @"settingGuideline"
#define kSettingDuplicationWarning      @"settingDuplicationWarning"
#define kSettingMarkingEqual            @"settingMarkingEqual"
#define kSettingDefMap                  @"settingDefMap"
#define kSettingAutoMemo                @"settingAutoMemo"

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
    
    mainView.bSettingSoundOff = [defaults boolForKey:kSettingSoundEffect];
    mainView.bSettingGuideline = [defaults boolForKey:kSettingGuideline];
    mainView.bSettingDuplicationWarning = [defaults boolForKey:kSettingDuplicationWarning];
    mainView.bSettingMarkingEqual = [defaults boolForKey:kSettingMarkingEqual];
    //mainView.bSettingDefMap = [defaults boolForKey:kSettingDefMap];
    mainView.bSettingAutoMemo = [defaults boolForKey:kSettingAutoMemo];
}

- (void) saveSetting
{
	DLog(@"saveSetting");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:SETTING_VERSION forKey:kSettingSavedVersion];
    [defaults setBool:mainView.bSettingSoundOff forKey:kSettingSoundEffect];
    [defaults setBool:mainView.bSettingGuideline forKey:kSettingGuideline];
    [defaults setBool:mainView.bSettingDuplicationWarning forKey:kSettingDuplicationWarning];
    [defaults setBool:mainView.bSettingMarkingEqual forKey:kSettingMarkingEqual];
    //[defaults setBool:mainView.bSettingDefMap forKey:kSettingDefMap];
    [defaults setBool:mainView.bSettingAutoMemo forKey:kSettingAutoMemo];
	
	[defaults synchronize];
}

- (void) setLocalizedMessage
{
	DLog(@"setLocalizedMessage");
	
    [buttonNewGame		setTitle:gettext(@"New game", nil) forState:UIControlStateNormal];
    [buttonScore		setTitle:gettext(@"Score", nil) forState:UIControlStateNormal];
    [buttonSetting		setTitle:gettext(@"Setting", nil) forState:UIControlStateNormal];
    [buttonReset		setTitle:gettext(@"reset", nil) forState:UIControlStateNormal];
	[buttonHelp			setTitle:gettext(@"Help", nil) forState:UIControlStateNormal];
	[buttonFeedback		setTitle:gettext(@"Feedback", nil) forState:UIControlStateNormal];
	[buttonMenuClose	setTitle:gettext(@"Close", nil) forState:UIControlStateNormal];

    [buttonMenu			setTitle:gettext(@"menu", nil) forState:UIControlStateNormal];
    [buttonMemo			setTitle:gettext(@"memo", nil) forState:UIControlStateNormal];
    [buttonDel			setTitle:gettext(@"del", nil) forState:UIControlStateNormal];
    [buttonHint			setTitle:gettext(@"hint", nil) forState:UIControlStateNormal];

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
	 [self hideAwaryView:viewMenu];
	 [self hideAwaryView:viewNewGame];



     
#ifdef ADMOB_FREEVERSION	 
     // Create a view of the standard size at the bottom of the screen.
     bannerView_ = [[GADBannerView alloc] initWithFrame:areaAdBanner.frame];
     [bannerView_ setDelegate:self];
     bannerView_.adUnitID = MY_BANNER_UNIT_ID;
     
     bannerView_.rootViewController = self;
     [self.view addSubview:bannerView_];
     
     [bannerView_ loadRequest:[GADRequest request]];     
#endif
	 
     
     [GameCenterUtil connectGameCenter];       //게임센터 접속~
     
 /*
     
     UIPanGestureRecognizer *pan;
     pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(Swipe4ScrollViews:)];
     [pan setMinimumNumberOfTouches:2];
     [mainView  addGestureRecognizer:pan];
     [pan release];

     
     
     
     UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(handleLeftSwipe:)];
     leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
     leftSwipeRecognizer.numberOfTouchesRequired = 1;
     [mainView addGestureRecognizer:leftSwipeRecognizer];
     leftSwipeRecognizer.delegate = self;
     [leftSwipeRecognizer release];
     
     UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
     rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
     rightSwipeRecognizer.numberOfTouchesRequired = 1;
     [mainView addGestureRecognizer:rightSwipeRecognizer];
     rightSwipeRecognizer.delegate = self;
     [rightSwipeRecognizer release];
*/
	 



}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#ifdef ADMOB_FREEVERSION    
    bannerView_.frame = areaAdBanner.frame;
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

	ScoreViewController *controller = [[ScoreViewController alloc] initWithNibName:
										  cDeviceType == DEVICETYPE_IPAD ? @"ScoreView4iPad" : 
										  @"ScoreView" bundle:nil];
    controller.mainViewController = self;
	[controller setScoreData:scoreTotal g:scoreGames c:scoreClears b:scoreBestTime s:scoreClearTimeSum];	
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;//UIModalTransitionStylePartialCurl;
	[self presentModalViewController:controller animated:YES];

	controller.bAuto = mainView.sudokuGame.bAutoMemo ? YES : NO;
	[controller setAutoSegment];		
	[controller displayScore];
    [controller setTotalScoreRank:scoreTotal];	
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

- (void)showHintButton
{
	[self updateButtonHint];
}


- (IBAction) doHint
{
	if (mainView.bMenuMode)
		return;

	
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
//	controller.title = gettext(@"Help", nil);
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;//UIModalTransitionStylePartialCurl;
	[self presentModalViewController:controller animated:YES];
    // UIModalTransitionStyleCrossDissolve for newgame
	
	
//	controller.title = gettext(@"Help", nil);
    
	
	[controller release];
	
    
}

- (IBAction)showFeedbackView
{
	[self hideMenuView:NO];
	
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

- (void) hideAwaryView:(UIView*) v
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
		[self hideAwaryView:viewMenu];
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
		[self hideAwaryView:viewNewGame];
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
	[mainView playSoundClick];
	
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
		scoreGames[mainView.sudokuGame.gameLevel + (mainView.sudokuGame.bAutoMemo ? 5 : 0)] += 1;     // 게임 수 1 증가
		scoreTotal += 1;                                    // 1게임 시도당 1점 추가
	}
}

- (void) makeNewGameData
{
	if (mainView.sudokuGame)
		[mainView.sudokuGame release];

	[mainView newGame:levelNewGame size:DEFPUZZLESIZE];
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
	
	time = [mainView.sudokuGame updateGameElapsedTime];
	[self updateGameTime:time];

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
    return scoreBestTime[level];
}

- (NSInteger) getTotalScore
{
    return scoreTotal;
}


- (void) updateButtons
{
	[self updateButtonMenu];
	[self updateButtonHint];
	[self updateButtonClear];
	[self updateButtonUndo];
	[self updateButtonDel];
	[self updateButtonMemo];
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
    [self stopGameTimer];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    [self startGameTimer];
}

- (void)adViewWillDismissScreen:(GADBannerView *)bannerView
{
    
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    
}



#endif

- (IBAction)LeftSwipe:(id)sender
{
    DLog(@"handleLeftSwipe called");
    
}
@end
