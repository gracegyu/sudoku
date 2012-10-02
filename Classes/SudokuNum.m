//
//  SudokuNum.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SudokuNum.h"
#import "Constants.h"


@implementation SudokuNum

@synthesize nums;
@synthesize strUndo;
@synthesize bOkSetCell;
@synthesize bOkAutoSet;
@synthesize countUserFixed;
@synthesize countAutoFixed;
@synthesize countNotFixed;



- (void)dealloc {
	[strUndo release];
    [map release];
	
	[super dealloc];
}

- (NSInteger) getCellSize
{
    return size;
}

- (void) initMap
{
    map = [[SudokuMap alloc] initWithSize:size];
}

- (void) initNums
{
	NSLog(@"initNums");
	NSString *str;
    
    NSString *strInit = [[[NSString alloc] initWithString:@"123456789ABCDEFG"] substringToIndex:size];
    
	nums = [NSMutableArray arrayWithCapacity:MAXMAPSIZE+1];
	
	for (int i=0; i<MAXMAPSIZE; i++) {
		NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:MAXMAPSIZE+1];
		for (int j=0; j<MAXMAPSIZE; j++) {
			str = [[NSString alloc] initWithString:strInit];
			[numbers addObject:str];
			[str release];
		}
		[nums addObject:numbers];
	}
	[nums retain];
    
//    [strInit release]; crash남
}

- (void) initNumsUndo {
    [self initNums];
    strUndo = [[NSString alloc] initWithString:@""];
    bOkSetCell = NO;
}

// 최초에 한번만 초기화
- (void) initPuzzle:(NSInteger)sizePuzzle
{
    numBackTracking = BACKTRACKING_START;
    countHandyTryFailed = 0;
    size = sizePuzzle;
    
    [self initMap];
    [self initNumsUndo];
}

- (id) init {

	if((self = [super init])) {
		NSLog(@"init");
	}
	return self;
}

- (SudokuMap*) getMap
{
    return map;
}

- (NSInteger) getCellNum:(NSInteger)x y:(NSInteger)y
{
    NSMutableArray *array = self.nums;
    NSString* str = [[array objectAtIndex:x] objectAtIndex:y];
    return [str integerValue];
}

- (BOOL) fixedByUser:(NSInteger)x y:(NSInteger)y;
{
	NSMutableArray *array = self.nums;
	NSString *str = [[array objectAtIndex:x] objectAtIndex:y];
    
	if (str.length != 2)
		return NO;
	
	NSRange range;
	range = [str rangeOfString:@"*"];
	if (range.location == NSNotFound)
		return NO;
	
	return YES;
	
}

- (BOOL) fixedByAuto:(NSInteger)x y:(NSInteger)y;
{
	NSMutableArray *array = self.nums;
	NSString *str = [[array objectAtIndex:x] objectAtIndex:y];
    
	if (str.length != 2)
		return NO;
	
	NSRange range;
	range = [str rangeOfString:@"~"];
	if (range.location == NSNotFound)
		return NO;
	
	return YES;
}

- (NSString*) strDelNum:(NSString*)str ucNum:(unichar)ucNum
{
	NSString *delStr = [[NSString alloc] initWithFormat:@"%c", ucNum];
	NSString *newStr = [str stringByReplacingOccurrencesOfString:delStr withString:@""];
	
	[delStr release];
	
	return newStr;
}


- (void) findFixedNum
{
	if (bOkAutoSet == NO)
		return;	
	
	NSMutableArray *array = self.nums;	
	int x,y;
	NSString *s;
	
	for (x=0; x<size; x++)
	{
		for (y=0; y<size; y++)
		{
			s = [[array objectAtIndex:x] objectAtIndex:y];
			if (s.length == 1)
			{
				NSString *strSet = [[NSString alloc] initWithFormat:@"%@~", s];
				[self setCellCheck:strSet xPos:x yPos:y];
				[strSet release];				
				if (bOkAutoSet == NO)
					return;
			}
		}		
	}
}

