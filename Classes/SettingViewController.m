//
//  SettingViewController.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import "MoreGamesViewController.h"
#import "Locale.h"
#import "SettingViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "Appirater.h"
#ifdef USE_JMC
#import "JMC.h"
#endif
#ifdef USE_FLURRY
#import "Flurry.h"
#endif
// Crash 테스트 버튼은 심사 빌드에서 뺀다.
//#import <stdlib.h>
//#import <FirebaseCore/FirebaseCore.h>
//#import <FirebaseCrashlytics/FirebaseCrashlytics.h>

#if 0
/// TestFlight(또는 샌드박스) 설치인지 본다.
///
/// App Store 정식 영수증은 `receipt`이고, TestFlight는 `sandboxReceipt`다.
/// 스토어 사용자에게는 크래시 버튼을 숨긴다.
///
/// 매개변수: 없음
/// 반환값: TestFlight이면 YES
static BOOL IsTestFlightInstall(void)
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    return [[receiptURL lastPathComponent] isEqualToString:@"sandboxReceipt"];
}
#endif


@implementation SettingViewController

@synthesize mainViewController;
@synthesize viewMain;
@synthesize naviItem;
@synthesize lableTitle;
@synthesize labelSoundEffect;
@synthesize labelGuideline;
@synthesize labelDuplicationWarning;
@synthesize labelMarkingEqual;
@synthesize labelSkinColor;
@synthesize labelLocale;
@synthesize labelNoAd;
@synthesize labelDescSoundEffect;
@synthesize labelDescGuideline;
@synthesize labelDescDuplicationWarning;
@synthesize labelDescMarkingEqual;
@synthesize labelDescSkinColor;
@synthesize labelDescLocale;
@synthesize labelDescNoAd;
@synthesize labelLicense;

@synthesize buttonDone;
@synthesize buttonSoundEffect;
@synthesize buttonGuildeline;
@synthesize buttonDuplicationWarning;
@synthesize buttonMarkingEqual;
@synthesize buttonSkinColor;
@synthesize buttonLocale;
@synthesize buttonNoAd;
@synthesize buttonRestore;

@synthesize buttonReview;

@synthesize buttonColor0;
@synthesize buttonColor1;
@synthesize buttonColor2;
@synthesize buttonColor3;
@synthesize buttonColor4;
@synthesize buttonColor5;
@synthesize buttonColor6;
@synthesize buttonColor7;
@synthesize buttonColor8;
@synthesize buttonColor9;
@synthesize buttonColor10;
@synthesize buttonColor11;

#ifdef ADMOB_FREEVERSION
@synthesize productNoAd;
@synthesize productRequestNoAd;
@synthesize paymentNoAd;
#endif



- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"viewWillAppear");
	self.navigationController.title = gettext(@"Setting", nil);
}

- (void) setLocalizedMessage
{
	NSString* str;
    naviItem.title = gettext(@"Setting", nil);
	
    labelLicense.text = [NSString stringWithFormat:STR_LICENSEFormat, [mainViewController getNowYYYY]];

    [buttonDone setTitle:gettext(@"Done", nil) forState:UIControlStateNormal];

    
    lableTitle.text = gettext(@"Setting", nil);
	labelSoundEffect.text = gettext(@"sound effect", nil);
    labelGuideline.text = gettext(@"guideline", nil);
    labelDuplicationWarning.text = gettext(@"duplication warning", nil);
    labelMarkingEqual.text = gettext(@"marking equal", nil);
    labelSkinColor.text = gettext(@"skin color", nil);
    labelLocale.text = gettext(@"language", nil);
    labelNoAd.text = gettext(@"no banner advertisement", nil);
    
    str = gettext(@"desc sound effect", nil);
	labelDescSoundEffect.text = [str stringByAppendingString:@"\n\n\n"];
    str = gettext(@"desc guideline", nil);
	labelDescGuideline.text = [str stringByAppendingString:@"\n\n\n"];
	str = gettext(@"desc duplication warning", nil);
    labelDescDuplicationWarning.text = [str stringByAppendingString:@"\n\n\n"];
	str = gettext(@"desc marking equal", nil);
    labelDescMarkingEqual.text = [str stringByAppendingString:@"\n\n\n"];
	str = gettext(@"desc auto memo", nil);
    labelDescSkinColor.text = [str stringByAppendingString:@"\n\n\n"];
	str = gettext(@"desc language", nil);
    labelDescLocale.text = [str stringByAppendingString:@"\n\n\n"];
    str = gettext(@"desc noad", nil);
    labelDescNoAd.text = [str stringByAppendingString:@"\n\n\n"];
    if (labelReviewTitle) {     // 언어를 바꿀 때 (줄은 layoutReviewRow 가 만든다)
        labelReviewTitle.text = gettext(@"app review", nil);
        labelReviewDesc.text = [gettext(@"desc app review", nil) stringByAppendingString:@"\n\n\n"];
    }
	
	
    
}

