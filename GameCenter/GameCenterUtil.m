//
//  GameCenterUtil.m
//  sudokuall
//
//  Created by Raymond on 10/4/12.
//
//

#import "GameCenterUtil.h"
#import "Locale.h"
#import "Constants.h"

@implementation GameCenterUtil



//GameCenter 사용 가능 단말인지 확인
+ (BOOL) isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] !=NSOrderedAscending);
    return (gcClass && osVersionSupported);
}


static BOOL bLoginedGamecenter = NO;

+ (BOOL) isGameCenterLogined
{
    return bLoginedGamecenter;
}

//GameCenter 로그인
+ (void) connectGameCenter
{
    if ([self isGameCenterAvailable] == NO)
        return;
    
    NSLog(@"connect... to gamecenter");
    if([GKLocalPlayer localPlayer].authenticated == NO)
    { //게임센터 로그인이 아직일때
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError* error)
        {
            if(error == NULL)
            {
                bLoginedGamecenter = YES;
                NSLog(@"게임센터 로그인 성공~");
            } else {
                NSLog(@"Error(%d):%@", error.code, [error localizedDescription]);
                
                
                NSLog(@"게임센터 로그인 에러. 별다른 처리는 하지 않는다.");
                
                // 15:게임센터에서 이 게임을 인식할 수 없습니다.
            }
        }];
    }
}

// 게임센터 서버로 점수를 보낸다.
+(void) sendScoreToGameCenter:(int)_score
{
    _score = 1;
    
    if ([self isGameCenterAvailable] == NO || bLoginedGamecenter == NO)
        return;

    
    GKScore* score = [[[GKScore alloc] initWithCategory:@"grp.sudoku9.points"]autorelease];
    // 위에서 kPoint 가 게임센터에서 설정한 Leaderboard ID
    score.value = _score;
    
    // 아래는 겜센터 스타일의 노티를 보여준다. 첫번째가 타이틀, 두번째가 표시할 메세지
    [[GKAchievementHandler defaultHandler]
        notifyAchievementTitle:@"SUDOKU Points"
        andMessage:[NSString stringWithFormat:gettext(@"You got %d points", nil),_score]];
    
    // 실지로 게임센터 서버에 점수를 보낸다.
    [score reportScoreWithCompletionHandler:^(NSError* error)
    {
        if(error != NULL){
            // Retain the score object and try again later (not shown).
            NSLog(@"Error:%@", [error localizedDescription]);
            
        }
    }];
    NSLog(@"rank=%d", score.rank);
}

// 게임센터 서버로 점수를 보낸다.
+(void) sendBestTimeToGameCenter:(NSInteger)level besttime:(NSInteger)num
{
    if ([self isGameCenterAvailable] == NO || bLoginedGamecenter == NO)
        return;

    
    NSString* strCategory;
    
    switch(level)
    {
		case GAMELEVEL_VERYEASY:
			strCategory = @"grp.sudoku9.timerecord.veryeasy";
			break;
		case GAMELEVEL_EASY:
			strCategory = @"grp.sudoku9.timerecord.easy";
			break;
		case GAMELEVEL_NORMAL:
			strCategory = @"grp.sudoku9.timerecord.normal";
			break;
		case GAMELEVEL_HARD:
			strCategory = @"grp.sudoku9.timerecord.hard";
			break;
		case GAMELEVEL_VERYHARD:
			strCategory = @"grp.sudoku9.timerecord.veryhard";
			break;
		default:
			return;

    }
		
    
    
    GKScore* score = [[[GKScore alloc] initWithCategory:strCategory] autorelease];
    // 위에서 kPoint 가 게임센터에서 설정한 Leaderboard ID
    score.value = num;
    
    // best time은 창을 보여주지 않는다.
    /*
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
    // 아래는 겜센터 스타일의 노티를 보여준다. 첫번째가 타이틀, 두번째가 표시할 메세지
    [[GKAchievementHandler defaultHandler]
        notifyAchievementTitle:@"SUDOKU Best time"
        andMessage:[NSString stringWithFormat:gettext(@"You got best time (%@)", nil), str]];
    
    [str release];
    */
    
    // 실지로 게임센터 서버에 점수를 보낸다.
    [score reportScoreWithCompletionHandler:^(NSError* error){
        if(error != NULL){
            // Retain the score object and try again later (not shown).
            NSLog(@"Error:%@", [error localizedDescription]);
            
        }
    }];

     

}

// 게임센터 서버로 목표달성도를 보낸다. 첫번째가 목표ID, 두번째가 달성도. 100%면 목표달성임
+ (void) sendAchievementWithIdentifier: (NSString*) identifier percentComplete: (float) percent
{
    if ([self isGameCenterAvailable] == NO || bLoginedGamecenter == NO)
        return;

    NSLog(@"--겜센터 : sendAchievementWithIdentifier %@ , %f",identifier,percent);
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: identifier]autorelease];
    if (achievement)
    {
        achievement.percentComplete = percent;
        
        [achievement reportAchievementWithCompletionHandler:^(NSError *error)
         {
             if (error != nil)
             {
                 NSLog(@"Error:%@", [error localizedDescription]);

             }
         }];
        
        // 이 아래는 게임센터로부터 목표달성이 등록되면 실행되는 리스너(?)
        [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:
         ^(NSArray *descriptions, NSError *error)
        {
             if (error != nil)
             {
                 NSLog(@"Error:%@", [error localizedDescription]);
             }
             // process the errors
             if (descriptions != nil)
             {
                 
                 //목표달성이 등록되면 노티로 알려준다.
                 for (GKAchievementDescription *achievementDescription in descriptions)
                 {
                     if ([[achievementDescription identifier] isEqualToString:identifier])
                     {
                         // 보낸 ID와 일치하면 달성도에 따라 노티를 보여준다.
                         if (percent >= 100.0f)
                         { // 100%면 달성완료 노티를...
                             [[GKAchievementHandler defaultHandler]notifyAchievement:achievementDescription];
                         } else { // 100%가 안되면 진행도를 노티.
                             [[GKAchievementHandler defaultHandler]notifyAchievementTitle:achievementDescription.title andMessage:[NSString stringWithFormat:gettext(@"%.0f%% 완료하셨습니다.",nil), percent]];
                         }
                     }
                 }
             }
         }];
    }
}


+ (void) sendAchievementClearGame:(NSInteger)cleargame
{
    if ([self isGameCenterAvailable] == NO || bLoginedGamecenter == NO)
        return;
    
    NSString* strCategory;
    float percent;
    
    if (cleargame <= 10) {
        strCategory = @"grp.sudoku9.clear.10";
        percent = (float)cleargame*100/10;
    } else if (cleargame <= 100) {
        percent = (float)cleargame*100/100;
        strCategory = @"grp.sudoku9.clear.100";
    } else if (cleargame <= 1000) {
        percent = (float)cleargame*100/1000;
        strCategory = @"grp.sudoku9.clear.1000";
    } else {
        // 1000 게임 이상은 목표가 없음...
        return;
    }
 
    
    [self sendAchievementWithIdentifier:strCategory percentComplete:percent];
}


// 테스트할때 현재까지 모든 진행도를 리셋하는 메소드.
+ (void) resetAchievements
{
    if ([self isGameCenterAvailable] == NO || bLoginedGamecenter == NO)
        return;

    
    // Clear all progress saved on Game Center
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
     {
         if (error != nil){}
         // handle errors
     }];
}


@end
