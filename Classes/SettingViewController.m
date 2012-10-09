//
//  SettingViewController.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import "Locale.h"
#import "SettingViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "Appirater.h"
#import "JMC.h"



@implementation SettingViewController

@synthesize mainViewController;
@synthesize naviItem;
@synthesize lableTitle;
@synthesize labelSoundEffect;
@synthesize labelGuildeline;
@synthesize labelDuplicationWarning;
@synthesize labelMarkingEqual;
@synthesize labelShapeOfMap;
@synthesize labelLocale;

@synthesize buttonDone;
@synthesize buttonSoundEffect;
@synthesize buttonGuildeline;
@synthesize buttonDuplicationWarning;
@synthesize buttonMarkingEqual;
@synthesize buttonShapeOfMap;
@synthesize buttonLocale;

@synthesize buttonFacebook;
@synthesize buttonBugReport;
@synthesize buttonReview;
@synthesize buttonNewApp;

@synthesize labelRuleTitle;
@synthesize labelRuleDesc;
@synthesize labelTipTitle;
@synthesize labelTipDesc;






- (void) viewWillAppear:(BOOL)animated {
	self.navigationController.title = gettext(@"Setting", nil);
}

- (void) setLocalizedMessage
{
    naviItem.title = gettext(@"Setting", nil);
	
    [buttonDone setTitle:gettext(@"Done", nil) forState:UIControlStateNormal];

    
    lableTitle.text = gettext(@"Setting", nil);
	labelSoundEffect.text = gettext(@"sound effect", nil);
    labelGuildeline.text = gettext(@"guideline", nil);
    labelDuplicationWarning.text = gettext(@"duplication warning", nil);
    labelMarkingEqual.text = gettext(@"marking equal", nil);
    labelShapeOfMap.text = gettext(@"shape of map", nil);
    labelLocale.text = gettext(@"language", nil);
    
    labelRuleTitle.text = gettext(@"ruletitle", nil);
#ifdef SUDOKU9
    labelRuleDesc.text = gettext(@"ruledesc9", nil);
#else
    labelRuleDesc.text = gettext(@"ruledesc6", nil);
#endif
    labelTipTitle.text = gettext(@"tiptitle", nil);
    labelTipDesc.text = gettext(@"tipdesc", nil);
    
    
}