- (void) setImageSoundEffect
{
    if (mainViewController.mainView.nSettingSoundOff > 0)
        [buttonSoundEffect setBackgroundImage:[UIImage imageNamed:@"soundeffect_on"] forState:UIControlStateNormal];
    else
        [buttonSoundEffect setBackgroundImage:[UIImage imageNamed:@"soundeffect_off"] forState:UIControlStateNormal];
//    [buttonSoundEffect setBackgroundImage:[UIImage imageNamed:@"soundeffect_h"] forState:UIControlStateHighlighted];
}

- (void) setImageGuideline
{
    if (mainViewController.mainView.bSettingGuideline == YES)
        [buttonGuildeline setBackgroundImage:[UIImage imageNamed:@"guideline_on"] forState:UIControlStateNormal];
    else
        [buttonGuildeline setBackgroundImage:[UIImage imageNamed:@"guideline_off"] forState:UIControlStateNormal];
//    [buttonGuildeline setBackgroundImage:[UIImage imageNamed:@"guideline_h"] forState:UIControlStateHighlighted];
}

- (void) setImageDuplicationWarning
{
    if (mainViewController.mainView.bSettingDuplicationWarning == YES)
        [buttonDuplicationWarning setBackgroundImage:[UIImage imageNamed:@"dupwan_on"] forState:UIControlStateNormal];
    else
        [buttonDuplicationWarning setBackgroundImage:[UIImage imageNamed:@"dupwan_off"] forState:UIControlStateNormal];
//    [buttonDuplicationWarning setBackgroundImage:[UIImage imageNamed:@"dupwan_h"] forState:UIControlStateHighlighted];
}

- (void) setImageMarkingEqual
{
    if (mainViewController.mainView.bSettingMarkingEqual == YES)
        [buttonMarkingEqual setBackgroundImage:[UIImage imageNamed:@"markingequal_on"] forState:UIControlStateNormal];
    else
        [buttonMarkingEqual setBackgroundImage:[UIImage imageNamed:@"markingequal_off"] forState:UIControlStateNormal];
//    [buttonMarkingEqual setBackgroundImage:[UIImage imageNamed:@"markingequal_h"] forState:UIControlStateHighlighted];
}


- (UIImage *) imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void) setInitSkinColor
{
    for (int i=0; i<MAX_SKIN_COUNT; i++)
    {
        [buttonColor[i].layer setMasksToBounds:YES];

        [buttonColor[i].layer setBorderColor:[[UIColor whiteColor] CGColor]];
        NSInteger RGBA = [mainViewController.mainView getRGBA:i num:0];
        CGFloat R = ((CGFloat)((RGBA & 0xFF000000) >> 8*3))/255.f;
        CGFloat G = ((CGFloat)((RGBA & 0x00FF0000) >> 8*2))/255.f;
        CGFloat B = ((CGFloat)((RGBA & 0x0000FF00) >> 8*1))/255.f;
        CGFloat A = ((CGFloat)((RGBA & 0x000000FF) >> 8*0))/255.f;
        buttonColor[i].backgroundColor = [UIColor colorWithRed:R green:G blue:B alpha:A];
    }
    
    
}

- (void) setImageSkinColor
{
    for (int i=0; i<MAX_SKIN_COUNT; i++)
    {
        if (skin == i)
            [buttonColor[i].layer setBorderWidth: isIpad ? 4.0f : 3.0f];
        else
            [buttonColor[i].layer setBorderWidth: 0.0f];
    }
 
}


