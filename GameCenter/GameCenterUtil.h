//
//  GameCenterUtil.h
//  sudokuall
//
//  Created by Raymond on 10/4/12.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "GKAchievementHandler.h"



@interface GameCenterUtil : NSObject




/////////////////Geunwon,Mo : GameCenter 추가 start /////////////
+ (BOOL) isGameCenterAvailable ; //게임센터가 사용가능하지 알아보는 메소드
+ (BOOL) isGameCenterLogined;
+ (void) connectGameCenter; //게임센터에 접속하는 메소드
+ (NSInteger) getRanking:(NSString*) category rank:(NSInteger*)rank;
+ (NSInteger) getTotalScoreRanking:(NSInteger*)rank;
+ (void) sendScoreToGameCenter:(int)_score; //게임센터서버에 점수 보내는 메소드
+ (void) sendBestTimeToGameCenter:(NSInteger)level besttime:(NSInteger)num;
+ (void) sendAchievementWithIdentifier: (NSString*) identifier percentComplete: (float) percent;//게임센터서버에 목표달성 보내는 메소드
+ (void) sendAchievementClearGame:(NSInteger)cleargame;
+ (void) resetAchievements; //테스트용으로 목표달성도를 리셋하는 메소드
/////////////////Geunwon,Mo : GameCenter 추가 end   /////////////
+ (NSString*) getLevelCategory:(NSInteger)level;

@end
