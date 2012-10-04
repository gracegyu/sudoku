//
//  ScoreViewController.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import "ScoreViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "Locale.h"


@implementation ScoreViewController

@synthesize mainViewController;
@synthesize naviItem;
@synthesize lableTitle;
@synthesize labelVeryEasyGames;
@synthesize labelVeryEasyClears;
@synthesize labelVeryEasyBestTime;
@synthesize labelVeryEasyAverage;
@synthesize labelEasyGames;
@synthesize labelEasyClears;
@synthesize labelEasyBestTime;
@synthesize labelEasyAverage;
@synthesize labelNormalGames;
@synthesize labelNormalClears;
@synthesize labelNormalBestTime;
@synthesize labelNormalAverage;
@synthesize labelHardGames;
@synthesize labelHardClears;
@synthesize labelHardBestTime;
@synthesize labelHardAverage;
@synthesize labelVeryHardGames;
@synthesize labelVeryHardClears;
@synthesize labelVeryHardBestTime;
@synthesize labelVeryHardAverage;
@synthesize labelTotalGames;
@synthesize labelTotalClears;
@synthesize labelTotalScore;
@synthesize labelTitleVeryEasy;
@synthesize labelTitleEasy;
@synthesize labelTitleNormal;
@synthesize labelTitleHard;
@synthesize labelTitleVeryHard;
@synthesize labelTitleTotal;
@synthesize labelTitleTotalScore;
@synthesize labelTitleGames;
@synthesize labelTitleClears;
@synthesize labelTitleBestTime;
@synthesize labelTitleAverage;



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
		str = [[NSString alloc] initWithFormat:@"%d:%02d:%02d",
			   num / (60*60),
			   num / (60) % (60),
			   num % (60)];
	else 
		str = [[NSString alloc] initWithFormat:@"%02d:%02d",
			   num / (60),
			   num % (60)];
	
	label.text = str; 
	
	[str release];
	
}

- (void) viewWillAppear:(BOOL)animated {
	self.navigationController.title = gettext(@"Score", nil);
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];     
	
	naviItem.title = gettext(@"Score", nil);
	
    lableTitle.text = gettext(@"Score", nil);

	labelTitleVeryEasy.text = gettext(@"very easy", nil);
	labelTitleEasy.text = gettext(@"easy", nil);
	labelTitleNormal.text = gettext(@"normal", nil);
	labelTitleHard.text = gettext(@"hard", nil);
	labelTitleVeryHard.text = gettext(@"very hard", nil);
	labelTitleTotal.text = gettext(@"total", nil);
	labelTitleTotalScore.text = gettext(@"point", nil);
	labelTitleGames.text = gettext(@"games", nil);
	labelTitleClears.text = gettext(@"clears", nil);
	labelTitleBestTime.text = gettext(@"best time", nil);
	labelTitleAverage.text = gettext(@"average", nil);
	
    [super viewDidLoad];
}


- (IBAction)done {
    [mainViewController dismissViewControllerAnimated:YES completion:nil];
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
