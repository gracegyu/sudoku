//
//  AppDelegate.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "SudokuGame.h"

@implementation AppDelegate


@synthesize window;
@synthesize mainViewController;




- (void)applicationDidFinishLaunching:(UIApplication *)application
{
//Tall????

//    NSInteger tall = [UIScreen mainScreen].bounds.size.height * [[UIScreen mainScreen] scale];
// 1136
    
	self.mainViewController = [[MainViewController alloc] initWithNibName:
#ifdef ADMOB_FREEVERSION
							    cDeviceType == DEVICETYPE_IPAD ? @"MainView4iPadFree" :
                               (isIphone5 ? @"MainView4iPhone5" : @"MainViewFree")
#else
                               cDeviceType == DEVICETYPE_IPAD ? @"MainView4iPad" :
                               (isIphone5 ? @"MainView4iPhone5" : @"MainView")
#endif
								bundle:nil];
	// xxx for autorotate
    [window setRootViewController:self.mainViewController];


	NSLog(@"model=%@(%d)", [UIDevice currentDevice].model, cDeviceType);
	
	
	
    mainViewController.mainView.frame = [UIScreen mainScreen].applicationFrame;
//    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	NSLog(@"mainViewController.view.frame size = %f,%f", mainViewController.mainView.frame.size.width, mainViewController.mainView.frame.size.height);
	[window addSubview:[mainViewController mainView]];
//	[window addSubview:[mainViewController view]];
	NSLog(@"window.screen = %@", window.screen);
	NSLog(@"window.frame = %f,%f", window.frame.size.width, window.frame.size.height);

    
    
    
    
    [window makeKeyAndVisible];
}

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
	NSLog(@"applicationWillResignActive");
	if (mainViewController.mainView.sudokuGame)
		[mainViewController.mainView.sudokuGame saveData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"applicationDidBecomeActive");
}

- (NSUInteger)supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    NSLog(@"supportedInterfaceOrientationsForWindow");
    return UIInterfaceOrientationMaskAll;
}

- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