+ (BOOL) fixedByUser:(NSString*)str
{
	if (str.length != 2)
		return NO;
	
	NSRange range;
	range = [str rangeOfString:@"*"];
	if (range.location == NSNotFound)
		return NO;
	
	return YES;
	
}

+ (BOOL) fixedByAuto:(NSString*)str
{
	if (str.length != 2)
		return NO;
	
	NSRange range;
	range = [str rangeOfString:@"~"];
	if (range.location == NSNotFound)
		return NO;
	
	return YES;
}


- (void) findUniqueNumX:(NSString*)str xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSMutableArray *array = self.nums;	
	int x,y,k;
	int	countFound;
	int posFirstFound;
	NSString *s;
	NSString *strNum;
	NSRange range;
	
	for (x=0; x<size && bOkAutoSet; x++)
	{
		for (k=1; k<=size && bOkAutoSet; k++)
		{
			countFound = 0;
			posFirstFound = -1;
			
			strNum = [[NSString alloc] initWithFormat:@"%d", k];
			
			for (y=0; y<size && bOkAutoSet; y++)
			{
				s = [[array objectAtIndex:x] objectAtIndex:y];
				range = [s rangeOfString:strNum];
				if (range.location != NSNotFound)
				{
					countFound++;
					if (countFound == 1)
					{
						posFirstFound = y;
					}
				}			
			}
			if (countFound == 1)
			{
				y = posFirstFound;
				s = [[array objectAtIndex:x] objectAtIndex:y];
				
				// * ~는 아니어야 함
				if ([SudokuNum fixedByUser:s] == NO && [SudokuNum fixedByAuto:s] == NO)
				{
					NSString *strSet = [[NSString alloc] initWithFormat:@"%d~", k];
					[self setCellCheck:strSet xPos:x yPos:y];
					[strSet release];						
				}

			}
			
			[strNum release];
		}		
	}
}

- (void) findUniqueNumY:(NSString*)str xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSMutableArray *array = self.nums;	
	int x,y,k;
	int	countFound;
	int posFirstFound;
	NSString *s;
	NSString *strNum;
	NSRange range;
	
	for (y=0; y<size && bOkAutoSet; y++)
	{
		for (k=1; k<=size && bOkAutoSet; k++)
		{
			countFound = 0;
			posFirstFound = -1;
			
			strNum = [[NSString alloc] initWithFormat:@"%d", k];
			
			for (x=0; x<size && bOkAutoSet; x++)
			{
				s = [[array objectAtIndex:x] objectAtIndex:y];
				range = [s rangeOfString:strNum];
				if (range.location != NSNotFound)
				{
					countFound++;
					if (countFound == 1)
					{
						posFirstFound = x;
					}
				}			
			}
			if (countFound == 1)
			{
				x = posFirstFound;
				s = [[array objectAtIndex:x] objectAtIndex:y];
				
				// * or ~는 아니어야 함	
				range = [s rangeOfString:@"*"];
				if (range.location == NSNotFound)
				{
					range = [s rangeOfString:@"~"];
					if (range.location == NSNotFound)
					{
						NSString *strSet = [[NSString alloc] initWithFormat:@"%d~", k];
						[self setCellCheck:strSet xPos:x yPos:y];
						[strSet release];						
					}					
				}
			}
			
			[strNum release];
		}		
	}
}


