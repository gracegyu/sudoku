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
#import "Constants.h"
#import "Appirater.h"
#import "JMC.h"

@implementation AppDelegate


@synthesize window;
@synthesize mainViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{

    [[JMC sharedInstance] configureJiraConnect:@"https://gracegyu.atlassian.net"
                                    projectKey:JMC_PRJKEY
                                        apiKey:JMC_APIKEY
                                      location:YES
                                    dataSource:mainViewController];
    
    
	NSString *strNib = [NSString stringWithString:
#ifdef ADMOB_FREEVERSION
	cDeviceType == DEVICETYPE_IPAD ? @"MainView4iPadFree" :
						(isIphone5 ? @"MainView4iPhone5" : @"MainViewFree")];
#else
	cDeviceType == DEVICETYPE_IPAD ? @"MainView4iPad" :
					    (isIphone5 ? @"MainView4iPhone5" : @"MainView") ];
#endif
	
    DLog(@"Nibname = %@", strNib);
	self.mainViewController = [[MainViewController alloc] initWithNibName:strNib	bundle:nil];
	// xxx for autorotate
    [window setRootViewController:self.mainViewController];


	DLog(@"model=%@(%d)", [UIDevice currentDevice].model, cDeviceType);
	
	
	
    mainViewController.mainView.frame = [UIScreen mainScreen].applicationFrame;
//    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	DLog(@"mainViewController.view.frame size = %f,%f", mainViewController.mainView.frame.size.width, mainViewController.mainView.frame.size.height);
	[window addSubview:[mainViewController mainView]];
//	[window addSubview:[mainViewController view]];
	DLog(@"window.screen = %@", window.screen);
	DLog(@"window.frame = %f,%f", window.frame.size.width, window.frame.size.height);

    [window makeKeyAndVisible];
    
    [Appirater setAppId:APP_ID];
    [Appirater setDaysUntilPrompt:30];   // 30              최소 사용한지 30일이 지나야 한다.
    [Appirater setUsesUntilPrompt:20];   // 20              최소 20번은 실행해야 한다.
    [Appirater setSignificantEventsUntilPrompt:-1]; // -1
    [Appirater setTimeBeforeReminding:7];   // 7            remind me를 선택하면 7일 후에 remind한다.
    
/*    [Appirater setDaysUntilPrompt:0];   // 30
    [Appirater setUsesUntilPrompt:3];   // 20
    [Appirater setSignificantEventsUntilPrompt:-1]; // -1
    [Appirater setTimeBeforeReminding:0];   // 7
*/
    //[Appirater setDebug:YES];
    
    [Appirater appLaunched:YES];
}

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
	DLog(@"applicationWillResignActive");
	if (mainViewController.mainView.sudokuGame)
	{
		[mainViewController.mainView.sudokuGame saveData];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		[defaults synchronize];
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	DLog(@"applicationDidBecomeActive");
}


-(void)applicationWillEnterForeground:(UIApplication*)application
{
    [Appirater appEnteredForeground:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	if (mainViewController.mainView.sudokuGame)
	{
		[mainViewController.mainView.sudokuGame saveData];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		[defaults synchronize];
	}
}

- (NSUInteger)supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    DLog(@"supportedInterfaceOrientationsForWindow");
    return UIInterfaceOrientationMaskAll;
}

- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
