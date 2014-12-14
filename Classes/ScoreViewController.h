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
#import "MainViewController.h"

typedef enum {
    SCORETYPE_GAMES = 0,
    SCORETYPE_CLEARS,
    SCORETYPE_AVERAGE,
    SCORETYPE_BESTTIME
} SCORETYPE;

@interface ScoreViewController : TPMultiLayoutViewController
<GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
    MainViewController *mainViewController;
	
	UINavigationItem	*naviItem;
	UILabel *lableTitle;
    UIButton *buttonDone;
    UILabel *labelSudokuType;
	UILabel	*labelVeryEasyGames;
	UILabel	*labelVeryEasyClears;
	UILabel	*labelVeryEasyAverage;
	UILabel	*labelVeryEasyBestTime;
	UILabel	*labelEasyGames;
	UILabel	*labelEasyClears;
	UILabel	*labelEasyAverage;
	UILabel	*labelEasyBestTime;
	UILabel	*labelNormalGames;
	UILabel	*labelNormalClears;
	UILabel	*labelNormalAverage;
	UILabel	*labelNormalBestTime;
	UILabel	*labelHardGames;
	UILabel	*labelHardClears;
	UILabel	*labelHardAverage;
	UILabel	*labelHardBestTime;
	UILabel	*labelVeryHardGames;
	UILabel	*labelVeryHardClears;
	UILabel	*labelVeryHardAverage;
	UILabel	*labelVeryHardBestTime;
	UILabel	*label2VeryEasyGames;
	UILabel	*label2VeryEasyClears;
	UILabel	*label2VeryEasyAverage;
	UILabel	*label2VeryEasyBestTime;
	UILabel	*label2EasyGames;
	UILabel	*label2EasyClears;
	UILabel	*label2EasyAverage;
	UILabel	*label2EasyBestTime;
	UILabel	*label2NormalGames;
	UILabel	*label2NormalClears;
	UILabel	*label2NormalAverage;
	UILabel	*label2NormalBestTime;
	UILabel	*label2HardGames;
	UILabel	*label2HardClears;
	UILabel	*label2HardAverage;
	UILabel	*label2HardBestTime;
	UILabel	*label2VeryHardGames;
	UILabel	*label2VeryHardClears;
	UILabel	*label2VeryHardAverage;
	UILabel	*label2VeryHardBestTime;
	UILabel	*labelTotalGames;
	UILabel	*labelTotalClears;
    UILabel *labelTotalScore;
    UILabel *labelScoresArray[4][10];
	
	
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
    UILabel *label2RankVeryEasy;
	UILabel *label2RankEasy;
	UILabel *label2RankNormal;
	UILabel *label2RankHard;
	UILabel *label2RankVeryHard;

    UILabel *labelRankArray[10];

    UIButton *buttonRankVeryEasy;
	UIButton *buttonRankEasy;
	UIButton *buttonRankNormal;
	UIButton *buttonRankHard;
	UIButton *buttonRankVeryHard;
    UIButton *button2RankVeryEasy;
	UIButton *button2RankEasy;
	UIButton *button2RankNormal;
	UIButton *button2RankHard;
	UIButton *button2RankVeryHard;
    
    UIButton *buttonRankArray[10];

    
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
@property (nonatomic, retain) IBOutlet UILabel	*label2VeryEasyGames;
@property (nonatomic, retain) IBOutlet UILabel	*label2VeryEasyClears;
@property (nonatomic, retain) IBOutlet UILabel	*label2VeryEasyBestTime;
@property (nonatomic, retain) IBOutlet UILabel	*label2VeryEasyAverage;
@property (nonatomic, retain) IBOutlet UILabel	*label2EasyGames;
@property (nonatomic, retain) IBOutlet UILabel	*label2EasyClears;
@property (nonatomic, retain) IBOutlet UILabel	*label2EasyBestTime;
@property (nonatomic, retain) IBOutlet UILabel	*label2EasyAverage;
@property (nonatomic, retain) IBOutlet UILabel	*label2NormalGames;
@property (nonatomic, retain) IBOutlet UILabel	*label2NormalClears;
@property (nonatomic, retain) IBOutlet UILabel	*label2NormalBestTime;
@property (nonatomic, retain) IBOutlet UILabel	*label2NormalAverage;
@property (nonatomic, retain) IBOutlet UILabel	*label2HardGames;
@property (nonatomic, retain) IBOutlet UILabel	*label2HardClears;
@property (nonatomic, retain) IBOutlet UILabel	*label2HardBestTime;
@property (nonatomic, retain) IBOutlet UILabel	*label2HardAverage;
@property (nonatomic, retain) IBOutlet UILabel	*label2VeryHardGames;
@property (nonatomic, retain) IBOutlet UILabel	*label2VeryHardClears;
@property (nonatomic, retain) IBOutlet UILabel	*label2VeryHardBestTime;
@property (nonatomic, retain) IBOutlet UILabel	*label2VeryHardAverage;
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
@property (nonatomic, retain) IBOutlet UILabel *label2RankVeryEasy;
@property (nonatomic, retain) IBOutlet UILabel *label2RankEasy;
@property (nonatomic, retain) IBOutlet UILabel *label2RankNormal;
@property (nonatomic, retain) IBOutlet UILabel *label2RankHard;
@property (nonatomic, retain) IBOutlet UILabel *label2RankVeryHard;

@property (nonatomic, retain) IBOutlet UIButton *buttonRankVeryEasy;
@property (nonatomic, retain) IBOutlet UIButton *buttonRankEasy;
@property (nonatomic, retain) IBOutlet UIButton *buttonRankNormal;
@property (nonatomic, retain) IBOutlet UIButton *buttonRankHard;
@property (nonatomic, retain) IBOutlet UIButton *buttonRankVeryHard;
@property (nonatomic, retain) IBOutlet UIButton *button2RankVeryEasy;
@property (nonatomic, retain) IBOutlet UIButton *button2RankEasy;
@property (nonatomic, retain) IBOutlet UIButton *button2RankNormal;
@property (nonatomic, retain) IBOutlet UIButton *button2RankHard;
@property (nonatomic, retain) IBOutlet UIButton *button2RankVeryHard;

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentAuto;
@property (nonatomic, retain) IBOutlet UIButton *buttonGameCenterRanking1;
@property (nonatomic, retain) IBOutlet UIButton *buttonGameCenterRanking2;
@property (nonatomic, retain) IBOutlet UIButton *buttonGameCenterRanking3;
@property (nonatomic, retain) IBOutlet UIButton *buttonGameCenterRanking4;
@property (nonatomic, retain) IBOutlet UIButton *buttonGameCenterRanking5;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentType;
@property (nonatomic, retain) IBOutlet UIButton *buttonLicense;

@property BOOL		bAuto;

- (IBAction)done;
- (IBAction)showGameCenterAchievement;

- (IBAction)showGameCenterLeaderboard;
- (IBAction)showGameCenterLeaderboardVeryEasy;
- (IBAction)showGameCenterLeaderboardEasy;
- (IBAction)showGameCenterLeaderboardNormal;
- (IBAction)showGameCenterLeaderboardHard;
- (IBAction)showGameCenterLeaderboardVeryHard;
- (IBAction)showGameCenterLeaderboardVeryEasy2;
- (IBAction)showGameCenterLeaderboardEasy2;
- (IBAction)showGameCenterLeaderboardNormal2;
- (IBAction)showGameCenterLeaderboardHard2;
- (IBAction)showGameCenterLeaderboardVeryHard2;
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


