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

@interface SudokuGame : NSObject {
	NSInteger		gameLevel;			// Game level 1(very hard), 2, 3, 4, 5(easy)
	NSTimeInterval	startTime;			// Start game time (~1970)
	NSTimeInterval	lastTime;			// Last game time (~1970)
	NSTimeInterval	gameTime;			// Game time (seconds)
	BOOL			gameFinished;		// 0, 1
	NSInteger		puzzleNums[9][9];	// Puzzle num (9x9 0~9, 0 means blank) - 문제
	NSInteger		answerNums[9][9];	// Puzzle num (9x9 0~9, 0 means blank) - 정답
	NSInteger		fixNums[9][9];		// User decided num (9x9 1~9, beside Puzzle num) 
	char			memoNums[9][9][9+1];// 
	NSString*		strUndo;			// x,y,num(0~9) (3bytes), 0 is del

	NSInteger		countBlank;
	NSInteger		countFixNums;
	NSInteger		countHint;			// Hint 가능 수
}

@property NSInteger		gameLevel;			
@property NSTimeInterval	startTime;			
@property NSTimeInterval	lastTime;			
@property NSTimeInterval	gameTime;			
@property BOOL			gameFinished;
@property (nonatomic, retain) NSString*		strUndo;
@property NSInteger		countBlank;
@property NSInteger		countFixNums;
@property NSInteger		countHint;

// Create Game : Level
// 

- (id)initWithSudokuNum:(SudokuNum*)sudoku;
- (NSInteger) getPuzzleNums:(NSInteger)x y:(NSInteger)y;
- (BOOL) isPuzzleNum:(NSInteger)x y:(NSInteger)y;
- (NSInteger) getFixNums:(NSInteger)x y:(NSInteger)y;
- (NSInteger) getDisplayNums:(NSInteger)x y:(NSInteger)y;
- (void) setHintNum:(NSInteger)x y:(NSInteger)y;
- (void) setFixNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) cancelFixNums:(NSInteger)x y:(NSInteger)y;
- (char*) getMemoNums:(NSInteger)x y:(NSInteger)y;
- (BOOL) beMemoNums:(NSInteger)num  x:(NSInteger)x y:(NSInteger)y;
- (void) addMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) delMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) revertMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) clearMemoNums:(NSInteger)x y:(NSInteger)y;
- (void) clearAllNums;
- (NSInteger) clearGame;
- (void) saveData;
+ (SudokuGame*) loadData;

+ (void) get9x9Nums:(char*)str	nums:(NSInteger*)nums;
+ (void) set9x9Nums:(NSString *)str	nums:(NSInteger*)nums;
+ (void) get9x9Strs:(char*)str	strs:(char*)strs;
+ (void) set9x9Strs:(NSString *)str	strs:(char*)strs;

- (NSInteger) add1sec;
- (NSInteger) countBlankCells;
- (NSInteger) countFixCells;


- (void) addUndoLog:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (CGPoint) runUndo;

@end