- (void) setImageSoundEffect
{
    if (mainViewController.mainView.bSettingSoundOff == YES)
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

- (void) setImageShapeOfMap
{
    if (mainViewController.mainView.bSettingDefMap == YES)
        [buttonShapeOfMap setBackgroundImage:[UIImage imageNamed:@"defmap_on"] forState:UIControlStateNormal];
    else
        [buttonShapeOfMap setBackgroundImage:[UIImage imageNamed:@"defmap_off"] forState:UIControlStateNormal];

//    [Locale setLocale:@"ko"];
//    [self setLocalizedMessage];
//    [mainViewController setLocalizedMessage];
    

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

- (void) viewDidLoad
{
/*    buttonDone = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 100.0f, 45.0f, 30.0f)];
    
    [buttonDone setBackgroundImage:[UIImage imageNamed:@"loclae_ja.png"] forState:UIControlStateNormal];
    
    [buttonDone addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchDown];
    buttonDone.titleLabel.text = gettext(@"Done", nil);
    buttonDone.titleLabel.font = [UIFont fontWithName:@"texgyreadventor-regular.otf" size:20.0f];
    buttonDone.titleLabel.textColor = [UIColor whiteColor];
    
    naviItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonDone];
  
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc]
         initWithTitle:gettext(@"Done", nil)
         style:UIBarButtonItemStyleDone
         target:self
         action:@selector(done)];
*/    
    
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
#ifndef SUDOKU6
    labelShapeOfMap.hidden = YES;
    buttonShapeOfMap.hidden = YES;
#endif
#ifdef GTSUDOKU
    labelShapeOfMap.hidden = YES;
    buttonShapeOfMap.hidden = YES;
#endif
    
    [self setLocalizedMessage];

    [self setImageSoundEffect];
    [self setImageGuideline];
    [self setImageDuplicationWarning];
    [self setImageMarkingEqual];
    [self setImageShapeOfMap];
	[self setImageLocale];
    
    [super viewDidLoad];
}




- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}







- (IBAction)done
{
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        [mainViewController dismissModalViewControllerAnimated:YES];
    } else {
        [mainViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


- (IBAction)setSoundEffect
{
    mainViewController.mainView.bSettingSoundOff = !mainViewController.mainView.bSettingSoundOff;
    [self setImageSoundEffect];
    [mainViewController.mainView playSoundClick];
    [mainViewController saveSetting];
}

- (IBAction)setGuideline
{
    mainViewController.mainView.bSettingGuideline = !mainViewController.mainView.bSettingGuideline;
    [self setImageGuideline];
    [mainViewController.mainView playSoundClick];
    [mainViewController saveSetting];
    
    [mainViewController.mainView setNeedsDisplay];
}

- (IBAction)setDuplicationWarning
{    
    mainViewController.mainView.bSettingDuplicationWarning = !mainViewController.mainView.bSettingDuplicationWarning;
    [self setImageDuplicationWarning];
    [mainViewController.mainView playSoundClick];
    [mainViewController saveSetting];
    
    [mainViewController.mainView setNeedsDisplay];
}

- (IBAction)setMarkingEqual
{
    mainViewController.mainView.bSettingMarkingEqual = !mainViewController.mainView.bSettingMarkingEqual;
    [self setImageMarkingEqual];
    [mainViewController.mainView playSoundClick];
    [mainViewController saveSetting];

    [mainViewController.mainView setNeedsDisplay];
}

- (IBAction)setShapeOfMap1
{
    mainViewController.mainView.bSettingDefMap = !mainViewController.mainView.bSettingDefMap;
    
    [self setImageShapeOfMap];
    [mainViewController.mainView playSoundClick];
    [mainViewController saveSetting];
    
    // 게임을 새로 시작할까????
}

- (IBAction)setLocaleChange
{
    NSString* strLocale = gettext(@"locale", nil);
//    NSString* strIcon = nil;
    
    if ([strLocale compare:@"en"] == NSOrderedSame)
        [Locale setLocale:@"ko"];
    else if ([strLocale compare:@"ko"] == NSOrderedSame)
        [Locale setLocale:@"ja"];
    else if ([strLocale compare:@"ja"] == NSOrderedSame)
        [Locale setLocale:@"zh_CN"];
    else if ([strLocale compare:@"zh_CN"] == NSOrderedSame)
        [Locale setLocale:@"zh_TW"];
    else if ([strLocale compare:@"zh_TW"] == NSOrderedSame)
        [Locale setLocale:@"en"];
    else
        return;
    
    [self setLocalizedMessage];
    [mainViewController setLocalizedMessage];
    [self setImageLocale];
}



- (IBAction)goFacebook
{
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:
              @"http://m.facebook.com/pages/smartoneapp/291656217607690?id=291656217607690&_rdr"]];
    

}

- (IBAction)goBugReport
{
    UIViewController *controller = [[JMC sharedInstance] viewController];
    [self presentModalViewController:controller animated:YES];
/*
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:
              @"http://code.google.com/p/gracegyu/issues/entry"]];
*/
}

- (IBAction)goReview
{
    [Appirater rateApp];
}

- (IBAction)goNewApps
{
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:
    @"http://itunes.apple.com/artist/abc-consulting/id353770805"]];

}






// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotate
{
    return NO;
    /*#ifdef ADMOB_FREEVERSION
     if (cDeviceType == DEVICETYPE_IPHONE)
     return NO;
     #endif
     return YES;
     */
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    /*
     #ifdef ADMOB_FREEVERSION
     if (cDeviceType == DEVICETYPE_IPHONE)
     return UIInterfaceOrientationMaskPortrait;
     #endif
     return UIInterfaceOrientationMaskAll;
     */
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    /*
     #ifdef ADMOB_FREEVERSION
     if (cDeviceType == DEVICETYPE_IPHONE)
     return (interfaceOrientation == UIInterfaceOrientationPortrait);
     else
     return YES;
     #else
     return YES;
     #endif
     */
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [mainViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [mainViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
