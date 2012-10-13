//
//  MainViewController.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import "ScoreViewController.h"
#import "SettingViewController.h"
#import "MainViewController.h"
#import "MainView.h"
#import "Locale.h"
#import "GameCenterUtil.h"



@implementation MainViewController

@synthesize mainView;
@synthesize labelNewGame;
@synthesize labelRights;
@synthesize labelTitleLevel;
@synthesize labelTitleGameTime;
@synthesize labelTitleBlank;
@synthesize labelTitleHint;
@synthesize buttonNewGameVeryEasy;
@synthesize areaPuzzleTable;
@synthesize areaNumButton;
@synthesize areaAdBanner;
@synthesize buttonNewGameEasy;
@synthesize buttonNewGameNormal;
@synthesize buttonNewGameHard;
@synthesize buttonNewGameVeryHard;
@synthesize buttonNewGameCancel;
@synthesize buttonNew;
@synthesize buttonUndo;
@synthesize buttonRedo;
@synthesize buttonBookmark;
@synthesize buttonMemo;
@synthesize buttonScore;
@synthesize buttonDel;
@synthesize buttonReset;
@synthesize buttonHint;
@synthesize buttonSetting;

@synthesize viewMenu;
@synthesize labelLevel;
@synthesize labelGameTime;
@synthesize labelBlank;
@synthesize labelHint;
@synthesize timerGame;
@synthesize timerNewGame;
@synthesize activityIndicator;



- (void) initScore
{
	NSLog(@"initScore");	
	
	
	for (int i=0; i<5; i++)
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
	NSLog(@"saveScoreData");	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	for (int i=0; i<5; i++)
	{
// set default for test
/*        scoreGames[i] = 100 + i;
        scoreClears[i] = 90 + i;
        scoreBestTime[i] = 150 +i;
        scoreClearTimeSum[i] = scoreClears[i] * scoreBestTime[i] * 1.7;
*/
		[defaults setInteger:scoreGames[i] forKey:[kScoreGames stringByAppendingFormat:@"%d", i]];
		[defaults setInteger:scoreClears[i] forKey:[kScoreClears stringByAppendingFormat:@"%d", i]];
		[defaults setInteger:scoreBestTime[i] forKey:[kScoreBestTime stringByAppendingFormat:@"%d", i]];
		[defaults setInteger:scoreClearTimeSum[i] forKey:[kScoreClearTimeSum stringByAppendingFormat:@"%d", i]];
	}
    [defaults setInteger:scoreTotal forKey:kScoreTotal];
}

- (NSInteger) getGameResultScore:(NSInteger)level sec:(NSInteger)sec
{
    NSInteger score = MIN(sec/60+1, 10);
    
    NSLog(@"getGameResultScore(%d,%d) => %d", level, sec, (5-level) * (10 - score + 1));
    
    score = (5-level) * (10 - score + 1);
    
#ifdef SUDOKU9  // zzz 나중에는 size 넘겨줘서 계산 해야 한다.
    score = score * (SIZE_9*SIZE_9)/100;
#else
    score = score * (SIZE_6*SIZE_6)/100;
#endif
    score = MAX(score, 1);
    
    return score;
}

- (void) loadScoreData
{
	NSLog(@"loadScoreData");	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	for (int i=0; i<5; i++)
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
        for (int i=0; i<5; i++)
        {
            scoreTotal += scoreGames[i];    // 게임 시작하면 무조건 1점씩 추가 됨
            if (scoreClears[i] > 0)
                scoreTotal += scoreClears[i] * [self getGameResultScore:i sec:scoreClearTimeSum[i]/scoreClears[i]];
        }
	}
    NSLog(@"scoreTotal = %d", scoreTotal);
    
}



