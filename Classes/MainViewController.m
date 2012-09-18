//
//  MainViewController.m
//  SudokuHelper
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"




@implementation MainViewController

@synthesize mainView;
@synthesize labelNewGame;
@synthesize labelRights;
@synthesize labelTitleLevel;
@synthesize labelTitleGameTime;
@synthesize labelTitleBlank;
@synthesize labelTitleHint;
@synthesize buttonNewGameVeryEasy;
@synthesize buttonNewGameEasy;
@synthesize buttonNewGameNormal;
@synthesize buttonNewGameHard;
@synthesize buttonNewGameVeryHard;
@synthesize buttonNewGameCancel;
@synthesize buttonNew;
@synthesize buttonUndo;
@synthesize buttonMemo;
@synthesize buttonScore;
@synthesize buttonDel;
@synthesize buttonReset;
@synthesize buttonHint;

@synthesize viewMenu;
@synthesize labelLevel;
@synthesize labelGameTime;
@synthesize labelBlank;
@synthesize labelHint;
@synthesize timerGame;
@synthesize timerNewGame;
@synthesize activityIndicator;
/*
#ifdef ADMOB_FREEVERSION
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
@synthesize bannerView;
#endif
@synthesize adViewController;
#endif
*/

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
}

#define kScoreGames			@"scoreGames"
#define kScoreClears		@"scoreClears"
#define kScoreBestTime		@"scoreBestTime"
#define kScoreClearTimeSum	@"scoreClearTimeSum"

- (void) saveScoreData
{
	NSLog(@"saveScoreData");	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	for (int i=0; i<5; i++)
	{
		[defaults setInteger:scoreGames[i] forKey:[kScoreGames stringByAppendingFormat:@"%d", i]];
		[defaults setInteger:scoreClears[i] forKey:[kScoreClears stringByAppendingFormat:@"%d", i]];
		[defaults setInteger:scoreBestTime[i] forKey:[kScoreBestTime stringByAppendingFormat:@"%d", i]];
		[defaults setInteger:scoreClearTimeSum[i] forKey:[kScoreClearTimeSum stringByAppendingFormat:@"%d", i]];
	}	
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
}

- (void) writeScore:(SudokuGame*)sudokuGame
{
	NSLog(@"writeScore");	

	scoreClears[sudokuGame.gameLevel] += 1;
	if (scoreBestTime[sudokuGame.gameLevel] == 0 || 
		sudokuGame.gameTime < scoreBestTime[sudokuGame.gameLevel])
		scoreBestTime[sudokuGame.gameLevel] = sudokuGame.gameTime;
	scoreClearTimeSum[sudokuGame.gameLevel] += sudokuGame.gameTime;
	
	[self saveScoreData];
}

#ifdef ADMOB_FREEVERSION	   
- (CGRect) setPressFrame:(CGRect) frame 
{
	frame.origin.y *= mainView.fPress;
	
	return frame;
}


- (void) setPressAd
{
	buttonNew.frame		= [self setPressFrame:buttonNew.frame];
	buttonUndo.frame	= [self setPressFrame:buttonUndo.frame];
	buttonMemo.frame	= [self setPressFrame:buttonMemo.frame];
	buttonDel.frame		= [self setPressFrame:buttonDel.frame];
	buttonReset.frame	= [self setPressFrame:buttonReset.frame];
	buttonScore.frame	= [self setPressFrame:buttonScore.frame];		
	buttonHint.frame	= [self setPressFrame:buttonHint.frame];
	
	labelTitleLevel.frame	= [self setPressFrame:labelTitleLevel.frame];
	labelLevel.frame		= [self setPressFrame:labelLevel.frame];	
	labelTitleGameTime.frame= [self setPressFrame:labelTitleGameTime.frame];
	labelGameTime.frame		= [self setPressFrame:labelGameTime.frame];	
	labelTitleBlank.frame	= [self setPressFrame:labelTitleBlank.frame];	
	labelBlank.frame		= [self setPressFrame:labelBlank.frame];	
	labelTitleHint.frame	= [self setPressFrame:labelTitleHint.frame];	
	labelHint.frame		= [self setPressFrame:labelHint.frame];	
	
    labelRights.hidden = false;
}

#endif


