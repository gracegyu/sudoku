//
//  AppDelegate.m
//  SudokuHelper
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "SudokuGame.h"

@implementation AppDelegate


@synthesize window;
@synthesize mainViewController;




- (void)applicationDidFinishLaunching:(UIApplication *)application {
 
	self.mainViewController = [[MainViewController alloc] initWithNibName:
#ifdef IPHONE_FREEVERSION___
								@"MainViewFree"
#else
							    cDeviceType == DEVICETYPE_IPAD ? @"MainView4iPad" : @"MainView" 
#endif
								bundle:nil];
		
//	[aController release];


	NSLog(@"model=%@(%d)", [UIDevice currentDevice].model, cDeviceType);
	
	
	
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	NSLog(@"mainViewController.view.frame size = %f,%f", mainViewController.view.frame.size.width, mainViewController.view.frame.size.height);
	[window addSubview:[mainViewController view]];
	NSLog(@"window.screen = %@", window.screen);
	NSLog(@"window.frame = %f,%f", window.frame.size.width, window.frame.size.height);

    [window makeKeyAndVisible];
}

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"applicationWillResignActive");
	if (mainViewController.mainView.sudokuGame)
		[mainViewController.mainView.sudokuGame saveData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"applicationDidBecomeActive");
}

- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
