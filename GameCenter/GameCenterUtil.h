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

#ifdef GTSUDOKU
#ifdef SUDOKU9
#define GK_CATEGORY_POINT       @"grp.gtsudoku9.points"
#define GK_CATEGORY_VERYHARD    @"grp.gtsudoku9.timerecord.veryhard"
#define GK_CATEGORY_HARD        @"grp.gtsudoku9.timerecord.hard"
#define GK_CATEGORY_NORMAL      @"grp.gtsudoku9.timerecord.normal"
#define GK_CATEGORY_EASY        @"grp.gtsudoku9.timerecord.easy"
#define GK_CATEGORY_VERYEASY    @"grp.gtsudoku9.timerecord.veryeasy"
#define GK_CATEGORY_VERYHARD_A  @"grp.gtsudoku9.timerecord.veryhard.auto"
#define GK_CATEGORY_HARD_A      @"grp.gtsudoku9.timerecord.hard.auto"
#define GK_CATEGORY_NORMAL_A    @"grp.gtsudoku9.timerecord.normal.auto"
#define GK_CATEGORY_EASY_A      @"grp.gtsudoku9.timerecord.easy.auto"
#define GK_CATEGORY_VERYEASY_A  @"grp.gtsudoku9.timerecord.veryeasy.auto"
#define GK_CATEGORY_CLEAR10     @"grp.gtsudoku9.clear.10"
#define GK_CATEGORY_CLEAR100    @"grp.gtsudoku9.clear.100"
#define GK_CATEGORY_CLEAR1000   @"grp.gtsudoku9.clear.1000"
#else // SODKU6
#define GK_CATEGORY_POINT       @"grp.gtsudoku6.points"
#define GK_CATEGORY_VERYHARD    @"grp.gtsudoku6.timerecord.veryhard"
#define GK_CATEGORY_HARD        @"grp.gtsudoku6.timerecord.hard"
#define GK_CATEGORY_NORMAL      @"grp.gtsudoku6.timerecord.normal"
#define GK_CATEGORY_EASY        @"grp.gtsudoku6.timerecord.easy"
#define GK_CATEGORY_VERYEASY    @"grp.gtsudoku6.timerecord.veryeasy"
#define GK_CATEGORY_VERYHARD_A  @"grp.gtsudoku6.timerecord.veryhard.auto"
#define GK_CATEGORY_HARD_A      @"grp.gtsudoku6.timerecord.hard.auto"
#define GK_CATEGORY_NORMAL_A    @"grp.gtsudoku6.timerecord.normal.auto"
#define GK_CATEGORY_EASY_A      @"grp.gtsudoku6.timerecord.easy.auto"
#define GK_CATEGORY_VERYEASY_A  @"grp.gtsudoku6.timerecord.veryeasy.auto"
#define GK_CATEGORY_CLEAR10     @"grp.gtsudoku6.clear.10"
#define GK_CATEGORY_CLEAR100    @"grp.gtsudoku6.clear.100"
#define GK_CATEGORY_CLEAR1000   @"grp.gtsudoku6.clear.1000"
#endif

#elif (defined KILLERSUDOKU)