- (void) writeScoreAfterFinishGame:(SudokuGame*)sudokuGame
{
	NSLog(@"writeScore");	
    BOOL bNewBest = NO;
    
	scoreClears[sudokuGame.gameLevel] += 1;
    
	if (scoreBestTime[sudokuGame.gameLevel] == 0 ||                     // 최초는 무조건 Best time
		sudokuGame.gameTime < scoreBestTime[sudokuGame.gameLevel])
    {
        if (scoreBestTime[sudokuGame.gameLevel] != 0)
        {
            bNewBest = YES;
        }
		scoreBestTime[sudokuGame.gameLevel] = sudokuGame.gameTime;      // best time 갱신
        
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

    
    
    

    // 하위 호환을 위해서 무조건 best time을 보내기
    [GameCenterUtil sendBestTimeToGameCenter:sudokuGame.gameLevel besttime:scoreBestTime[sudokuGame.gameLevel]];
    
    scoreClearTimeSum[sudokuGame.gameLevel] += sudokuGame.gameTime;
	
    // add current game score to Total Score
    scoreTotal += [self getGameResultScore:sudokuGame.gameLevel sec:sudokuGame.gameTime];
    scoreTotal += sudokuGame.countHint*3;   // 남은 힌트 점수 추가
    
	[self saveScoreData];
    
    // 총점 보내기
    [GameCenterUtil sendScoreToGameCenter:scoreTotal];      
    // best time 보내기
    [GameCenterUtil sendBestTimeToGameCenter:sudokuGame.gameLevel besttime:scoreBestTime[sudokuGame.gameLevel]];
    // achievement 보내기
    [GameCenterUtil sendAchievementClearGame:scoreClears[0]+scoreClears[1]+scoreClears[2]+scoreClears[3]+scoreClears[4]];
}

#define SETTING_VERSION                 1
#define kSettingSavedVersion            @"settingSavedVersion"
#define kSettingSoundEffect             @"settingSoundEffect"
#define kSettingGuideline               @"settingGuideline"
#define kSettingDuplicationWarning      @"settingDuplicationWarning"
#define kSettingMarkingEqual            @"settingMarkingEqual"
#define kSettingDefMap                  @"settingDefMap"

- (void) loadSetting
{
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
    mainView.bSettingDefMap = [defaults boolForKey:kSettingDefMap];
}

- (void) saveSetting
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:SETTING_VERSION forKey:kSettingSavedVersion];
    [defaults setBool:mainView.bSettingSoundOff forKey:kSettingSoundEffect];
    [defaults setBool:mainView.bSettingGuideline forKey:kSettingGuideline];
    [defaults setBool:mainView.bSettingDuplicationWarning forKey:kSettingDuplicationWarning];
    [defaults setBool:mainView.bSettingMarkingEqual forKey:kSettingMarkingEqual];
    [defaults setBool:mainView.bSettingDefMap forKey:kSettingDefMap];
}

- (void) setLocalizedMessage
{
    [buttonMemo setTitle:gettext(@"memo", nil) forState:UIControlStateNormal];
    [buttonDel setTitle:gettext(@"del", nil) forState:UIControlStateNormal];
    [buttonNew setTitle:gettext(@"new", nil) forState:UIControlStateNormal];
    [buttonReset setTitle:gettext(@"reset", nil) forState:UIControlStateNormal];
    [buttonScore setTitle:gettext(@"score", nil) forState:UIControlStateNormal];
    [buttonHint setTitle:gettext(@"hint", nil) forState:UIControlStateNormal];
    [buttonSetting setTitle:@"" forState:UIControlStateNormal];
    [buttonSetting setImage:[UIImage imageNamed:@"setting_n"] forState:UIControlStateNormal];
    [buttonSetting setImage:[UIImage imageNamed:@"setting_h"] forState:UIControlStateHighlighted];   
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
    labelNewGame.text = gettext(@"New Game", nil);
    
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



- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 	NSLog(@"initWithNibName");	
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        mainView = (MainView*) self.view;
 	    frameMainViewOrg = mainView.frame;
	   NSLog(@"frameMainViewOrg = %f,%f", frameMainViewOrg.size.width, frameMainViewOrg.size.height);

       
       [self decideLocale];
       
       [self loadSetting];
       [self setLocalizedMessage];

		if ([mainView loadGame] == YES) {
			[self setGameLevel];
			[self updateBlankCellCount];
			[self updateHintCount];
			[self updateButtonUndo];
			[self updateButtonClear];
			[self updateButtonDel];
			[self updateButtonHint];
            [self startTimer];          // load 했을 때만 Timer를 시작한다.
		} else { 
			[self showMenu];
		}
		[self initScore];
		[self loadScoreData];
		//[self startTimer];
		[self showMemoButton];
	    [self showHintButton];

    }
    return self;
}


-(void)Swipe4ScrollViews:(UIPanGestureRecognizer *)sender
{
   
}
- (void)handleLeftSwipe:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"handleLeftSwipe called");
}

- (void)handleRightSwipe:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"handleRightSwipe called");
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
	 NSLog(@"viewDidLoad");	

     
     

     
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

     [super viewDidLoad];


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
	NSString* str;
	
	str = [[NSString alloc] initWithFormat:@"%d", num];
	label.text = str;
	
	[str release];
}

