//
//  ScoreViewController.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import "ScoreViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "Locale.h"
#import "GameCenterUtil.h"
#import "Flurry.h"



@implementation ScoreViewController

@synthesize mainViewController;
@synthesize naviItem;
@synthesize lableTitle;
@synthesize buttonDone;
@synthesize labelSudokuType;
@synthesize labelVeryEasyGames;
@synthesize labelVeryEasyClears;
@synthesize labelVeryEasyBestTime;
@synthesize labelVeryEasyAverage;
@synthesize labelEasyGames;
@synthesize labelEasyClears;
@synthesize labelEasyBestTime;
@synthesize labelEasyAverage;
@synthesize labelNormalGames;
@synthesize labelNormalClears;
@synthesize labelNormalBestTime;
@synthesize labelNormalAverage;
@synthesize labelHardGames;
@synthesize labelHardClears;
@synthesize labelHardBestTime;
@synthesize labelHardAverage;
@synthesize labelVeryHardGames;
@synthesize labelVeryHardClears;
@synthesize labelVeryHardBestTime;
@synthesize labelVeryHardAverage;
@synthesize label2VeryEasyGames;
@synthesize label2VeryEasyClears;
@synthesize label2VeryEasyBestTime;
@synthesize label2VeryEasyAverage;
@synthesize label2EasyGames;
@synthesize label2EasyClears;
@synthesize label2EasyBestTime;
@synthesize label2EasyAverage;
@synthesize label2NormalGames;
@synthesize label2NormalClears;
@synthesize label2NormalBestTime;
@synthesize label2NormalAverage;
@synthesize label2HardGames;
@synthesize label2HardClears;
@synthesize label2HardBestTime;
@synthesize label2HardAverage;
@synthesize label2VeryHardGames;
@synthesize label2VeryHardClears;
@synthesize label2VeryHardBestTime;
@synthesize label2VeryHardAverage;
@synthesize labelTotalGames;
@synthesize labelTotalClears;
@synthesize labelTotalScore;
@synthesize labelTitleVeryEasy;
@synthesize labelTitleEasy;
@synthesize labelTitleNormal;
@synthesize labelTitleHard;
@synthesize labelTitleVeryHard;
@synthesize labelTitleTotal;
@synthesize labelTitleTotalScore;
@synthesize labelTitleGames;
@synthesize labelTitleClears;
@synthesize labelTitleBestTime;
@synthesize labelTitleAverage;
@synthesize buttonGameCenterRanking;
@synthesize labelRankVeryEasy;
@synthesize labelRankEasy;
@synthesize labelRankNormal;
@synthesize labelRankHard;
@synthesize labelRankVeryHard;
@synthesize label2RankVeryEasy;
@synthesize label2RankEasy;
@synthesize label2RankNormal;
@synthesize label2RankHard;
@synthesize label2RankVeryHard;

@synthesize buttonRankVeryEasy;
@synthesize buttonRankEasy;
@synthesize buttonRankNormal;
@synthesize buttonRankHard;
@synthesize buttonRankVeryHard;
@synthesize button2RankVeryEasy;
@synthesize button2RankEasy;
@synthesize button2RankNormal;
@synthesize button2RankHard;
@synthesize button2RankVeryHard;

@synthesize segmentAuto;
@synthesize bAuto;
@synthesize buttonGameCenterRanking1;
@synthesize buttonGameCenterRanking2;
@synthesize buttonGameCenterRanking3;
@synthesize buttonGameCenterRanking4;
@synthesize buttonGameCenterRanking5;
@synthesize segmentType;
//@synthesize labelLicense;




- (void) setInteger:(UILabel*)label num:(NSInteger)num
{
	label.text = [NSString stringWithFormat:@"%ld", (long)num];
}

- (void) setInteger2:(UILabel*)label num1:(NSInteger)num1  num2:(NSInteger)num2
{
	label.text = [NSString stringWithFormat:@"%d\n%ld", num1, (long)num2];
}