- (void) findUniqueNumXY:(NSString*)str xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSMutableArray *array = self.nums;	
	int x,y,k;//,i,j;
	int	countFound;
	int posXFirstFound;
	int posYFirstFound;
	NSString *s;
	NSString *strNum;
	NSRange range;
    NSInteger numMap = [map getMapNum:xPos y:yPos];

	for (k=1; k<=size && bOkAutoSet; k++)
	{
		countFound = 0;
		posXFirstFound = -1;
		posYFirstFound = -1;
		
		strNum = [[NSString alloc] initWithFormat:@"%d", k];

		for (x=0; x<size && bOkAutoSet; x++)
		{
			for (y=0; y<size && bOkAutoSet; y++)
			{
                if (numMap == [map getMapNum:x y:y]) // 작은 블록 내의 칸인가?
                {
                    s = [[array objectAtIndex:x] objectAtIndex:y];
                    range = [s rangeOfString:strNum];
                    if (range.location != NSNotFound)
                    {
                        countFound++;
                        if (countFound == 1)
                        {
                            posXFirstFound = x;
                            posYFirstFound = y;
                        }
                    }
                }
			}
		}
		if (countFound == 1)
		{
			x = posXFirstFound;
			y = posYFirstFound;
			s = [[array objectAtIndex:x] objectAtIndex:y];
			
			// * or ~는 아니어야 함	
			range = [s rangeOfString:@"*"];
			if (range.location == NSNotFound)
			{
				range = [s rangeOfString:@"~"];
				if (range.location == NSNotFound)
				{
					NSString *strSet = [[NSString alloc] initWithFormat:@"%d~", k];
					[self setCellCheck:strSet xPos:x yPos:y];
					[strSet release];						
				}					
			}
		}
		
		[strNum release];
	}
}


- (void) findUniqueNum:(NSString*)str xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	if (bOkAutoSet == NO)
		return;	
	
	[self findUniqueNumX:str xPos:xPos yPos:yPos];
	[self findUniqueNumY:str xPos:xPos yPos:yPos];
	[self findUniqueNumXY:str xPos:xPos yPos:yPos];
}

- (NSInteger) countUserFixedNumX:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSMutableArray *array = self.nums;	
	int x = xPos;
	int y = yPos;
	NSInteger num = 0;
	NSString *str;

	for (y=0; y<size; y++) {
		str = [[array objectAtIndex:x] objectAtIndex:y];
		if ([SudokuNum fixedByUser:str])
			num++;
	}
	NSLog(@"countUserFixedNumX(%d,%d) => %d", xPos, yPos, num);	
	return num;
}

- (NSInteger) countUserFixedNumY:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSMutableArray *array = self.nums;	
	int x = xPos;
	int y = yPos;
	NSInteger num = 0;
	NSString *str;
	
	for (x=0; x<size; x++) {
		str = [[array objectAtIndex:x] objectAtIndex:y];
		if ([SudokuNum fixedByUser:str])
			num++;
	}
	
	NSLog(@"countUserFixedNumY(%d,%d) => %d", xPos, yPos, num);	
	return num;
}
- (NSInteger) countUserFixedNumXY:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSMutableArray *array = self.nums;	
	int x = xPos;
	int y = yPos;
//	int i, j;
	NSInteger num = 0;
	NSString *str;
	
    int mapNum = [map getMapNum:xPos y:yPos];
	
	for (x=0; x<size; x++)
	{
		for (y=0; y<size; y++)
		{
            if (mapNum == [map getMapNum:x y:y])
            {
                str = [[array objectAtIndex:x] objectAtIndex:y];
                if ([SudokuNum fixedByUser:str])
                    num++;
            }
        }
	}
	NSLog(@"countUserFixedNumXY(%d,%d) => %d", xPos, yPos, num);	
	return num;
			
}


