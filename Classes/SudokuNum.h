//
//  SudokuNum.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SudokuMap.h"
#import "KillerMap.h"
#import "Constants.h"

#define kSudokuNum		@"sudokunum"
#define kSudokuTrack	@"sudokutrack"

@interface SudokuNum : NSObject 
{
    NSInteger       size;
    SUDOKUTYPE      sudokuType;
    
//	NSMutableArray	*nums;
    
	char			defaultMemo[MAXMAPSIZE+1];
	char			memo[MAXMAPSIZE][MAXMAPSIZE][MAXMAPSIZE+1];
	NSInteger		memonum[MAXMAPSIZE][MAXMAPSIZE];	// 메모 갯수
    NSInteger       puzzle[MAXMAPSIZE][MAXMAPSIZE];   // 0, 1~9|12|16 (User fix) *
    NSInteger       answer[MAXMAPSIZE][MAXMAPSIZE];   // 0, 1~9|12|16 (Auto fix) ~
	/////////// 메모 개수 처리..........
	NSInteger		foundSingle;
	NSInteger		foundUnique;
	NSInteger		foundLoop;
	NSInteger		foundFail;
	NSInteger		countBack;
	NSInteger		sumBack;
	NSInteger		countFunc;
    
    
    SudokuMap       *map;
	KillerMap		*kmap;      //for Killer/Calcu Sudoku

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

    NSInteger       arrGT[3][3];    // for GTSudoku
    NSInteger       wGT;
    NSInteger       hGT;

    
}

@property (nonatomic, assign) NSMutableArray	*nums;
@property (nonatomic, retain) NSString			*strUndo;
@property BOOL bOkSetCell;
@property BOOL bOkAutoSet;
@property NSInteger		countUserFixed;
@property NSInteger		countAutoFixed;
@property NSInteger		countNotFixed;


- (NSInteger) getCellSize;
- (SudokuMap*) getMap;
- (KillerMap*) getKillerMap;
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




- (BOOL) setCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (BOOL) setCellPuzzleCheck:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (BOOL) setCellAnswerCheck:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (BOOL) setCellCheck:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (BOOL) setCellUserFixed:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;



//- (void) clearCell;
- (void) editCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (void) printNums;
- (void) saveData;
- (void) loadData;
- (CGPoint) undoSet:(NSInteger)num;
- (void) countCell;


+ (BOOL) insertNumToStr:(char*)str num:(NSInteger)num;
+ (BOOL) deleteNumFromStr:(char*)str num:(NSInteger)num;

@end


SudokuNum* sudokuNumGenerate(SUDOKUTYPE type, NSInteger level, NSInteger sizePuzzle, BOOL bSettingDefMap);


