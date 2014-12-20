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
#ifdef USE_JMC
#import "JMCCustomDataSource.h"
#endif


#ifdef ADMOB_FREEVERSION
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"
#endif

#import "MainView.h"
#import "Constants.h"


typedef struct DAILYSTAT
{
    NSInteger total;
    NSInteger besttime;
    BOOL played;
} DAILYSTAT;


//@class GADInterstitial;
//@class GADRequest;

@interface MainViewController : TPMultiLayoutViewController <UIGestureRecognizerDelegate
    ,UIAlertViewDelegate
#ifdef USE_JMC
    ,JMCCustomDataSource
#endif
#ifdef LOCATIONTRACK
    ,CLLocationManagerDelegate
#endif
    ,SKProductsRequestDelegate
#ifdef ADMOB_FREEVERSION
    ,GADBannerViewDelegate
    ,GADInterstitialDelegate
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
//	UIButton	*buttonNewGameDailyPuzzle;
    UILabel     *labelDailyStat;
	UIButton	*buttonNewGameVeryEasy;
	UIButton	*buttonNewGameEasy;
	UIButton	*buttonNewGameNormal;
	UIButton	*buttonNewGameHard;
	UIButton	*buttonNewGameVeryHard;
	UIButton	*buttonNewGameCancel;

    
//    UILabel		*labelDailyAutoMemo;
//	UIButton	*buttonDailyCheckboxAutoMemo;
	UIButton	*buttonDailyRanking;
	UIButton	*buttonDailyGameSudoku;
	UIButton	*buttonDailyGameGt;
	UIButton	*buttonDailyGameKiller;
	UIButton	*buttonDailyGameCalcu;
    UIButton    *buttonNickname;
    UILabel     *labelDailyStatSudoku;
    UILabel     *labelDailyStatGt;
    UILabel     *labelDailyStatKiller;
    UILabel     *labelDailyStatCalcu;
    UILabel     *labelNickname;
    
	UIButton	*buttonDailyGameCancel;
    
    UIButton	*buttonNewGame;
	UIButton	*buttonDailyGame;
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
	UIButton	*buttonRank;
	UIButton	*buttonHistory;
	UIButton	*buttonFeedback;
    
    UIButton    *buttonCloseButton;
    UIButton    *buttonPlayNew;
    UIButton    *buttonPlayAgain;
    UIButton    *buttonSeeReplay;
	UIButton    *buttonRecordShare;
	UIButton    *buttonPuzzleShare;
	
	UIView		*viewMenu;
	UIView		*viewNewGame;
	UIView		*viewDailyGame;
	UIView		*viewGlass;

	
	NSTimer		*timerGame;
	NSTimer		*timerNewGame;
	NSTimer		*timerDailyGame;
	UIActivityIndicatorView	*activityIndicator;
	UIActivityIndicatorView	*activityIndicatorDailyStat;
	UIActivityIndicatorView	*activityIndicatorDailyGame;
	
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
    
    
//    NSInteger        nAddThisWait;
    
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
    NSString* strMsgFinish;
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

//@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameDailyPuzzle;
@property (nonatomic, retain) IBOutlet UILabel  *labelDailyStat;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameVeryEasy;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameEasy;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameNormal;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameHard;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameVeryHard;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGameCancel;

//@property (nonatomic, retain) IBOutlet UILabel	*labelDailyAutoMemo;
//@property (nonatomic, retain) IBOutlet UIButton	*buttonDailyCheckboxAutoMemo;
@property (nonatomic, retain) IBOutlet UIButton	*buttonDailyRanking;
@property (nonatomic, retain) IBOutlet UIButton	*buttonDailyGameSudoku;
@property (nonatomic, retain) IBOutlet UIButton	*buttonDailyGameGt;
@property (nonatomic, retain) IBOutlet UIButton	*buttonDailyGameKiller;
@property (nonatomic, retain) IBOutlet UIButton	*buttonDailyGameCalcu;
@property (nonatomic, retain) IBOutlet UIButton	*buttonNickname;
@property (nonatomic, retain) IBOutlet UILabel  *labelDailyStatSudoku;
@property (nonatomic, retain) IBOutlet UILabel  *labelDailyStatGt;
@property (nonatomic, retain) IBOutlet UILabel  *labelDailyStatKiller;
@property (nonatomic, retain) IBOutlet UILabel  *labelDailyStatCalcu;
@property (nonatomic, retain) IBOutlet UILabel  *labelNickname;