- (void) setTime:(UILabel*)label num:(NSInteger)num
{
	NSString *str;
	
	if (num >= 60*60*100)
		num = 60*60*100 - 1;
	
	if (num >= 60*60)
		str = [[NSString alloc] initWithFormat:@"%2d:%02d:%02d",
			   num / (60*60),
			   num / (60) % (60),
			   num % (60)];
	else if (num > 0) 
		str = [[NSString alloc] initWithFormat:@"%02d:%02d",
			   num / (60),
			   num % (60)];
	else 
		str = [[NSString alloc] initWithString:@"-"];

	
	label.text = str; 
	
	[str release];
	
}

- (IBAction) showScoreView
{
	ScoreViewController *controller = [[ScoreViewController alloc] initWithNibName:
										  cDeviceType == DEVICETYPE_IPAD ? @"ScoreView4iPad" : 
										  @"ScoreView" bundle:nil];
    controller.mainViewController = self;
	
	controller.title = gettext(@"Score", nil);
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;//UIModalTransitionStylePartialCurl;
	[self presentModalViewController:controller animated:YES];
    // UIModalTransitionStyleCrossDissolve for newgame
	
	
	controller.title = gettext(@"Score", nil);

	[self setInteger:controller.labelVeryHardGames num:scoreGames[0]];
	[self setInteger:controller.labelVeryHardClears num:scoreClears[0]];
	[self setTime:controller.labelVeryHardBestTime num:scoreBestTime[0]];
	[self setTime:controller.labelVeryHardAverage num:scoreClears[0] ? scoreClearTimeSum[0]/scoreClears[0] : 0];	
	[self setInteger:controller.labelHardGames num:scoreGames[1]];
	[self setInteger:controller.labelHardClears num:scoreClears[1]];
	[self setTime:controller.labelHardBestTime num:scoreBestTime[1]];
	[self setTime:controller.labelHardAverage num:scoreClears[1] ? scoreClearTimeSum[1]/scoreClears[1] : 0];
	[self setInteger:controller.labelNormalGames num:scoreGames[2]];
	[self setInteger:controller.labelNormalClears num:scoreClears[2]];
	[self setTime:controller.labelNormalBestTime num:scoreBestTime[2]];
	[self setTime:controller.labelNormalAverage num:scoreClears[2] ? scoreClearTimeSum[2]/scoreClears[2] : 0];
	[self setInteger:controller.labelEasyGames num:scoreGames[3]];
	[self setInteger:controller.labelEasyClears num:scoreClears[3]];
	[self setTime:controller.labelEasyBestTime num:scoreBestTime[3]];
	[self setTime:controller.labelEasyAverage num:scoreClears[3] ? scoreClearTimeSum[3]/scoreClears[3] : 0];
	[self setInteger:controller.labelVeryEasyGames num:scoreGames[4]];
	[self setInteger:controller.labelVeryEasyClears num:scoreClears[4]];
	[self setTime:controller.labelVeryEasyBestTime num:scoreBestTime[4]];
	[self setTime:controller.labelVeryEasyAverage num:scoreClears[4] ? scoreClearTimeSum[4]/scoreClears[4] : 0];
	
	[self setInteger:controller.labelTotalGames num:scoreGames[0]+scoreGames[1]+scoreGames[2]+scoreGames[3]+scoreGames[4]];
	[self setInteger:controller.labelTotalClears num:scoreClears[0]+scoreClears[1]+scoreClears[2]+scoreClears[3]+scoreClears[4]];
	
    
    [controller setTotalScoreRank:scoreTotal];
    
	[controller release];

}

