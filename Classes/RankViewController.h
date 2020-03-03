//
//  RankViewController.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//


//@protocol RankViewControllerDelegate;
#import "MainViewController.h"
#import <WebKit/WebKit.h>


@interface RankViewController : TPMultiLayoutViewController <WKNavigationDelegate> {
    MainViewController *mainViewController;
	
	UINavigationItem	*naviItem;
	UILabel *lableTitle;
    UIButton *buttonDone;
    BOOL bMyRankCheck;
    
    WKWebView *webView;
    UIActivityIndicatorView *activityIndicator;
}


@property (nonatomic, retain) UIViewController	*mainViewController;
@property (nonatomic, retain) IBOutlet UINavigationItem	*naviItem;
@property (nonatomic, retain) IBOutlet UILabel *lableTitle;
@property (nonatomic, retain) IBOutlet UIButton *buttonDone;
@property (nonatomic, retain) IBOutlet WKWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property BOOL bMyRankCheck;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (IBAction)done;


@end


