//
//  QuestViewController.m
//  sudokuall
//
//  Created by Raymond on 2/2/15.
//
//

#import "Locale.h"
#import "QuestViewController.h"
#import "CustomCell.h"
#import "Quest.h"
#define CELL_ID @"CELL_ID"

@interface QuestViewController ()

@end

@implementation QuestViewController

@synthesize mainViewController;
@synthesize naviItem;
@synthesize lableTitle;
@synthesize buttonDone;
@synthesize tableData,tableviewObject;




- (void) setLocalizedMessage
{
    naviItem.title = gettext(@"Quest", nil);
    [buttonDone setTitle:gettext(@"Done", nil) forState:UIControlStateNormal];
    lableTitle.text = gettext(@"Quest", nil);
}

- (void)viewDidLoad {
    
    [self setLocalizedMessage];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    tableData = [[NSMutableArray alloc]initWithCapacity:5];
    [tableData addObject:[Quest quest:@"iPad" point:10 imageName:@"type_0_36b"]];
    [tableData addObject:[Quest quest:@"iMac" point:20 imageName:@"type_1_36b.png"]];
    [tableData addObject:[Quest quest:@"iPhone" point:30 imageName:@"type_2_36b.png"]];
    [tableData addObject:[Quest quest:@"MacBook" point:40 imageName:@"type_3_36b.png"]];
    [tableData addObject:[Quest quest:@"iPod Touch" point:50 imageName:@"type_0_36b.png"]];
    
    
    if (SUPPORT_ROTATION)
        [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.3];
    DLog(@"[UIApplication sharedApplication].statusBarOrientation=%ld", (long)[UIApplication sharedApplication].statusBarOrientation);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)done
{    
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
}


#pragma - markup TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    
    return [tableData count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    CustomCell *cell = (CustomCell *) [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    
    if (cell == nil) {
        
        //cell = [[QuestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"CustomCell" owner:nil options:nil];
        cell = [array objectAtIndex:0];
        
    }
    

    
    [cell setQuest:[tableData objectAtIndex:indexPath.row]];
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Selected Value is %@",[tableData objectAtIndex:indexPath.row]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //
    //[alertView show];
    
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


@end
