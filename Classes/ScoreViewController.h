//
//  ScoreViewController.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//


//@protocol ScoreViewControllerDelegate;

#import <GameKit/GameKit.h>
#import "Constants.h"
#import "TPMultiLayoutViewController.h"

@interface ScoreViewController : TPMultiLayoutViewController
<GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
    UIViewController *mainViewController;
	
	UINavigationItem	*naviItem;
	UILabel *lableTitle;
    UIButton *buttonDone;
    UILabel *labelSudokuType;
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
    
    UIButton *buttonGameCenterRanking1;
    UIButton *buttonGameCenterRanking2;
    UIButton *buttonGameCenterRanking3;
    UIButton *buttonGameCenterRanking4;
    UIButton *buttonGameCenterRanking5;
    
    NSInteger nTimer;
    //NSInteger rankTotal;
    //NSInteger rankLevel[10];
    NSInteger score;
    NSTimer *timerScore;
    
    UILabel *labelRankVeryEasy;
	UILabel *labelRankEasy;
	UILabel *labelRankNormal;
	UILabel *labelRankHard;
	UILabel *labelRankVeryHard;

    UILabel *labelRankArray[5];
	
	UISegmentedControl *segmentAuto;
	BOOL		bAuto;
	
    SUDOKUSCORE *pScore;
    UISegmentedControl *segmentType;
    
    SUDOKUTYPE  sudokuType;
    
    UILabel     *labelLicense;

}


@property (nonatomic, retain) UIViewController	*mainViewController;
@property (nonatomic, retain) IBOutlet UINavigationItem	*naviItem;
@property (nonatomic, retain) IBOutlet UILabel *lableTitle;
@property (nonatomic, retain) IBOutlet UIButton *buttonDone;

@property (nonatomic, retain) IBOutlet UILabel	*labelSudokuType;
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
@property (nonatomic, retain) IBOutlet UIButton *buttonGameCenterRanking;

@property (nonatomic, retain) IBOutlet UILabel *labelRankVeryEasy;
@property (nonatomic, retain) IBOutlet UILabel *labelRankEasy;
@property (nonatomic, retain) IBOutlet UILabel *labelRankNormal;
@property (nonatomic, retain) IBOutlet UILabel *labelRankHard;
@property (nonatomic, retain) IBOutlet UILabel *labelRankVeryHard;

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentAuto;
@property (nonatomic, retain) IBOutlet UIButton *buttonGameCenterRanking1;
@property (nonatomic, retain) IBOutlet UIButton *buttonGameCenterRanking2;
@property (nonatomic, retain) IBOutlet UIButton *buttonGameCenterRanking3;
@property (nonatomic, retain) IBOutlet UIButton *buttonGameCenterRanking4;
@property (nonatomic, retain) IBOutlet UIButton *buttonGameCenterRanking5;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentType;
@property (nonatomic, retain) IBOutlet UILabel *labelLicense;

@property BOOL		bAuto;

- (IBAction)done;
- (IBAction)showGameCenterAchievement;

- (IBAction)showGameCenterLeaderboard;
- (IBAction)showGameCenterLeaderboardVeryEasy;
- (IBAction)showGameCenterLeaderboardEasy;
- (IBAction)showGameCenterLeaderboardNormal;
- (IBAction)showGameCenterLeaderboardHard;
- (IBAction)showGameCenterLeaderboardVeryHard;
- (IBAction)setAuto;
- (IBAction)setSudokuType;

- (void) setAutoSegment;

- (void) displayScore;
- (void) setScoreData:(SUDOKUSCORE*)p;


//- (void) setTotalScoreRank;
- (void) showLeaderboard:(NSString*)category; //실제로 점수판을 띄우는 부분 구현 메소드
- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;//점수판이 닫힐때 호출되는 메소드
- (void) showArchboard; //목표달성판을 띄우는 부분 구현 메소드
- (void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;

@end