- (BOOL) setCellCheck:(NSString*)str xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSMutableArray *array = self.nums;	
	unichar c = [str characterAtIndex:0];
	int x,y;//,i,j;
	NSString *s;
	NSString *newStr;

	bOkSetCell = YES;	
	numSetCell += 1;
	
	[[array objectAtIndex:xPos] replaceObjectAtIndex:yPos withObject:str];	

	// 주변 후보 숫자 수정	
	
	for (x=0; x<size; x++) {
		if (x != xPos) {
			s = [[array objectAtIndex:x] objectAtIndex:yPos];
			newStr = [self strDelNum:s ucNum:c];
			if ([newStr length] == 0)
			{
				NSLog(@"Failed");
				bOkAutoSet = NO;
				return NO;
			}
			[[array objectAtIndex:x] replaceObjectAtIndex:yPos withObject:newStr];
//			[s release];

		}		
	}
	
	for (y=0; y<size; y++) {
		if (y != yPos) {
			s = [[array objectAtIndex:xPos] objectAtIndex:y];
			newStr = [self strDelNum:s ucNum:c];
			if ([newStr length] == 0)
			{
				NSLog(@"Failed");
				bOkAutoSet = NO;
				return NO;

			}
			[[array objectAtIndex:xPos] replaceObjectAtIndex:y withObject:newStr];
//			[s release];

		}		
	}	
	
    int mapNum = [map getMapNum:xPos y:yPos];
	
    for (x=0; x<size; x++)
    {
		for (y=0; y<size; y++)
        {
            if (mapNum == [map getMapNum:x y:y])
            {
                if (x != xPos && y != yPos)
                {
                    s = [[array objectAtIndex:x] objectAtIndex:y];
                    newStr = [self strDelNum:s ucNum:c];
                    if ([newStr length] == 0)
                    {
                        NSLog(@"Failed");
                        bOkAutoSet = NO;
                        return NO;
                        
                    }
                    
                    [[array objectAtIndex:x] replaceObjectAtIndex:y withObject:newStr];	
                }
            }
		}
	}
	
	[self findFixedNum];
	[self findUniqueNum:str xPos:xPos yPos:yPos];
	
	// http://blog.daum.net/bonwon/13666388
	
	// 1줄 쏠림 수 처리   
	// 2줄 쏠림 수 처리
	
	// CPU 많이 소유할 것으로 예상됨
	// 노출된 순환수, 숨어 있는 순환수
	// 2 순환수 처리 - 2순환 위치 나머지 칸의 순환수는 제거
	// 3 순환수 처리 - 3순환 위치 나머지 칸의 순환수는 제거
	// 4 순환수 처리 - 4순환 위치 나머지 칸의 순환수는 제거
	
	
	
	// 숨은 순환수 처리
	
	//
	
	return YES;
}

- (BOOL) validNumInCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSMutableArray *array = self.nums;	
	NSString *s;
	NSRange range;
	NSString *str;
	
	s = [[array objectAtIndex:xPos] objectAtIndex:yPos];

	range = [s rangeOfString:@"~"];
	if (range.location != NSNotFound)
	{
		return NO;	// 이미 자동세팅 값이 채워져 있어서 수정할 수 없음
	}
	
	
	range = [s rangeOfString:@"*"];
	if (range.location != NSNotFound)
	{
		str = [[NSString alloc] initWithFormat:@"%d*", num];
		range = [s rangeOfString:str];
		[str release];
		if (range.location != NSNotFound)
		{
			return NO;	// 이미 같은 값이 설정 되어 있어서 아무 일도 할 것이 없음
			
		}

		// 이전에 지정한 셀에 다른 값(0~size)을 설정하려고 함
		[self editCell:num xPos:xPos yPos:yPos];
		
		return NO;	
	}
		
	str = [[NSString alloc] initWithFormat:@"%d", num];

	range = [s rangeOfString:str];
	[str release];
	if (range.location == NSNotFound)	// 후보군의 숫자가 아님, 설정 불가능
	{
		return NO;	// 세팅 불가능한 숫자임
	}
	
	int x,y;
	NSString *str1 = [[NSString alloc] initWithFormat:@"%d*", num];
	NSString *str2 = [[NSString alloc] initWithFormat:@"%d~", num];

	for (x=0; x<size; x++)
	{
		for (y=0; y<size; y++)
		{
			if (x != xPos && y != yPos) {
				if ((x == xPos || y == yPos) ||
                    [map isSameMap:x y:y x2:xPos y2:yPos]) {
                    
                    
					s = [[array objectAtIndex:x] objectAtIndex:y];
					range = [s rangeOfString:str1];
					if (range.location != NSNotFound)		// 이미 세팅했던 것들임
					{
						[str1 release];
						[str2 release];
						return NO;
					}				
					range = [s rangeOfString:@"~"];	
					if (range.location != NSNotFound)		// 자동 계산 값이 있음
					{
						range = [s rangeOfString:str2];
						if (range.location != NSNotFound)	// 자동 계산 값과 같음
						{	
							[str1 release];
							[str2 release];
							return NO;
						}
					}				
				}
			}	
		}			
	}
	[str1 release];
	[str2 release];
	return YES;
}

