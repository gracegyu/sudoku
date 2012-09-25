//
//  SudokuNum.h
//  SudokuHelper
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
	NSMutableArray	*nums;
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
- (NSInteger) getCellNum:(NSInteger)x y:(NSInteger)y;
- (BOOL) fixedByUser:(NSInteger)x y:(NSInteger)y;
- (BOOL) setCellAuto:(NSInteger)handy;
- (BOOL) setCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (BOOL) setCellCheck:(NSString*)str xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (BOOL) setCellUserFixed:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (NSString*) strDelNum:(NSString*)str ucNum:(unichar)ucNum;
- (NSString*) getCellNumX:(NSInteger)xPos yPos:(NSInteger)yPos;
+ (BOOL) fixedByUser:(NSString*)str;
+ (BOOL) fixedByAuto:(NSString*)str;
- (void) clearCell;
- (void) editCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos;
- (void) printNums;
- (void) saveData;
- (void) loadData;
- (CGPoint) undoSet:(NSInteger)num;
- (void) countCell;
   
@end
