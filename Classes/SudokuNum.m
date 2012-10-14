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
// zzz release nums
    
	[super dealloc];
}

- (NSInteger) getCellSize
{
    return size;
}

- (void) initMap:(BOOL)defmap
{
    map = [[SudokuMap alloc] initWithSize:size defmap:defmap];
}

- (void) initNums
{
	NSLog(@"initNums");
	
	for (int i=0; i<size; i++)
	{
		for (int j=0; j<size; j++)
		{
			[self setDefaultMemo:i y:j];
		}
	}
}

- (void) initNumsUndo {
    [self initNums];
    strUndo = [[NSString alloc] initWithString:@""];
    bOkSetCell = NO;
}

// 최초에 한번만 초기화
- (void) initPuzzle:(NSInteger)sizePuzzle defmap:(BOOL)defmap
{
    numBackTracking = BACKTRACKING_START;
    countHandyTryFailed = 0;
    size = sizePuzzle;
    
    [self initMap:defmap];
    [self initNumsUndo];
    
#ifdef GTSUDOKU
    
    [self initGTSudoku];
    
#endif
    
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

- (NSInteger) randNum:(NSInteger) num
{
    return ((unsigned int)arc4random()) % num;
}



- (NSInteger) getPuzzleNum:(NSInteger)x y:(NSInteger)y
{
    NSAssert(x >= 0 && x < size, @"getPuzzleNum x");
    NSAssert(y >= 0 && y < size, @"getPuzzleNum y");
    
    return puzzle[x][y];
}

- (void) setPuzzleNum:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    NSAssert(num <= size, @"setPuzzleNum num");
    NSAssert(x >= 0 && x < size, @"setPuzzleNum x");
    NSAssert(y >= 0 && y < size, @"setPuzzleNum y");
    
    puzzle[x][y] = num;
    answer[x][y] = 0;
    memo[x][y] = 0;
	
}

- (NSInteger) getAnswerNum:(NSInteger)x y:(NSInteger)y
{
    NSAssert(x >= 0 && x < size, @"getAnswerNum x");
    NSAssert(y >= 0 && y < size, @"getAnswerNum y");
    
    return answer[x][y];
    
}

- (void) setAnswerNum:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    NSAssert1(num <= size, @"setAnswerNum num = %d", num);
    NSAssert1(x >= 0 && x < size, @"setAnswerNum x = %d", x);
    NSAssert1(y >= 0 && y < size, @"setAnswerNum y = %d", y);
    
	answer[x][y] = num;
	puzzle[x][y] = 0;
	memo[x][y] = 0;
}

- (void) setDefaultMemo:(NSInteger)x y:(NSInteger)y
{
    NSLog(@"setDefaultMemo(%d,%d)", x, y);
    NSAssert1(x >= 0 && x < size, @"setDefaultMemo x=%d", x);
    NSAssert1(y >= 0 && y < size, @"setDefaultMemo y=%d", y);
    
    memo[x][y] = 1;
    for (int i=0; i<size-1; i++)
    {
        memo[x][y] = memo[x][y] << 1;
        memo[x][y] |= 1;
    }
	puzzle[x][y] = 0;
	answer[x][y] = 0;

}

- (BOOL) isMemoed:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	if (num > size || x >= size || y >= size)
		NSLog(@"isMemoed(%d,%d,%d)", num, x, y);
	
    NSAssert(num >= 1 && num <= size, @"isMemoed num");
    NSAssert(x >= 0 && x < size, @"isMemoed x");
    NSAssert(y >= 0 && y < size, @"isMemoed y");
    
    
    NSUInteger n = (1 << (num-1));
    
    return (memo[x][y] & n) != 0;
}

- (BOOL) isEmptyMemo:(NSInteger)x y:(NSInteger)y
{
    NSAssert(x >= 0 && x < size, @"isEmptyMemo x");
    NSAssert(y >= 0 && y < size, @"isEmptyMemo y");
    
    return memo[x][y] == 0;
}

