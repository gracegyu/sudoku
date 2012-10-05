//
//  SettingViewController.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//


//@protocol SettingViewControllerDelegate;
#import "MainViewController.h"

@interface SettingViewController : UIViewController {
    MainViewController *mainViewController;
	
	UINavigationItem	*naviItem;
	UILabel *lableTitle;
    
    UILabel	*labelSoundEffect;
    UILabel	*labelGuildeline;
    UILabel	*labelDuplicationWarning;
    UILabel	*labelMarkingEqual;
    UILabel	*labelShapeOfMap;
    UILabel	*labelLocale;
    
    UIButton *buttonDone;
    
    UIButton *buttonSoundEffect;
    UIButton *buttonGuildeline;
    UIButton *buttonDuplicationWarning;
    UIButton *buttonMarkingEqual;
    UIButton *buttonShapeOfMap;
    UIButton *buttonLocale;

	
    UIButton *buttonFacebook;
    UIButton *buttonBugReport;
    UIButton *buttonReview;
    UIButton *buttonNewApp;
}


@property (nonatomic, retain) UIViewController	*mainViewController;
@property (nonatomic, retain) IBOutlet UINavigationItem	*naviItem;
@property (nonatomic, retain) IBOutlet UILabel *lableTitle;

@property (nonatomic, retain) IBOutlet UILabel	*labelSoundEffect;
@property (nonatomic, retain) IBOutlet UILabel	*labelGuildeline;
@property (nonatomic, retain) IBOutlet UILabel	*labelDuplicationWarning;
@property (nonatomic, retain) IBOutlet UILabel	*labelMarkingEqual;
@property (nonatomic, retain) IBOutlet UILabel	*labelShapeOfMap;
@property (nonatomic, retain) IBOutlet UILabel	*labelLocale;

@property (nonatomic, retain) IBOutlet UIButton *buttonDone;
@property (nonatomic, retain) IBOutlet UIButton *buttonSoundEffect;
@property (nonatomic, retain) IBOutlet UIButton *buttonGuildeline;
@property (nonatomic, retain) IBOutlet UIButton *buttonDuplicationWarning;
@property (nonatomic, retain) IBOutlet UIButton *buttonMarkingEqual;
@property (nonatomic, retain) IBOutlet UIButton *buttonShapeOfMap;
@property (nonatomic, retain) IBOutlet UIButton *buttonLocale;


@property (nonatomic, retain) IBOutlet UIButton *buttonFacebook;
@property (nonatomic, retain) IBOutlet UIButton *buttonBugReport;
@property (nonatomic, retain) IBOutlet UIButton *buttonReview;
@property (nonatomic, retain) IBOutlet UIButton *buttonNewApp;


- (IBAction)setSoundEffect;
- (IBAction)setGuideline;
- (IBAction)setDuplicationWarning;
- (IBAction)setMarkingEqual;
- (IBAction)setShapeOfMap1;
- (IBAction)setLocaleChange;


- (IBAction)goFacebook;
- (IBAction)goBugReport;
- (IBAction)goReview;
- (IBAction)goNewApps;

- (IBAction)done;

@end


