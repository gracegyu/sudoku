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


@implementation SettingViewController

@synthesize mainViewController;
@synthesize naviItem;
@synthesize lableTitle;


- (void) viewWillAppear:(BOOL)animated {
	self.navigationController.title = NSLocalizedString(@"Setting", nil);
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];     
	
	naviItem.title = NSLocalizedString(@"Setting", nil);
	
//	labelTitleVeryEasy.text = NSLocalizedString(@"very easy", nil);

	
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
