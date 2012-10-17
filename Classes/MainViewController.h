//
//  MainViewController.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "TPMultiLayoutViewController.h"



#ifdef ADMOB_FREEVERSION
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
#endif

#import "MainView.h"



@interface MainViewController : TPMultiLayoutViewController <UIGestureRecognizerDelegate 
#ifdef ADMOB_FREEVERSION
    ,GADBannerViewDelegate
#endif
    >
{
	MainView	*mainView;
	CGRect		frameMainViewOrg;
//    enum LOCALE localeNow;

	UILabel		*labelNewGame;
	UILabel		*labelRights;
	UILabel		*labelTitleLevel;
	UILabel		*labelTitleGameTime;
	UILabel		*labelTitleBlank;
	UILabel		*labelTitleHint;
	UILabel		*labelLevel;
	UILabel		*labelGameTime;
	UILabel		*labelBlank;
	UILabel		*labelHint;

    UIButton    *areaPuzzleTable;
    UIButton    *areaNumButton;
    UIButton    *areaAdBanner;
    
	UIButton	*buttonNewGameVeryEasy;
	UIButton	*buttonNewGameEasy;
	UIButton	*buttonNewGameNormal;
	UIButton	*buttonNewGameHard;
	UIButton	*buttonNewGameVeryHard;
	UIButton	*buttonNewGameCancel;

	
	UIButton	*buttonNew;
	UIButton	*buttonUndo;
	UIButton	*buttonRedo;
	UIButton	*buttonBookmark;
	UIButton	*buttonMemo;
	UIButton	*buttonDel;
	UIButton	*buttonReset;
	UIButton	*buttonScore;
	UIButton	*buttonHint;
    UIButton    *buttonSetting;
	
	
	UIView		*viewMenu;

	
	NSTimer		*timerGame;
	NSTimer		*timerNewGame;
	UIActivityIndicatorView	*activityIndicator;
	
	NSInteger	scoreGames[10];					// original:5 automemo:5
	NSInteger	scoreClears[10];
	NSInteger	scoreBestTime[10];
	NSInteger	scoreClearTimeSum[10];
    NSInteger   scoreTotal;
	NSInteger	levelNewGame;
	NSInteger	countHint;

#ifdef ADMOB_FREEVERSION
    GADBannerView *bannerView_;

#endif
}


@property (nonatomic, retain) MainView *mainView;
@property (nonatomic, retain) IBOutlet UILabel	*labelNewGame;
@property (nonatomic, retain) IBOutlet UILabel	*labelRights;
@property (nonatomic, retain) IBOutlet UILabel	*labelTitleLevel;
@property (nonatomic, retain) IBOutlet UILabel	*labelTitleGameTime;
@property (nonatomic, retain) IBOutlet UILabel	*labelTitleBlank;
@property (nonatomic, retain) IBOutlet UILabel	*labelTitleHint;
@property (nonatomic, retain) IBOutlet UIButton	*areaPuzzleTable;
@property (nonatomic, retain) IBOutlet UIButton	*areaNumButton;
@property (nonatomic, retain) IBOutlet UIButton *areaAdBanner;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameVeryEasy;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameEasy;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameNormal;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameHard;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameVeryHard;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameCancel;

@property (nonatomic, retain) IBOutlet UIButton	*buttonNew;
@property (nonatomic, retain) IBOutlet UIButton	*buttonUndo;
@property (nonatomic, retain) IBOutlet UIButton	*buttonRedo;
@property (nonatomic, retain) IBOutlet UIButton	*buttonBookmark;
@property (nonatomic, retain) IBOutlet UIButton	*buttonMemo;
@property (nonatomic, retain) IBOutlet UIButton	*buttonScore;
@property (nonatomic, retain) IBOutlet UIButton	*buttonDel;
@property (nonatomic, retain) IBOutlet UIButton	*buttonReset;
@property (nonatomic, retain) IBOutlet UIButton	*buttonHint;
@property (nonatomic, retain) IBOutlet UIButton	*buttonSetting;


@property (nonatomic, retain) IBOutlet UIView		*viewMenu;
@property (nonatomic, retain) IBOutlet UILabel		*labelLevel;
@property (nonatomic, retain) IBOutlet UILabel		*labelGameTime;
@property (nonatomic, retain) IBOutlet UILabel		*labelBlank;
@property (nonatomic, retain) IBOutlet UILabel		*labelHint;
@property (nonatomic, retain) NSTimer		*timerGame;
@property (nonatomic, retain) NSTimer		*timerNewGame;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*activityIndicator;


- (IBAction)showScoreView;
- (IBAction)runUndo;
- (IBAction)runRedo;
- (IBAction)runBookmark;
- (IBAction)memoOnOff;
- (IBAction)delNumber;
- (IBAction)clearNumbers;
- (IBAction)doHint;
- (IBAction)showSettingView;



- (IBAction)showMenu;
- (IBAction)menuVeryEasy;
- (IBAction)menuEasy;
- (IBAction)menuNormal;
- (IBAction)menuHard;
- (IBAction)menuVeryHard;
- (IBAction)menuCancel;

- (void) setLocalizedMessage;

- (void) showMenuView;
- (void) hideMenuView;
- (void) setGameLevel;
- (void) startTimer;
- (void) stopTimer;
- (void) OnTimer:(NSTimer *)timer;
- (void) updateBlankCellCount;
- (void) updateHintCount;
- (void) updateButtonUndo;
- (void) updateButtonClear;
- (void) updateButtonDel;
- (void) updateButtonHint;

- (void) writeScoreAfterFinishGame:(SudokuGame*)sudokuGame;
- (void) showMemoButton;
- (void) showHintButton;
//- (void) setOrientationReady;
- (void) loadSetting;
- (void) saveSetting;
- (NSInteger) getBestTime:(NSInteger)level;
- (NSInteger) getTotalScore;



@end
