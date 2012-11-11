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
#import "AppDelegate.h"

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
+ (void) connectGameCenter:(MainViewController*) controller
{
    if ([self isGameCenterAvailable] == NO)
        return;
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    NSLog(@"connect... to gamecenter");
    if(localPlayer.authenticated == NO)
    { //게임센터 로그인이 아직일때
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
        {
            localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
            {
                if (viewController != nil)
                {
                    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
                    [ctrl presentViewController:viewController animated:YES completion:nil];
                }
                else if (localPlayer.isAuthenticated)
                {
                    NSLog(@"Player authenticated");
                    bLoginedGamecenter = YES;
                }
                else
                {
                    NSLog(@"Player authentication failed");
                }
            };
            
        } else {    // deprecated 6.0 and above
            [localPlayer authenticateWithCompletionHandler:^(NSError* error)
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
}

+ (NSInteger) getTotalScoreRanking:(NSInteger*)rank
{
    NSLog(@"getTotalScoreRanking");
    if ([self isGameCenterAvailable] == NO || bLoginedGamecenter == NO)
        return 0;

    return [self getRanking:[self getPointCategory] rank:rank];
}



+ (NSInteger) getRanking:(NSString*)category rank:(NSInteger*)rank
{
    NSLog(@"getRanking(%@)", category);
    
    if ([self isGameCenterAvailable] == NO || bLoginedGamecenter == NO)
        return 0;

    //__block NSInteger nRank = -1;
    
    if([GKLocalPlayer localPlayer].authenticated)
    {
        NSArray *arr = [[NSArray alloc] initWithObjects:[GKLocalPlayer localPlayer].playerID, nil];
        GKLeaderboard *board = [[GKLeaderboard alloc] initWithPlayerIDs:arr];
        if(board != nil)
        {
            board.timeScope = GKLeaderboardTimeScopeAllTime;
            board.range = NSMakeRange(1, 1);
            board.category = category;
            [board loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error)
             {
                 GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
                 for (GKScore* score in scores)
                 {
                     if ([score.playerID isEqualToString:lp.playerID])
                     {
                         DLog(@"rank(%@)=%d", category, score.rank);
                         
                         //nRank = score.rank;
                         *rank = score.rank;
                     }
                 }
             }];
        } else {
            DLog(@"borad(%@) == nil", category);
        }
        [board release];
        [arr release];
    }
    
    return *rank;
    
}

// 게임센터 서버로 점수를 보낸다.
+(void) sendScoreToGameCenter:(int)_score
{
 
    NSLog(@"sendScoreToGameCenter");
    
    if ([self isGameCenterAvailable] == NO || bLoginedGamecenter == NO)
        return;

    
    GKScore* score = [[[GKScore alloc] initWithCategory:[self getPointCategory]]autorelease];
    // 위에서 kPoint 가 게임센터에서 설정한 Leaderboard ID
    score.value = _score;
    
    // 아래는 겜센터 스타일의 노티를 보여준다. 첫번째가 타이틀, 두번째가 표시할 메세지
    [[GKAchievementHandler defaultHandler]
        notifyAchievementTitle:@"SUDOKU Points"
        andMessage:[NSString stringWithFormat:gettext(@"You got %d points", nil),_score]];
    
    // 실제로 게임센터 서버에 점수를 보낸다.
    [score reportScoreWithCompletionHandler:^(NSError* error)
    {
        if(error != NULL){
            // Retain the score object and try again later (not shown).
            NSLog(@"Error:%@", [error localizedDescription]);
            
        }
    }];
    
    
    // 보내기 직전의 점수가 나온다. 이유가 뭘까?
    

    

}

+ (NSString*) getPointCategory
{
    return GK_CATEGORY_POINT;
}

+ (NSString*) getLevelCategory:(SUDOKUTYPE)type level:(NSInteger)level
{
    NSLog(@"getLevelCategory(%d,%d)", type, level);
    
    static NSString* strLevel[SUDOKUTYPE_MAX][5] = {
        {
            GK_CATEGORY_VERYHARD,
            GK_CATEGORY_HARD,
            GK_CATEGORY_NORMAL,
            GK_CATEGORY_EASY,
            GK_CATEGORY_VERYEASY
        },
        {
            GK_CATEGORY_VERYHARD_COM,
            GK_CATEGORY_HARD_COM,
            GK_CATEGORY_NORMAL_COM,
            GK_CATEGORY_EASY_COM,
            GK_CATEGORY_VERYEASY_COM
        },
        {
            GK_CATEGORY_VERYHARD_SUM,
            GK_CATEGORY_HARD_SUM,
            GK_CATEGORY_NORMAL_SUM,
            GK_CATEGORY_EASY_SUM,
            GK_CATEGORY_VERYEASY_SUM
        },
        {
            GK_CATEGORY_VERYHARD_CAL,
            GK_CATEGORY_HARD_CAL,
            GK_CATEGORY_NORMAL_CAL,
            GK_CATEGORY_EASY_CAL,
            GK_CATEGORY_VERYEASY_CAL
        }
        
    };

    if (level >= 0 && level < 5)
	{
		return strLevel[type][level];
	} else {
		return @"";
	}
}

// 게임센터 서버로 점수를 보낸다.
+ (void) sendBestTimeToGameCenter:(SUDOKUTYPE)type level:(NSInteger)level besttime:(NSInteger)num;
{
    DLog(@"sendBestTimeToGameCenter(%d,%d,%d)", type, level, num);
    if ([self isGameCenterAvailable] == NO || bLoginedGamecenter == NO)
        return;

	if (num < 3)	// too fast
	{
		return;
	}
    
    NSString* strCategory;

    if (level >= 0 && level < 5)
	{
		strCategory = [self getLevelCategory:type level:level];
    } else {
        return;
	}
    
    
    DLog(@"Sending(%@) <- %d seconds", strCategory, num);
    GKScore* score = [[[GKScore alloc] initWithCategory:strCategory] autorelease];
    // 위에서 kPoint 가 게임센터에서 설정한 Leaderboard ID
    score.value = num;
    
    
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
    NSLog(@"--겜센터 : sendAchievementWithIdentifier %@ , %f",identifier,percent);
    if ([self isGameCenterAvailable] == NO || bLoginedGamecenter == NO)
        return;

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
    NSLog(@"sendAchievementClearGame");
    if ([self isGameCenterAvailable] == NO || bLoginedGamecenter == NO)
        return;
    
    NSString* strCategory;
    float percent;
    
    if (cleargame <= 10) {
        strCategory = GK_CATEGORY_CLEAR10;
        percent = (float)cleargame*100/10;
		[self sendAchievementWithIdentifier:strCategory percentComplete:percent];
    } else if (cleargame <= 100) {
        percent = (float)cleargame*100/100;
        strCategory = GK_CATEGORY_CLEAR100;
		[self sendAchievementWithIdentifier:strCategory percentComplete:percent];
		[self sendAchievementWithIdentifier:GK_CATEGORY_CLEAR10 percentComplete:100.f];
    } else if (cleargame <= 1000) {
        percent = (float)cleargame*100/1000;
        strCategory = GK_CATEGORY_CLEAR1000;
		[self sendAchievementWithIdentifier:strCategory percentComplete:percent];
		[self sendAchievementWithIdentifier:GK_CATEGORY_CLEAR10 percentComplete:100.f];
		[self sendAchievementWithIdentifier:GK_CATEGORY_CLEAR100 percentComplete:100.f];
    } else {
        // 1000 게임 이상은 목표가 없음...
        return;
    }
    
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
