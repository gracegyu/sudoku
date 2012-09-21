//
//  SudokuNum.h
//  SudokuHelper
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSudokuNum		@"sudokunum"
#define kSudokuTrack	@"sudokutrack"

@interface SudokuNum : NSObject // 스도쿠 퍼즐 생성기
{
	NSMutableArray	*nums;
	NSString		*strUndo;
	BOOL			bOkSetCell;
	BOOL			bOkAutoSet;
	NSInteger		numSetCell;
	
	NSInteger		countUserFixed;
	NSInteger		countAutoFixed;
	NSInteger		countNotFixed;
	
	// 숫자 array 로 변환
}

@property (nonatomic, assign) NSMutableArray	*nums;
@property (nonatomic, retain) NSString			*strUndo;
@property BOOL bOkSetCell;
@property BOOL bOkAutoSet;
@property NSInteger		countUserFixed;
@property NSInteger		countAutoFixed;
@property NSInteger		countNotFixed;


- (BOOL) setCellAuto:(NSInteger)handy;
- (NSString*) getCellStr:(NSInteger)x y:(NSInteger)y;
+ (BOOL) isFixedByUser:(NSString*)str;
- (void) printNums;
- (void) countCell;
   
@end