- (void) addMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    NSAssert(num >= 1 && num <= size, @"addMemo num");
    NSAssert(x >= 0 && x < size, @"addMemo x");
    NSAssert(y >= 0 && y < size, @"addMemo y");
    
    
    NSUInteger n = (1 << (num-1));
    
    memo[x][y] |= n;
    
}


- (BOOL) delMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    NSAssert(num >= 1 && num <= size, @"delMemo num");
    NSAssert(x >= 0 && x < size, @"delMemo x");
    NSAssert(y >= 0 && y < size, @"delMemo y");
    

	
	if (puzzle[x][y] || answer[x][y])
		return YES;	// 삭제할 필요가 없음
	
	if (memo[x][y] == 0)
		return NO;			// memo 오류
    
    NSUInteger n = (1 << (num-1));
	NSUInteger temp = memo[x][y];
    
    n = ~n;
    temp = (temp & n);

	if (temp != 0)
	{
		memo[x][y] = temp;
		return YES;
	} else {
		NSLog(@"delMemo(%d,%d - %d) memo=%d(%@%@%@%@%@%@%@%@%@)", x, y, num, memo[x][y],
			  memo[x][y]&(1)?@"1":@"",
			  memo[x][y]&(1<<1)?@"2":@"",
			  memo[x][y]&(1<<2)?@"3":@"",
			  memo[x][y]&(1<<3)?@"4":@"",
			  memo[x][y]&(1<<4)?@"5":@"",
			  memo[x][y]&(1<<5)?@"6":@"",
			  memo[x][y]&(1<<6)?@"7":@"",
			  memo[x][y]&(1<<7)?@"8":@"",
			  memo[x][y]&(1<<8)?@"9":@"");
		return NO;
	}
}

- (NSInteger) getUniqueMemo:(NSInteger)x y:(NSInteger)y
{
    NSAssert(x >= 0 && x < size, @"getUniqueMemo x");
    NSAssert(y >= 0 && y < size, @"getUniqueMemo y");
    
    NSInteger num = 1;
    NSInteger found = 0;
    
    for (int i=0; i<size; i++, num = num << 1)
    {
        if ((memo[x][y] & num) != 0)
        {
            if (found > 0)
                return 0;
            found = i+1;
        }
    }
    
    return found;
}

- (NSInteger) getRandomMemo:(NSInteger)x y:(NSInteger)y
{
    NSAssert(x >= 0 && x < size, @"getRandomMemo x");
    NSAssert(y >= 0 && y < size, @"getRandomMemo y");
    
    NSInteger num = 1;
    NSInteger count = 0;
	NSInteger rand;
    
    for (int i=0; i<size; i++, num = num << 1)
    {
        if ((memo[x][y] & num) != 0)
        {
            count++;
        }
    }
	
	rand = [self randNum:count];
	num = 1;
    for (int i=0; i<size; i++, num = num << 1)
    {
        if ((memo[x][y] & num) != 0)
        {
			if (rand-- <= 0)
			{
				return i+1;
			}
        }
    }
    return 0;
	
}




- (void) findFixedNum
{
	if (bOkAutoSet == NO)
		return;	
	
	int x,y;
	NSInteger num;
	
	for (x=0; x<size; x++)
	{
		for (y=0; y<size; y++)
		{
			num = [self getUniqueMemo:x y:y];
			if (num > 0)
			{
				[self setCellAnswerCheck:num x:x y:y];
				if (bOkAutoSet == NO)
					return;
			}
		}		
	}
	[self printNums];
}


