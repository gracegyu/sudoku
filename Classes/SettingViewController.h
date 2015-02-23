//
//  SettingViewController.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//


//@protocol SettingViewControllerDelegate;
#import "MainViewController.h"

#ifdef ADMOB_FREEVERSION
#import <StoreKit/StoreKit.h>
#import <StoreKit/SKProductsRequest.h>
#import <StoreKit/SKProduct.h>
#import <StoreKit/SKPaymentQueue.h>
#import <StoreKit/SKPaymentTransaction.h>
#endif

@interface SettingViewController :
TPMultiLayoutViewController
#ifdef ADMOB_FREEVERSION
<SKProductsRequestDelegate,SKPaymentTransactionObserver>
#endif
{
    MainViewController *mainViewController;
	
//    UINavigationBar     *naviBar;
	UINavigationItem	*naviItem;
    UIView  *viewMain;
	UILabel *lableTitle;
    
    UILabel	*labelSoundEffect;
    UILabel	*labelGuideline;
    UILabel	*labelDuplicationWarning;
    UILabel	*labelMarkingEqual;
    UILabel	*labelSkinColor;
    UILabel	*labelLocale;
    UILabel *labelNoAd;
    UILabel	*labelDescSoundEffect;
    UILabel	*labelDescGuideline;
    UILabel	*labelDescDuplicationWarning;
    UILabel	*labelDescMarkingEqual;
    UILabel	*labelDescSkinColor;
    UILabel	*labelDescLocale;
    UILabel *labelDescNoAd;
    
    UIButton *buttonDone;
    
    UIButton *buttonSoundEffect;
    UIButton *buttonGuildeline;
    UIButton *buttonDuplicationWarning;
    UIButton *buttonMarkingEqual;
    UIButton *buttonSkinColor;
    UIButton *buttonLocale;
    UIButton *buttonNoAd;

	
    UIButton *buttonFacebook;
    UIButton *buttonBugReport;
    UIButton *buttonReview;
    UIButton *buttonNewApp;
    

	UIButton *buttonColor0;
	UIButton *buttonColor1;
	UIButton *buttonColor2;
	UIButton *buttonColor3;
	UIButton *buttonColor4;
	UIButton *buttonColor5;
	UIButton *buttonColor6;
	UIButton *buttonColor7;
	UIButton *buttonColor8;
	UIButton *buttonColor9;
	UIButton *buttonColor10;
	UIButton *buttonColor11;

    UIButton *buttonColor[MAX_SKIN_COUNT];
    
    
    NSInteger skin;
    
    UILabel     *labelLicense;
    
#ifdef ADMOB_FREEVERSION
    SKProduct *productNoAd;
    SKProductsRequest *productRequestNoAd;
    SKPayment *paymentNoAd;
#endif

}


@property (nonatomic, retain) UIViewController	*mainViewController;
//@property (nonatomic, retain) IBOutlet UINavigationBar     *naviBar;
@property (nonatomic, retain) IBOutlet UINavigationItem	*naviItem;
@property (nonatomic, retain) IBOutlet UIView  *viewMain;
@property (nonatomic, retain) IBOutlet UILabel *lableTitle;

@property (nonatomic, retain) IBOutlet UILabel	*labelSoundEffect;
@property (nonatomic, retain) IBOutlet UILabel	*labelGuideline;
@property (nonatomic, retain) IBOutlet UILabel	*labelDuplicationWarning;
@property (nonatomic, retain) IBOutlet UILabel	*labelMarkingEqual;
@property (nonatomic, retain) IBOutlet UILabel	*labelSkinColor;
@property (nonatomic, retain) IBOutlet UILabel	*labelLocale;
@property (nonatomic, retain) IBOutlet UILabel	*labelNoAd;

@property (nonatomic, retain) IBOutlet UILabel	*labelDescSoundEffect;
@property (nonatomic, retain) IBOutlet UILabel	*labelDescGuideline;
@property (nonatomic, retain) IBOutlet UILabel	*labelDescDuplicationWarning;
@property (nonatomic, retain) IBOutlet UILabel	*labelDescMarkingEqual;
@property (nonatomic, retain) IBOutlet UILabel	*labelDescSkinColor;
@property (nonatomic, retain) IBOutlet UILabel	*labelDescLocale;
@property (nonatomic, retain) IBOutlet UILabel	*labelDescNoAd;
@property (nonatomic, retain) IBOutlet UILabel  *labelLicense;

@property (nonatomic, retain) IBOutlet UIButton *buttonDone;
@property (nonatomic, retain) IBOutlet UIButton *buttonSoundEffect;
@property (nonatomic, retain) IBOutlet UIButton *buttonGuildeline;
@property (nonatomic, retain) IBOutlet UIButton *buttonDuplicationWarning;
@property (nonatomic, retain) IBOutlet UIButton *buttonMarkingEqual;
@property (nonatomic, retain) IBOutlet UIButton *buttonSkinColor;
@property (nonatomic, retain) IBOutlet UIButton *buttonLocale;
@property (nonatomic, retain) IBOutlet UIButton *buttonNoAd;


@property (nonatomic, retain) IBOutlet UIButton *buttonFacebook;
@property (nonatomic, retain) IBOutlet UIButton *buttonBugReport;
@property (nonatomic, retain) IBOutlet UIButton *buttonReview;
@property (nonatomic, retain) IBOutlet UIButton *buttonNewApp;


@property (nonatomic, retain) IBOutlet UIButton *buttonColor0;
@property (nonatomic, retain) IBOutlet UIButton *buttonColor1;
@property (nonatomic, retain) IBOutlet UIButton *buttonColor2;
@property (nonatomic, retain) IBOutlet UIButton *buttonColor3;
@property (nonatomic, retain) IBOutlet UIButton *buttonColor4;
@property (nonatomic, retain) IBOutlet UIButton *buttonColor5;
@property (nonatomic, retain) IBOutlet UIButton *buttonColor6;
@property (nonatomic, retain) IBOutlet UIButton *buttonColor7;
@property (nonatomic, retain) IBOutlet UIButton *buttonColor8;
@property (nonatomic, retain) IBOutlet UIButton *buttonColor9;
@property (nonatomic, retain) IBOutlet UIButton *buttonColor10;
@property (nonatomic, retain) IBOutlet UIButton *buttonColor11;


#ifdef ADMOB_FREEVERSION
@property (nonatomic, retain) SKProduct *productNoAd;
@property (nonatomic, retain) SKProductsRequest *productRequestNoAd;
@property (nonatomic, retain) SKPayment *paymentNoAd;
#endif


- (IBAction)setSoundEffect;
- (IBAction)setGuideline;
- (IBAction)setDuplicationWarning;
- (IBAction)setMarkingEqual;
- (IBAction)setChanageSkin;
- (IBAction)dragChanageSkin:(id)sender;
- (IBAction)setLocaleChange;
- (IBAction)setNoAd;

- (IBAction)goFacebook;
- (IBAction)goBugReport;
- (IBAction)goReview;
- (IBAction)goNewApps;

- (IBAction)done;

@end


