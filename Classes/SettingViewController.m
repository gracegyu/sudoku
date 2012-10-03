//
//  SettingViewController.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import "SettingViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "Appirater.h"


@implementation SettingViewController

@synthesize mainViewController;
@synthesize naviItem;
@synthesize lableTitle;
@synthesize labelSoundEffect;
@synthesize labelGuildeline;
@synthesize labelDuplicationWarning;
@synthesize labelMarkingEqual;
@synthesize labelShapeOfMap;
@synthesize buttonSoundEffect;
@synthesize buttonGuildeline;
@synthesize buttonDuplicationWarning;
@synthesize buttonMarkingEqual;
@synthesize buttonShapeOfMap;

@synthesize buttonFacebook;
@synthesize buttonBugReport;
@synthesize buttonReview;
@synthesize buttonNewApp;








- (void) viewWillAppear:(BOOL)animated {
	self.navigationController.title = NSLocalizedString(@"Setting", nil);
}



- (void) setImageSoundEffect
{
    if (mainViewController.mainView.bSettingSoundOff == YES)
        [buttonSoundEffect setBackgroundImage:[UIImage imageNamed:@"soundeffect_on"] forState:UIControlStateNormal];
    else
        [buttonSoundEffect setBackgroundImage:[UIImage imageNamed:@"soundeffect_off"] forState:UIControlStateNormal];
    [buttonSoundEffect setBackgroundImage:[UIImage imageNamed:@"soundeffect_h"] forState:UIControlStateHighlighted];
}

- (void) setImageGuideline
{
    if (mainViewController.mainView.bSettingGuideline == YES)
        [buttonGuildeline setBackgroundImage:[UIImage imageNamed:@"guideline_on"] forState:UIControlStateNormal];
    else
        [buttonGuildeline setBackgroundImage:[UIImage imageNamed:@"guideline_off"] forState:UIControlStateNormal];
    [buttonGuildeline setBackgroundImage:[UIImage imageNamed:@"guideline_h"] forState:UIControlStateHighlighted];
}

- (void) setImageDuplicationWarning
{
    if (mainViewController.mainView.bSettingDuplicationWarning == YES)
        [buttonDuplicationWarning setBackgroundImage:[UIImage imageNamed:@"dupwan_on"] forState:UIControlStateNormal];
    else
        [buttonDuplicationWarning setBackgroundImage:[UIImage imageNamed:@"dupwan_off"] forState:UIControlStateNormal];
    [buttonDuplicationWarning setBackgroundImage:[UIImage imageNamed:@"dupwan_h"] forState:UIControlStateHighlighted];
}

- (void) setImageMarkingEqual
{
    if (mainViewController.mainView.bSettingMarkingEqual == YES)
        [buttonMarkingEqual setBackgroundImage:[UIImage imageNamed:@"markingequal_on"] forState:UIControlStateNormal];
    else
        [buttonMarkingEqual setBackgroundImage:[UIImage imageNamed:@"markingequal_off"] forState:UIControlStateNormal];
    [buttonMarkingEqual setBackgroundImage:[UIImage imageNamed:@"markingequal_h"] forState:UIControlStateHighlighted];
}

- (void) setImageShapeOfMap
{
    if (mainViewController.mainView.bSettingDefMap == YES)
        [buttonShapeOfMap setBackgroundImage:[UIImage imageNamed:@"defmap_on"] forState:UIControlStateNormal];
    else
        [buttonShapeOfMap setBackgroundImage:[UIImage imageNamed:@"defmap_off"] forState:UIControlStateNormal];


}


- (void) viewDidLoad {
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];     
	
	naviItem.title = NSLocalizedString(@"Setting", nil);
	
    lableTitle.text = NSLocalizedString(@"Setting", nil);
	labelSoundEffect.text = NSLocalizedString(@"sound effect", nil);
    labelGuildeline.text = NSLocalizedString(@"guideline", nil);
    labelDuplicationWarning.text = NSLocalizedString(@"duplication warning", nil);
    labelMarkingEqual.text = NSLocalizedString(@"marking equal", nil);
    labelShapeOfMap.text = NSLocalizedString(@"shape of map", nil);

    [self setImageSoundEffect];
    [self setImageGuideline];
    [self setImageDuplicationWarning];
    [self setImageMarkingEqual];
    [self setImageShapeOfMap];
	
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


- (IBAction)done {
    [mainViewController dismissViewControllerAnimated:YES completion:nil];
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





- (IBAction)goFacebook
{
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:
              @"http://m.facebook.com/pages/smartoneapp/291656217607690?id=291656217607690&_rdr"]];
    

}

- (IBAction)goBugReport
{
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:
              @"http://code.google.com/p/gracegyu/issues/entry"]];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
#ifdef ADMOB_FREEVERSION
    if (cDeviceType == DEVICETYPE_IPHONE)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else
        return YES;	
#else	
	return YES;
#endif
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
