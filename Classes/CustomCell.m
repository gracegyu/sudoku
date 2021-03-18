//
//  CustomCell.m
//  CustomCellEx
//
//  Created by 근재 전 on 11. 11. 19..
//  Copyright (c) 2011년 __MyCompanyName__. All rights reserved.
//

#import "Locale.h"
#import "CustomCell.h"
#import "Quest.h"

@implementation CustomCell
@synthesize questImage;
@synthesize questName;
@synthesize questPoint;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setQuest:(Quest *)quest {
    self.questImage.image = [quest questImage];
    self.questName.text = [quest questName];
    self.questPoint.text = [NSString stringWithFormat:gettext(@"%d points", nil), [quest questPoint]];
    
    if (quest.questDone == NO)
        self.questImage.alpha = 0.1f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [questImage release];
    [questName release];
    [questPoint release];
    [super dealloc];
}
- (IBAction)addCart:(id)sender {
}
@end