- (void) setOrientation
{
	NSLog(@"setOrientation");	

	mainView.rectPortrait = self.view.frame;
	NSLog(@"mainView.rectPortrait=%f,%f", mainView.rectPortrait.size.width, mainView.rectPortrait.size.height);	

	CGRect rectLandscape = mainView.rectPortrait;
	rectLandscape.size.width = mainView.rectPortrait.size.height+20;    // titlebar:20
	rectLandscape.size.height = mainView.rectPortrait.size.width-20;    // titlebar:20
	mainView.rectLandscape = rectLandscape;
	NSLog(@"mainView.rectLandscape=%f,%f", mainView.rectLandscape.size.width, mainView.rectLandscape.size.height);	
	
	mainView.rectCurrent = mainView.rectPortrait;
	mainView.fTableWidth = mainView.rectCurrent.size.width;
	mainView.fButtonStart = labelLevel.frame.origin.y+labelLevel.frame.size.height+5;
	
	CGRect frameTemp;
	
	frameNewPortrait = buttonNew.frame;
	frameUndoPortrait = buttonUndo.frame;
	frameMemoPortrait = buttonMemo.frame;
	frameDelPortrait = buttonDel.frame;
	frameResetPortrait = buttonReset.frame;
	frameScorePortrait = buttonScore.frame;	
	frameHintButtonPortrait = buttonHint.frame;
	
    CGFloat widthLandTable;
#ifdef ADMOB_FREEVERSION
    if (cDeviceType == DEVICETYPE_IPAD)
        widthLandTable = (mainView.rectLandscape.size.height - IPAD_GAD_H) / mainView.fPress;
    else
        widthLandTable = mainView.rectLandscape.size.height;
#else
    widthLandTable = mainView.rectLandscape.size.height;
#endif
    NSLog(@"widthLandTable=%f", widthLandTable);
	CGFloat startButtonX = widthLandTable + 10;
	CGFloat widthButtons = mainView.rectLandscape.size.width - startButtonX - frameNewPortrait.size.width - 10;
	
	
	frameTemp = frameNewPortrait;
	frameTemp.origin.x = startButtonX;//mainView.rectLandscape.size.height + 10; 
	frameTemp.origin.y = 2;
	frameNewLandscape = frameTemp;
	
	frameTemp = frameScorePortrait;
	frameTemp.origin.x = startButtonX + widthButtons/2;//mainView.rectLandscape.size.width - 10 - frameTemp.size.width; 
	frameTemp.origin.y = 2;
	frameScoreLandscape = frameTemp;

	frameTemp = frameResetPortrait;
	frameTemp.origin.x = startButtonX + widthButtons*2/3;//frameNewLandscape.origin.x*1/3 + frameScoreLandscape.origin.x*2/3;
	frameTemp.origin.y = -100;          // 사라진다.
	frameResetLandscape = frameTemp;	
	
	frameTemp = frameDelPortrait;
	frameTemp.origin.x = startButtonX + widthButtons;//frameNewLandscape.origin.x*2/3 + frameScoreLandscape.origin.x*1/3;
	frameTemp.origin.y = 2;
	frameDelLandscape = frameTemp;
	
    

	
	frameTemp = frameHintButtonPortrait;
	frameTemp.origin.x = startButtonX;
	frameTemp.origin.y = mainView.rectLandscape.size.height - 2 - frameTemp.size.height;
	frameHintButtonLandscape = frameTemp;	

	frameTemp = frameUndoPortrait;
	frameTemp.origin.x = frameHintButtonLandscape.origin.x + widthButtons/2;
	frameTemp.origin.y = frameHintButtonLandscape.origin.y;
	frameUndoLandscape = frameTemp;
	
	frameTemp = frameMemoPortrait;
	frameTemp.origin.x = frameHintButtonLandscape.origin.x + widthButtons;  
	frameTemp.origin.y = mainView.rectLandscape.size.height - 2 - frameTemp.size.height;
	frameMemoLandscape = frameTemp;
	
	
	
	

	
	
	
	frameTitleLevelPortrait = labelTitleLevel.frame;
	frameLevelPortrait = labelLevel.frame;	
	frameTitleGameTimePortrait = labelTitleGameTime.frame;	
	frameGameTimePortrait = labelGameTime.frame;	
	frameTitleBlankPortrait = labelTitleBlank.frame;	
	frameBlankPortrait = labelBlank.frame;
	frameTitleHintPortrait = labelTitleHint.frame;	
	frameHintPortrait = labelHint.frame;
	
	frameTemp = frameTitleLevelPortrait;
	frameTemp.origin.x = frameNewLandscape.origin.x; 
	frameTemp.origin.y = frameNewLandscape.origin.y + frameNewLandscape.size.height*1.3;
	frameTitleLevelLandscape = frameTemp;
	
	frameTemp = frameLevelPortrait;
	frameTemp.origin.x = frameTitleLevelLandscape.origin.x; 
	frameTemp.origin.y = frameTitleLevelLandscape.origin.y + frameTitleLevelLandscape.size.height;
	frameLevelLandscape = frameTemp;

 	frameTemp = frameTitleBlankPortrait;
	frameTemp.origin.x = frameResetLandscape.origin.x;
	frameTemp.origin.y = frameTitleLevelLandscape.origin.y;
	frameTitleBlankLandscape = frameTemp;
	
	frameTemp = frameBlankPortrait;
	frameTemp.origin.x = frameTitleBlankLandscape.origin.x; 
	frameTemp.origin.y = frameLevelLandscape.origin.y;
	frameBlankLandscape = frameTemp;
   

	frameTemp = frameTitleHintPortrait;
	frameTemp.origin.x = frameLevelLandscape.origin.x; 
	frameTemp.origin.y = frameHintButtonLandscape.origin.y - frameHintButtonLandscape.size.height*0.4 - frameHintPortrait.size.height - frameTitleHintPortrait.size.height;
	frameTitleHintLandscape = frameTemp;
	
	frameTemp = frameHintPortrait;
	frameTemp.origin.x = frameTitleHintLandscape.origin.x; 
	frameTemp.origin.y = frameTitleHintLandscape.origin.y + frameTitleHintLandscape.size.height;
	frameHintLandscape = frameTemp;
	

	frameTemp = frameTitleGameTimePortrait;
	frameTemp.origin.x = frameUndoLandscape.origin.x; 
	frameTemp.origin.y = frameTitleHintLandscape.origin.y;
	frameTitleGameTimeLandscape = frameTemp;
	
	frameTemp = frameGameTimePortrait;
	frameTemp.origin.x = frameTitleGameTimeLandscape.origin.x; 
	frameTemp.origin.y = frameHintLandscape.origin.y;
	frameGameTimeLandscape = frameTemp;
    
	

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 	NSLog(@"initWithNibName");	
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        mainView = (MainView*) self.view;
 	    frameMainViewOrg = mainView.frame;
	   NSLog(@"frameMainViewOrg = %f,%f", frameMainViewOrg.size.width, frameMainViewOrg.size.height);
#ifdef ADMOB_FREEVERSION	   
       mainView.fPress =  (frameMainViewOrg.size.height - ((cDeviceType == DEVICETYPE_IPAD) ? IPAD_GAD_H : IPHONE_GAD_H)) / 
                            frameMainViewOrg.size.height;	
       NSLog(@"fPress = %f", mainView.fPress);
		[self setPressAd];
#else
		mainView.fPress = 1.f;
#endif

       
       [buttonMemo setTitle:NSLocalizedString(@"memo", nil) forState:UIControlStateNormal];
       [buttonDel setTitle:NSLocalizedString(@"del", nil) forState:UIControlStateNormal];
       [buttonNew setTitle:NSLocalizedString(@"new", nil) forState:UIControlStateNormal];
       [buttonReset setTitle:NSLocalizedString(@"reset", nil) forState:UIControlStateNormal];
       [buttonScore setTitle:NSLocalizedString(@"score", nil) forState:UIControlStateNormal];
       [buttonUndo setTitle:NSLocalizedString(@"undo", nil) forState:UIControlStateNormal];
       [buttonHint setTitle:NSLocalizedString(@"hint", nil) forState:UIControlStateNormal];
       
       
       [self setOrientation];
		[mainView setFont];
		if ([mainView loadGame] == YES) {
			[self setGameLevel];
			[self updateBlankCellCount];
			[self updateHintCount];
			[self updateButtonUndo];
			[self updateButtonClear];
			[self updateButtonDel];
			[self updateButtonHint];
		} else { 
			[self showMenu];
		}
		[self initScore];
		[self loadScoreData];
		[self startTimer];
		[self showMemoButton];
	    [self showHintButton];

    }
    return self;
}



 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 NSLog(@"viewDidLoad");	
	 [super viewDidLoad];

	 labelTitleLevel.text = NSLocalizedString(@"level", nil);
	 labelTitleGameTime.text = NSLocalizedString(@"game time", nil);
	 labelTitleBlank.text = NSLocalizedString(@"blank", nil);
	 labelTitleHint.text = NSLocalizedString(@"hint", nil);
	 labelNewGame.text = NSLocalizedString(@"New Game", nil);
	 
	 [buttonNewGameVeryEasy setTitle:NSLocalizedString(@"very easy", nil) forState:UIControlStateNormal];
	 [buttonNewGameEasy setTitle:NSLocalizedString(@"easy", nil) forState:UIControlStateNormal];
	 [buttonNewGameNormal setTitle:NSLocalizedString(@"normal", nil) forState:UIControlStateNormal];
	 [buttonNewGameHard setTitle:NSLocalizedString(@"hard", nil) forState:UIControlStateNormal];
	 [buttonNewGameVeryHard setTitle:NSLocalizedString(@"very hard", nil) forState:UIControlStateNormal];
	 [buttonNewGameCancel setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];

     //
     mainView.lastOrientation = [UIDevice currentDevice].orientation;
     