- (void) addUndoLog:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
//	NSLog(@"Undo Log = %@", strUndo);
//  이미 기존의 데이터를 수정하는 것이라면 그부분은 제거

	int len = strUndo.length;
	int max = len/3;
	NSString *str;
	unichar chNum, chX, chY;
	
	for (int i=0; i<max; i++) 
	{
		chX = [strUndo characterAtIndex:i*3+1];
		chY = [strUndo characterAtIndex:i*3+2];
		
		if ((chX-'0') == xPos && (chY-'0') == yPos)
		{
			chNum = [strUndo characterAtIndex:i*3];
			// 같은 위치 발견, 앞에서 설정한 값은 제거해야 함
			str = [[NSString alloc] initWithFormat:@"%d%d%d", chNum-'0', xPos, yPos];
			NSLog(@"Undo Log remove = %@", str);
			strUndo = [strUndo stringByReplacingOccurrencesOfString:str withString: @""];
			[str release];
			break;
		}
	}	
	
/*	
	str = [[NSString alloc] initWithFormat:@"%@%d%d%d", strUndo, num, xPos, yPos];
	[strUndo release];
	strUndo = str;
	[str release];
	
*/

	str = [strUndo stringByAppendingFormat:@"%d%d%d", num, xPos, yPos];
	[strUndo release];
	strUndo = str; 
//	NSLog(@"Undo Log = %@", strUndo);
	[strUndo retain];
	
}

- (BOOL) setCellSub:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	if ([self validNumInCell:num xPos:xPos yPos:yPos] == NO)
	{
		NSLog(@"Unvalid Number Setting(num:%d, xPos:%d, yPos:%d", num, xPos, yPos);
		return NO;
	} 	
		
	NSString *str = [[NSString alloc] initWithFormat:@"%d*", num];
	BOOL bRet = [self setCellCheck:str xPos:xPos yPos:yPos];
	[str release];

	return bRet;
}

- (BOOL) setCellAuto:(NSInteger)handy;
{
	NSMutableArray *array = self.nums;	
	unsigned valRand;
	int numRandom;
	int num;
	int strRandom;
	NSInteger len;
	NSString *str;	
	
    
    // Handy 적용하다가 무한루프에 빠질 수 있음... 
	if (countNotFixed == 0) {	// last time
		for (int i=0; i<handy && countAutoFixed>0 && countHandyTryFailed < MAX_HANDYTRAYFAIL; i++) {
			valRand = arc4random();	
			numRandom = valRand % countAutoFixed;
			num = 0;
            
            // 자동Fix된 셀중에서 Random 번째의 셀을 찾는다.
			for (int y=0; y<size && num <= numRandom; y++) {
				for (int x=0; x<size && num <= numRandom; x++) {
					str = [[array objectAtIndex:x] objectAtIndex:y];
					if ([SudokuNum fixedByAuto:str] == YES) {
						if (num == numRandom) {
							unichar c = [str characterAtIndex:0];
							
							if ([self setCellUserFixed:(NSInteger)(c - '0') xPos:x yPos:y] == NO)
                            {
								i--;
                                countHandyTryFailed += 1;
                            }
						}
						num += 1;
					}			
				}
			}	
//			[self printNums];
			[self countCell];
            if (countHandyTryFailed >= MAX_HANDYTRAYFAIL)
                NSLog(@"countHandyTryFailed == MAX_HANDYTRAYFAIL");
		}		
		return NO;
	}	
	bOkAutoSet = YES;
	numSetCell = 0;
	// countNotFixed -> Random 값 만들기
	valRand = arc4random();	
	numRandom = valRand % countNotFixed;
	num = 0;

    
	for (int y=0; y<size && num <= numRandom; y++) {
		for (int x=0; x<size && num <= numRandom; x++) {
			str = [[array objectAtIndex:x] objectAtIndex:y];
			if ([SudokuNum fixedByUser:str] == NO &&
				[SudokuNum fixedByAuto:str] == NO) {
				if (num == numRandom) {
					len = [str length];
					strRandom = arc4random() % len;
					unichar c = [str characterAtIndex:strRandom];
					
                    // zzz 4x4 다시 해야 한다.
					if ([self countUserFixedNumX:x yPos:y] >= size-1 ||
						[self countUserFixedNumY:x yPos:y] >= size-1 ||
						[self countUserFixedNumXY:x yPos:y] >= size-1) {
						
                        
					} else {
						[self setCell:(NSInteger)(c - '0') xPos:x yPos:y];
					}
					
				} 
				num += 1;
			}
		}
	}	
	
	if (bOkAutoSet == NO) {
		[self undoSet:numBackTracking];
        
        numBackTracking += BACKTRACKING_INTERVAL;   // 잘못되면 Backtracking 깊이를 점점 증가시킨다.
        if (numBackTracking > BACKTRACKING_MAX)
            numBackTracking = BACKTRACKING_MAX;
	}

	
	return YES;
}

