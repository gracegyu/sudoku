//
//  SudokuGame.h
//  sudoku
//
//  Created by Raymond Jeon on 10. 7. 23..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SudokuNum.h"
#import "Constants.h"
#import "SudokuUndo.h"
#import "SudokuBoard.h"
#import "KillerMap.h"




@interface SudokuGame : NSObject {      // 스도쿠 게임 운영
    NSInteger       size;
    SUDOKUTYPE      sudokuType;
	GAMELEVEL		gameLevel;			// Game level 1(very hard), 2, 3, 4, 5(easy)
	NSTimeInterval	startTime;			// Start game time (~1970)
	NSTimeInterval	lastTime;			// Last game time (~1970)
	NSTimeInterval	gameTime;			// Game time (seconds)
	NSTimeInterval	hintTime;			// Hint add time (seconds)
	
	BOOL			isGameFinished;		// 0, 1
    NSInteger       mapNums[MAXMAPSIZE][MAXMAPSIZE];		// Map num (9x9 1~9
	NSInteger		puzzleNums[MAXMAPSIZE][MAXMAPSIZE];	// Puzzle num (9x9 0~9, 0 means blank) - 문제
	NSInteger		answerNums[MAXMAPSIZE][MAXMAPSIZE];	// Puzzle num (9x9 0~9, 0 means 보여지는 숫자) - 정답
	NSInteger		fixNums[MAXMAPSIZE][MAXMAPSIZE];		// User decided num (9x9 1~9, beside Puzzle num) 
	char			memoNums[MAXMAPSIZE][MAXMAPSIZE][MAXMAPSIZE+1];// 
    SudokuUndo      *sudokuUndo;
	SudokuMap       *map;
	KillerMap		*kmap;

	NSInteger		countBlank;
	NSInteger		countFixNums;
	NSInteger		countHint;			// Hint 가능 수
	
	BOOL			bAutoMemo;			// AutoMemoMode;
	BOOL			bAutoMemoUndoLog;
    
    NSInteger       countNums[MAXMAPSIZE];
}

@property NSInteger         size;
@property SUDOKUTYPE		sudokuType;
@property GAMELEVEL			gameLevel;
@property NSTimeInterval	startTime;
@property NSTimeInterval	lastTime;			
@property NSTimeInterval	gameTime;
@property NSTimeInterval	hintTime;
@property BOOL			isGameFinished;
@property (nonatomic, retain) SudokuUndo      *sudokuUndo;
@property NSInteger		countBlank;
@property NSInteger		countFixNums;
@property NSInteger		countHint;
@property BOOL			bAutoMemo;
@property (nonatomic, retain) KillerMap		*kmap;


// Create Game : Level
// 

- (id) initWithSudokuBoard:(SudokuBoard*)sudoku type:(SUDOKUTYPE)type level:(GAMELEVEL)level automemo:(BOOL)automemo;
- (id)initWithSudokuNum:(SudokuNum*)sudoku type:(SUDOKUTYPE)type level:(GAMELEVEL)level automemo:(BOOL)automemo;
- (BOOL) isSameMap:(NSInteger)x y:(NSInteger)y x2:(NSInteger)x2 y2:(NSInteger)y2;
- (BOOL) isSameColor:(NSInteger)x y:(NSInteger)y x2:(NSInteger)x2 y2:(NSInteger)y2;
- (NSInteger) getMapNums:(NSInteger)x y:(NSInteger)y;
- (NSInteger) getPuzzleNums:(NSInteger)x y:(NSInteger)y;
- (NSInteger) getAnswerNums:(NSInteger)x y:(NSInteger)y;
- (NSInteger) getDisplayNum:(NSInteger)x y:(NSInteger)y;
- (BOOL) isPuzzleNum:(NSInteger)x y:(NSInteger)y;
- (NSInteger) getFixNums:(NSInteger)x y:(NSInteger)y;
- (void) setHintNum:(NSInteger)x y:(NSInteger)y;
- (void) setFixNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) cancelFixNums:(NSInteger)x y:(NSInteger)y;
- (BOOL) emptyMemo:(NSInteger)x y:(NSInteger)y;
- (NSInteger) smallestMemo:(NSInteger)x y:(NSInteger)y;
- (NSInteger) biggestMemo:(NSInteger)x y:(NSInteger)y;
- (char*) getMemoNums:(NSInteger)x y:(NSInteger)y;
- (BOOL) beMemoNums:(NSInteger)num  x:(NSInteger)x y:(NSInteger)y;
- (void) addMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (BOOL) setMemoNumsForAutoMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) delMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y bUndo:(BOOL)bUndo;
- (void) delMemoNumsForAutoMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) revertMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) clearMemoNums:(NSInteger)x y:(NSInteger)y;
- (void) clearAllNums;
- (void) replayGames;
- (NSInteger) clearGameCheckAllCells:(NSInteger*)wrongSums;
- (BOOL) isWrongSumCellXY:(NSInteger)xPos yPos:(NSInteger)yPos;
- (NSInteger) countCellInSum:(NSInteger)xPos yPos:(NSInteger)yPos;
- (void) saveData;
+ (SudokuGame*) loadData;

+ (void) get9x9Nums:(char*)str	size:(NSInteger)size   nums:(NSInteger*)nums;
+ (void) set9x9Nums:(NSString *)str	size:(NSInteger)size nums:(NSInteger*)nums;
+ (void) get9x9Strs:(char*)str	size:(NSInteger)size    strs:(char*)strs;
+ (void) set9x9Strs:(NSString *)str	size:(NSInteger)size strs:(char*)strs;

- (NSInteger) updateGameElapsedTime;
- (NSInteger) updateHintElapsedTime;
- (void) resetHintTime;
- (NSInteger) countBlankCells;
- (NSInteger) countFixCells;
- (BOOL)conflictNumber:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (BOOL) conflictMemoCompare:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;

- (void) addUndoLog:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (CGPoint) runUndo;
- (CGPoint) runRedo;

- (BOOL) checkGreatThan:(NSInteger)xPos y:(NSInteger)yPos;

- (void) bonusGameElapsedTime;
- (void) bonusHintElapsedTime;
- (void) readyToReplay;

- (void) calcuCountNum;
- (NSInteger) getCountNum:(NSInteger)num;

+ (NSString*) getSudokuTypeName:(SUDOKUTYPE)type;

@end
