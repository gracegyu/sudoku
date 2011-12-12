//
//  MainViewController.h
//  SudokuHelper
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#ifdef IPHONE_FREEVERSION
#import <UIKit/UIKit.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
#import <iAd/iAd.h>
#endif
#import "AdViewController.h"
#import "AdMobDelegateProtocol.h"
#endif

#import "FlipsideViewController.h"
#import "MainView.h"


@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
	MainView	*mainView;
	CGRect		frameMainViewOrg;

	UILabel		*labelNewGame;
	UILabel		*labelTitleLevel;
	UILabel		*labelTitleGameTime;
	UILabel		*labelTitleBlank;
	UILabel		*labelLevel;
	UILabel		*labelGameTime;
	UILabel		*labelBlank;
	
	CGRect		frameTitleLevelPortrait;
	CGRect		frameTitleLevelLandscape;
	CGRect		frameLevelPortrait;
	CGRect		frameLevelLandscape;
	CGRect		frameTitleGameTimePortrait;
	CGRect		frameTitleGameTimeLandscape;
	CGRect		frameGameTimePortrait;
	CGRect		frameGameTimeLandscape;
	CGRect		frameTitleBlankPortrait;
	CGRect		frameTitleBlankLandscape;
	CGRect		frameBlankPortrait;
	CGRect		frameBlankLandscape;
	
	UIButton	*buttonNewGameVeryEasy;
	UIButton	*buttonNewGameEasy;
	UIButton	*buttonNewGameNormal;
	UIButton	*buttonNewGameHard;
	UIButton	*buttonNewGameVeryHard;
	UIButton	*buttonNewGameCancel;

	
	UIButton	*buttonNew;
	UIButton	*buttonUndo;
	UIButton	*buttonMemo;
	UIButton	*buttonDel;
	UIButton	*buttonReset;
	UIButton	*buttonScore;
	UIButton	*buttonHint;
	
	CGRect		frameNewPortrait;
	CGRect		frameNewLandscape;
	CGRect		frameUndoPortrait;
	CGRect		frameUndoLandscape;
	CGRect		frameMemoPortrait;
	CGRect		frameMemoLandscape;
	CGRect		frameDelPortrait;
	CGRect		frameDelLandscape;
	CGRect		frameResetPortrait;
	CGRect		frameResetLandscape;
	CGRect		frameScorePortrait;
	CGRect		frameScoreLandscape;
	CGRect		frameHintPortrait;
	CGRect		frameHintLandscape;
	
	UIView		*viewMenu;

	
	NSTimer		*timerGame;
	NSTimer		*timerNewGame;
	UIActivityIndicatorView	*activityIndicator;
	
	NSInteger	scoreGames[5];
	NSInteger	scoreClears[5];
	NSInteger	scoreBestTime[5];
	NSInteger	scoreClearTimeSum[5];
	NSInteger	levelNewGame;
	NSInteger	countHint;
	
#ifdef IPHONE_FREEVERSION
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	ADBannerView	*bannerView;
#endif
	AdViewController *adViewController;	
#endif
	
}

#ifdef IPHONE_FREEVERSION
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
@property (nonatomic, retain) IBOutlet ADBannerView	*bannerView;
#endif
@property (nonatomic, retain) IBOutlet AdViewController *adViewController;
#endif

@property (nonatomic, retain) MainView *mainView;
@property (nonatomic, retain) IBOutlet UILabel	*labelNewGame;
@property (nonatomic, retain) IBOutlet UILabel	*labelTitleLevel;
@property (nonatomic, retain) IBOutlet UILabel	*labelTitleGameTime;
@property (nonatomic, retain) IBOutlet UILabel	*labelTitleBlank;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameVeryEasy;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameEasy;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameNormal;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameHard;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameVeryHard;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameCancel;

@property (nonatomic, retain) IBOutlet UIButton	*buttonNew;
@property (nonatomic, retain) IBOutlet UIButton	*buttonUndo;
@property (nonatomic, retain) IBOutlet UIButton	*buttonMemo;
@property (nonatomic, retain) IBOutlet UIButton	*buttonScore;
@property (nonatomic, retain) IBOutlet UIButton	*buttonDel;
@property (nonatomic, retain) IBOutlet UIButton	*buttonReset;
@property (nonatomic, retain) IBOutlet UIButton	*buttonHint;


@property (nonatomic, retain) IBOutlet UIView		*viewMenu;
@property (nonatomic, retain) IBOutlet UILabel		*labelLevel;
@property (nonatomic, retain) IBOutlet UILabel		*labelGameTime;
@property (nonatomic, retain) IBOutlet UILabel		*labelBlank;
@property (nonatomic, retain) NSTimer		*timerGame;
@property (nonatomic, retain) NSTimer		*timerNewGame;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*activityIndicator;



- (IBAction)showInfo;
- (IBAction)runUndo;
- (IBAction)memoOnOff;
- (IBAction)delNumber;
- (IBAction)clearNumbers;
- (IBAction)doHint;



- (IBAction)showMenu;
- (IBAction)menuVeryEasy;
- (IBAction)menuEasy;
- (IBAction)menuNormal;
- (IBAction)menuHard;
- (IBAction)menuVeryHard;
- (IBAction)menuCancel;



- (void) showMenuView;
- (void) hideMenuView;
- (void) setGameLevel;
- (void) startTimer;
- (void) stopTimer;
- (void) OnTimer:(NSTimer *)timer;
- (void) updateBlankCellCount;
- (void) updateButtonUndo;
- (void) updateButtonClear;
- (void) updateButtonDel;
- (void) updateButtonHint;
- (void) writeScore:(SudokuGame*)sudokuGame;
- (void) showMemoButton;
- (void) showHintButton;




@end
