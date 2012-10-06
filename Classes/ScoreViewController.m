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
	
    [super viewDidLoad];
}


- (IBAction)done {
    [mainViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showGameCenterLeaderboard
{
    [self showLeaderboard:@"grp.sudoku9.points"]; // 실행~
}

- (IBAction)showGameCenterLeaderboardVeryEasy
{
    [self showLeaderboard:@"grp.sudoku9.timerecord.veryeasy"]; // 실행~
}

- (IBAction)showGameCenterLeaderboardEasy
{
    [self showLeaderboard:@"grp.sudoku9.timerecord.easy"]; // 실행~
}
- (IBAction)showGameCenterLeaderboardNormal
{
    [self showLeaderboard:@"grp.sudoku9.timerecord.normal"]; // 실행~
}
- (IBAction)showGameCenterLeaderboardHard
{
    [self showLeaderboard:@"grp.sudoku9.timerecord.hard"]; // 실행~
}
- (IBAction)showGameCenterLeaderboardVeryHard
{
    [self showLeaderboard:@"grp.sudoku9.timerecord.veryhard"]; // 실행~
}


- (IBAction)showGameCenterAchievement
{
    [self showArchboard];
}



- (void) setScoreText
{
    NSString* strScore = [[NSString alloc] initWithFormat:gettext(@"%d points", nil), score];
    NSString* strRank = [[NSString alloc] initWithFormat:gettext(@"(# %d)", nil), rank];
    NSString* strTotalScore = [[NSString alloc] initWithFormat:@"%@ %@", strScore, rank>0 ? strRank : @""];
    labelTotalScore.text = strTotalScore;
    [strTotalScore release];
    [strRank release];
    [strScore release];
}

- (void) OnTimer:(NSTimer *)timer
{
    if (rank > 0)
        [self setScoreText];

    if (++nTimer > 10 || rank > 0)
        [timerScore invalidate];
}

- (void) setTotalScoreRank:(NSInteger)nScore;
{
    
    rank = [GameCenterUtil getTotalScoreRanking:&rank];
    score = nScore;
    
    [self setScoreText];
    
    if (rank < 1)
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
