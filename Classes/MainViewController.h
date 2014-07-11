//
//  MainViewController.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//



#import <UIKit/UIKit.h>
#ifdef LOCATIONTRACK
#import <CoreLocation/CoreLocation.h>
#endif
#import <StoreKit/StoreKit.h>
#import <StoreKit/SKProductsRequest.h>
#import <StoreKit/SKProduct.h>
#import <StoreKit/SKPaymentQueue.h>
#import <StoreKit/SKPaymentTransaction.h>
#import "TPMultiLayoutViewController.h"
#import "JMCCustomDataSource.h"



#ifdef ADMOB_FREEVERSION
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
#endif

#import "MainView.h"
#import "Constants.h"


typedef struct DAILYSTAT
{
    NSInteger total;
    NSInteger besttime;
    BOOL played;
} DAILYSTAT;



@interface MainViewController : TPMultiLayoutViewController <UIGestureRecognizerDelegate
    ,JMCCustomDataSource
#ifdef LOCATIONTRACK
    ,CLLocationManagerDelegate
#endif
    ,SKProductsRequestDelegate
#ifdef ADMOB_FREEVERSION
    ,GADBannerViewDelegate
#endif
    >
{
	MainView	*mainView;
	CGRect		frameMainViewOrg;

	UILabel		*labelNewGame;
	UILabel		*labelTitleLevel;
	UILabel		*labelTitleGameTime;
	UILabel		*labelTitleBlank;
	UILabel		*labelTitleHint;
	UILabel		*labelLevel;
	UILabel		*labelGameTime;
	UILabel		*labelBlank;
	UILabel		*labelHint;
    
    UILabel     *labelLicense;

    UIButton    *areaPuzzleTable;
    UIButton    *areaNumButton;
    UIButton    *areaAdBanner;
    
	UILabel		*labelAutoMemo;
    UILabel     *labelSudokuType;
	UIButton	*buttonCheckboxAutoMemo;
	UIButton	*buttonNewGameDailyPuzzle;
    UILabel     *labelDailyStat;
	UIButton	*buttonNewGameVeryEasy;
	UIButton	*buttonNewGameEasy;
	UIButton	*buttonNewGameNormal;
	UIButton	*buttonNewGameHard;
	UIButton	*buttonNewGameVeryHard;
	UIButton	*buttonNewGameCancel;

	
	UIButton	*buttonNewGame;
	UIButton	*buttonMenu;
	UIButton	*buttonUndo;
	UIButton	*buttonRedo;
	UIButton	*buttonBookmark;
	UIButton	*buttonMemo;
	UIButton	*buttonDel;
	UIButton	*buttonReset;
	UIButton	*buttonSharePuzzle;
	UIButton	*buttonScore;
	UIButton	*buttonHint;
    UIButton    *buttonSetting;
	
	UIButton	*buttonMenuClose;
	UIButton	*buttonHelp;
	UIButton	*buttonHistory;
	UIButton	*buttonFeedback;
    
    UIButton    *buttonCloseButton;
    UIButton    *buttonPlayNew;
    UIButton    *buttonPlayAgain;
    UIButton    *buttonSeeReplay;
	UIButton    *buttonFacebookRecord;
	UIButton    *buttonFacebookPuzzle;
	UIButton    *buttonTwitterRecord;
	UIButton    *buttonTwitterPuzzle;
	
	UIView		*viewMenu;
	UIView		*viewNewGame;
	UIView		*viewGlass;

	
	NSTimer		*timerGame;
	NSTimer		*timerNewGame;
	UIActivityIndicatorView	*activityIndicator;
	UIActivityIndicatorView	*activityIndicatorNewGame;
	
	SUDOKUSCORE score;
    
	NSInteger	levelNewGame;
	NSInteger	countHint;

#ifdef ADMOB_FREEVERSION
    GADBannerView *bannerView_;

#endif
	CGFloat		intervalX;
	CGFloat		intervalX2;
	
	NSTimer		*timerUndoRepeat;
	NSTimer		*timerRedoRepeat;
	BOOL		bUndoRepeat;
    BOOL        bAd;
    BOOL        bReplay;
    UISegmentedControl *segmentType;
    
    
    NSInteger        nAddThisWait;
    
	NSString *gServerIP;
	NSInteger gUserID;
    NSString *gUserName;
	NSString *gDeviceID;
	NSInteger gVersion;

    DAILYSTAT   dailyStat[4];   // daily puzzle 통계
    BOOL    bReadyDownloadDailyPuzzle;
    NSString *nowDate;
#ifdef LOCATIONTRACK
    CLLocationManager *locationManager;
    CLLocationDegrees currentLatitude;
    CLLocationDegrees currentLongtitude;
#endif
    SKProduct *productHint50;
    BOOL    bBuyingHint50;
}



@property (nonatomic, retain) MainView *mainView;
@property (nonatomic, retain) IBOutlet UILabel	*labelNewGame;
@property (nonatomic, retain) IBOutlet UILabel	*labelTitleLevel;
@property (nonatomic, retain) IBOutlet UILabel	*labelTitleGameTime;
@property (nonatomic, retain) IBOutlet UILabel	*labelTitleBlank;
@property (nonatomic, retain) IBOutlet UILabel	*labelTitleHint;
@property (nonatomic, retain) IBOutlet UIButton	*areaPuzzleTable;
@property (nonatomic, retain) IBOutlet UIButton	*areaNumButton;
@property (nonatomic, retain) IBOutlet UIButton *areaAdBanner;

@property (nonatomic, retain) IBOutlet UILabel *labelLicense;


