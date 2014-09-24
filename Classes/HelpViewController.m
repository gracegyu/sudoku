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
#ifdef USE_JMC
#import "JMC.h"
#endif


@implementation HelpViewController

@synthesize mainViewController;
@synthesize naviItem;
@synthesize lableTitle;
@synthesize buttonDone;
@synthesize imageHelp;

@synthesize labelRuleTitle;
@synthesize labelRuleDesc;
//@synthesize labelTipTitle;
//@synthesize labelTipDesc;
@synthesize segmentType;
@synthesize labelSudokuType;
@synthesize labelLicense;




- (void) setLocalizedMessage
{
	NSString* str;
	
    naviItem.title = gettext(@"Help", nil);
    labelLicense.text = STR_LICENSE;

    [buttonDone setTitle:gettext(@"Done", nil) forState:UIControlStateNormal];

    
    lableTitle.text = gettext(@"Help", nil);

    if (sudokuType == SUDOKUTYPE_MAX)
    {
        labelRuleTitle.text = gettext(@"tiptitle", nil);
        str = [NSString stringWithString:gettext(@"tipdesc", nil)];
    } else {
        labelRuleTitle.text = [NSString stringWithFormat:@"%@ (%@)",
                               gettext(@"ruletitle", nil),
                               [SudokuGame getSudokuTypeName:sudokuType]];
#ifdef SUDOKU9
        str = [NSString stringWithString:gettext(@"ruledesc9", nil)];
#else
        str = [NSString stringWithString:gettext(@"ruledesc6", nil)];
#endif
    }
    str = [str stringByAppendingString:@"\n"];
    
    switch (sudokuType)
    {
        case SUDOKUTYPE_SUDOKU :
            break;
        case SUDOKUTYPE_GT :
            str = [str stringByAppendingString:gettext(@"ruledescgt", nil)];
            break;
        case SUDOKUTYPE_KILLER :
            str = [str stringByAppendingString:gettext(@"ruledesckiller", nil)];
            break;
        case SUDOKUTYPE_CALCU :
            str = [str stringByAppendingString:gettext(@"ruledesccalcu", nil)];
        case SUDOKUTYPE_MAX : // tip
        default :
            break;
            
    }
	str = [str stringByAppendingString:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"];
	
	labelRuleDesc.text = str;

    if (sudokuType == SUDOKUTYPE_MAX)
    {
        str = @"help_tip";
    } else {
#ifdef SUDOKU9
        str = [NSString stringWithFormat:@"help9_%d_%@", sudokuType+1, cDeviceType == DEVICETYPE_IPAD ? @"ipad" : @"iphone"];
#else
        str = [NSString stringWithFormat:@"help6_%d_%@", sudokuType+1, cDeviceType == DEVICETYPE_IPAD ? @"ipad" : @"iphone"];
#endif
    }
    
    [imageHelp setBackgroundImage:[UIImage imageNamed:str] forState:UIControlStateNormal];

    
    
}



- (void) viewDidLoad
{
    MainViewController *ctrl = (MainViewController*)mainViewController;
	segmentType.selectedSegmentIndex = sudokuType = ctrl.mainView.nSettingSudokuType;
    //self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    [self setLocalizedMessage];
    [super viewDidLoad];

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

- (IBAction)setSudokuType
{
    sudokuType = (SUDOKUTYPE)[segmentType selectedSegmentIndex];
    
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
    [mainViewController stopGameTimer];
}

@end
