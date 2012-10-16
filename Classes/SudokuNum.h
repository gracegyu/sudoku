//
//  SudokuNum.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SudokuMap.h"

#define kSudokuNum		@"sudokunum"
#define kSudokuTrack	@"sudokutrack"

@interface SudokuNum : NSObject 
{
    NSInteger       size;
//	NSMutableArray	*nums;
    
	char			defaultMemo[9+1];
	char			memo[9][9][9+1];//
//    NSInteger       memo[9][9];		// bit 연산
	NSInteger		memonum[9][9];	// 메모 갯수
    NSInteger       puzzle[9][9];   // 0, 1~9 (User fix) *
    NSInteger       answer[9][9];   // 0, 1~9 (Auto fix) ~
	/////////// 메모 개수 처리..........
	NSInteger		foundSingle;
	NSInteger		foundUnique;
	NSInteger		foundLoop;
	NSInteger		foundFail;
	NSInteger		countBack;
	NSInteger		sumBack;
	NSInteger		countFunc;
    
    
    SudokuMap       *map;
	NSString		*strUndo;
	BOOL			bOkSetCell;
	BOOL			bOkAutoSet;
	NSInteger		numSetCell;
	
	NSInteger		countUserFixed;
	NSInteger		countAutoFixed;
	NSInteger		countNotFixed;
    NSInteger       countHandyTryFailed;
    
    NSInteger       numBackTracking;
	
	// 숫자 array 로 변환
#ifdef GTSUDOKU
    NSInteger       arrGT[3][3];
    NSInteger       wGT;
    NSInteger       hGT;
#endif
    
}

@property (nonatomic, assign) NSMutableArray	*nums;
@property (nonatomic, retain) NSString			*strUndo;
@property BOOL bOkSetCell;
@property BOOL bOkAutoSet;
@property NSInteger		countUserFixed;
@property NSInteger		countAutoFixed;
@property NSInteger		countNotFixed;

- (void) initPuzzle:(NSInteger)sizePuzzle defmap:(BOOL)defmap;
- (NSInteger) getCellSize;
- (SudokuMap*) getMap;
- (NSInteger) randNum:(NSInteger) num;
//////////////////////////////////////////////////////////////////////////
- (NSInteger) getPuzzleNum:(NSInteger)x y:(NSInteger)y;
- (void) setPuzzleNum:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (NSInteger) getAnswerNum:(NSInteger)x y:(NSInteger)y;
- (void) setAnswerNum:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) setDefaultMemo:(NSInteger)x y:(NSInteger)y;
- (BOOL) isMemoed:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (BOOL) isEmptyMemo:(NSInteger)x y:(NSInteger)y;
- (void) addMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (BOOL) delMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (NSInteger) getUniqueMemo:(NSInteger)x y:(NSInteger)y;
- (NSInteger) getRandomMemo:(NSInteger)x y:(NSInteger)y;
//////////////////////////////////////////////////////////////////////////



- (BOOL) setCellAuto:(NSInteger)handy;
- (BOOL) setCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (BOOL) setCellPuzzleCheck:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (BOOL) setCellAnswerCheck:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (BOOL) setCellCheck:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (BOOL) setCellUserFixed:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;



- (void) clearCell;
- (void) editCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (void) printNums;
- (void) saveData;
- (void) loadData;
- (CGPoint) undoSet:(NSInteger)num;
- (void) countCell;
- (void) initGTSudoku;

+ (BOOL) insertNumToStr:(char*)str num:(NSInteger)num;
+ (BOOL) deleteNumFromStr:(char*)str num:(NSInteger)num;

@end


SudokuNum* sudokuNumGenerate(NSInteger level, NSInteger sizePuzzle, BOOL bSettingDefMap);