- (void) setImageLocale
{
    NSString* strLocale = gettext(@"locale", nil); 
    NSString* strIcon = nil;
    
    if ([strLocale compare:@"en"] == NSOrderedSame)
        strIcon = @"locale_en";
    else if ([strLocale compare:@"ko"] == NSOrderedSame)
        strIcon = @"locale_ko";
    else if ([strLocale compare:@"ja"] == NSOrderedSame)
        strIcon = @"locale_ja";
    else if ([strLocale compare:@"zh_CN"] == NSOrderedSame)
        strIcon = @"locale_zh_CN";
    else if ([strLocale compare:@"zh_TW"] == NSOrderedSame)
        strIcon = @"locale_zh_TW";
    else
        return;
    
    [buttonLocale setBackgroundImage:[UIImage imageNamed:strIcon] forState:UIControlStateNormal];
    
}

- (void) hideNoAd
{
    buttonNoAd.hidden = YES;
    labelNoAd.hidden = YES;
    labelDescNoAd.hidden = YES;
    buttonRestore.hidden = YES;
}

/// 설정 맨 아래 「app review」 줄. 다른 설정 줄과 같은 꼴 — 왼쪽 그림 단추 · 제목 · 설명.
/// 위치는 마지막으로 보이는 줄(광고 제거 줄이 보이면 그 아래, 아니면 그 자리) 바로 아래다.
/// 줄 간격 · 글꼴 · 색은 기존 줄(skin color · sound effect)에서 그대로 따른다.
- (UIImage *)reviewIconImage
{
    CGFloat side = 150;
    UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(side, side)];
    UIImage *img = [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        UIBezierPath *bg = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, side, side) cornerRadius:14];
        [[UIColor whiteColor] setFill];
        [bg fill];
        UIBezierPath *star = [UIBezierPath bezierPath];
        CGPoint c = CGPointMake(side / 2, side / 2 + 4);
        for (int k = 0; k < 10; k++) {
            CGFloat rad = (k % 2 == 0) ? 56 : 24;
            CGFloat ang = -M_PI_2 + k * M_PI / 5;
            CGPoint pt = CGPointMake(c.x + rad * cos(ang), c.y + rad * sin(ang));
            if (k == 0) [star moveToPoint:pt]; else [star addLineToPoint:pt];
        }
        [star closePath];
        [[UIColor colorWithRed:0.85 green:0.23 blue:0.19 alpha:1] setFill];
        [star fill];
    }];
    [r release];
    return img;
}

- (void)layoutReviewRow
{
    if (!buttonReview || !buttonSkinColor || !buttonMarkingEqual || !labelSkinColor || !labelDescSoundEffect || !buttonSoundEffect) return;
    UIView *host = buttonSkinColor.superview;
    CGFloat step = buttonSkinColor.frame.origin.y - buttonMarkingEqual.frame.origin.y;
    CGFloat y = buttonSkinColor.frame.origin.y + step;
    if (buttonNoAd && !buttonNoAd.hidden) y = buttonNoAd.frame.origin.y + step;

    if (buttonReview.superview != host) [host addSubview:buttonReview];
    buttonReview.frame = CGRectMake(buttonSkinColor.frame.origin.x, y, buttonSkinColor.frame.size.width, buttonSkinColor.frame.size.height);
    [buttonReview setBackgroundImage:[self reviewIconImage] forState:UIControlStateNormal];
    [buttonReview setBackgroundImage:nil forState:UIControlStateHighlighted];
    [buttonReview setTitle:nil forState:UIControlStateNormal];
    buttonReview.hidden = NO;

    if (!labelReviewTitle) {
        labelReviewTitle = [[UILabel alloc] init];
        labelReviewTitle.font = labelSkinColor.font;
        labelReviewTitle.textColor = labelSkinColor.textColor;
        labelReviewTitle.backgroundColor = [UIColor clearColor];
        labelReviewTitle.shadowColor = labelSkinColor.shadowColor;
        labelReviewTitle.shadowOffset = labelSkinColor.shadowOffset;
        labelReviewTitle.adjustsFontSizeToFitWidth = labelSkinColor.adjustsFontSizeToFitWidth;
        labelReviewTitle.minimumScaleFactor = labelSkinColor.minimumScaleFactor;
        [host addSubview:labelReviewTitle];
        labelReviewDesc = [[UILabel alloc] init];
        labelReviewDesc.font = labelDescSoundEffect.font;
        labelReviewDesc.textColor = labelDescSoundEffect.textColor;
        labelReviewDesc.backgroundColor = [UIColor clearColor];
        labelReviewDesc.shadowColor = labelDescSoundEffect.shadowColor;
        labelReviewDesc.shadowOffset = labelDescSoundEffect.shadowOffset;
        labelReviewDesc.numberOfLines = labelDescSoundEffect.numberOfLines;
        labelReviewDesc.lineBreakMode = labelDescSoundEffect.lineBreakMode;
        [host addSubview:labelReviewDesc];
        // 제목 · 설명을 눌러도 열리게 (투명 단추)
        UIButton *hit = [UIButton buttonWithType:UIButtonTypeCustom];
        hit.tag = 7701;
        [hit addTarget:self action:@selector(goReview) forControlEvents:UIControlEventTouchUpInside];
        [host addSubview:hit];
    }
    labelReviewTitle.frame = CGRectMake(labelSkinColor.frame.origin.x, y + (labelSkinColor.frame.origin.y - buttonSkinColor.frame.origin.y),
                                        labelSkinColor.frame.size.width, labelSkinColor.frame.size.height);
    labelReviewDesc.frame = CGRectMake(labelDescSoundEffect.frame.origin.x, y + (labelDescSoundEffect.frame.origin.y - buttonSoundEffect.frame.origin.y),
                                       labelDescSoundEffect.frame.size.width, labelDescSoundEffect.frame.size.height);
    labelReviewTitle.text = gettext(@"app review", nil);
    labelReviewDesc.text = [gettext(@"desc app review", nil) stringByAppendingString:@"\n\n\n"];
    UIView *hit = [host viewWithTag:7701];
    hit.frame = CGRectUnion(labelReviewTitle.frame, labelReviewDesc.frame);
}

