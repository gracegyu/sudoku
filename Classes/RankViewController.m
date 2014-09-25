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
 
    webView.delegate = self;
    
    NSString* strURI = [NSString stringWithFormat:
						@"act=%@&userid=%ld&size=%d&date=%@&countrycode=%@&locale=%@",
                        @"rankingmenu",
                        (long)(ctrl.gUserID),
                        DEFPUZZLESIZE,
                        [ctrl getNowYYYYMMDD],
                        countryCode,
                        [Locale getFullLocale:gettext(@"locale", nil)]];
    DLog(@"strURI* = \n%@", strURI);
    
    NSString *strURL = [[NSString alloc] initWithFormat: @"http://%@/%@?%@",
						ctrl.gServerIP,
						cServerRankingScript,
						strURI];
    DLog(@"strURL* = \n%@", strURL);
    
    
    
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];

    // above ios5 && Paid
    if (SUPPORT_ROTATION)
        [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.3];
    DLog(@"[UIApplication sharedApplication].statusBarOrientation=%d", [UIApplication sharedApplication].statusBarOrientation);

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







- (IBAction)done
{
    [mainViewController startGameTimer];

    
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        [mainViewController dismissModalViewControllerAnimated:YES];
    } else
    {
        DLog(@"Done [UIDevice currentDevice].orientation=%ld", [UIDevice currentDevice].orientation);
        //[mainViewController willRotateToInterfaceOrientation:[UIDevice currentDevice].orientation duration:0.3];
        //[mainViewController didRotateFromInterfaceOrientation:[UIDevice currentDevice].orientation];
        
        [mainViewController dismissViewControllerAnimated:YES completion:nil];
    }
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotate
{
    return SUPPORT_ROTATION;
}

- (NSUInteger)supportedInterfaceOrientations
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
    activityIndicator.hidden = TRUE;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityIndicator stopAnimating];
}

@end