- (void) setTime:(UILabel*)label num:(NSInteger)num
{
	NSString *str;
	
	if (num >= 60*60*100)
		num = 60*60*100 - 1;
	
	if (num >= 60*60)
		str = [NSString stringWithFormat:@"%ld:%02ld:%02ld",
			   num / (60*60),
			   num / (60) % (60),
			   num % (60)];
	else if (num > 0)
		str = [NSString stringWithFormat:@"%02ld:%02ld",
			   num / (60),
			   num % (60)];
    else
        str = @"-";
	
	label.text = str;
}

- (void) setTime2:(UILabel*)label num1:(NSInteger)num1  num2:(NSInteger)num2
{
	NSString *str, *str2;
	
	if (num1 >= 60*60*100)
		num1 = 60*60*100 - 1;
	
	if (num1 >= 60*60)
		str = [NSString stringWithFormat:@"%ld:%02ld:%02ld",
			   num1 / (60*60),
			   num1 / (60) % (60),
			   num1 % (60)];
	else
		str = [NSString stringWithFormat:@"%02ld:%02ld",
			   num1 / (60),
			   num1 % (60)];

    if (num2 >= 60*60*100)
		num2 = 60*60*100 - 1;
	
	if (num2 >= 60*60)
		str2 = [NSString stringWithFormat:@"%@\n%ld:%02ld:%02ld",
                str,
			   num2 / (60*60),
			   num2 / (60) % (60),
			   num2 % (60)];
	else
		str2 = [NSString stringWithFormat:@"%@\n%02ld:%02ld",
                str,
			   num2 / (60),
			   num2 % (60)];

	label.text = str2;
}



- (void) viewWillAppear:(BOOL)animated {
	self.navigationController.title = gettext(@"Score", nil);
}

- (void) setLocalizedMessage
{
	naviItem.title = gettext(@"Score", nil);
    labelLicense.text = STR_LICENSE;
    
    lableTitle.text = gettext(@"Score", nil);
    [buttonDone setTitle:gettext(@"Done", nil) forState:UIControlStateNormal];
    
	labelTitleVeryEasy.text = gettext(@"very easy", nil);
	labelTitleEasy.text = gettext(@"easy", nil);
	labelTitleNormal.text = gettext(@"normal", nil);
	labelTitleHard.text = gettext(@"hard", nil);
	labelTitleVeryHard.text = gettext(@"very hard", nil);
	labelTitleTotal.text = gettext(@"total", nil);
	labelTitleTotalScore.text = gettext(@"point", nil);
	labelTitleGames.text = gettext(@"games", nil);
	labelTitleClears.text = gettext(@"clears", nil);
	labelTitleBestTime.text = gettext(@"best time", nil);
	labelTitleAverage.text = gettext(@"average", nil);
}

