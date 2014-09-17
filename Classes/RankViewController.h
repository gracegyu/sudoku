//
//  RankViewController.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//


//@protocol RankViewControllerDelegate;
#import "MainViewController.h"

@interface RankViewController : TPMultiLayoutViewController {
    MainViewController *mainViewController;
	
	UINavigationItem	*naviItem;
	UILabel *lableTitle;
    UIButton *buttonDone;
    
    UIWebView *webView;
}


@property (nonatomic, retain) UIViewController	*mainViewController;
@property (nonatomic, retain) IBOutlet UINavigationItem	*naviItem;
@property (nonatomic, retain) IBOutlet UILabel *lableTitle;
@property (nonatomic, retain) IBOutlet UIButton *buttonDone;
@property (nonatomic, retain) IBOutlet UIWebView *webView;




- (IBAction)done;


@end