#ifdef ADMOB_FREEVERSION	 
     // Create a view of the standard size at the bottom of the screen.
     if (cDeviceType == DEVICETYPE_IPAD)
     {    
         bannerView_ = [[GADBannerView alloc]
                        initWithFrame:CGRectMake((self.view.frame.size.width - IPAD_GAD_W)/2.0,
                                                 self.view.frame.size.height - IPAD_GAD_H,
                                                 IPAD_GAD_W,
                                                 IPAD_GAD_H)];
         bannerView_.adUnitID = MY_BANNER_UNIT_ID_IPAD;
     } else {   
         bannerView_ = [[GADBannerView alloc]
                        initWithFrame:CGRectMake((self.view.frame.size.width - IPHONE_GAD_W)/2.0,
                                                 self.view.frame.size.height - IPHONE_GAD_H,
                                                 IPHONE_GAD_W,
                                                 IPHONE_GAD_H)];
         // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
         bannerView_.adUnitID = MY_BANNER_UNIT_ID_IPHONE;
     }
     
     // Let the runtime know which UIViewController to restore after taking
     // the user wherever the ad goes and add it to the view hierarchy.
     bannerView_.rootViewController = self;
     [self.view addSubview:bannerView_];
     
     // Initiate a generic request to load it with an ad.
     [bannerView_ loadRequest:[GADRequest request]];     
