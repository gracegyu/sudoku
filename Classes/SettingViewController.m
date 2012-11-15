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
@synthesize viewMain;
//@synthesize naviBar;
@synthesize naviItem;
@synthesize lableTitle;
@synthesize labelSoundEffect;
@synthesize labelGuildeline;
@synthesize labelDuplicationWarning;
@synthesize labelMarkingEqual;
@synthesize labelSkinColor;
@synthesize labelLocale;
@synthesize labelDescSoundEffect;
@synthesize labelDescGuildeline;
@synthesize labelDescDuplicationWarning;
@synthesize labelDescMarkingEqual;
@synthesize labelDescSkinColor;
@synthesize labelDescLocale;

@synthesize buttonDone;
@synthesize buttonSoundEffect;
@synthesize buttonGuildeline;
@synthesize buttonDuplicationWarning;
@synthesize buttonMarkingEqual;
@synthesize buttonSkinColor;
@synthesize buttonLocale;

@synthesize buttonFacebook;
@synthesize buttonBugReport;
@synthesize buttonReview;
@synthesize buttonNewApp;

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





- (void) viewWillAppear:(BOOL)animated {
	DLog(@"viewWillAppear");
	self.navigationController.title = gettext(@"Setting", nil);
}

- (void) setLocalizedMessage
{
	NSString* str;
    naviItem.title = gettext(@"Setting", nil);
	
    [buttonDone setTitle:gettext(@"Done", nil) forState:UIControlStateNormal];

    
    lableTitle.text = gettext(@"Setting", nil);
	labelSoundEffect.text = gettext(@"sound effect", nil);
    labelGuildeline.text = gettext(@"guideline", nil);
    labelDuplicationWarning.text = gettext(@"duplication warning", nil);
    labelMarkingEqual.text = gettext(@"marking equal", nil);
    labelSkinColor.text = gettext(@"skin color", nil);
    labelLocale.text = gettext(@"language", nil);
    
    str = gettext(@"desc sound effect", nil);
	labelDescSoundEffect.text = [str stringByAppendingString:@"\n\n\n"];
    str = gettext(@"desc guideline", nil);
	labelDescGuildeline.text = [str stringByAppendingString:@"\n\n\n"];
	str = gettext(@"desc duplication warning", nil);
    labelDescDuplicationWarning.text = [str stringByAppendingString:@"\n\n\n"];
	str = gettext(@"desc marking equal", nil);
    labelDescMarkingEqual.text = [str stringByAppendingString:@"\n\n\n"];
	str = gettext(@"desc auto memo", nil);
    labelDescSkinColor.text = [str stringByAppendingString:@"\n\n\n"];
	str = gettext(@"desc language", nil);
    labelDescLocale.text = [str stringByAppendingString:@"\n\n\n"];
	
	
    
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
    
    [mainViewController.mainView setSkinColorNum:skin];
    [mainViewController saveSetting];
    
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        [mainViewController dismissModalViewControllerAnimated:YES];
    } else {
        DLog(@"Done [UIDevice currentDevice].orientation=%d", [UIDevice currentDevice].orientation);
        [mainViewController willRotateToInterfaceOrientation:[UIDevice currentDevice].orientation duration:0.3];
        [mainViewController didRotateFromInterfaceOrientation:[UIDevice currentDevice].orientation];
        
        [mainViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


- (IBAction)setSoundEffect
{
    mainViewController.mainView.nSettingSoundOff = (mainViewController.mainView.nSettingSoundOff+1)%3;
    [self setImageSoundEffect];
    [mainViewController.mainView playSoundClick];
    [mainViewController saveSetting];
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
}

- (IBAction)dragChanageSkin:(id)sender
{
    DLog(@"dragChanageSkin:%p", sender);
    
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
        [Locale setLocale:@"en"];
    
    [self setLocalizedMessage];
    [mainViewController setLocalizedMessage];
    [self setImageLocale];
}



- (IBAction)goFacebook
{
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:
              @"http://www.facebook.com/pages/SmartOne/392309084183421"]];
    

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
