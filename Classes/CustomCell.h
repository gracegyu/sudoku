#import <UIKit/UIKit.h>

@class Quest;
@interface CustomCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *questImage;
@property (retain, nonatomic) IBOutlet UILabel *questName;
@property (retain, nonatomic) IBOutlet UILabel *questPoint;

- (void) setQuest:(Quest *)quest;
@end