#endif
	 

}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
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
		str = [[NSString alloc] initWithFormat:@"%02d:%02d:%02d",
			   num / (60*60),
			   num / (60),
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

- (IBAction)showInfo {    
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:
										  cDeviceType == DEVICETYPE_IPAD ? @"FlipsideView4iPad" : 
										  @"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.title = NSLocalizedString(@"Score", nil);
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];

//	[self.navigationController presentModalViewController:controller animated:YES];
	
	
	controller.title = NSLocalizedString(@"Score", nil);

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
	
	[controller release];

}

- (void) updateButtonUndo
{
	if (mainView.sudokuGame.strUndo.length > 0 && mainView.sudokuGame.gameFinished == NO) {
		buttonUndo.alpha = 1.0f;
		buttonUndo.enabled = YES;
	} else {
		buttonUndo.alpha = 0.5f;
		buttonUndo.enabled = NO;
	}
}

- (IBAction)runUndo {    
	[mainView runUndo];
	
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
}

- (void)showHintButton
{
	[self updateButtonHint];
}


- (IBAction) doHint
{
	[mainView doHint];
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
/*
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000	
	bannerView.delegate = nil;
	[bannerView release];
#endif
*/
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
	viewMenu.alpha = 0.8f;
	mainView.bMenuMode = YES;
	
	buttonNewGameCancel.hidden = (mainView.sudokuGame == nil);	
}