- (void) initScoreArray
{
    labelScoresArray[SCORETYPE_GAMES][GAMELEVEL_VERYHARD] = labelVeryHardGames;
	labelScoresArray[SCORETYPE_CLEARS][GAMELEVEL_VERYHARD] = labelVeryHardClears;
	labelScoresArray[SCORETYPE_AVERAGE][GAMELEVEL_VERYHARD] = labelVeryHardAverage;
	labelScoresArray[SCORETYPE_BESTTIME][GAMELEVEL_VERYHARD] = labelVeryHardBestTime;
	labelScoresArray[SCORETYPE_GAMES][GAMELEVEL_HARD] = labelHardGames;
	labelScoresArray[SCORETYPE_CLEARS][GAMELEVEL_HARD] = labelHardClears;
	labelScoresArray[SCORETYPE_AVERAGE][GAMELEVEL_HARD] = labelHardAverage;
	labelScoresArray[SCORETYPE_BESTTIME][GAMELEVEL_HARD] = labelHardBestTime;
	labelScoresArray[SCORETYPE_GAMES][GAMELEVEL_NORMAL] = labelNormalGames;
	labelScoresArray[SCORETYPE_CLEARS][GAMELEVEL_NORMAL] = labelNormalClears;
	labelScoresArray[SCORETYPE_AVERAGE][GAMELEVEL_NORMAL] = labelNormalAverage;
	labelScoresArray[SCORETYPE_BESTTIME][GAMELEVEL_NORMAL] = labelNormalBestTime;
	labelScoresArray[SCORETYPE_GAMES][GAMELEVEL_EASY] = labelEasyGames;
	labelScoresArray[SCORETYPE_CLEARS][GAMELEVEL_EASY] = labelEasyClears;
	labelScoresArray[SCORETYPE_AVERAGE][GAMELEVEL_EASY] = labelEasyAverage;
	labelScoresArray[SCORETYPE_BESTTIME][GAMELEVEL_EASY] = labelEasyBestTime;
    labelScoresArray[SCORETYPE_GAMES][GAMELEVEL_VERYEASY] = labelVeryEasyGames;
	labelScoresArray[SCORETYPE_CLEARS][GAMELEVEL_VERYEASY] = labelVeryEasyClears;
	labelScoresArray[SCORETYPE_AVERAGE][GAMELEVEL_VERYEASY] = labelVeryEasyAverage;
	labelScoresArray[SCORETYPE_BESTTIME][GAMELEVEL_VERYEASY] = labelVeryEasyBestTime;

    labelScoresArray[SCORETYPE_GAMES][5+GAMELEVEL_VERYHARD] = label2VeryHardGames;
	labelScoresArray[SCORETYPE_CLEARS][5+GAMELEVEL_VERYHARD] = label2VeryHardClears;
	labelScoresArray[SCORETYPE_AVERAGE][5+GAMELEVEL_VERYHARD] = label2VeryHardAverage;
	labelScoresArray[SCORETYPE_BESTTIME][5+GAMELEVEL_VERYHARD] = label2VeryHardBestTime;
	labelScoresArray[SCORETYPE_GAMES][5+GAMELEVEL_HARD] = label2HardGames;
	labelScoresArray[SCORETYPE_CLEARS][5+GAMELEVEL_HARD] = label2HardClears;
	labelScoresArray[SCORETYPE_AVERAGE][5+GAMELEVEL_HARD] = label2HardAverage;
	labelScoresArray[SCORETYPE_BESTTIME][5+GAMELEVEL_HARD] = label2HardBestTime;
	labelScoresArray[SCORETYPE_GAMES][5+GAMELEVEL_NORMAL] = label2NormalGames;
	labelScoresArray[SCORETYPE_CLEARS][5+GAMELEVEL_NORMAL] = label2NormalClears;
	labelScoresArray[SCORETYPE_AVERAGE][5+GAMELEVEL_NORMAL] = label2NormalAverage;
	labelScoresArray[SCORETYPE_BESTTIME][5+GAMELEVEL_NORMAL] = label2NormalBestTime;
	labelScoresArray[SCORETYPE_GAMES][5+GAMELEVEL_EASY] = label2EasyGames;
	labelScoresArray[SCORETYPE_CLEARS][5+GAMELEVEL_EASY] = label2EasyClears;
	labelScoresArray[SCORETYPE_AVERAGE][5+GAMELEVEL_EASY] = label2EasyAverage;
	labelScoresArray[SCORETYPE_BESTTIME][5+GAMELEVEL_EASY] = label2EasyBestTime;
    labelScoresArray[SCORETYPE_GAMES][5+GAMELEVEL_VERYEASY] = label2VeryEasyGames;
	labelScoresArray[SCORETYPE_CLEARS][5+GAMELEVEL_VERYEASY] = label2VeryEasyClears;
	labelScoresArray[SCORETYPE_AVERAGE][5+GAMELEVEL_VERYEASY] = label2VeryEasyAverage;
	labelScoresArray[SCORETYPE_BESTTIME][5+GAMELEVEL_VERYEASY] = label2VeryEasyBestTime;
    
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];     
	
    [self setLocalizedMessage];
    [self initScoreArray];
    
    labelRankArray[GAMELEVEL_VERYHARD] = labelRankVeryHard;
    labelRankArray[GAMELEVEL_HARD] = labelRankHard;
    labelRankArray[GAMELEVEL_NORMAL] = labelRankNormal;
    labelRankArray[GAMELEVEL_EASY] = labelRankEasy;
    labelRankArray[GAMELEVEL_VERYEASY] = labelRankVeryEasy;
    labelRankArray[5+GAMELEVEL_VERYHARD] = label2RankVeryHard;
    labelRankArray[5+GAMELEVEL_HARD] = label2RankHard;
    labelRankArray[5+GAMELEVEL_NORMAL] = label2RankNormal;
    labelRankArray[5+GAMELEVEL_EASY] = label2RankEasy;
    labelRankArray[5+GAMELEVEL_VERYEASY] = label2RankVeryEasy;

    buttonRankArray[GAMELEVEL_VERYHARD] = buttonRankVeryHard;
    buttonRankArray[GAMELEVEL_HARD] = buttonRankHard;
    buttonRankArray[GAMELEVEL_NORMAL] = buttonRankNormal;
    buttonRankArray[GAMELEVEL_EASY] = buttonRankEasy;
    buttonRankArray[GAMELEVEL_VERYEASY] = buttonRankVeryEasy;
    buttonRankArray[5+GAMELEVEL_VERYHARD] = button2RankVeryHard;
    buttonRankArray[5+GAMELEVEL_HARD] = button2RankHard;
    buttonRankArray[5+GAMELEVEL_NORMAL] = button2RankNormal;
    buttonRankArray[5+GAMELEVEL_EASY] = button2RankEasy;
    buttonRankArray[5+GAMELEVEL_VERYEASY] = button2RankVeryEasy;

    
    MainViewController *ctrl = (MainViewController*)mainViewController;
    // Gamecenter와 sync맞추기 -> MainViewController로 이동