- (void) setNoAdButton
{
#ifdef ADMOB_FREEVERSION
    if (mainViewController.bNoAd)
        [self hideNoAd];
#else
    [self hideNoAd];
#endif
    [self layoutReviewRow];
}


- (void) viewDidLoad
{
    DLog(@"viewDidLoad");
    
    skin = mainViewController.mainView.skin;
    
    buttonColor[0] = buttonColor0;
    buttonColor[1] = buttonColor1;
    buttonColor[2] = buttonColor2;
    buttonColor[3] = buttonColor3;
    buttonColor[4] = buttonColor4;
    buttonColor[5] = buttonColor5;
    buttonColor[6] = buttonColor6;
    buttonColor[7] = buttonColor7;
    buttonColor[8] = buttonColor8;
    buttonColor[9] = buttonColor9;
    buttonColor[10] = buttonColor10;
    buttonColor[11] = buttonColor11;    
    
    [self setLocalizedMessage];

    [self setImageSoundEffect];
    [self setImageGuideline];
    [self setImageDuplicationWarning];
    [self setImageMarkingEqual];
    [self setInitSkinColor];
    [self setImageSkinColor];
	[self setImageLocale];
    [self setNoAdButton];
    // [self installTestFlightCrashButton];
    
    
    
#ifdef ADMOB_FREEVERSION
    if ([SKPaymentQueue canMakePayments]) {	// 스토어가 사용 가능하다면
        NSLog(@"Start Shop!");
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];	// Observer를 등록한다.
    } else {
        NSLog(@"Failed Shop!");
    }

    productNoAd = nil;
    productRequestNoAd = [[SKProductsRequest alloc]
                          initWithProductIdentifiers:
                          [NSSet setWithObject:kNoAdItem]];
    productRequestNoAd.delegate = self;
    [productRequestNoAd start];
#endif
    
    
    
    [super viewDidLoad];
    // above ios5 && Paid
    if (SUPPORT_ROTATION) {
        [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.3];
        
    }
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [super viewDidUnload];
}


- (void)dealloc {
#ifdef ADMOB_FREEVERSION
    productRequestNoAd.delegate = nil;
    [productRequestNoAd release];
    productRequestNoAd = nil;
#endif
    [labelReviewTitle release];
    [labelReviewDesc release];
    [super dealloc];
}







- (IBAction)done
{
    
#ifdef ADMOB_FREEVERSION
    if ([SKPaymentQueue canMakePayments]) {	// 스토어가 사용 가능하다면
        NSLog(@"Start Shop!");
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];	// Observer를 해제한다.
        [[SKPaymentQueue defaultQueue] addTransactionObserver:mainViewController];	// Observer를 등록한다.
    } else {
        NSLog(@"Failed Shop!");
    }