@property (nonatomic, retain) IBOutlet UIButton	*buttonDailyGameCancel;


@property (nonatomic, retain) IBOutlet UIButton	*buttonNewGame;
@property (nonatomic, retain) IBOutlet UIButton	*buttonDailyGame;
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
@property (nonatomic, retain) IBOutlet UIButton	*buttonRank;
@property (nonatomic, retain) IBOutlet UIButton	*buttonHistory;
@property (nonatomic, retain) IBOutlet UIButton	*buttonFeedback;
@property (nonatomic, retain) IBOutlet UIButton *buttonCloseButton;
@property (nonatomic, retain) IBOutlet UIButton *buttonPlayNew;
@property (nonatomic, retain) IBOutlet UIButton *buttonPlayAgain;
@property (nonatomic, retain) IBOutlet UIButton *buttonSeeReplay;

@property (nonatomic, retain) IBOutlet UIButton *buttonRecordShare;
@property (nonatomic, retain) IBOutlet UIButton *buttonPuzzleShare;


@property (nonatomic, retain) IBOutlet UIView		*viewMenu;
@property (nonatomic, retain) IBOutlet UIView		*viewNewGame;
@property (nonatomic, retain) IBOutlet UIView		*viewDailyGame;
@property (nonatomic, retain) IBOutlet UILabel		*labelLevel;
@property (nonatomic, retain) IBOutlet UILabel		*labelGameTime;
@property (nonatomic, retain) IBOutlet UILabel		*labelBlank;
@property (nonatomic, retain) IBOutlet UILabel		*labelHint;
@property (nonatomic, retain) NSTimer		*timerGame;
@property (nonatomic, retain) NSTimer		*timerNewGame;
@property (nonatomic, retain) NSTimer		*timerDailyGame;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*activityIndicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*activityIndicatorDailyStat;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*activityIndicatorDailyGame;
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
@property (nonatomic, retain) NSString *strMsgFinish;

#ifdef ADMOB_FREEVERSION
@property (nonatomic, strong) GADInterstitial *interstitial;
- (GADRequest *)request;
- (void) loadInterstitial;
- (void) showInterstitial;
#endif

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

- (IBAction)openShareRecord;
- (IBAction)openSharePuzzle;

- (IBAction)doHint;
- (IBAction)showScoreView;
- (IBAction)showSettingView;
- (IBAction)showHelpView;
- (IBAction)showRankView;
- (IBAction)showFeedbackView;



- (IBAction)showMenu;
- (IBAction)menuCancel;

- (IBAction)showNewGame;
- (IBAction)showDailyGame;
- (IBAction)newgameDailyPuzzle;
- (IBAction)newgameVeryEasy;
- (IBAction)newgameEasy;
- (IBAction)newgameNormal;
- (IBAction)newgameHard;
- (IBAction)newgameVeryHard;
- (IBAction)newgameCancel;
- (IBAction)changeAutoMemo;
- (IBAction)setSudokuType;

- (IBAction)dailygameSudoku;
- (IBAction)dailygameGt;
- (IBAction)dailygameKiller;
- (IBAction)dailygameCalcudoku;
- (IBAction)dailygameCancel;
- (IBAction)changeNickName;
//- (IBAction)changeDailyAutoMemo;


- (void) setLocalizedMessage;

- (void) showMenuView;
- (void) showNewGameView;
- (void) hideNewGameView;
- (void) showDailyGameView;
- (void) hideDailyGameView;
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
- (NSInteger) getCheckSum;	// forVersion2
- (NSString*) getNowYYYYMMDD;
- (NSString *)percentEscapeString:(NSString *)string;

@end

@interface APActivityProvider : UIActivityItemProvider <UIActivityItemSource>
{
    NSString *strMsg;
    NSString *strMsgTwitter;
}

@property (nonatomic, retain) NSString *strMsg;
@property (nonatomic, retain) NSString *strMsgTwitter;
@end


