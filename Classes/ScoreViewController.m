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



- (void) setInteger:(UILabel*)label num:(NSInteger)num
{
	NSString* str;
	
	str = [[NSString alloc] initWithFormat:@"%d", num];
	label.text = str;
	
	[str release];
}

- (void) setTime:(UILabel*)label num:(NSInteger)num
{
	NSString *str;
	
	if (num >= 60*60*100)
		num = 60*60*100 - 1;
	
	if (num >= 60*60)
		str = [[NSString alloc] initWithFormat:@"%d:%02d:%02d",
			   num / (60*60),
			   num / (60) % (60),
			   num % (60)];
	else 
		str = [[NSString alloc] initWithFormat:@"%02d:%02d",
			   num / (60),
			   num % (60)];
	
	label.text = str; 
	
	[str release];
	
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


- (IBAction)done {
    [mainViewController dismissViewControllerAnimated:YES completion:nil];
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



- (void) setScoreText
{
    NSString* strScore = [[NSString alloc] initWithFormat:gettext(@"%d points", nil), score];
    NSString* strRank = [[NSString alloc] initWithFormat:gettext(@"(# %d)", nil), rankTotal];
    NSString* strTotalScore = [[NSString alloc] initWithFormat:@"%@ %@", strScore, rankTotal>0 ? strRank : @""];
    labelTotalScore.text = strTotalScore;
    [strTotalScore release];
    [strRank release];
    [strScore release];
}

- (void) setLableRank:(UILabel*)label rank:(NSInteger)rank
{
    NSString* strRank = [[NSString alloc] initWithFormat:gettext(@"(# %d)", nil), rank];
    label.text = strRank;
    [strRank release];
}


- (void) OnTimer:(NSTimer *)timer
{
    BOOL bWait = NO;
    
    NSLog(@"OnTimer");
    
    
    if (rankTotal > 0)
        [self setScoreText];
    else
        bWait = YES;
    
    for (int level=0; level<5; level++)
    {
        NSLog(@"level=%d", level);
        if (rankLevel[level] > 0)
            [self setLableRank:labelRankArray[level] rank:rankLevel[level]];
        else if (rankLevel[level] == -1)
            bWait = YES;
    }
    

    if (++nTimer > 10 || bWait == NO)
       [timerScore invalidate];
}

- (void) setTotalScoreRank:(NSInteger)nScore;
{
    NSLog(@"setTotalScoreRank(%d)", nScore);
    
    rankTotal = -1;
    
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
        labelRankArray[level].text = @"";
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
                                                    repeats:NO];
        
        
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