#endif
    
    
    [mainViewController.mainView setSkinColorNum:skin];
    [mainViewController saveSetting];
    [mainViewController startGameTimer];
    
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        [mainViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        DLog(@"Done [UIDevice currentDevice].orientation=%ld", (long)[UIDevice currentDevice].orientation);
        //[mainViewController willRotateToInterfaceOrientation:[UIDevice currentDevice].orientation duration:0.3];
        //[mainViewController didRotateFromInterfaceOrientation:[UIDevice currentDevice].orientation];
        
        [mainViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


- (IBAction)setSoundEffect
{
    mainViewController.mainView.nSettingSoundOff = (mainViewController.mainView.nSettingSoundOff+1)%3;
    [self setImageSoundEffect];
    [mainViewController.mainView playSoundClick];
    [mainViewController saveSetting];
    
#ifdef USE_FLURRY
   NSString *str = [NSString stringWithFormat:@"SetSoundEffect(%ld)", (long)mainViewController.mainView.nSettingSoundOff];
    [Flurry logEvent:str];
#endif
}

- (IBAction)setGuideline
{
    mainViewController.mainView.bSettingGuideline = !mainViewController.mainView.bSettingGuideline;
    [self setImageGuideline];
    //[mainViewController.mainView playSoundClick];
    [mainViewController saveSetting];
    
    [mainViewController.mainView setNeedsDisplay];
}

- (IBAction)setDuplicationWarning
{    
    mainViewController.mainView.bSettingDuplicationWarning = !mainViewController.mainView.bSettingDuplicationWarning;
    [self setImageDuplicationWarning];
    //[mainViewController.mainView playSoundClick];
    [mainViewController saveSetting];
    
    [mainViewController.mainView setNeedsDisplay];
}

- (IBAction)setMarkingEqual
{
    mainViewController.mainView.bSettingMarkingEqual = !mainViewController.mainView.bSettingMarkingEqual;
    [self setImageMarkingEqual];
    //[mainViewController.mainView playSoundClick];
    [mainViewController saveSetting];

    [mainViewController.mainView setNeedsDisplay];
}

- (IBAction)setChanageSkin
{
    skin += 1;
    
    if (skin >= MAX_SKIN_COUNT)
        skin = 0;
    
//    [mainViewController.mainView setNextSkinColor];
    

    [self setImageSkinColor];
    //[mainViewController.mainView playSoundClick];
    //[mainViewController saveSetting];
 
#ifdef USE_FLURRY
    NSString *str = @"SetChangeSkin";
    [Flurry logEvent:str];
#endif
}

- (IBAction)dragChanageSkin:(id)sender
{
//    DLog(@"dragChanageSkin:%@", sender);   죽는다.

    int i;
    for (i=0; i<MAX_SKIN_COUNT; i++)
    {
        if (sender == buttonColor[i])
            break;
    }
    if (i < MAX_SKIN_COUNT)
    {
        skin = i;
        [self setImageSkinColor];
        //[mainViewController.mainView playSoundClick];
        
    }
 
}


- (IBAction)setLocaleChange
{
   // char dummy[100];
    
    DLog(@"setLocaleChange(%@)", gettext(@"locale", nil));
    
    NSString* strLocale = gettext(@"locale", nil);
    NSString* strLocale2 = nil;
//    NSString* strIcon = nil;
    
    if ([strLocale isEqualToString:@"en"])
        strLocale2 = @"ja";
    else if ([strLocale isEqualToString:@"ja"])
        strLocale2 = @"ko";
    else if ([strLocale isEqualToString:@"ko"])
        strLocale2 = @"zh_CN";
    else if ([strLocale isEqualToString:@"zh_CN"])
        strLocale2 = @"zh_TW";
    else if ([strLocale isEqualToString:@"zh_TW"])
        strLocale2 = @"en";
    else
        strLocale2 = @"en";
    
#ifdef USE_FLURRY
    NSString *str = [NSString stringWithFormat:@"SetLocale(%@)", strLocale2];
    [Flurry logEvent:str];
#endif
    
    [Locale setLocale:strLocale2];
    [self setLocalizedMessage];
    [mainViewController setLocalizedMessage];
    [self setImageLocale];
    
    [mainViewController DoneQuest:eQuestChangeLang];
}


- (IBAction)setNoAd
{
#ifdef ADMOB_FREEVERSION

    DLog(@"Buy NoAd");
    
    
    if (productNoAd) { // buy hint
        paymentNoAd = [SKPayment paymentWithProduct:productNoAd];
        [[SKPaymentQueue defaultQueue] addPayment:paymentNoAd];
    } else {
        DLog(@"Can't buy items");
        [mainViewController alertLocalizedAlertView:(NSString*)gettext(@"Can't buy this item in current setting.", nil)];
    }
    
#else
    // do nothing
#endif
    
}

- (IBAction)setRestore
{
#ifdef ADMOB_FREEVERSION
    
    DLog(@"Buy NoAd");
    
    if (productNoAd) { // buy hint
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    } else {
        DLog(@"Can't buy items");
        [mainViewController alertLocalizedAlertView:(NSString*)gettext(@"Can't buy this item in current setting.", nil)];
    }
    
#else
    // do nothing
#endif
    
}







//typedef struct SUDOKUSCORE
//{
//    NSInteger    scoreGames[SUDOKUTYPE_MAX][MAX_SCORE_TYPE];                    // original:5 automemo:5, userinput 2
//    NSInteger    scoreClears[SUDOKUTYPE_MAX][MAX_SCORE_TYPE];
//    NSInteger    scoreBestTime[SUDOKUTYPE_MAX][MAX_SCORE_TYPE];
//    NSInteger    scoreClearTimeSum[SUDOKUTYPE_MAX][MAX_SCORE_TYPE];
//    NSInteger    scoreRankLevel[SUDOKUTYPE_MAX][MAX_SCORE_TYPE];            // normal sudoku는 auto ranking도 저장
//    NSInteger   scoreTotal;                                                 // 총점
//    NSInteger   scoreRankTotal;                                             // 총점 랭킹
//    NSUInteger  spendTotalSec;                                              // 지금까지 총 게임 시간(초)
//} SUDOKUSCORE;


//{
//    "magicNumber":847362883,
//    "userId":203437,
//    "userName":"Raymond Jeon",
//    "totalScore":11111,
//    "totalSec":4444,
//    "games":[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
//    "clears":[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
//    "bestTime":[9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9],
//    "clearTimeSum":[33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33]
//}

#if 0
/// TestFlight일 때만 설정 네비게이션 왼쪽에 Crash 버튼을 붙인다.
///
/// 매개변수: 없음
/// 반환값: 없음
- (void)installTestFlightCrashButton
{
    if (!IsTestFlightInstall()) {
        return;
    }
    UIBarButtonItem *crashItem = [[UIBarButtonItem alloc] initWithTitle:@"Crash"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(crashForCrashlytics)];
    naviItem.leftBarButtonItem = crashItem;
    [crashItem release];
}

/// 확인을 받은 뒤 Crashlytics 테스트 크래시를 낸다.
///
/// 매개변수: 없음
/// 반환값: 없음
- (void)crashForCrashlytics
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Crashlytics"
                                message:@"테스트용으로 앱을 바로 종료합니다. TestFlight에서 다시 실행하면 Firebase 콘솔에 리포트가 보입니다."
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:gettext(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *crashAction = [UIAlertAction actionWithTitle:@"Crash"
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction *action) {
        if ([FIRApp defaultApp] == nil) {
            [FIRApp configure];
        }
        [[FIRCrashlytics crashlytics] log:@"TF settings crash button"];
        abort();
    }];
    [alert addAction:cancelAction];
    [alert addAction:crashAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#endif

- (void) alertMessageButton:(NSString*)title msg:(NSString*) msg button:(NSString*)button
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:button
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) alertMessageOk:(NSString*)title msg:(NSString*) msg
{
    [self alertMessageButton:title msg:msg button:gettext(@"Ok", nil)];
}


- (IBAction)goReview
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:gettext(@"Recommendation", nil)
                                  message:gettext(@"Please enter your cheering message with 5 stars. We will make more interesting game with your comments.", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:gettext(@"Yes", nil)
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [Appirater rateApp];
                              [mainViewController DoneQuest:eQuestAppReview];
                              
                          }];
    
    [alert addAction:yes];
    UIAlertAction* cancel = [UIAlertAction
                        actionWithTitle:gettext(@"Cancel", nil)
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action)
                        {
                            
                        }];
    
    [alert addAction:cancel];
    
    
    [self presentViewController:alert animated:YES completion:nil];
