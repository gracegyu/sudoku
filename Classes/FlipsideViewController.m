//
//  FlipsideViewController.m
//  SudokuHelper
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"


@implementation FlipsideViewController

@synthesize delegate;
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
@synthesize labelTitleVeryEasy;
@synthesize labelTitleEasy;
@synthesize labelTitleNormal;
@synthesize labelTitleHard;
@synthesize labelTitleVeryHard;
@synthesize labelTitleTotal;
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
		str = [[NSString alloc] initWithFormat:@"%02d:%02d:%02d",
			   num / (60*60),
			   num / (60),
			   num % (60)];
	else 
		str = [[NSString alloc] initWithFormat:@"%02d:%02d",
			   num / (60),
			   num % (60)];
	
	label.text = str; 
	
	[str release];
	
}

- (void) viewWillAppear:(BOOL)animated {
	self.navigationController.title = NSLocalizedString(@"Score", nil);
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];     
	
	naviItem.title = NSLocalizedString(@"Score", nil);
	
	labelTitleVeryEasy.text = NSLocalizedString(@"very easy", nil);
	labelTitleEasy.text = NSLocalizedString(@"easy", nil);
	labelTitleNormal.text = NSLocalizedString(@"normal", nil);
	labelTitleHard.text = NSLocalizedString(@"hard", nil);
	labelTitleVeryHard.text = NSLocalizedString(@"very hard", nil);
	labelTitleTotal.text = NSLocalizedString(@"total", nil);
	labelTitleGames.text = NSLocalizedString(@"games", nil);
	labelTitleClears.text = NSLocalizedString(@"clears", nil);
	labelTitleBestTime.text = NSLocalizedString(@"best time", nil);
	labelTitleAverage.text = NSLocalizedString(@"average", nil);
	
    [super viewDidLoad];
}


- (IBAction)done {
	[self.delegate flipsideViewControllerDidFinish:self];	
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
#ifdef ADMOB_FREEVERSION
    if (cDeviceType == DEVICETYPE_IPAD)
        return YES;
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);	
#else	
	return YES;
#endif
}

@end