- (void) findUniqueNumX:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x,y,k;
	int	countFound;
	int posFirstFound;

	
	for (x=0; x<size && bOkAutoSet; x++)
	{
		for (k=1; k<=size && bOkAutoSet; k++)
		{
			countFound = 0;
			posFirstFound = -1;
			for (y=0; y<size && bOkAutoSet; y++)
			{
				if ([self isMemoed:num x:x y:y] > 0)
				{
					countFound++;
					if (countFound == 1)
					{
						posFirstFound = y;
					}
				}			
			}
			if (countFound == 1)	// 유일한 숫자 발견
			{
				y = posFirstFound;
				
				// * ~는 아니어야 함
				if ([self isEmptyMemo:x y:y] == NO)
				{
					[self setCellAnswerCheck:num x:x y:y];
				}
			}
		}		
	}
}

- (void) findUniqueNumY:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x,y,k;
	int	countFound;
	int posFirstFound;

	
	for (y=0; y<size && bOkAutoSet; y++)
	{
		for (k=1; k<=size && bOkAutoSet; k++)
		{
			countFound = 0;
			posFirstFound = -1;
			
			for (x=0; x<size && bOkAutoSet; x++)
			{
				if ([self isMemoed:num x:x y:y] > 0)
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
				// * ~는 아니어야 함
				if ([self isEmptyMemo:x y:y] == NO)
				{
					[self setCellAnswerCheck:num x:x y:y];
				}
			}
		}		
	}
}


- (void) findUniqueNumXY:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{

	int x,y,k;//,i,j;
	int	countFound;
	int posXFirstFound;
	int posYFirstFound;

    NSInteger numMap = [map getMapNum:xPos y:yPos];

	for (k=1; k<=size && bOkAutoSet; k++)
	{
		countFound = 0;
		posXFirstFound = -1;
		posYFirstFound = -1;

		for (x=0; x<size && bOkAutoSet; x++)
		{
			for (y=0; y<size && bOkAutoSet; y++)
			{
                if (numMap == [map getMapNum:x y:y]) // 작은 블록 내의 칸인가?
                {
                    if ([self isMemoed:num x:x y:y] > 0)
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
			// * ~는 아니어야 함
			if ([self isEmptyMemo:x y:y] == NO)
			{
				[self setCellAnswerCheck:num x:x y:y];
			}
		}
	}
}


- (void) findUniqueNum:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	if (bOkAutoSet == NO)
		return;	
	
	[self findUniqueNumX:num xPos:xPos yPos:yPos];
	[self findUniqueNumY:num xPos:xPos yPos:yPos];
	[self findUniqueNumXY:num xPos:xPos yPos:yPos];
}

- (NSInteger) countUserFixedNumX:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x = xPos;
	int y = yPos;
	NSInteger count = 0;

	for (y=0; y<size; y++)
	{
		if ([self getPuzzleNum:x y:y] > 0)
			count++;
	}
	NSLog(@"countUserFixedNumX(%d,%d) => %d", xPos, yPos, count);	
	return count;
}

- (NSInteger) countUserFixedNumY:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x = xPos;
	int y = yPos;
	NSInteger count = 0;
	
	for (x=0; x<size; x++) 
	{
		if ([self getPuzzleNum:x y:y] > 0)
			count++;
	}
	NSLog(@"countUserFixedNumY(%d,%d) => %d", xPos, yPos, count);
	return count;

}
	
- (NSInteger) countUserFixedNumXY:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x = xPos;
	int y = yPos;
	NSInteger count = 0;
	
	int mapNum = [map getMapNum:xPos y:yPos];
	
	for (x=0; x<size; x++)
	{
		for (y=0; y<size; y++)
		{
			if (mapNum == [map getMapNum:x y:y])
			{
				if ([self getPuzzleNum:x y:y] > 0)
					count++;
            }
        }
	}
	NSLog(@"countUserFixedNumXY(%d,%d) => %d", xPos, yPos, count);
	return count;
			
}