/*    for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int level=0; level<NUM_RANK_BESTTIME; level++)
        {
            if (pScore->scoreRankLevel[type][level] > 0)
                [GameCenterUtil sendBestTimeToGameCenter:type level:level besttime:pScore->scoreRankLevel[type][level]];
        }
    }
    // 총점 보내기
    [GameCenterUtil sendScoreToGameCenter:[ctrl getTotalScore]];
*/	
	segmentType.selectedSegmentIndex = sudokuType = ctrl.mainView.nSettingSudokuType;
    [self displayScore];
	
    [super viewDidLoad];
    
    // above ios5 && Paid
    if (SUPPORT_ROTATION)
        [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.3];
    DLog(@"[UIApplication sharedApplication].statusBarOrientation=%d", [UIApplication sharedApplication].statusBarOrientation);
}


- (IBAction)done
{
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        [mainViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        DLog(@"Done [UIDevice currentDevice].orientation=%d", [UIDevice currentDevice].orientation);
        //[mainViewController willRotateToInterfaceOrientation:[UIDevice currentDevice].orientation duration:0.3];
        //[mainViewController didRotateFromInterfaceOrientation:[UIDevice currentDevice].orientation];
        [mainViewController dismissViewControllerAnimated:YES completion:nil];
        
        
    }
}

- (IBAction)showGameCenterLeaderboard
{
    [self showLeaderboard:[GameCenterUtil getPointCategory]]; // 실행~
    [Flurry logEvent:@"ShowLeaderboard"];
}

- (IBAction)showGameCenterLeaderboardVeryEasy
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_VERYEASY]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardEasy
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_EASY]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardNormal
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_NORMAL]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardHard
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_HARD]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardVeryHard
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_VERYHARD]]; // 실행~
}

- (IBAction)showGameCenterLeaderboardVeryEasy2
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_VERYEASY + 5]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardEasy2
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_EASY + 5]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardNormal2
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_NORMAL + 5]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardHard2
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_HARD + 5]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardVeryHard2
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_VERYHARD + 5]]; // 실행~
}


- (IBAction)showGameCenterAchievement
{
    [self showArchboard];
    [Flurry logEvent:@"ShowAchievement"];

}


- (IBAction)setAuto
{
	if ([segmentAuto selectedSegmentIndex] == 0)
		bAuto = NO;
	else
		bAuto = YES;		
	
	
	[self setAutoSegment];
	[self displayScore];
}

- (IBAction)setSudokuType
{
    sudokuType = (SUDOKUTYPE)[segmentType selectedSegmentIndex];
    
    [self displayScore];
}




- (void) setAutoSegment
{
	// change segment by bAuto
	if (bAuto)
	{
		segmentAuto.selectedSegmentIndex = 1;
	} else {
		segmentAuto.selectedSegmentIndex = 0;
	}
    
    buttonGameCenterRanking1.hidden = bAuto;
    buttonGameCenterRanking2.hidden = bAuto;
    buttonGameCenterRanking3.hidden = bAuto;
    buttonGameCenterRanking4.hidden = bAuto;
    buttonGameCenterRanking5.hidden = bAuto;
}


