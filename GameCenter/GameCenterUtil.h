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
#import "Constants.h"
#import "MainViewController.h"



@interface GameCenterUtil : NSObject


#ifdef SUDOKU9
#define GK_CATEGORY_POINT           @"grp.sudoku9.points"
#define GK_CATEGORY_VERYHARD        @"grp.sudoku9.timerecord.veryhard"
#define GK_CATEGORY_HARD            @"grp.sudoku9.timerecord.hard"
#define GK_CATEGORY_NORMAL          @"grp.sudoku9.timerecord.normal"
#define GK_CATEGORY_EASY            @"grp.sudoku9.timerecord.easy"
#define GK_CATEGORY_VERYEASY        @"grp.sudoku9.timerecord.veryeasy"
#define GK_CATEGORY_VERYHARD_COM    @"grp.sudoku9.timerecord.veryhard.compare"
#define GK_CATEGORY_HARD_COM        @"grp.sudoku9.timerecord.hard.compare"
#define GK_CATEGORY_NORMAL_COM      @"grp.sudoku9.timerecord.normal.compare"
#define GK_CATEGORY_EASY_COM        @"grp.sudoku9.timerecord.easy.compare"
#define GK_CATEGORY_VERYEASY_COM    @"grp.sudoku9.timerecord.veryeasy.compare"
#define GK_CATEGORY_VERYHARD_SUM    @"grp.sudoku9.timerecord.veryhard.sum"
#define GK_CATEGORY_HARD_SUM        @"grp.sudoku9.timerecord.hard.sum"
#define GK_CATEGORY_NORMAL_SUM      @"grp.sudoku9.timerecord.normal.sum"
#define GK_CATEGORY_EASY_SUM        @"grp.sudoku9.timerecord.easy.sum"
#define GK_CATEGORY_VERYEASY_SUM    @"grp.sudoku9.timerecord.veryeasy.sum"
#define GK_CATEGORY_VERYHARD_CAL    @"grp.sudoku9.timerecord.veryhard.calcu"
#define GK_CATEGORY_HARD_CAL        @"grp.sudoku9.timerecord.hard.calcu"
#define GK_CATEGORY_NORMAL_CAL      @"grp.sudoku9.timerecord.normal.calcu"
#define GK_CATEGORY_EASY_CAL        @"grp.sudoku9.timerecord.easy.calcu"
#define GK_CATEGORY_VERYEASY_CAL    @"grp.sudoku9.timerecord.veryeasy.calcu"
#define GK_CATEGORY_CLEAR10         @"grp.sudoku9.clear.10"
#define GK_CATEGORY_CLEAR100        @"grp.sudoku9.clear.100"
#define GK_CATEGORY_CLEAR1000       @"grp.sudoku9.clear.1000"
#else // SUDOKU6
#define GK_CATEGORY_POINT           @"grp.sudoku9.points"
#define GK_CATEGORY_VERYHARD        @"grp.sudoku6.timerecord.veryhard"
#define GK_CATEGORY_HARD            @"grp.sudoku6.timerecord.hard"
#define GK_CATEGORY_NORMAL          @"grp.sudoku6.timerecord.normal"
#define GK_CATEGORY_EASY            @"grp.sudoku6.timerecord.easy"
#define GK_CATEGORY_VERYEASY        @"grp.sudoku6.timerecord.veryeasy"
#define GK_CATEGORY_VERYHARD_COM    @"grp.sudoku6.timerecord.veryhard.compare"
#define GK_CATEGORY_HARD_COM        @"grp.sudoku6.timerecord.hard.compare"
#define GK_CATEGORY_NORMAL_COM      @"grp.sudoku6.timerecord.normal.compare"
#define GK_CATEGORY_EASY_COM        @"grp.sudoku6.timerecord.easy.compare"
#define GK_CATEGORY_VERYEASY_COM    @"grp.sudoku6.timerecord.veryeasy.compare"
#define GK_CATEGORY_VERYHARD_SUM    @"grp.sudoku6.timerecord.veryhard.sum"
#define GK_CATEGORY_HARD_SUM        @"grp.sudoku6.timerecord.hard.sum"
#define GK_CATEGORY_NORMAL_SUM      @"grp.sudoku6.timerecord.normal.sum"
#define GK_CATEGORY_EASY_SUM        @"grp.sudoku6.timerecord.easy.sum"
#define GK_CATEGORY_VERYEASY_SUM    @"grp.sudoku6.timerecord.veryeasy.sum"
#define GK_CATEGORY_VERYHARD_CAL    @"grp.sudoku6.timerecord.veryhard.calcu"
#define GK_CATEGORY_HARD_CAL        @"grp.sudoku6.timerecord.hard.calcu"
#define GK_CATEGORY_NORMAL_CAL      @"grp.sudoku6.timerecord.normal.calcu"
#define GK_CATEGORY_EASY_CAL        @"grp.sudoku6.timerecord.easy.calcu"
#define GK_CATEGORY_VERYEASY_CAL    @"grp.sudoku6.timerecord.veryeasy.calcu"
#define GK_CATEGORY_CLEAR10         @"grp.sudoku9.clear.10"
#define GK_CATEGORY_CLEAR100        @"grp.sudoku9.clear.100"
#define GK_CATEGORY_CLEAR1000       @"grp.sudoku9.clear.1000"
#endif


/////////////////Geunwon,Mo : GameCenter 추가 start /////////////
+ (BOOL) isGameCenterAvailable ; //게임센터가 사용가능하지 알아보는 메소드
+ (BOOL) isGameCenterLogined;
+ (void) connectGameCenter:(MainViewController*) controller; //게임센터에 접속하는 메소드
+ (NSInteger) getRanking:(NSString*) category rank:(NSInteger*)rank value:(NSInteger*)value;
+ (NSInteger) getTotalScoreRanking:(NSInteger*)rank value:(NSInteger*)value;
+ (void) sendScoreToGameCenter:(int)_score; //게임센터서버에 점수 보내는 메소드
+ (void) sendBestTimeToGameCenter:(SUDOKUTYPE)type level:(NSInteger)level besttime:(NSInteger)num;
+ (void) sendAchievementWithIdentifier: (NSString*) identifier percentComplete: (float) percent;//게임센터서버에 목표달성 보내는 메소드
+ (void) sendAchievementClearGame:(NSInteger)cleargame;
+ (void) resetAchievements; //테스트용으로 목표달성도를 리셋하는 메소드
/////////////////Geunwon,Mo : GameCenter 추가 end   /////////////
+ (NSString*) getLevelCategory:(SUDOKUTYPE)type level:(NSInteger)level;
+ (NSString*) getPointCategory;


@end