- (BOOL) setCellCheck:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x,y;

	bOkSetCell = YES;	
	numSetCell += 1;

	// 주변 후보 숫자 수정	
	for (x=0, y=yPos; x<size; x++)
	{
		if (x != xPos)
		{
			if ([self delMemo:num x:x y:y] == NO)
			{
				NSLog(@"Failed");
				bOkAutoSet = NO;
				return NO;
			}
		}
	}
	
	for (x=xPos, y=0; y<size; y++)
	{
		if (y != yPos)
		{
			if ([self delMemo:num x:x y:y] == NO)
			{
				NSLog(@"Failed");
				bOkAutoSet = NO;
				return NO;
			}
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
					if ([self delMemo:num x:x y:y] == NO)
					{
						NSLog(@"Failed");
						bOkAutoSet = NO;
						return NO;
					}
				}
			}
		}
	}
	[self printNums];
	
	[self findFixedNum];
	[self findUniqueNum:num xPos:xPos yPos:yPos];
	
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

- (BOOL) setCellPuzzleCheck:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	[self setPuzzleNum:num x:x y:y];
	return [self setCellCheck:num xPos:x yPos:y];

}

- (BOOL) setCellAnswerCheck:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	[self setAnswerNum:num x:x y:y];
	return [self setCellCheck:num xPos:x yPos:y];
}


- (BOOL) validNumInCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{	
	if ([self getAnswerNum:xPos y:yPos] > 0)
	{
		return NO;		// 이미 자동세팅 값이 채워져 있어서 수정할 수 없음
	}
	
	NSInteger puzzleNum = [self getPuzzleNum:xPos y:yPos];
	
	if (puzzleNum > 0)
	{
		if (puzzleNum == num)
		{
			return NO;	// 이미 같은 값이 설정 되어 있어서 아무 일도 할 것이 없음
			
		}

		// 이전에 지정한 셀에 다른 값(0~size)을 설정하려고 함
		[self editCell:num xPos:xPos yPos:yPos];
		
		return NO;	
	}
		
	if ([self isMemoed:num x:xPos y:yPos] == NO) // 후보군의 숫자가 아님, 설정 불가능
	{
		return NO;	// 세팅 불가능한 숫자임
	}
	
	int x,y;


	for (x=0; x<size; x++)
	{
		for (y=0; y<size; y++)
		{
			if (x != xPos && y != yPos)
			{
				if ((x == xPos || y == yPos) || [map isSameMap:x y:y x2:xPos y2:yPos])
				{
					if ([self getPuzzleNum:x y:y] == num)		// 이미 세팅했던 것들임
					{
						return NO;
					}				
					if ([self getAnswerNum:x y:y] == num)		// 자동 계산 값과 같음
					{
						return NO;
					}
				}
			}	
		}			
	}
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
		
	BOOL bRet = [self setCellPuzzleCheck:num x:xPos y:yPos];
	return bRet;
}