- (void) setScoreData:(SUDOKUSCORE*)p
{
    pScore = p;
}


- (void) displayScore
{
	//NSInteger n = (bAuto?5:0);
    NSInteger iAverage1 = 0;
    NSInteger iAverage2 = 0;
    NSInteger iTotalGames = 0;
    NSInteger iTotalClears = 0;
    
    labelSudokuType.text = [SudokuGame getSudokuTypeName:sudokuType];
    
    for (int i=GAMELEVEL_VERYHARD; i<=GAMELEVEL_VERYEASY; i++)
    {
        iTotalGames += pScore->scoreGames[sudokuType][i] + pScore->scoreGames[sudokuType][i+5];
        iTotalClears += pScore->scoreClears[sudokuType][i] + pScore->scoreClears[sudokuType][i+5];
        iAverage1 = pScore->scoreClears[sudokuType][i] ? pScore->scoreClearTimeSum[sudokuType][i]/pScore->scoreClears[sudokuType][i] : 0;
        iAverage2 = pScore->scoreClears[sudokuType][i+5] ? pScore->scoreClearTimeSum[sudokuType][i+5]/pScore->scoreClears[sudokuType][i+5] : 0;

        [self setInteger:labelScoresArray[SCORETYPE_GAMES][i] num:pScore->scoreGames[sudokuType][i]];
        [self setInteger:labelScoresArray[SCORETYPE_CLEARS][i] num:pScore->scoreClears[sudokuType][i]];
        [self setTime:   labelScoresArray[SCORETYPE_AVERAGE][i] num:iAverage1];
        [self setTime:   labelScoresArray[SCORETYPE_BESTTIME][i] num:pScore->scoreBestTime[sudokuType][i]];
        [self setInteger:labelScoresArray[SCORETYPE_GAMES][i+5] num:pScore->scoreGames[sudokuType][i+5]];
        [self setInteger:labelScoresArray[SCORETYPE_CLEARS][i+5] num:pScore->scoreClears[sudokuType][i+5]];
        [self setTime:   labelScoresArray[SCORETYPE_AVERAGE][i+5] num:iAverage2];
        [self setTime:   labelScoresArray[SCORETYPE_BESTTIME][i+5] num:pScore->scoreBestTime[sudokuType][i+5]];
    }
    
	[self setInteger:labelTotalGames num:iTotalGames];
	[self setInteger:labelTotalClears num:iTotalClears];
	
	[self displayRank];
}


- (void) setScoreText
{
    NSString* strScore = [NSString stringWithFormat:gettext(@"%d points", nil), pScore->scoreTotal];
    NSString* strRank = [NSString stringWithFormat:gettext(@"(# %d)", nil), pScore->scoreRankTotal];
    NSString* strTotalScore = [NSString stringWithFormat:@"%@ %@", strScore, pScore->scoreRankTotal>0 ? strRank : @""];
    labelTotalScore.text = strTotalScore;

}

- (void) setLableRank:(UILabel*)label rank:(NSInteger)rank
{
	if (rank > 0)
	{
		label.text = [NSString stringWithFormat:gettext(@"#%d", nil), rank];
	} else {
		label.text = @"";
	}
}

- (void) setButtonRank:(UIButton*)button rank:(NSInteger)rank
{
	if (rank > 0)
	{
		[button setTitle:[NSString stringWithFormat:gettext(@"#%d", nil), rank] forState:UIControlStateNormal];
        button.enabled = YES;
    } else {
        [button setTitle:@"" forState:UIControlStateNormal];
        button.enabled = NO;
	}
}