@property (nonatomic, retain) IBOutlet UILabel	*labelAutoMemo;
@property (nonatomic, retain) IBOutlet UILabel	*labelSudokuType;
@property (nonatomic, retain) IBOutlet UIButton	*buttonCheckboxAutoMemo;

@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameDailyPuzzle;
@property (nonatomic, retain) IBOutlet UILabel  *labelDailyStat;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameVeryEasy;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameEasy;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameNormal;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameHard;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameVeryHard;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameCancel;

@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGame;
@property (nonatomic, retain) IBOutlet UIButton	*buttonMenu;
@property (nonatomic, retain) IBOutlet UIButton	*buttonUndo;
@property (nonatomic, retain) IBOutlet UIButton	*buttonRedo;
@property (nonatomic, retain) IBOutlet UIButton	*buttonBookmark;
@property (nonatomic, retain) IBOutlet UIButton	*buttonMemo;
@property (nonatomic, retain) IBOutlet UIButton	*buttonScore;
@property (nonatomic, retain) IBOutlet UIButton	*buttonDel;
@property (nonatomic, retain) IBOutlet UIButton	*buttonReset;
@property (nonatomic, retain) IBOutlet UIButton	*buttonSharePuzzle;
@property (nonatomic, retain) IBOutlet UIButton	*buttonHint;
@property (nonatomic, retain) IBOutlet UIButton	*buttonSetting;
@property (nonatomic, retain) IBOutlet UIButton	*buttonMenuClose;
@property (nonatomic, retain) IBOutlet UIButton	*buttonHelp;
@property (nonatomic, retain) IBOutlet UIButton	*buttonHistory;
@property (nonatomic, retain) IBOutlet UIButton	*buttonFeedback;
@property (nonatomic, retain) IBOutlet UIButton *buttonCloseButton;
@property (nonatomic, retain) IBOutlet UIButton *buttonPlayNew;
@property (nonatomic, retain) IBOutlet UIButton *buttonPlayAgain;
@property (nonatomic, retain) IBOutlet UIButton *buttonSeeReplay;
@property (nonatomic, retain) IBOutlet UIButton *buttonFacebookRecord;
@property (nonatomic, retain) IBOutlet UIButton *buttonFacebookPuzzle;
@property (nonatomic, retain) IBOutlet UIButton *buttonTwitterRecord;
@property (nonatomic, retain) IBOutlet UIButton *buttonTwitterPuzzle;


@property (nonatomic, retain) IBOutlet UIView		*viewMenu;
@property (nonatomic, retain) IBOutlet UIView		*viewNewGame;
@property (nonatomic, retain) IBOutlet UILabel		*labelLevel;
@property (nonatomic, retain) IBOutlet UILabel		*labelGameTime;
@property (nonatomic, retain) IBOutlet UILabel		*labelBlank;
@property (nonatomic, retain) IBOutlet UILabel		*labelHint;
@property (nonatomic, retain) NSTimer		*timerGame;
@property (nonatomic, retain) NSTimer		*timerNewGame;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*activityIndicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*activityIndicatorNewGame;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentType;


@property (nonatomic, retain) NSString *gServerIP;
@property NSInteger gUserID;
@property (nonatomic, retain) NSString *gUserName;
@property (nonatomic, retain) NSString *gDeviceID;
@property NSInteger gVersion;
#ifdef LOCATIONTRACK
@property (nonatomic, retain) CLLocationManager *locationManager;
#endif
@property (nonatomic, retain) NSString *nowDate;


- (IBAction)runUndo;
- (IBAction)runRedo;
- (IBAction)stopUndoRedoRepeat;

- (IBAction)runBookmark;
- (IBAction)memoOnOff;
- (IBAction)delNumber;
- (IBAction)clearNumbers;
- (IBAction)closeButton;
- (IBAction)playAgain;
- (IBAction)seeReplay;
- (IBAction)shareRecordFacebook;
- (IBAction)sharePuzzleFacebook;
- (IBAction)shareRecordTwitter;
- (IBAction)sharePuzzleTwitter;
//- (IBAction)shareToTwitter;
- (IBAction)doHint;
- (IBAction)showScoreView;
- (IBAction)showSettingView;
- (IBAction)showHelpView;
- (IBAction)showFeedbackView;



- (IBAction)showMenu;
- (IBAction)menuCancel;

- (IBAction)showNewGame;
- (IBAction)newgameDailyPuzzle;
- (IBAction)newgameVeryEasy;
- (IBAction)newgameEasy;
- (IBAction)newgameNormal;
- (IBAction)newgameHard;
- (IBAction)newgameVeryHard;
- (IBAction)newgameCancel;
- (IBAction)changeAutoMemo;
- (IBAction)setSudokuType;


- (void) setLocalizedMessage;

- (void) showMenuView;
- (void) showNewGameView;
- (void) hideNewGameView;
- (void) setGameLevel;
- (void) startGameTimer;
- (void) stopGameTimer;
- (void) OnTimer:(NSTimer *)timer;
- (void) updateBlankCellCount;
- (void) updateHintCount;
- (void) updateButtonUndo;
- (void) updateButtonBookmark;
- (void) updateButtonClear;
- (void) updateButtonDel;
- (void) updateButtonHint;

- (void) writeScoreAfterFinishGame:(SudokuGame*)sudokuGame;
- (void) updateButtonMemo;
- (void) showHintButton;
//- (void) setOrientationReady;
- (void) loadSetting;
- (void) saveSetting;
- (NSInteger) getBestTime:(NSInteger)level;
- (NSInteger) getTotalScore;

- (void) updateButtons;
- (BOOL) isReplaying;

@end
