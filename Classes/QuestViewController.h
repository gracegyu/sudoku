//
//  QuestViewController.h
//  sudokuall
//
//  Created by Raymond on 2/2/15.
//
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"


@interface QuestViewController : TPMultiLayoutViewController <UITableViewDataSource,UITableViewDelegate> {
    MainViewController *mainViewController;
    UINavigationItem	*naviItem;
    UILabel *lableTitle;
    UIButton *buttonDone;
    UITableView *tableviewObject;
    NSMutableArray *tableData;
    

}

@property (nonatomic, retain) UIViewController	*mainViewController;
@property (nonatomic, retain) NSMutableArray *tableData;
@property (nonatomic, retain) IBOutlet UINavigationItem	*naviItem;
@property (nonatomic, retain) IBOutlet UILabel *lableTitle;
@property (nonatomic, retain) IBOutlet UIButton *buttonDone;
@property (nonatomic, retain) IBOutlet UITableView *tableviewObject;


- (IBAction)done;

@end
