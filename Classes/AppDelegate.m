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
#ifdef USE_JMC
#import "JMC.h"
#endif
#import "Flurry.h"
#import "Locale.h"
//#import <FacebookSDK/FacebookSDK.h>

@implementation AppDelegate


@synthesize window;
@synthesize mainViewController;
#ifdef ADMOB_FREEVERSION
@synthesize bNoAd;              // 광고 제거 아이템 구매
@synthesize bNoAdRestarted;     // 광고 제거된 xib으로 load됨
#endif

/*
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    } else {
        // handling statusBar (iOS7)
        application.statusBarStyle = UIStatusBarStyleLightContent;
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        self.window.clipsToBounds = YES;
        
        
        // handling screen rotations for statusBar (iOS7)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return YES;
}

- (void)applicationDidChangeStatusBarOrientationNotification:(NSNotification *)notification {
    // handling statusBar (iOS7)
    self.window.frame = [UIScreen mainScreen].applicationFrame;
}
*/


#define kNoAdPurchase           @"kNoAdPurchase"
#ifdef ADMOB_FREEVERSION
- (void) loadSetting
{
    DLog(@"loadSetting");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    bNoAd = [defaults boolForKey:kNoAdPurchase];
}

- (void) saveSetting
{
    DLog(@"saveSetting");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:bNoAd forKey:kNoAdPurchase];
    
    [defaults synchronize];
}

- (void) saveNoAdSetting
{
    bNoAd = YES;
    [self saveSetting];
}
#endif

- (BOOL) supportRotate
{
#ifdef ADMOB_FREEVERSION
    if (cDeviceType == DEVICETYPE_IPHONE) {
        if (bNoAdRestarted)
            return YES;
        else
            return NO;
    } else {
        return YES;
    }
#else
    return YES;
#endif
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString* strLocale = gettext(@"locale", nil);
    NSString *str = [NSString stringWithFormat:@"Locale(%@)", strLocale];
    
    [Flurry startSession:FLURRY_KEY];
    [Flurry setAppVersion:majorVersion];
    [Flurry logEvent:str];

#ifdef USE_JMC
    [[JMC sharedInstance] configureJiraConnect:@"https://gracegyu.atlassian.net"
                                    projectKey:JMC_PRJKEY
                                        apiKey:JMC_APIKEY
                                      location:YES
                                    dataSource:mainViewController];
#endif
    
#ifdef ADMOB_FREEVERSION
    bNoAd = NO;
    [self loadSetting];
    bNoAdRestarted = bNoAd;
#endif
    
	NSString *strNib = [NSString stringWithString:
#ifdef ADMOB_FREEVERSION
    bNoAd ?
    (cDeviceType == DEVICETYPE_IPAD ? @"MainView4iPad" : (isIphone5or6 ? @"MainView4iPhone5" : @"MainView")) :
	(cDeviceType == DEVICETYPE_IPAD ? @"MainView4iPadFree" : (isIphone5or6 ? @"MainView4iPhone5Free" : @"MainViewFree"))
                        
#else
	cDeviceType == DEVICETYPE_IPAD ? @"MainView4iPad" : (isIphone5or6 ? @"MainView4iPhone5" : @"MainView")
#endif
     ];
	
    DLog(@"Nibname = %@", strNib);
    DLog(@"[UIScreen mainScreen].bounds.size.height = %f", [UIScreen mainScreen].bounds.size.height);
    DLog(@"[[UIScreen mainScreen] scale] = %f", [[UIScreen mainScreen] scale]);
    
	self.mainViewController = [[MainViewController alloc] initWithNibName:strNib	bundle:nil];
	// xxx for autorotate
    [window setRootViewController:self.mainViewController];

    [mainViewController.mainView setViewBackgroundColor];
#ifdef ADMOB_FREEVERSION
    mainViewController.bNoAd = bNoAd;
    mainViewController.bNoAdRestarted = bNoAdRestarted;
#endif


	DLog(@"model=%@(%d)", [UIDevice currentDevice].model, cDeviceType);
	
    mainViewController.mainView.frame = [UIScreen mainScreen].applicationFrame;
	DLog(@"mainViewController.view.frame size = %f,%f", mainViewController.mainView.frame.size.width, mainViewController.mainView.frame.size.height);
	[window addSubview:[mainViewController mainView]];
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
    return ((AppDelegate *) [UIApplication sharedApplication].delegate);
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

- (void)dealloc
{
    [mainViewController release];
    [window release];
    [super dealloc];
}
/*
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    return [FBSession.activeSession handleOpenURL:url];
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    return [FBSession.activeSession handleOpenURL:url];
    
}
*/

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
	DLog(@"applicationDidBecomeActive");
    
    //[FBSession.activeSession handleDidBecomeActive];
}


@end