- (void) setGameLevel
{
	switch (mainView.sudokuGame.gameLevel) {
		case GAMELEVEL_VERYEASY:
			labelLevel.text = NSLocalizedString(@"very easy", nil);
			break;
		case GAMELEVEL_EASY:
			labelLevel.text = NSLocalizedString(@"easy", nil);
			break;
		case GAMELEVEL_NORMAL:
			labelLevel.text = NSLocalizedString(@"normal", nil);
			break;
		case GAMELEVEL_HARD:
			labelLevel.text = NSLocalizedString(@"hard", nil);
			break;
		case GAMELEVEL_VERYHARD:
			labelLevel.text = NSLocalizedString(@"very hard", nil);
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
		str = [[NSString alloc] initWithFormat:@"%02d:%02d:%02d",
			   time / (60*60),
			   time / (60),
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




- (void)OnTimerNewGame:(NSTimer *)timer
{
	NSLog(@"OnTimerNewGame");	
	
	//	[self allButtonLock];
	[mainView.sudokuGame release];
	[mainView newGame:levelNewGame];
	
	scoreGames[mainView.sudokuGame.gameLevel] += 1;
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
//	if (!mainView.sudokuGame.gameFinished)	// lock the screen
//		[mainView.sudokuGame saveData];
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
	if ([mainView selectedCellisFixed])	{
		buttonDel.alpha = 1.0f;
		buttonDel.enabled = YES;
	} else {
		buttonDel.alpha = 0.5f;
		buttonDel.enabled = NO;		
	}
}

- (void) updateButtonHint	// TODO Hint 아이템이 남아있고 힌트 가능한 셀일경우 On;
{
	if ([mainView selectedCellisableHint])	{	// AND Hint item > 0
		buttonHint.alpha = 1.0f;
		buttonHint.enabled = YES;
	} else {
		buttonHint.alpha = 0.5f;
		buttonHint.enabled = NO;		
	}
}



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{ 
	NSLog(@"duration = %f", duration);

	if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
		toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)	{
		buttonNew.frame = frameNewPortrait;
		buttonReset.frame = frameResetPortrait;
		buttonScore.frame = frameScorePortrait;
		buttonDel.frame = frameDelPortrait;
		buttonUndo.frame = frameUndoPortrait;
		buttonMemo.frame = frameMemoPortrait;
		buttonHint.frame = frameHintButtonPortrait;
		
		labelTitleLevel.frame = frameTitleLevelPortrait;
		labelLevel.frame = frameLevelPortrait;	
		labelTitleGameTime.frame = frameTitleGameTimePortrait;	
		labelGameTime.frame = frameGameTimePortrait;	
		labelTitleBlank.frame = frameTitleBlankPortrait;	
		labelBlank.frame = frameBlankPortrait;
		labelTitleHint.frame = frameTitleHintPortrait;	
		labelHint.frame = frameHintPortrait;
	} else {
		buttonNew.frame = frameNewLandscape;
		buttonReset.frame = frameResetLandscape;
		buttonScore.frame = frameScoreLandscape;
		buttonDel.frame = frameDelLandscape;
		buttonUndo.frame = frameUndoLandscape;
		buttonMemo.frame = frameMemoLandscape;
		buttonHint.frame = frameHintButtonLandscape;

		labelTitleLevel.frame = frameTitleLevelLandscape;
		labelLevel.frame = frameLevelLandscape;	
		labelTitleGameTime.frame = frameTitleGameTimeLandscape;	
		labelGameTime.frame = frameGameTimeLandscape;	
		labelTitleBlank.frame = frameTitleBlankLandscape;	
		labelBlank.frame = frameBlankLandscape;
		labelTitleHint.frame = frameTitleHintLandscape;
		labelHint.frame = frameHintLandscape;
	}
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


// deprecated
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	NSLog(@"shouldAutorotateToInterfaceOrientation");	

#ifdef ADMOB_FREEVERSION
    if (cDeviceType == DEVICETYPE_IPHONE)
	{ 
        mainView.lastOrientation = UIInterfaceOrientationPortrait;	
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
/*        CGRect frameTemp = bannerView_.frame;
        NSLog(@"bannerView_.frame = %f,%f", bannerView_.frame.origin.x, bannerView_.frame.origin.y);
        frameTemp.origin.y -= 1;
        
        bannerView_.frame = frameTemp;
        NSLog(@"bannerView_.frame = %f,%f", bannerView_.frame.origin.x, bannerView_.frame.origin.y);
*/        
//        NSLog(@"self.view.frame.size=%f,%f", self.view.frame.size.width, self.view.frame.size.height);
        if (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)	{
            CGRect frameTemp = bannerView_.frame;
            
            frameTemp.origin.x = (mainView.rectPortrait.size.width - IPAD_GAD_W)/2.0;
            frameTemp.origin.y = mainView.rectPortrait.size.height - IPAD_GAD_H;
            bannerView_.frame = frameTemp;
        } else {
            CGRect frameTemp = bannerView_.frame;
            
            frameTemp.origin.x = -5; 
            frameTemp.origin.y = mainView.rectLandscape.size.height - IPAD_GAD_H;
            
            bannerView_.frame = frameTemp;
        }
    }
#endif
	
	mainView.lastOrientation = interfaceOrientation;	
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait ||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)	{
		mainView.rectCurrent = mainView.rectPortrait;
		mainView.fTableWidth = mainView.rectCurrent.size.width;
	} else { 
		mainView.rectCurrent = mainView.rectLandscape;
        NSLog(@"mainView.rectCurrent=%f,%f", mainView.rectCurrent.size.width, mainView.rectCurrent.size.height);       
#ifdef ADMOB_FREEVERSION
        if (cDeviceType == DEVICETYPE_IPAD)
        {
            mainView.fTableWidth = (mainView.rectCurrent.size.height - IPAD_GAD_H) / mainView.fPress;            NSLog(@"%f,%f", mainView.rectCurrent.size.height - IPAD_GAD_H, mainView.rectCurrent.size.height);
            return YES;
        }
#endif        
        mainView.fTableWidth = mainView.rectCurrent.size.height;
	}

	
	return YES;
}


#if 0 //def ADMOB_FREEVERSION


#pragma mark -
#pragma mark Banner frame change methods

- (void)moveBannerViewOffscreen
{
	CGRect newBannerFrame;	
	CGRect newMainFrame = frameMainViewOrg;
	newMainFrame.origin.y = self.view.frame.origin.y;
	frameMainViewOrg = newMainFrame;
	
	// Hide iAd
	newBannerFrame= self.bannerView.frame;
	newBannerFrame.origin.y = -60;
	self.bannerView.frame = newBannerFrame;
	
	// Show adMob
	newBannerFrame = adViewController.view.frame;
	if (newBannerFrame.origin.y > -100) {
		newBannerFrame.origin.y = frameMainViewOrg.size.height-newBannerFrame.size.height;
		adViewController.view.frame = newBannerFrame;

		// MainView resize
/*		newMainFrame.size.height = frameMainViewOrg.size.height - newBannerFrame.size.height;
		self.mainView.frame = newMainFrame;
		
		self.mainView.fPress = newMainFrame.size.height / frameMainViewOrg.size.height;
*/		
	} else {	
		// Fail to show adMob
/*		newMainFrame.size.height = frameMainViewOrg.size.height;
		self.mainView.frame = newMainFrame;
		self.mainView.fPress = 1.f;
*/	}
}


- (void)moveBannerViewOnscreen
{
	CGRect newBannerFrame;		
	CGRect newMainFrame = frameMainViewOrg;
	newMainFrame.origin.y = self.view.frame.origin.y;
	frameMainViewOrg = newMainFrame;
	
	// Show iAd
	newBannerFrame= self.bannerView.frame;
	newBannerFrame.origin.y = frameMainViewOrg.size.height - newBannerFrame.size.height;
	self.bannerView.frame = newBannerFrame;	
	
	// MainView resize
/*	newMainFrame.size.height = frameMainViewOrg.size.height - self.bannerView.frame.size.height;
	self.mainView.frame = newMainFrame;
	self.mainView.fPress = newMainFrame.size.height / frameMainViewOrg.size.height;
*/	
	// Hide iAdMob
	newBannerFrame = adViewController.view.frame;
	if (newBannerFrame.origin.y > -100) {
		newBannerFrame.origin.y = -60;
		adViewController.view.frame = newBannerFrame;
	}	
}




#pragma mark -
#pragma mark ADBannerViewDelegate methods


- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	[self moveBannerViewOffscreen];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
//	[self moveBannerViewOnscreen];
	[self moveBannerViewOffscreen];
}


#endif


@end