#ifdef SUDOKU9
#define GK_CATEGORY_POINT       @"grp.ksudoku9.points"
#define GK_CATEGORY_VERYHARD    @"grp.ksudoku9.timerecord.veryhard"
#define GK_CATEGORY_HARD        @"grp.ksudoku9.timerecord.hard"
#define GK_CATEGORY_NORMAL      @"grp.ksudoku9.timerecord.normal"
#define GK_CATEGORY_EASY        @"grp.ksudoku9.timerecord.easy"
#define GK_CATEGORY_VERYEASY    @"grp.ksudoku9.timerecord.veryeasy"
#define GK_CATEGORY_VERYHARD_A  @"grp.ksudoku9.timerecord.veryhard.auto"
#define GK_CATEGORY_HARD_A      @"grp.ksudoku9.timerecord.hard.auto"
#define GK_CATEGORY_NORMAL_A    @"grp.ksudoku9.timerecord.normal.auto"
#define GK_CATEGORY_EASY_A      @"grp.ksudoku9.timerecord.easy.auto"
#define GK_CATEGORY_VERYEASY_A  @"grp.ksudoku9.timerecord.veryeasy.auto"
#define GK_CATEGORY_CLEAR10     @"grp.ksudoku9.clear.10"
#define GK_CATEGORY_CLEAR100    @"grp.ksudoku9.clear.100"
#define GK_CATEGORY_CLEAR1000   @"grp.ksudoku9.clear.1000"
#else // SUDOKU6
#define GK_CATEGORY_POINT       @"grp.ksudoku9.points"
#define GK_CATEGORY_VERYHARD    @"grp.ksudoku6.timerecord.veryhard"
#define GK_CATEGORY_HARD        @"grp.ksudoku6.timerecord.hard"
#define GK_CATEGORY_NORMAL      @"grp.ksudoku6.timerecord.normal"
#define GK_CATEGORY_EASY        @"grp.ksudoku6.timerecord.easy"
#define GK_CATEGORY_VERYEASY    @"grp.ksudoku6.timerecord.veryeasy"
#define GK_CATEGORY_VERYHARD_A  @"grp.ksudoku6.timerecord.veryhard.auto"
#define GK_CATEGORY_HARD_A      @"grp.ksudoku6.timerecord.hard.auto"
#define GK_CATEGORY_NORMAL_A    @"grp.ksudoku6.timerecord.normal.auto"
#define GK_CATEGORY_EASY_A      @"grp.ksudoku6.timerecord.easy.auto"
#define GK_CATEGORY_VERYEASY_A  @"grp.ksudoku6.timerecord.veryeasy.auto"
#define GK_CATEGORY_CLEAR10     @"grp.ksudoku9.clear.10"
#define GK_CATEGORY_CLEAR100    @"grp.ksudoku9.clear.100"
#define GK_CATEGORY_CLEAR1000   @"grp.ksudoku9.clear.1000"
#endif


#else // Sudoku
#ifdef SUDOKU9
#define GK_CATEGORY_POINT       @"grp.sudoku9.points"
#define GK_CATEGORY_VERYHARD    @"grp.sudoku9.timerecord.veryhard"
#define GK_CATEGORY_HARD        @"grp.sudoku9.timerecord.hard"
#define GK_CATEGORY_NORMAL      @"grp.sudoku9.timerecord.normal"
#define GK_CATEGORY_EASY        @"grp.sudoku9.timerecord.easy"
#define GK_CATEGORY_VERYEASY    @"grp.sudoku9.timerecord.veryeasy"
#define GK_CATEGORY_VERYHARD_A  @"grp.sudoku9.timerecord.veryhard.auto"
#define GK_CATEGORY_HARD_A      @"grp.sudoku9.timerecord.hard.auto"
#define GK_CATEGORY_NORMAL_A    @"grp.sudoku9.timerecord.normal.auto"
#define GK_CATEGORY_EASY_A      @"grp.sudoku9.timerecord.easy.auto"
#define GK_CATEGORY_VERYEASY_A  @"grp.sudoku9.timerecord.veryeasy.auto"
#define GK_CATEGORY_CLEAR10     @"grp.sudoku9.clear.10"
#define GK_CATEGORY_CLEAR100    @"grp.sudoku9.clear.100"
#define GK_CATEGORY_CLEAR1000   @"grp.sudoku9.clear.1000"
#else // SUDOKU6
#define GK_CATEGORY_POINT       @"grp.sudoku9.points"
#define GK_CATEGORY_VERYHARD    @"grp.sudoku6.timerecord.veryhard"
#define GK_CATEGORY_HARD        @"grp.sudoku6.timerecord.hard"
#define GK_CATEGORY_NORMAL      @"grp.sudoku6.timerecord.normal"
#define GK_CATEGORY_EASY        @"grp.sudoku6.timerecord.easy"
#define GK_CATEGORY_VERYEASY    @"grp.sudoku6.timerecord.veryeasy"
#define GK_CATEGORY_VERYHARD_A  @"grp.sudoku6.timerecord.veryhard.auto"
#define GK_CATEGORY_HARD_A      @"grp.sudoku6.timerecord.hard.auto"
#define GK_CATEGORY_NORMAL_A    @"grp.sudoku6.timerecord.normal.auto"
#define GK_CATEGORY_EASY_A      @"grp.sudoku6.timerecord.easy.auto"
#define GK_CATEGORY_VERYEASY_A  @"grp.sudoku6.timerecord.veryeasy.auto"
#define GK_CATEGORY_CLEAR10     @"grp.sudoku9.clear.10"
#define GK_CATEGORY_CLEAR100    @"grp.sudoku9.clear.100"
#define GK_CATEGORY_CLEAR1000   @"grp.sudoku9.clear.1000"
#endif
#endif // GTSUDOKU

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
+ (NSString*) getPointCategory;


@end