#ifdef USE_FLURRY
    [Flurry logEvent:@"goAppReview"];
#endif
    
}

#ifdef ADMOB_FREEVERSION

#pragma mark - SKPaymentTransactionObserver Protocol

- (void)successBuyNoAd
{
    [[AppDelegate sharedAppDelegate] saveNoAdSetting];
    mainViewController.bNoAd = YES;
    [mainViewController removeAd];
    [self setNoAdButton];
    
    // 성공 메시지
    [self alertMessageOk:gettext(@"Information", nil) msg:gettext(@"All of advertisements will be removed", nil)];
}

- (void)successResotreNoAd
{
    [[AppDelegate sharedAppDelegate] saveNoAdSetting];
    mainViewController.bNoAd = YES;
    [mainViewController removeAd];
    [self setNoAdButton];
    
    // 성공 메시지
    [self alertMessageOk:gettext(@"Information", nil) msg:gettext(@"Restored No Advertisements item", nil)];
}

- (void)failedBuyNoAd:(NSString*)message;
{
    NSString *msg = [NSString stringWithFormat:@"%@\n%@", gettext(@"Failed to buy No Advertisement item", nil), message];
    
    // 실패 메시지
    // 성공 메시지
    [self alertMessageOk:gettext(@"Information", nil) msg:msg];
}