// 	~ -> *

- (BOOL) setCellUserFixed:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	if ([self countUserFixedNumX:xPos yPos:yPos] >= size-1 ||
		[self countUserFixedNumY:xPos yPos:yPos] >= size-1 ||
		[self countUserFixedNumXY:xPos yPos:yPos] >= size-1)
	{
		
		return NO;
	}
	
	NSMutableArray *array = self.nums;	
	
	NSString *str = [[NSString alloc] initWithFormat:@"%d*", num];
// only one cell check
	[[array objectAtIndex:xPos] replaceObjectAtIndex:yPos withObject:str];	

	[str release];
	
	return YES;
}



// clear를 제외한 모든 셀의 값 세팅을 여기로 와야 한다.
- (BOOL) setCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	bOkSetCell = NO;
	
	if ([self validNumInCell:num xPos:xPos yPos:yPos] == NO)
	{
		NSLog(@"Unvalid Number Setting(num:%d, xPos:%d, yPos:%d", num, xPos, yPos);
	} else {
		NSString *str = [[NSString alloc] initWithFormat:@"%d*", num];
		[self setCellCheck:str xPos:xPos yPos:yPos];
		[str release];
		[self addUndoLog:num xPos:xPos yPos:yPos];		// set undo data 
	}

	
	return bOkSetCell;
}

- (NSString*) getCellNumX:(NSInteger)xPos yPos:(NSInteger)yPos
{
	
	return [[nums objectAtIndex:xPos] objectAtIndex:yPos];
}

- (void) clearCell
{
	int x, y;
	NSMutableArray *array = self.nums;	
    NSString *strInit = [[[NSString alloc] initWithString:@"123456789ABCDEFG"] substringToIndex:size];
	
	for (x=0; x<size; x++)
	{
		for (y=0; y<size; y++)
		{
			[[array objectAtIndex:x] replaceObjectAtIndex:y withObject:strInit];
		}
	}
	NSLog(@"clearCell");
//	[strUndo stringWithString:@""];
	strUndo = @"";
}

- (void) editCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSMutableArray *array = self.nums;	
	NSString *newStr;
	NSRange range;
	NSString *s;
    NSString *strInit = [[[NSString alloc] initWithString:@"123456789ABCDEFG"] substringToIndex:size];

	
	if (num == 0)
	{
		newStr = [[NSString alloc] initWithString:strInit]; // del number
	} else 
	{
		newStr = [[NSString alloc] initWithFormat:@"%d*", num];	// edit number
	}
	[[array objectAtIndex:xPos] replaceObjectAtIndex:yPos withObject:newStr];	
	[newStr release];
	
	[self initNums];    // zzz ???
	

	int x, y;
	for (x=0; x<size; x++)
	{
		for (y=0; y<size; y++)
		{
			s = [[array objectAtIndex:x] objectAtIndex:y];
			range = [s rangeOfString:@"*"];
			if (range.location != NSNotFound)
			{
				[self setCellSub:[s integerValue] xPos:x yPos:y];	
			}				
		}
	}
	
	[array release];	// release old array
