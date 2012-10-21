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

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];     
	
	naviItem.title = gettext(@"Score", nil);
	
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
    
    labelRankArray[GAMELEVEL_VERYHARD] = labelRankVeryHard;
    labelRankArray[GAMELEVEL_HARD] = labelRankHard;
    labelRankArray[GAMELEVEL_NORMAL] = labelRankNormal;
    labelRankArray[GAMELEVEL_EASY] = labelRankEasy;
    labelRankArray[GAMELEVEL_VERYEASY] = labelRankVeryEasy;

    MainViewController *ctrl = (MainViewController*)mainViewController;
    // Gamecenter와 sync맞추기
    for (int level=0; level<5; level++)
    {
        if ([ctrl getBestTime:level] > 0)
            [GameCenterUtil sendBestTimeToGameCenter:level besttime:[ctrl getBestTime:level]];
    }
    // 총점 보내기
    [GameCenterUtil sendScoreToGameCenter:[ctrl getTotalScore]];
	
	
	
    
	
    [super viewDidLoad];
}


- (IBAction)done
{
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        [mainViewController dismissModalViewControllerAnimated:YES];
    } else {
        [mainViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)showGameCenterLeaderboard
{
    [self showLeaderboard:[GameCenterUtil getPointCategory]]; // 실행~
}

- (IBAction)showGameCenterLeaderboardVeryEasy
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:GAMELEVEL_VERYEASY]]; // 실행~
}

