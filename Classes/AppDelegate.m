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

#ifdef GTSUDOKU

#ifdef SUDOKU9
    #ifdef ADMOB_FREEVERSION
    #define JMC_PRJKEY  @"SDGTSNINEF"
    #define JMC_APIKEY  @"7e35de83-0ce1-4f69-b30b-ca4c08269299"
    #else
    #define JMC_PRJKEY  @"SDGTSNINEP"
	#define JMC_APIKEY  @"9176b134-1289-4782-adba-5f6be380f7b9"
    #endif
#else // DUDOKU6
    #ifdef ADMOB_FREEVERSION
    #define JMC_PRJKEY  @"SDGTSSIXF"
    #define JMC_APIKEY  @"f40f6440-259a-4c81-a878-569453fe7fe4"
    #else
    #define JMC_PRJKEY  @"SDGTSSIXP"
	#define JMC_APIKEY  @"d69a926b-d57e-4f6a-9904-464877c17ec2"
    #endif
#endif

#elif (defined KILLERSUDOKU)

#ifdef SUDOKU9
#ifdef ADMOB_FREEVERSION
#define JMC_PRJKEY  @"SDKSNINEF"
#define JMC_APIKEY  @"b7adf06f-0474-4e44-a4e2-455022b6f73b"
#else
#define JMC_PRJKEY  @"SDKSNINEP"
#define JMC_APIKEY  @"5f92294a-2d26-4dec-b342-b9710a2f1e99"
#endif
#else // DUDOKU6
#ifdef ADMOB_FREEVERSION
#define JMC_PRJKEY  @"SDKSSIXF"
#define JMC_APIKEY  @"73c6ac34-1f53-4fc3-b6b5-c39f9e2e088c"
#else
#define JMC_PRJKEY  @"SDKSSIXP"
#define JMC_APIKEY  @"87dab42e-13c6-4cc7-b16d-5d107b8b4fbb"
#endif
#endif

#elif (defined KILLERSUDOKU) && (!defined CALCUDOKU) // KILLERSUDOKU

#ifdef SUDOKU9
#ifdef ADMOB_FREEVERSION
#define JMC_PRJKEY  @"SDSDKNINEF"
#define JMC_APIKEY  @"0d51a400-def2-4d60-b866-31d16d4af924"
#else
#define JMC_PRJKEY  @"SDSDKNINEP"
#define JMC_APIKEY  @"0c18415e-2e1c-47a3-a61b-cd5cf322703b"
#endif
#else // SUDOKU6
#ifdef ADMOB_FREEVERSION
#define JMC_PRJKEY  @"SDSDKSIXF"
#define JMC_APIKEY  @"e1a7b32b-2a9d-4cf4-818e-efdd886034b9"
#else
#define JMC_PRJKEY  @"SDSDKSIXP"
#define JMC_APIKEY  @"e914b167-d0f2-4501-be8a-fdbb9d7e30ba"
#endif
#endif

#elif (defined CALCUDOKU)

#ifdef SUDOKU9
#ifdef ADMOB_FREEVERSION
#define JMC_PRJKEY  @"SDCDNINEF"
#define JMC_APIKEY  @"43a37625-743e-448f-a42e-767bebf6b412"
#else
#define JMC_PRJKEY  @"SDCDNINEP"
#define JMC_APIKEY  @"2f250f70-7954-4b1d-99a1-4f6fe0cf6d49"
#endif
#else // SUDOKU6
#ifdef ADMOB_FREEVERSION
#define JMC_PRJKEY  @"SDCDSIXF"
#define JMC_APIKEY  @"22738ec4-9f37-4bfe-9932-19bc34b3d591"
#else
#define JMC_PRJKEY  @"SDCDSIXP"
#define JMC_APIKEY  @"8d7f1b27-be8b-4125-83b2-0dc8678c2acf"
#endif
#endif

#else   // etc.

#define JMC_PRJKEY  @"SDALL"
#define JMC_APIKEY  @"bfa9e7a3-208c-4200-add4-55a5d8970e5e"

#endif // GTSUDOKU


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