//    [strInit release];
}

- (NSInteger) getIntegerAtIndexFromString:(NSString *)str index:(NSUInteger)index
{
	unichar c = [str characterAtIndex:index];
	
	return c-'0';
}


- (void) saveData
{
}

- (void) loadData
{

}



- (CGPoint) undoSet:(NSInteger)num
{
	NSLog(@"undoSet");
	NSMutableArray *array = self.nums;	
	NSString *oldStrUndo = [[NSString alloc] initWithString:strUndo];
	int len = oldStrUndo.length;
	int max = len/3;
	NSInteger iNum, x, y;
	CGPoint pointLastUndoPos;
	
	pointLastUndoPos.x = -1;
	pointLastUndoPos.y = -1;
	
	[strUndo release];
	strUndo = nil;
	[self initNumsUndo];

	
	
	for (int i=0; i<max; i++) {
		iNum = [self getIntegerAtIndexFromString:oldStrUndo index:i*3];
		x = [self getIntegerAtIndexFromString:oldStrUndo index:i*3+1];
		y = [self getIntegerAtIndexFromString:oldStrUndo index:i*3+2];
		if (i >= max-num)
		{
			pointLastUndoPos.x = x;
			pointLastUndoPos.y = y;
			
			break;
			
		} else {
			[self setCell:iNum xPos:x yPos:y];
		}
	}


	
	[array release];	// release old array
	
	return pointLastUndoPos;
}


- (void) printNums 
{
	NSString *str = [[NSString alloc] init];
	
	
	NSMutableArray *array = self.nums;
	str = [str stringByAppendingString:@"\n"];
	str = [str stringByAppendingString:@"-------------------------------------\n"];
	for (int y=0; y<size; y++) {
		for (int k=0; k<3; k++) {
			str = [str stringByAppendingString:@"|"];
			for (int x=0; x<size; x++) {
				NSString *s = [[array objectAtIndex:x] objectAtIndex:y];
				NSInteger len = s.length;
				for (int l=0; l<3; l++) {
					int pos = k*3 + l;
					if (pos < len) {
						unichar c = [s characterAtIndex:pos];
						str = [str stringByAppendingFormat:@"%c", c];	
					} else {
						str = [str stringByAppendingString:@" "];	
					}						
					
				}				
				if (x%3 == 2) {
					str = [str stringByAppendingString:@"|"];
				} else {
					str = [str stringByAppendingString:@" "];
				}
			}
			str = [str stringByAppendingString:@"\n"];
		}
		if (y%3 == 2) {
			str = [str stringByAppendingString:@"-------------------------------------\n"];
		} else {
			//str = [str stringByAppendingString:@"\n"];
			
			
		}
		
	}
	NSLog(@"str = %@", str);
	
	//	[str release];
}

- (void) countCell
{
	countUserFixed = 0;
	countAutoFixed = 0;	
	countNotFixed = 0;
	
	NSMutableArray *array = self.nums;
	NSString *str;

	for (int y=0; y<size; y++) {
		for (int x=0; x<size; x++) {
			str = [[array objectAtIndex:x] objectAtIndex:y];
			if ([SudokuNum fixedByUser:str])
				countUserFixed += 1;	
			else if ([SudokuNum fixedByAuto:str])
				countAutoFixed += 1;
			else 
				countNotFixed += 1;

		}
	}
	NSLog(@"countCell (U:%d,A:%d,N:%d)", countUserFixed, countAutoFixed, countNotFixed); 				  
					  
}


@end