- (void)failedRestoreNoAd:(NSString*)message;
{
    NSString *msg = [NSString stringWithFormat:@"%@\n%@", gettext(@"Failed to restore No Advertisement item", nil), message];
    
    // 실패 메시지
    // 성공 메시지
    [self alertMessageOk:gettext(@"Information", nil) msg:msg];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        NSLog(@"transaction.transactionState=%d", (int)transaction.transactionState);
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                // 구매 처리
                [self successBuyNoAd];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Error:%d:%@", (int)[transaction.error code], transaction.error.localizedDescription);
                [self failedTransaction:transaction];
                // 실패 처리
                [self failedBuyNoAd:transaction.error.localizedDescription];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"SKPaymentTransactionStateRestored");
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"SKPaymentTransactionStateFailed");
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"SKPaymentTransactionStatePurchased");
    
    NSLog(@"Trasaction Identifier : %@", transaction.transactionIdentifier);
    NSLog(@"Trasaction Date : %@", transaction.transactionDate);
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"SKProductRequest got response");
    if( [response.products count] > 0 ) {
        SKProduct *product = [response.products objectAtIndex:0];
        NSLog(@"Title : %@", product.localizedTitle);
        NSLog(@"Description : %@", product.localizedDescription);
        NSLog(@"Price : %@", product.price);
        
        productNoAd = product;
        [productNoAd retain];
    }
    
    if( [response.invalidProductIdentifiers count] > 0 ) {
        NSString *invalidString = [response.invalidProductIdentifiers objectAtIndex:0];
        NSLog(@"Invalid Identifiers : %@", invalidString);
    }
}


- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions ");
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error ");
    [self failedRestoreNoAd:error.localizedDescription];
}
// Then this is called
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"%@",queue );
    NSLog(@"Restored Transactions are once again in Queue for purchasing %@",[queue transactions]);
    
    //NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    NSLog(@"received restored transactions: %d", (int)queue.transactions.count);
    
    //결재 기록이 없을때 alert 뛰우기
    if(queue.transactions.count==0){
        [self alertMessageOk:@"Failed" msg:gettext(@"There is no record of your purchase.", nil)];
    }
    
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        //[purchasedItemIDs addObject:productID];
        NSLog (@"product id is %@" , productID);
        // here put an if/then statement to write files based on previously purchased items
        // example if ([productID isequaltostring: @"youruniqueproductidentifier]){write files} else { nslog sorry}
        
        if([productID isEqualToString:kNoAdItem])
        {
            //재구입확인dh
            NSLog(@"already buy");
            [self successResotreNoAd];
        }
    }
}







#endif //ADMOB_FREEVERSION



#pragma mark - Alert
/*- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) // "확인" 버튼
    {        
        [Appirater rateApp];
        [mainViewController DoneQuest:eQuestAppReview];
    }
}
*/




// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotate
{
    //return NO;
    return SUPPORT_ROTATION;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return SUPPORT_ROTATION?UIInterfaceOrientationMaskAll:UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return SUPPORT_ROTATION?YES:(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [mainViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [mainViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [mainViewController stopGameTimer];
}




@end



