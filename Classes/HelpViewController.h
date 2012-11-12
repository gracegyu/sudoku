//
//  HelpViewController.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//


//@protocol HelpViewControllerDelegate;
#import "MainViewController.h"

@interface HelpViewController : UIViewController {
    MainViewController *mainViewController;
	
	UINavigationItem	*naviItem;
	UILabel *lableTitle;
    
    
    UIButton *buttonDone;
    
    UILabel *labelSudokuType;
    UILabel	*labelRuleTitle;
    UILabel	*labelRuleDesc;
    UILabel	*labelTipTitle;
    UILabel	*labelTipDesc;
	
    UISegmentedControl *segmentType;
    SUDOKUTYPE  sudokuType;

}


@property (nonatomic, retain) UIViewController	*mainViewController;
@property (nonatomic, retain) IBOutlet UINavigationItem	*naviItem;
@property (nonatomic, retain) IBOutlet UILabel *lableTitle;

@property (nonatomic, retain) IBOutlet UILabel *labelSudokuType;

@property (nonatomic, retain) IBOutlet UIButton *buttonDone;


@property (nonatomic, retain) IBOutlet UILabel	*labelRuleTitle;
@property (nonatomic, retain) IBOutlet UILabel	*labelRuleDesc;
@property (nonatomic, retain) IBOutlet UILabel	*labelTipTitle;
@property (nonatomic, retain) IBOutlet UILabel	*labelTipDesc;

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentType;




- (IBAction)done;
- (IBAction)setSudokuType;

@end


