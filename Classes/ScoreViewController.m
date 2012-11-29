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
@synthesize segmentAuto;
@synthesize bAuto;
@synthesize buttonGameCenterRanking1;
@synthesize buttonGameCenterRanking2;
@synthesize buttonGameCenterRanking3;
@synthesize buttonGameCenterRanking4;
@synthesize buttonGameCenterRanking5;
@synthesize segmentType;
@synthesize labelLicense;




- (void) setInteger:(UILabel*)label num:(NSInteger)num
{
	label.text = [NSString stringWithFormat:@"%d", num];
}

- (void) setTime:(UILabel*)label num:(NSInteger)num
{
	NSString *str;
	
	if (num >= 60*60*100)
		num = 60*60*100 - 1;
	
	if (num >= 60*60)
		str = [NSString stringWithFormat:@"%d:%02d:%02d",
			   num / (60*60),
			   num / (60) % (60),
			   num % (60)];
	else 
		str = [NSString stringWithFormat:@"%02d:%02d",
			   num / (60),
			   num % (60)];
	
	label.text = str;
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

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];     
	
    [self setLocalizedMessage];
    
    labelRankArray[GAMELEVEL_VERYHARD] = labelRankVeryHard;
    labelRankArray[GAMELEVEL_HARD] = labelRankHard;
    labelRankArray[GAMELEVEL_NORMAL] = labelRankNormal;
    labelRankArray[GAMELEVEL_EASY] = labelRankEasy;
    labelRankArray[GAMELEVEL_VERYEASY] = labelRankVeryEasy;

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
        [mainViewController dismissModalViewControllerAnimated:YES];
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
}

- (IBAction)showGameCenterLeaderboardVeryEasy
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_VERYEASY + (bAuto?5:0)]]; // 실행~
}

- (IBAction)showGameCenterLeaderboardEasy
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_EASY + (bAuto?5:0)]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardNormal
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_NORMAL + (bAuto?5:0)]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardHard
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_HARD + (bAuto?5:0)]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardVeryHard
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:sudokuType level:GAMELEVEL_VERYHARD + (bAuto?5:0)]]; // 실행~
}


- (IBAction)showGameCenterAchievement
{
    [self showArchboard];
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
    sudokuType = [segmentType selectedSegmentIndex];
    
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
	NSInteger n = (bAuto?5:0);
    
    labelSudokuType.text = [SudokuGame getSudokuTypeName:sudokuType];
    
	
	[self setInteger:labelVeryHardGames num:pScore->scoreGames[sudokuType][0+n]];
	[self setInteger:labelVeryHardClears num:pScore->scoreClears[sudokuType][0+n]];
	[self setTime:labelVeryHardBestTime num:pScore->scoreBestTime[sudokuType][0+n]];
	[self setTime:labelVeryHardAverage num:pScore->scoreClears[sudokuType][0+n] ? pScore->scoreClearTimeSum[sudokuType][0+n]/pScore->scoreClears[sudokuType][0+n] : 0];
	[self setInteger:labelHardGames num:pScore->scoreGames[sudokuType][1+n]];
	[self setInteger:labelHardClears num:pScore->scoreClears[sudokuType][1+n]];
	[self setTime:labelHardBestTime num:pScore->scoreBestTime[sudokuType][1+n]];
	[self setTime:labelHardAverage num:pScore->scoreClears[sudokuType][1+n] ? pScore->scoreClearTimeSum[sudokuType][1+n]/pScore->scoreClears[sudokuType][1+n] : 0];
	[self setInteger:labelNormalGames num:pScore->scoreGames[sudokuType][2+n]];
	[self setInteger:labelNormalClears num:pScore->scoreClears[sudokuType][2+n]];
	[self setTime:labelNormalBestTime num:pScore->scoreBestTime[sudokuType][2+n]];
	[self setTime:labelNormalAverage num:pScore->scoreClears[sudokuType][2+n] ? pScore->scoreClearTimeSum[sudokuType][2+n]/pScore->scoreClears[sudokuType][2+n] : 0];
	[self setInteger:labelEasyGames num:pScore->scoreGames[sudokuType][3+n]];
	[self setInteger:labelEasyClears num:pScore->scoreClears[sudokuType][3+n]];
	[self setTime:labelEasyBestTime num:pScore->scoreBestTime[sudokuType][3+n]];
	[self setTime:labelEasyAverage num:pScore->scoreClears[sudokuType][3+n] ? pScore->scoreClearTimeSum[sudokuType][3+n]/pScore->scoreClears[sudokuType][3+n] : 0];
	[self setInteger:labelVeryEasyGames num:pScore->scoreGames[sudokuType][4+n]];
	[self setInteger:labelVeryEasyClears num:pScore->scoreClears[sudokuType][4+n]];
	[self setTime:labelVeryEasyBestTime num:pScore->scoreBestTime[sudokuType][4+n]];
	[self setTime:labelVeryEasyAverage num:pScore->scoreClears[sudokuType][4+n] ? pScore->scoreClearTimeSum[sudokuType][4+n]/pScore->scoreClears[sudokuType][4+n] : 0];
	
	[self setInteger:labelTotalGames num:
        pScore->scoreGames[sudokuType][0+n]+
        pScore->scoreGames[sudokuType][1+n]+
        pScore->scoreGames[sudokuType][2+n]+
        pScore->scoreGames[sudokuType][3+n]+
        pScore->scoreGames[sudokuType][4+n]];
	[self setInteger:labelTotalClears num:
        pScore->scoreClears[sudokuType][0+n]+
        pScore->scoreClears[sudokuType][1+n]+
        pScore->scoreClears[sudokuType][2+n]+
        pScore->scoreClears[sudokuType][3+n]+
        pScore->scoreClears[sudokuType][4+n]];
	
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
		label.text = [NSString stringWithFormat:gettext(@"(# %d)", nil), rank];
	} else {
		label.text = @"";
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
		DLog(@"level=%d", level);
		if (bAuto)
			rank = 0;
		else
			rank = pScore->scoreRankLevel[sudokuType][level];

		[self setLableRank:labelRankArray[level] rank:rank];
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
        [self presentModalViewController:leaderboardController animated: YES];
    }
}

// 레더보드 델리게이트를 구현한 부분. 닫힐때 호출된다.
- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [self dismissModalViewControllerAnimated:YES]; //점수판 모달뷰를 내림
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
        
        [self presentModalViewController:archiveController animated: YES];
        
    }
}

- (void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
    [self dismissModalViewControllerAnimated:YES];
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



