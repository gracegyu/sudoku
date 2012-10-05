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


#ifdef SUDOKU9
    #ifdef ADMOB_FREEVERSION
    #define JMC_PRJKEY  @"SDSDKNINEF"
    #define JMC_APIKEY  @"0d51a400-def2-4d60-b866-31d16d4af924"
    #else
    #define JMC_PRJKEY  @"SDSDKNINEP"
    #define JMC_APIKEY  @"0c18415e-2e1c-47a3-a61b-cd5cf322703b"
    #endif
#else // DUDOKU6
    #ifdef ADMOB_FREEVERSION
    #define JMC_PRJKEY  @"SDSDKSIXF"
    #define JMC_APIKEY  @"e1a7b32b-2a9d-4cf4-818e-efdd886034b9"
    #else
    #define JMC_PRJKEY  @"SDSDKSIXP"
    #define JMC_APIKEY  @"e914b167-d0f2-4501-be8a-fdbb9d7e30ba"
    #endif
#endif


- (void)applicationDidFinishLaunching:(UIApplication *)application
{

    [[JMC sharedInstance] configureJiraConnect:@"https://gracegyu.atlassian.net"
                                    projectKey:JMC_PRJKEY
                                        apiKey:JMC_APIKEY
                                      location:YES
                                    dataSource:mainViewController];
    
    
    
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
	NSLog(@"applicationWillResignActive");
	if (mainViewController.mainView.sudokuGame)
		[mainViewController.mainView.sudokuGame saveData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"applicationDidBecomeActive");
}


-(void)applicationWillEnterForeground:(UIApplication*)application
{
    [Appirater appEnteredForeground:YES];
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
