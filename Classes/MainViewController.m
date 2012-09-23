//
//  MainViewController.m
//  SudokuHelper
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ScoreViewController.h"
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





- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 	NSLog(@"initWithNibName");	
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        mainView = (MainView*) self.view;
 	    frameMainViewOrg = mainView.frame;
	   NSLog(@"frameMainViewOrg = %f,%f", frameMainViewOrg.size.width, frameMainViewOrg.size.height);

       
       [buttonMemo setTitle:NSLocalizedString(@"memo", nil) forState:UIControlStateNormal];
       [buttonDel setTitle:NSLocalizedString(@"del", nil) forState:UIControlStateNormal];
       [buttonNew setTitle:NSLocalizedString(@"new", nil) forState:UIControlStateNormal];
       [buttonReset setTitle:NSLocalizedString(@"reset", nil) forState:UIControlStateNormal];
       [buttonScore setTitle:NSLocalizedString(@"score", nil) forState:UIControlStateNormal];
       [buttonUndo setTitle:NSLocalizedString(@"undo", nil) forState:UIControlStateNormal];
       [buttonHint setTitle:NSLocalizedString(@"hint", nil) forState:UIControlStateNormal];
       

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

     
#ifdef ADMOB_FREEVERSION	 
     // Create a view of the standard size at the bottom of the screen.
     bannerView_ = [[GADBannerView alloc] initWithFrame:areaAdBanner.frame];
     bannerView_.adUnitID = MY_BANNER_UNIT_ID;
     
     bannerView_.rootViewController = self;
     [self.view addSubview:bannerView_];
     
     [bannerView_ loadRequest:[GADRequest request]];     
#endif
	 

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    bannerView_.frame = areaAdBanner.frame;;
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

- (IBAction) showScoreView {    
	ScoreViewController *controller = [[ScoreViewController alloc] initWithNibName:
										  cDeviceType == DEVICETYPE_IPAD ? @"ScoreView4iPad" : 
										  @"ScoreView" bundle:nil];
    controller.mainViewController = self;
	
	controller.title = NSLocalizedString(@"Score", nil);
	
	controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
	[self presentModalViewController:controller animated:YES];
    // UIModalTransitionStyleCrossDissolve for newgame
	
	
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
    
    
    CGRect frameOld = viewMenu.frame;
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



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{ 
	NSLog(@"willRotateToInterfaceOrientation toInterfaceOrientation = %d duration = %f", toInterfaceOrientation, duration);
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    bannerView_.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    [self setOrientationFrame: mainView.lastOrientation];
    bannerView_.frame = areaAdBanner.frame;
    bannerView_.hidden = NO;

    [mainView setNeedsDisplay];
//    [self setOrientation];
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



@end