- (void) displayRank
{
	DLog(@"displayRank");
	
	//if (pScore->scoreRankTotal > 0)
    [self setScoreText];
	
	NSInteger rank;
    
    
	
	for (int level=0; level<NUM_RANK_BESTTIME; level++)
	{
        if (sudokuType == SUDOKUTYPE_SUDOKU)
        {
            rank = pScore->scoreRankLevel[sudokuType][level];
            [self setLableRank:labelRankArray[level] rank:rank];
            rank = pScore->scoreRankLevel[sudokuType][level+5];
            [self setLableRank:labelRankArray[level+5] rank:rank];
        } else {
            rank = pScore->scoreRankLevel[sudokuType][level];
            [self setLableRank:labelRankArray[level] rank:rank];
            rank = 0;
            [self setLableRank:labelRankArray[level+5] rank:rank];
        }
	}

	for (int level=0; level<NUM_RANK_BESTTIME; level++)
	{
        if (sudokuType == SUDOKUTYPE_SUDOKU)
        {
            rank = pScore->scoreRankLevel[sudokuType][level];
            [self setButtonRank:buttonRankArray[level] rank:rank];
            rank = pScore->scoreRankLevel[sudokuType][level+5];
            [self setButtonRank:buttonRankArray[level+5] rank:rank];
        } else {
            rank = pScore->scoreRankLevel[sudokuType][level];
            [self setButtonRank:buttonRankArray[level] rank:rank];
            rank = 0;
            [self setButtonRank:buttonRankArray[level+5] rank:rank];
        }
	}
    
    
}
/*
- (void) OnTimer:(NSTimer *)timer
{
    BOOL bWait = NO;
	
    DLog(@"OnTimer");
    
	if (pScore->scoreRankTotal <= 0)
		bWait = YES;
	
    for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int level=0; level<NUM_RANK_BESTTIME; level++)
        {
            DLog(@"pScore->scoreRankLevel%d][%d]=%d", type, level, pScore->scoreRankLevel[type][level]);
            if (pScore->scoreRankLevel[type][level] <= 0)
                bWait = YES;
        }
    }
	
	if (++nTimer > 10 || bWait == NO)
		[timerScore invalidate];
	
	[self displayRank];

}

- (void) setTotalScoreRank  // 게임셍터로 랭킹을 보낸다.
{   
    DLog(@"setTotalScoreRank");


    
	[GameCenterUtil getTotalScoreRanking:&(pScore->scoreRankTotal)];
        
    for (SUDOKUTYPE type=0; type<SUDOKUTYPE_MAX; type++)
    {
        for (int level=0; level<NUM_RANK_BESTTIME; level++)
        {
            if (pScore->scoreBestTime[type][level] > 0)
            {
                [GameCenterUtil getRanking:[GameCenterUtil getLevelCategory:level] rank:&(pScore->scoreRankLevel[type][level])];
            } else {
                pScore->scoreRankLevel[type][level] = 0;  // best time이 없음
            }
        }
    }
    
    //[self setScoreText];
    
    //if (rankTotal < 1)
    {
        nTimer = 0;
        timerScore = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(OnTimer:)
                                                   userInfo:nil
                                                    repeats:YES];
        
        
    }    
}
 */

- (void) showLeaderboard:(NSString*)category

{
    if ([GameCenterUtil isGameCenterAvailable] == NO ||
        [GameCenterUtil isGameCenterLogined] == NO)
        return;
    
    GKLeaderboardViewController *leaderboardController = [[[GKLeaderboardViewController alloc] init]autorelease];
    if (leaderboardController != nil) {
        // 레더보드 델리게이트는 나임
        leaderboardController.leaderboardDelegate = self;
        
        leaderboardController.category = category;
        
        // 레더보드를 현재 뷰에 모달로 띄운다.
        [self presentViewController:leaderboardController animated: YES completion:nil];
    }
}

// 레더보드 델리게이트를 구현한 부분. 닫힐때 호출된다.
- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil]; //점수판 모달뷰를 내림
    // 추가적으로 자신의 어플에 맞게 구현해야할것이 있으면 한다.
}


- (void) showArchboard
{
    if ([GameCenterUtil isGameCenterAvailable] == NO ||
        [GameCenterUtil isGameCenterLogined] == NO)
        return;

    GKAchievementViewController *archiveController = [[[GKAchievementViewController alloc]init] autorelease];
    
    if (archiveController != nil) {
        
        archiveController.achievementDelegate = self;
        
        [self presentViewController:archiveController animated: YES completion:nil];
        
    }
}

- (void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) didReceiveMemoryWarning {
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



