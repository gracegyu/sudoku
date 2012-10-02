//
//  ScoreViewController.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//


//@protocol ScoreViewControllerDelegate;

@interface ScoreViewController : UIViewController {
    UIViewController *mainViewController;
	
	UINavigationItem	*naviItem;
	UILabel *lableTitle;
	
	UILabel	*labelVeryEasyGames;
	UILabel	*labelVeryEasyClears;
	UILabel	*labelVeryEasyBestTime;
	UILabel	*labelVeryEasyAverage;
	UILabel	*labelEasyGames;
	UILabel	*labelEasyClears;
	UILabel	*labelEasyBestTime;
	UILabel	*labelEasyAverage;
	UILabel	*labelNormalGames;
	UILabel	*labelNormalClears;
	UILabel	*labelNormalBestTime;
	UILabel	*labelNormalAverage;
	UILabel	*labelHardGames;
	UILabel	*labelHardClears;
	UILabel	*labelHardBestTime;
	UILabel	*labelHardAverage;
	UILabel	*labelVeryHardGames;
	UILabel	*labelVeryHardClears;
	UILabel	*labelVeryHardBestTime;
	UILabel	*labelVeryHardAverage;	
	UILabel	*labelTotalGames;
	UILabel	*labelTotalClears;
    UILabel *labelTotalScore;
	
	
	UILabel *labelTitleVeryEasy;
	UILabel *labelTitleEasy;
	UILabel *labelTitleNormal;
	UILabel *labelTitleHard;
	UILabel *labelTitleVeryHard;
	UILabel *labelTitleTotal;
	UILabel *labelTitleTotalScore;
	UILabel *labelTitleGames;
	UILabel *labelTitleClears;
	UILabel *labelTitleBestTime;
	UILabel *labelTitleAverage;
}


@property (nonatomic, retain) UIViewController	*mainViewController;
@property (nonatomic, retain) IBOutlet UINavigationItem	*naviItem;
@property (nonatomic, retain) IBOutlet UILabel *lableTitle;

@property (nonatomic, retain) IBOutlet UILabel	*labelVeryEasyGames;
@property (nonatomic, retain) IBOutlet UILabel	*labelVeryEasyClears;
@property (nonatomic, retain) IBOutlet UILabel	*labelVeryEasyBestTime;
@property (nonatomic, retain) IBOutlet UILabel	*labelVeryEasyAverage;
@property (nonatomic, retain) IBOutlet UILabel	*labelEasyGames;
@property (nonatomic, retain) IBOutlet UILabel	*labelEasyClears;
@property (nonatomic, retain) IBOutlet UILabel	*labelEasyBestTime;
@property (nonatomic, retain) IBOutlet UILabel	*labelEasyAverage;
@property (nonatomic, retain) IBOutlet UILabel	*labelNormalGames;
@property (nonatomic, retain) IBOutlet UILabel	*labelNormalClears;
@property (nonatomic, retain) IBOutlet UILabel	*labelNormalBestTime;
@property (nonatomic, retain) IBOutlet UILabel	*labelNormalAverage;
@property (nonatomic, retain) IBOutlet UILabel	*labelHardGames;
@property (nonatomic, retain) IBOutlet UILabel	*labelHardClears;
@property (nonatomic, retain) IBOutlet UILabel	*labelHardBestTime;
@property (nonatomic, retain) IBOutlet UILabel	*labelHardAverage;
@property (nonatomic, retain) IBOutlet UILabel	*labelVeryHardGames;
@property (nonatomic, retain) IBOutlet UILabel	*labelVeryHardClears;
@property (nonatomic, retain) IBOutlet UILabel	*labelVeryHardBestTime;
@property (nonatomic, retain) IBOutlet UILabel	*labelVeryHardAverage;
@property (nonatomic, retain) IBOutlet UILabel	*labelTotalGames;
@property (nonatomic, retain) IBOutlet UILabel	*labelTotalClears;
@property (nonatomic, retain) IBOutlet UILabel	*labelTotalScore;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleVeryEasy;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleEasy;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleNormal;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleHard;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleVeryHard;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleTotal;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleTotalScore;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleGames;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleClears;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleBestTime;
@property (nonatomic, retain) IBOutlet UILabel *labelTitleAverage;

- (IBAction)done;

@end