- (BOOL) setCellAuto:(NSInteger)handy;
{
	int numRandom;
	int num, answerNum;

	
    
    // Handy 적용하다가 무한루프에 빠질 수 있음... 
	if (countNotFixed == 0) {	// last time, Handy 적용한다.
#ifdef GTSUDOKU 
		// 일단 여기서 모든 셀을 AutoCell로 지정한다.
		for (int y=0; y<size; y++)
		{
			for (int x=0; x<size; x++)
			{
				num = [self getPuzzleNum:x y:y];
				if (num > 0)
				{
					[self setAnswerNum:num x:x y:y];
				}
			}
		}
        
        
#endif
		for (int i=0; i<handy && countAutoFixed>0 && countHandyTryFailed < MAX_HANDYTRAYFAIL; i++)
		{
			numRandom = [self randNum:countAutoFixed];
			num = 0;
            
            // 자동Fix된 셀중에서 Random 번째의 셀을 찾는다.
			for (int y=0; y<size && num <= numRandom; y++)
			{
				for (int x=0; x<size && num <= numRandom; x++)
				{
					answerNum = [self getAnswerNum:x y:y];
					
					if (answerNum > 0)
					{
						if (num == numRandom)
						{							
							if ([self setCellUserFixed:answerNum xPos:x yPos:y] == NO)
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
		return NO;  // 게임 생성 완성
	}	
	bOkAutoSet = YES;
	numSetCell = 0;
	// countNotFixed -> Random 값 만들기
	numRandom = [self randNum:countNotFixed];
	num = 0;

    
	for (int y=0; y<size && num <= numRandom; y++)
	{
		for (int x=0; x<size && num <= numRandom; x++)
		{
			if ([self isEmptyMemo:x y:y] == NO)
			{
				if (num == numRandom)
				{
                    // zzz 4x4 다시 해야 한다.
					if ([self countUserFixedNumX:x yPos:y] >= size-1 ||
						[self countUserFixedNumY:x yPos:y] >= size-1 ||
						[self countUserFixedNumXY:x yPos:y] >= size-1)
					{
						// 꽉 찼음...
                        
					} else {
						
						[self setCell:[self getRandomMemo:x y:y] xPos:x yPos:y];
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
	
	[self setPuzzleNum:num x:xPos y:yPos];
	
	return YES;
}




// clear를 제외한 모든 셀의 값 세팅을 여기로 와야 한다.
- (BOOL) setCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
    NSLog(@"setCell(%d)(%d,%d)", num, xPos, yPos);
	bOkSetCell = NO;
	
	if ([self validNumInCell:num xPos:xPos yPos:yPos] == NO)
	{
		NSLog(@"Unvalid Number Setting(num:%d, xPos:%d, yPos:%d", num, xPos, yPos);
	} else {
		[self setCellPuzzleCheck:num x:xPos y:yPos];
		[self addUndoLog:num xPos:xPos yPos:yPos];		// set undo data
	}

	
	return bOkSetCell;
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
	if (num == 0)
	{
		[self setDefaultMemo:xPos y:yPos];
	} else {
		[self setPuzzleNum:num x:xPos y:yPos];
	}
	
	[self initNums];    // zzz ???
	

	NSInteger puzzleNum;
	int x, y;
	for (x=0; x<size; x++)
	{
		for (y=0; y<size; y++)
		{
			puzzleNum = [self getPuzzleNum:x y:y];
			if (puzzleNum > 0)
			{
				[self setCellSub:puzzleNum xPos:x yPos:y];
			}				
		}
	}
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
	
	str = [str stringByAppendingString:@"\n"];
	str = [str stringByAppendingString:@"-------------------------------------\n"];
	for (int y=0; y<size; y++)
	{
		for (int k=0; k<3; k++)
		{
			str = [str stringByAppendingString:@"|"];
			for (int x=0; x<size; x++)
			{
				for (int l=0; l<3; l++)
				{
					int pos = k*3 + l;
					if (pos < size && x < size && y < size && [self isMemoed:pos+1 x:x y:y])
					{
						str = [str stringByAppendingFormat:@"%d", pos+1];
					} else {
						if (x < size && y < size && [self getPuzzleNum:x y:y] > 0)
						{
							if (pos == 3)
								str = [str stringByAppendingString:@"["];
							else if (pos == 4)
								str = [str stringByAppendingFormat:@"%d", [self getPuzzleNum:x y:y]];
							else if (pos == 5)
								str = [str stringByAppendingString:@"]"];
							else
								str = [str stringByAppendingString:@" "];
						}
						else if (x < size && y < size && [self getAnswerNum:x y:y] > 0)
						{
							if (pos == 3)
								str = [str stringByAppendingString:@"-"];
							else if (pos == 4)
								str = [str stringByAppendingFormat:@"%d", [self getAnswerNum:x y:y]];
							else if (pos == 5)
								str = [str stringByAppendingString:@"-"];
							else
								str = [str stringByAppendingString:@" "];

						} else {
							str = [str stringByAppendingString:@" "];
						}
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

	for (int y=0; y<size; y++)
	{
		for (int x=0; x<size; x++)
		{
			str = [[array objectAtIndex:x] objectAtIndex:y];
			if ([self getPuzzleNum:x y:y] > 0)
				countUserFixed += 1;	
			else if ([self getAnswerNum:x y:y] > 0)
				countAutoFixed += 1;
			else 
				countNotFixed += 1;

		}
	}
	NSLog(@"countCell (U:%d,A:%d,N:%d)", countUserFixed, countAutoFixed, countNotFixed); 				  
					  
}


#ifdef GTSUDOKU

- (BOOL) isContacted:(NSInteger)x y:(NSInteger)y w:(NSInteger)w h:(NSInteger)h
{
    if (arrGT[x][y] != 0)
        return NO;    
    
    if (x > 0 && arrGT[x-1][y] != 0)
        return YES;
    if (x < w-1 && arrGT[x+1][y] != 0)
        return YES;
    if (y > 0 && arrGT[x][y-1] != 0)
        return YES;
    if (y < h-1 && arrGT[x][y+1] != 0)
        return YES;

    return NO;
}


- (void) setGTNum:(NSInteger)num inc:(BOOL)inc
{
    NSInteger max = wGT*hGT;
    NSInteger i;
    NSInteger x, y;
    NSInteger setNum = inc ? num + 1 : max - num;
    
    if (num == 0)
    {
        arrGT[[self randNum:wGT]][[self randNum:hGT]] = setNum;
    } else {
        i = [self randNum:max]+max;
        
        for (y=0; i>0;y=(++y % hGT))
        {
            for (x=0; x<wGT && i>0;x++)
            {                
                if ([self isContacted:x y:y w:wGT h:hGT])
                {
                    //NSLog(@"Contacted(%d)(%d)", x, y);
                    if (--i <= 0)
                    {
                        arrGT[x][y] = setNum;
                    }
                } else {
                   // NSLog(@"Not contacted(%d)(%d)", x, y);
                }
            }
        }
        
    }
    
    
    
    NSString *str = [[NSString alloc] init];

    str = [str stringByAppendingString:@"\n----------\n"];
    for (y=0; y<hGT; y++)
    {
        for (x=0; x<wGT; x++)
        {
            str = [str stringByAppendingString:@"|"];
            str = [str stringByAppendingFormat:@"%d", arrGT[x][y]];
        }
        str = [str stringByAppendingString:@"|\n"];
        str = [str stringByAppendingString:@"----------\n"];
    }
    NSLog(@"%@", str);
}


- (void) getGTBase
{
    memset(&arrGT, 0, sizeof(arrGT));
    if (size == SIZE_9)
    {
        wGT = 3;
        hGT = 3;
    } else {    // SIZE_6
        wGT = 3;
        hGT = 2;
    }
    
    BOOL bInc = [self randNum:2] == 1 ? YES : NO;
    
    for (int i=0; i<wGT*hGT; i++)
    {
        [self setGTNum:i inc:bInc];
    }
}

// Greater than sudoku를 위한 초기화
NSInteger Rand123[6][3] = {
    {0,1,2},
    {0,2,1},
    {1,0,2},
    {1,2,0},
    {2,0,1},
    {2,1,0}
};

NSInteger Rand12[2][3] = {
    {0,1,2},
    {1,0,2}
};


//- (BOOL) setCell:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos

- (void) initGTSudoku
{
    
    NSInteger baseCount = (size == SIZE_9) ? 3 : 2; // very hard는 2:1로?
    
    NSInteger* arrX = (size == SIZE_9) ?
                    Rand123[[self randNum:6]]:
                    Rand12[[self randNum:2]];
    NSInteger* arrY = Rand123[[self randNum:6]];
    
    for (int i=0; i<baseCount; i++)
    {
        [self getGTBase];
        for (int y=0; y<hGT; y++)
        {
            for (int x=0; x<wGT; x++)
            {
                [self setCell:arrGT[x][y] xPos:arrX[i]*wGT+x yPos:arrY[i]*hGT+y];
                [self printNums];
            }
        }
    }
}


#endif

@end
