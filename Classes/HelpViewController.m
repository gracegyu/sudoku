//
//  HelpViewController.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import "Locale.h"
#import "HelpViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "Appirater.h"
#import "JMC.h"



@implementation HelpViewController

@synthesize mainViewController;
@synthesize naviItem;
@synthesize lableTitle;
@synthesize buttonDone;

@synthesize labelRuleTitle;
@synthesize labelRuleDesc;
@synthesize labelTipTitle;
@synthesize labelTipDesc;
@synthesize segmentType;
@synthesize labelSudokuType;




- (void) setLocalizedMessage
{
	NSString* str;
	
    naviItem.title = gettext(@"Help", nil);
	
    [buttonDone setTitle:gettext(@"Done", nil) forState:UIControlStateNormal];

    
    lableTitle.text = gettext(@"Help", nil);

    
    labelSudokuType.text = [SudokuGame getSudokuTypeName:sudokuType];
    
    labelRuleTitle.text = gettext(@"ruletitle", nil);
#ifdef SUDOKU9
    str = [NSString stringWithString:gettext(@"ruledesc9", nil)];
#else
    str = [NSString stringWithString:gettext(@"ruledesc6", nil)];
#endif
    
    if (sudokuType == SUDOKUTYPE_GT)
    {
        str = [str stringByAppendingString:@"\n"];
        str = [str stringByAppendingString:gettext(@"ruledescgt", nil)];
    }
    else if (sudokuType == SUDOKUTYPE_KILLER)
    {
        str = [str stringByAppendingString:@"\n"];
        str = [str stringByAppendingString:gettext(@"ruledesckiller", nil)];
    }
    else if (sudokuType == SUDOKUTYPE_CALCU)
    {
        str = [str stringByAppendingString:@"\n"];
        str = [str stringByAppendingString:gettext(@"ruledesccalcu", nil)];
    }
	str = [str stringByAppendingString:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"];
	
	labelRuleDesc.text = str;
	
	
    labelTipTitle.text = gettext(@"tiptitle", nil);
	str = [NSString stringWithString:gettext(@"tipdesc", nil)];
	str = [str stringByAppendingString:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"];
    labelTipDesc.text = str;
    
    
}



- (void) viewDidLoad
{
    MainViewController *ctrl = (MainViewController*)mainViewController;
	segmentType.selectedSegmentIndex = sudokuType = ctrl.mainView.nSettingSudokuType;
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    [self setLocalizedMessage];
    [super viewDidLoad];

    
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
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        [mainViewController dismissModalViewControllerAnimated:YES];
    } else {
        DLog(@"Done [UIDevice currentDevice].orientation=%d", [UIDevice currentDevice].orientation);
        //[mainViewController willRotateToInterfaceOrientation:[UIDevice currentDevice].orientation duration:0.3];
        //[mainViewController didRotateFromInterfaceOrientation:[UIDevice currentDevice].orientation];
        
        [mainViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)setSudokuType
{
    sudokuType = [segmentType selectedSegmentIndex];
    
    [self setLocalizedMessage];
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
}

@end
