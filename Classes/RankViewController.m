//
//  RankViewController.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import "Locale.h"
#import "RankViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "Appirater.h"
#ifdef USE_JMC
#import "JMC.h"
#endif


@implementation RankViewController

@synthesize mainViewController;
@synthesize naviItem;
@synthesize lableTitle;
@synthesize buttonDone;
@synthesize webView;
@synthesize activityIndicator;
@synthesize bMyRankCheck;




- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
     bMyRankCheck = NO;
    
    DLog(@"initWithNibName");
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
    }
    return self;
}

- (void) setLocalizedMessage
{
//	NSString* str;
	
    naviItem.title = gettext(@"Ranking", nil);

    [buttonDone setTitle:gettext(@"Done", nil) forState:UIControlStateNormal];
    
    lableTitle.text = gettext(@"Rank", nil);
    
    
}



- (void) viewDidLoad
{
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    MainViewController *ctrl = (MainViewController*)mainViewController;

    //self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    [self setLocalizedMessage];
    [super viewDidLoad];
    webView.navigationDelegate = self;

    
//    activityIndicator.hidden = TRUE;
    
//    http://10.211.55.10:88/dailyranking.php?act=rankingview&userid=158902&size=6&date=20150114&type=0&rankingtype=0&countrycode=US&locale=ko_KR

    NSString* strURI;
    if (bMyRankCheck) {
        strURI = [NSString stringWithFormat:
                  @"act=%@&userid=%ld&size=%d&date=%@&type=%d&level=%d&rankingtype=%d&countrycode=%@&locale=%@",
                  @"rankingview",
                  (long)(ctrl.gUserID),
                  DEFPUZZLESIZE,
                  [ctrl getNowYYYYMMDD],
                  ctrl.mainView.sudokuGame.sudokuType,
                  ctrl.mainView.sudokuGame.gameLevel,
                  0,
                  countryCode,
                  [Locale getFullLocale:gettext(@"locale", nil)]];
    } else {
        strURI = [NSString stringWithFormat:
						@"act=%@&userid=%ld&size=%d&date=%@&countrycode=%@&locale=%@",
                        @"rankingmenu",
                        (long)(ctrl.gUserID),
                        DEFPUZZLESIZE,
                        [ctrl getNowYYYYMMDD],
                        countryCode,
                        [Locale getFullLocale:gettext(@"locale", nil)]];
    }
    DLog(@"strURI* = \n%@", strURI);
    
    
    
    NSString *strURL = [NSString stringWithFormat: @"http://%@/%@?%@",
						ctrl.gServerIP,
						cServerRankingScript,
						strURI];
    DLog(@"strURL* = \n%@", strURL);
    
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
    
    [webView loadRequest:request];
//    webView.load(request);

    // above ios5 && Paid
    if (SUPPORT_ROTATION)
        [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.3];
    DLog(@"[UIApplication sharedApplication].statusBarOrientation=%d", (int)[UIApplication sharedApplication].statusBarOrientation);

}




- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}







- (IBAction)done
{
    [mainViewController startGameTimer];

    
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        [mainViewController dismissModalViewControllerAnimated:YES];
    } else
    {
        DLog(@"Done [UIDevice currentDevice].orientation=%ld", (long)[UIDevice currentDevice].orientation);
        //[mainViewController willRotateToInterfaceOrientation:[UIDevice currentDevice].orientation duration:0.3];
        //[mainViewController didRotateFromInterfaceOrientation:[UIDevice currentDevice].orientation];
        
        [mainViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (bMyRankCheck)
        [mainViewController DoneQuest:eQuestCheckRanking];
    else
        [mainViewController DoneQuest:eQuestVisitRanking];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotate
{
    return SUPPORT_ROTATION;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return SUPPORT_ROTATION?UIInterfaceOrientationMaskAll:UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return SUPPORT_ROTATION?YES:(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [mainViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [mainViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [mainViewController stopGameTimer];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    [activityIndicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [activityIndicator stopAnimating];
    activityIndicator.hidden = TRUE;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [activityIndicator stopAnimating];
}


//- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
//
//    DLog(@"%@", navigation);
//}
//
//- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
//
//    DLog(@"%@", navigation);
//}
//
//- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
//
//    DLog(@"%@", navigation);
//}
//
//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//
//    DLog(@"%@", navigation);
//}
//
//- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
//
//    DLog(@"%@", navigation);
//}
//
//- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
//  
//    DLog(@"%@", navigation);
//}
//
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
// 
//    DLog(@"%@", navigationAction);
//    decisionHandler(WKNavigationActionPolicyAllow);
//}
//
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
// 
//    DLog(@"%@", navigationResponse);
//    decisionHandler(WKNavigationResponsePolicyAllow);
//}

@end