- (void) updateButtonUndo
{
	if ([mainView.sudokuGame.sudokuUndo countUndo] > 0 && mainView.sudokuGame.gameFinished == NO)
    {
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_n"] forState:UIControlStateNormal];
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_h"] forState:UIControlStateHighlighted];
		buttonUndo.enabled = YES;
	} else {
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_d"] forState:UIControlStateNormal];
        [buttonUndo setBackgroundImage:[UIImage imageNamed:@"undo_h"] forState:UIControlStateHighlighted];
		buttonUndo.enabled = NO;
	}
    
	if ([mainView.sudokuGame.sudokuUndo countRedo] > 0 && mainView.sudokuGame.gameFinished == NO)
    {
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_n"] forState:UIControlStateNormal];
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_h"] forState:UIControlStateHighlighted];
		buttonRedo.enabled = YES;
	} else {
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_d"] forState:UIControlStateNormal];
        [buttonRedo setBackgroundImage:[UIImage imageNamed:@"redo_h"] forState:UIControlStateHighlighted];
		buttonRedo.enabled = NO;
	}

    if (mainView.sudokuGame.gameFinished == YES)
    {
        [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkoff_d"] forState:UIControlStateNormal];
        [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkoff_d"] forState:UIControlStateHighlighted];
		buttonBookmark.enabled = NO;
	} else if ([mainView.sudokuGame.sudokuUndo isBookmarked])
    {
        [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkon_n"] forState:UIControlStateNormal];
        [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkon_h"] forState:UIControlStateHighlighted];
		buttonBookmark.enabled = YES;
	} else {
        [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkoff_n"] forState:UIControlStateNormal];
        [buttonBookmark setBackgroundImage:[UIImage imageNamed:@"bookmarkoff_h"] forState:UIControlStateHighlighted];
		buttonBookmark.enabled = YES;
	}
    
    

}

- (IBAction)runUndo
{
	[mainView runUndo];
	
	[self updateBlankCellCount];
	[self updateHintCount];
	[self updateButtonUndo];
	[self updateButtonClear];
	[self updateButtonDel];
	[self updateButtonHint];
	
}

- (IBAction)runRedo
{
	[mainView runRedo];
	
	[self updateBlankCellCount];
	[self updateHintCount];
	[self updateButtonUndo];
	[self updateButtonClear];
	[self updateButtonDel];
	[self updateButtonHint];
}

- (IBAction)runBookmark
{
	[mainView runBookmark];
	
	[self updateBlankCellCount];
	[self updateHintCount];
	[self updateButtonUndo];
	[self updateButtonClear];
	[self updateButtonDel];
	[self updateButtonHint];
}


- (void)showMemoButton
{
	if (mainView.bMemoMode) {
		buttonMemo.alpha = 1.f;	
	} else {
		buttonMemo.alpha = 0.5f;	
	}
	
}

- (IBAction) memoOnOff {
	[mainView memoOnOff];
	[self showMemoButton];
}

- (IBAction) delNumber
{
	[mainView delNumber];
}

- (IBAction) clearNumbers
{
	[mainView clearNumbers];
    //[self writeScoreAfterFinishGame:mainView.sudokuGame];
    
}

- (void)showHintButton
{
	[self updateButtonHint];
}


- (IBAction) doHint
{
	[mainView doHint];
}



- (IBAction)showSettingView
{

    NSLog(@"showSettingView");
    SettingViewController *controller = [[SettingViewController alloc] initWithNibName:
                                       cDeviceType == DEVICETYPE_IPAD ? @"SettingView4iPad" :
                                       @"SettingView" bundle:nil];
    controller.mainViewController = self;
	controller.title = gettext(@"Setting", nil);
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;//UIModalTransitionStylePartialCurl;
	[self presentModalViewController:controller animated:YES];
    // UIModalTransitionStyleCrossDissolve for newgame
	
	
	controller.title = gettext(@"Setting", nil);
    
	
	[controller release];

    
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
	NSLog(@"viewDidUnload");	
    
#ifdef ADMOB_FREEVERSION
    [bannerView_ release];
#endif    
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	NSLog(@"dealloc");
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


- (void) showMenuView
{
	[activityIndicator stopAnimating];
	viewMenu.hidden = NO;
    
    
    CGRect frameOld = viewMenu.frame;
    frameOld.origin.x = 0;
    frameOld.origin.y = 0;
    viewMenu.frame = frameOld;
	viewMenu.alpha = 0.8f;
	mainView.bMenuMode = YES;
	
	buttonNewGameCancel.hidden = (mainView.sudokuGame == nil);	
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

- (void) hideMenuView
{
	viewMenu.hidden = YES;
	mainView.bMenuMode = NO;
	
	[self setGameLevel];
	[self updateBlankCellCount];
    [self updateHintCount];
	[self startTimer];

}
- (void) updateGameTime:(NSInteger) time
{
	NSString *str;
	
	if (time >= 60*60*100)
		time = 60*60*100 - 1;
	
	if (time >= 60*60)
		str = [[NSString alloc] initWithFormat:@"%d:%02d:%02d",
			   time / (60*60),
			   time / (60) % (60),
			   time % (60)];
	else 
		str = [[NSString alloc] initWithFormat:@"%02d:%02d",
			   time / (60),
			   time % (60)];
	
	labelGameTime.text = str; 
	
	[str release];
	
}


- (IBAction)showMenu
{
//	[self allButtonUnLock];
	[self showMenuView];
	[self stopTimer];

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



- (void)OnTimerNewGame:(NSTimer *)timer
{
	NSLog(@"OnTimerNewGame");	
	
	//	[self allButtonLock];
	[mainView.sudokuGame release];
    NSLog(@"DEFPUZZLESIZE=%d", DEFPUZZLESIZE);
	[mainView newGame:levelNewGame size:DEFPUZZLESIZE];
	
	scoreGames[mainView.sudokuGame.gameLevel] += 1;     // 게임 수 1 증가
    scoreTotal += 1;                                    // 1게임 시도당 1점 추가
    
	[self saveScoreData];
	
	[self updateGameTime:0];
	[activityIndicator stopAnimating];
	// all button unlock
	
	[self updateButtonUndo];
	[self updateButtonClear];
	[self updateButtonDel];
	[self updateButtonHint];
	
	[self hideMenuView];	
	
}

- (void) makeNewGame:(NSInteger)level
{
	NSLog(@"makeNewGame");	
//	[self startIndicator];
	[activityIndicator startAnimating];
	levelNewGame = level;

	timerNewGame = [NSTimer scheduledTimerWithTimeInterval:0 
												target:self
											  selector:@selector(OnTimerNewGame:)
											  userInfo:nil
											   repeats:NO];	
	
	
}	



- (IBAction)menuVeryEasy
{
	[self makeNewGame:GAMELEVEL_VERYEASY];

}

- (IBAction)menuEasy
{
	[self makeNewGame:GAMELEVEL_EASY];

}

- (IBAction)menuNormal
{
	[self makeNewGame:GAMELEVEL_NORMAL];

}

- (IBAction)menuHard
{
	[self makeNewGame:GAMELEVEL_HARD];

}

- (IBAction)menuVeryHard
{
	[self makeNewGame:GAMELEVEL_VERYHARD];

}

- (IBAction)menuCancel
{
	[self hideMenuView];
}

- (void) startTimer
{
	timerGame = [NSTimer scheduledTimerWithTimeInterval:1 
												 target:self
											   selector:@selector(OnTimer:)
											   userInfo:nil
												repeats:YES];
}

- (void) stopTimer
{
	[timerGame invalidate];	
}



- (void) OnTimer:(NSTimer *)timer
{
	NSInteger time = [mainView.sudokuGame add1sec];
	
	[self updateGameTime:time];	
	if (!mainView.sudokuGame.gameFinished)	// lock the screen
		[mainView.sudokuGame saveData];
}

- (void) updateBlankCellCount
{
	NSInteger count = [mainView.sudokuGame countBlankCells];
	NSString *str;
	str = [[NSString alloc] initWithFormat:@"%d", count];
	
	labelBlank.text =str;
	[str release];
}

- (void) updateHintCount
{
	NSInteger count = mainView.sudokuGame.countHint;
	NSString *str;
	str = [[NSString alloc] initWithFormat:@"%d", count];
	
	labelHint.text =str;
	[str release];
}


- (void) updateButtonClear
{
	NSInteger count = [mainView.sudokuGame countFixCells];

	if (count > 0)	{
		buttonReset.alpha = 1.0f;
		buttonReset.enabled = YES;
	} else {
		buttonReset.alpha = 0.5f;
		buttonReset.enabled = NO;		
	}
}

- (void) updateButtonDel
{
	if ([mainView isSelectedCellisFixed])	{
		buttonDel.alpha = 1.0f;
		buttonDel.enabled = YES;
	} else {
		buttonDel.alpha = 0.5f;
		buttonDel.enabled = NO;		
	}
}

- (void) updateButtonHint	// TODO Hint 아이템이 남아있고 힌트 가능한 셀일경우 On;
{
	if ([mainView isSelectedCellisableHint])	{	// AND Hint item > 0
		buttonHint.alpha = 1.0f;
		buttonHint.enabled = YES;
	} else {
		buttonHint.alpha = 0.5f;
		buttonHint.enabled = NO;		
	}
}

- (NSInteger) getBestTime:(NSInteger)level
{
    return scoreBestTime[level];
}

- (NSInteger) getTotalScore
{
    return scoreTotal;
}




- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{ 
	NSLog(@"willRotateToInterfaceOrientation toInterfaceOrientation = %d duration = %f", toInterfaceOrientation, duration);
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
#ifdef ADMOB_FREEVERSION
    bannerView_.hidden = YES;
#endif
    CGRect frameOld = viewMenu.frame;
    frameOld.origin.x = 0;
    frameOld.origin.y = 0;
    viewMenu.frame = frameOld;

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
    if (cDeviceType == DEVICETYPE_IPHONE)
        return NO;
#endif
    return YES;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
#ifdef ADMOB_FREEVERSION
    if (cDeviceType == DEVICETYPE_IPHONE)
        return UIInterfaceOrientationMaskPortrait;
#endif
    return UIInterfaceOrientationMaskAll;
}


// Deprecated
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	NSLog(@"shouldAutorotateToInterfaceOrientation");	

	
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
    [self stopTimer];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    [self startTimer];
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
    NSLog(@"handleLeftSwipe called");
    
}
@end
