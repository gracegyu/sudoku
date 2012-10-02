//
//  SettingViewController.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//


//@protocol SettingViewControllerDelegate;

@interface SettingViewController : UIViewController {
    UIViewController *mainViewController;
	
	UINavigationItem	*naviItem;
	UILabel *lableTitle;
	

}


@property (nonatomic, retain) UIViewController	*mainViewController;
@property (nonatomic, retain) IBOutlet UINavigationItem	*naviItem;
@property (nonatomic, retain) IBOutlet UILabel *lableTitle;

- (IBAction)done;

@end