- (IBAction)showGameCenterLeaderboardEasy
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:GAMELEVEL_EASY]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardNormal
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:GAMELEVEL_NORMAL]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardHard
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:GAMELEVEL_HARD]]; // 실행~
}
- (IBAction)showGameCenterLeaderboardVeryHard
{
    [self showLeaderboard:[GameCenterUtil getLevelCategory:GAMELEVEL_VERYHARD]]; // 실행~
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

- (void) setAutoSegment
{
	// change segment by bAuto
	if (bAuto)
	{
		segmentAuto.selectedSegmentIndex = 1;
	} else {
		segmentAuto.selectedSegmentIndex = 0;
	}
}


- (void) setScoreData:(NSInteger)t g:(NSInteger*)g c:(NSInteger*)c b:(NSInteger*)b s:(NSInteger*)s
{
	scoreGames = g;
	scoreClears = c;
	scoreBestTime = b;
	scoreClearTimeSum = s;
	scoreTotal = t;
}


- (void) displayScore
{
	NSInteger n = bAuto?5:0;
	
	[self setInteger:labelVeryHardGames num:scoreGames[0+n]];
	[self setInteger:labelVeryHardClears num:scoreClears[0+n]];
	[self setTime:labelVeryHardBestTime num:scoreBestTime[0+n]];
	[self setTime:labelVeryHardAverage num:scoreClears[0+n] ? scoreClearTimeSum[0+n]/scoreClears[0+n] : 0];
	[self setInteger:labelHardGames num:scoreGames[1+n]];
	[self setInteger:labelHardClears num:scoreClears[1+n]];
	[self setTime:labelHardBestTime num:scoreBestTime[1+n]];
	[self setTime:labelHardAverage num:scoreClears[1+n] ? scoreClearTimeSum[1+n]/scoreClears[1+n] : 0];
	[self setInteger:labelNormalGames num:scoreGames[2+n]];
	[self setInteger:labelNormalClears num:scoreClears[2+n]];
	[self setTime:labelNormalBestTime num:scoreBestTime[2+n]];
	[self setTime:labelNormalAverage num:scoreClears[2+n] ? scoreClearTimeSum[2+n]/scoreClears[2+n] : 0];
	[self setInteger:labelEasyGames num:scoreGames[3+n]];
	[self setInteger:labelEasyClears num:scoreClears[3+n]];
	[self setTime:labelEasyBestTime num:scoreBestTime[3+n]];
	[self setTime:labelEasyAverage num:scoreClears[3+n] ? scoreClearTimeSum[3+n]/scoreClears[3+n] : 0];
	[self setInteger:labelVeryEasyGames num:scoreGames[4+n]];
	[self setInteger:labelVeryEasyClears num:scoreClears[4+n]];
	[self setTime:labelVeryEasyBestTime num:scoreBestTime[4+n]];
	[self setTime:labelVeryEasyAverage num:scoreClears[4+n] ? scoreClearTimeSum[4+n]/scoreClears[4+n] : 0];
	
	[self setInteger:labelTotalGames num:scoreGames[0+n]+scoreGames[1+n]+scoreGames[2+n]+scoreGames[3+n]+scoreGames[4+n]];
	[self setInteger:labelTotalClears num:scoreClears[0+n]+scoreClears[1+n]+scoreClears[2+n]+scoreClears[3+n]+scoreClears[4+n]];
	
	[self displayRank];
}


- (void) setScoreText
{
    NSString* strScore = [NSString stringWithFormat:gettext(@"%d points", nil), score];
    NSString* strRank = [NSString stringWithFormat:gettext(@"(# %d)", nil), rankTotal];
    NSString* strTotalScore = [NSString stringWithFormat:@"%@ %@", strScore, rankTotal>0 ? strRank : @""];
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
	NSLog(@"displayRank");
	
	if (rankTotal > 0)
		[self setScoreText];
	
	NSInteger rank;
	
	for (int level=0; level<5; level++)
	{
		NSLog(@"level=%d", level);
		if (bAuto)
			rank = -1;
		else
			rank = rankLevel[level];

		[self setLableRank:labelRankArray[level] rank:rank];
	}
	buttonGameCenterRanking1.hidden = bAuto ? YES: NO;
	buttonGameCenterRanking2.hidden = bAuto ? YES: NO;
	buttonGameCenterRanking3.hidden = bAuto ? YES: NO;
	buttonGameCenterRanking4.hidden = bAuto ? YES: NO;
	buttonGameCenterRanking5.hidden = bAuto ? YES: NO;
}

- (void) OnTimer:(NSTimer *)timer
{
    BOOL bWait = NO;
	
    NSLog(@"OnTimer");
    
	if (rankTotal <= 0)
		bWait = YES;
	
	for (int level=0; level<5; level++)
	{
		if (rankLevel[level] == -1)
			bWait = YES;
	}
	
	
	if (++nTimer > 10 || bWait == NO)
		[timerScore invalidate];
	
	[self displayRank];

}

- (void) setTotalScoreRank:(NSInteger)nScore;
{
    NSLog(@"setTotalScoreRank(%d)", nScore);

    
    rankTotal = -1;
    
	for (int level=0; level<5; level++)
		labelRankArray[level].text = @"";

    
	[GameCenterUtil getTotalScoreRanking:&rankTotal];
    
    MainViewController *ctrl = (MainViewController*)mainViewController;
    

    for (int level=0; level<5; level++)
    {
        if ([ctrl getBestTime:level] > 0)
        {
            rankLevel[level] = -1;
            [GameCenterUtil getRanking:[GameCenterUtil getLevelCategory:level] rank:&(rankLevel[level])];
        } else {
            rankLevel[level] = 0;  // best time이 없음
        }
	}
    
    
    score = nScore;
    
    [self setScoreText];
    
    if (rankTotal < 1)
    {
        nTimer = 0;
        timerScore = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(OnTimer:)
                                                   userInfo:nil
                                                    repeats:YES];
        
        
    }    
}

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
    return NO;
/*#ifdef ADMOB_FREEVERSION
    if (cDeviceType == DEVICETYPE_IPHONE)
        return NO;
#endif
    return YES;
*/    
}

- (NSUInteger)supportedInterfaceOrientations
{
     return UIInterfaceOrientationMaskPortrait;
    /*
#ifdef ADMOB_FREEVERSION
    if (cDeviceType == DEVICETYPE_IPHONE)
        return UIInterfaceOrientationMaskPortrait;
#endif
    return UIInterfaceOrientationMaskAll;
     */
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
/*
#ifdef ADMOB_FREEVERSION
    if (cDeviceType == DEVICETYPE_IPHONE)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else
        return YES;	
#else	
	return YES;
#endif
 */
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [mainViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [mainViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
