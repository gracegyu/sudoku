//
//  SudokuGame.m
//  sudoku
//
//  Created by Raymond Jeon on 10. 7. 23..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SudokuGame.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "SudokuBoard.h"

@implementation SudokuGame

//@synthesize strUndo;
@synthesize sudokuUndo;
@synthesize size;
@synthesize gameLevel;
@synthesize startTime;
@synthesize lastTime;
@synthesize gameTime;
@synthesize hintTime;
@synthesize isGameFinished;
@synthesize countBlank;
@synthesize countFixNums;
@synthesize countHint;
@synthesize bAutoMemo;
#ifdef KILLERSUDOKU
@synthesize kmap;
#endif



- (void)dealloc
{
    
    [sudokuUndo release];
    [map release];
#ifdef KILLERSUDOKU
	[kmap release];
#endif
	
	[super dealloc];
}

- (NSInteger) randNum:(NSInteger) num
{
    return ((unsigned int)arc4random()) % num;
}


- (NSInteger) getDefHintCount:(NSInteger)sizeTable
{
    return sizeTable > 6 ? 2 : 1;
/*

#ifdef GTSUDOKU
    return sizeTable > 6 ? 3 : 2;
#else
#ifdef KILLERSUDOKU
    return sizeTable > 6 ? 3 : 2;
#else
    return sizeTable > 6 ? 2 : 1;
#endif
#endif
*/
}

- (NSInteger) countPuzzleNum
{
	NSInteger num = 0;
	
	for (int y=0; y<size; y++)
	{
		for (int x=0; x<size; x++)
		{
			if (puzzleNums[x][y] > 0)
				num += 1;
		}
	}
	return num;
}

- (NSInteger) countUserFixedNumX:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x = xPos;
	int y = yPos;
	NSInteger count = 0;
	
	for (y=0; y<size; y++)
	{
		if (puzzleNums[x][y] > 0)
			count++;
	}
	//DLog(@"countUserFixedNumX(%d,%d) => %d", xPos, yPos, count);
	return count;
}

- (NSInteger) countUserFixedNumY:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x = xPos;
	int y = yPos;
	NSInteger count = 0;
	
	for (x=0; x<size; x++)
	{
		if (puzzleNums[x][y] > 0)
			count++;
	}
	//DLog(@"countUserFixedNumY(%d,%d) => %d", xPos, yPos, count);
	return count;
	
}

- (NSInteger) countUserFixedNumXY:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x = xPos;
	int y = yPos;
	NSInteger count = 0;
	
	int mapNum = mapNums[xPos][yPos];
	
	for (x=0; x<size; x++)
	{
		for (y=0; y<size; y++)
		{
			if (mapNum == mapNums[x][y])
			{
				if (puzzleNums[x][y] > 0)
					count++;
            }
        }
	}
	//DLog(@"countUserFixedNumXY(%d,%d) => %d", xPos, yPos, count);
	return count;
	
}

- (BOOL) setCellUserFixed:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	if ([self countUserFixedNumX:xPos yPos:yPos] >= size-1 ||
		[self countUserFixedNumY:xPos yPos:yPos] >= size-1 ||
		[self countUserFixedNumXY:xPos yPos:yPos] >= size-1)
	{
		
		return NO;
	}
	
	puzzleNums[xPos][yPos] = num;
	
	return YES;
}



#ifdef GTSUDOKU
static int	HandyCount[][5] = {
    { 0, 0, 0, 0, 0 },   // 0
    { 0, 0, 0, 0, 0 },   // 1
    { 0, 0, 0, 0, 0 },   // 2
    { 0, 0, 0, 0, 0 },   // 3
    { 0, 2, 4, 7, 10 },   // 4
    { 0, 2, 4, 10, 15 }, // 5
    { 0, 2, 6, 13, 20 }, // 6 ok
    { 0, 3, 8, 16, 22 }, // 7
    { 0, 4, 9, 18, 25 }, // 8
    { 0, 4, 15, 24, 45 }  // 9 ok
};
static int	HandyCountAuto[][5] = {
    { 0, 0, 0, 0, 0 },   // 0
    { 0, 0, 0, 0, 0 },   // 1
    { 0, 0, 0, 0, 0 },   // 2
    { 0, 0, 0, 0, 0 },   // 3
    { 0, 2, 4, 7, 10 },   // 4
    { 0, 2, 4, 10, 15 }, // 5
    { 0, 2, 6, 12, 18 }, // 6
    { 0, 3, 8, 16, 22 }, // 7
    { 0, 4, 9, 18, 25 }, // 8
    { 0, 4, 15, 22, 30 }  // 9 ok
};
#elif (defined KILLERSUDOKU)
static int	HandyCount[][5] = {
    { 0, 0, 0, 0, 0 },   // 0
    { 0, 0, 0, 0, 0 },   // 1
    { 0, 0, 0, 0, 0 },   // 2
    { 0, 0, 0, 0, 0 },   // 3
    { 0, 2, 4, 7, 10 },   // 4
    { 0, 2, 4, 10, 15 }, // 5
    { 0, 2, 6, 13, 20 }, // 6 ok
    { 0, 3, 8, 16, 22 }, // 7
    { 0, 4, 9, 18, 25 }, // 8
    { 0, 4, 15, 33, 45 }  // 9 ok
};
static int	HandyCountAuto[][5] = {
    { 0, 0, 0, 0, 0 },   // 0
    { 0, 0, 0, 0, 0 },   // 1
    { 0, 0, 0, 0, 0 },   // 2
    { 0, 0, 0, 0, 0 },   // 3
    { 0, 2, 4, 7, 10 },   // 4
    { 0, 2, 4, 10, 15 }, // 5
    { 0, 2, 5, 10, 18 }, // 6 ok
    { 0, 3, 8, 16, 22 }, // 7
    { 0, 4, 9, 18, 25 }, // 8
    { 0, 6, 18, 25, 33 }  // 9 ok
};
#else
static int	HandyCount[][5] = {
    { 0, 0, 0, 0, 0 },   // 0
    { 0, 0, 0, 0, 0 },   // 1
    { 0, 0, 0, 0, 0 },   // 2
    { 0, 0, 0, 0, 0 },   // 3
    { 0, 1, 2, 3, 4 },   // 4
    { 0, 2, 4, 10, 15 }, // 5
    { 0, 2, 6, 13, 20 }, // 6 ok
    { 0, 3, 8, 16, 22 }, // 7
    { 0, 4, 9, 18, 25 }, // 8
    { 0, 5, 10, 20, 30 } // 9 ok
};
static int	HandyCountAuto[][5] = {
    { 0, 0, 0, 0, 0 },   // 0
    { 0, 0, 0, 0, 0 },   // 1
    { 0, 0, 0, 0, 0 },   // 2
    { 0, 0, 0, 0, 0 },   // 3
    { 0, 1, 2, 3, 4 },   // 4
    { 0, 2, 4, 10, 15 }, // 5
    { 0, 3, 5, 8, 12 },  // 6 ok
    { 0, 3, 8, 16, 22 }, // 7
    { 0, 4, 9, 18, 25 }, // 8
    { 0, 5, 10, 15, 20 } // 9 ok
};
#endif

- (void) applyHandy
{
	int numRandom;
	int num;
	int handy = bAutoMemo ? HandyCountAuto[size][gameLevel] : HandyCount[size][gameLevel];
	
	
#if (defined GTSUDOKU) || (defined KILLERSUDOKU)
	memset(puzzleNums, 0, sizeof(puzzleNums));
#endif
	NSInteger countPuzzle = [self countPuzzleNum];
	NSInteger countBlankCell = size*size - countPuzzle;
	NSInteger countHandyTryFailed=0;

	for (int i=0; i<handy && countBlankCell>0 && countHandyTryFailed < MAX_HANDYTRAYFAIL; i++)
	{
		numRandom = [self randNum:countBlankCell];
		num = 0;
		
		// 자동Fix된 셀중에서 Random 번째의 셀을 찾는다.
		for (int y=0; y<size && num <= numRandom; y++)
		{
			for (int x=0; x<size && num <= numRandom; x++)
			{
				if (puzzleNums[x][y] == 0)
				{
					if (num == numRandom)
					{
						if ([self setCellUserFixed:answerNums[x][y] xPos:x yPos:y] == YES)
						{
							countPuzzle++;
							countBlankCell--;
						} else {
							i--;
							countHandyTryFailed += 1;
						}
					}
					num += 1;
				}
			}
		}
		//			[self printNums];

		if (countHandyTryFailed >= MAX_HANDYTRAYFAIL)
			DLog(@"countHandyTryFailed == MAX_HANDYTRAYFAIL");
		
	}
	
}

- (void) initData:(GAMELEVEL)level
{
	gameLevel = GAMELEVEL_NORMAL;       // default
	startTime = [[NSDate date]timeIntervalSince1970];
	lastTime = [[NSDate date]timeIntervalSince1970];
	gameTime = 0;
	hintTime = SECONDSFORFREEHINT;
	isGameFinished = NO;
	countHint = [self getDefHintCount:size];
	gameLevel = level;
	
	bAutoMemoUndoLog = YES;
}

- (void) deleteAutoMemoX:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x, y;
	for (x=xPos, y=0; y<size; y++)
	{
		if (y != yPos)
		{
			[self delMemoNumsForAutoMemo:num x:x y:y];
			//DLog(@"deleteAutoMemoX(%d,%d)->%d", x, y, num);
		}
	}
}

- (void) deleteAutoMemoY:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x, y;
	for (x=0, y=yPos; x<size; x++)
	{
		if (x != xPos)
		{
			[self delMemoNumsForAutoMemo:num x:x y:y];
			//DLog(@"deleteAutoMemoY(%d,%d)->%d", x, y, num);

		}
	}

}

- (void) deleteAutoMemoXY:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x, y;
	NSInteger mapNum = mapNums[xPos][yPos];
	
    for (x=0; x<size; x++)
    {
		for (y=0; y<size; y++)
		{
			if (mapNum == mapNums[x][y])
			{
				if (x != xPos && y != yPos)
				{
					[self delMemoNumsForAutoMemo:num x:x y:y];
					//DLog(@"deleteAutoMemoXY(%d,%d)->%d", x, y, num);
				}
			}
		}
	}
}

#ifdef KILLERSUDOKU
- (void) deleteAutoMemoCage:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	int x, y;
	NSInteger cageNum = [kmap getCageNumber:xPos yPos:yPos];
	
    for (x=0; x<size; x++)
    {
		for (y=0; y<size; y++)
		{
			if (cageNum == [kmap getCageNumber:x yPos:y])
			{
				if (x != xPos && y != yPos)
				{
					[self delMemoNumsForAutoMemo:num x:x y:y];
					//DLog(@"deleteAutoMemoXY(%d,%d)->%d", x, y, num);
				}
			}
		}
	}
}
#endif

- (BOOL) deleteAutoMemoUniqueNumX
{
	int x,y,k;
	int	countFound;
	int posFirstFound;
	BOOL bRet = NO;
	
	
	for (x=0; x<size; x++)
	{	
		for (k=1; k<=size; k++)
		{
			countFound = 0;
			posFirstFound = -1;
			for (y=0; y<size; y++)
			{
				if ([self getPuzzleNums:x y:y] == k ||	// 메모 중에서만 찾아야 한다.
					[self getFixNums:x y:y] == k)
				{
					countFound = 0;
					break;
				} else
				if ([self beMemoNums:k x:x y:y] == YES)	// 이미 한글자 메모는 처리 할 필요가 없다.
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
				if ([self setMemoNumsForAutoMemo:k x:x y:y])
				{
					DLog(@"deleteAutoMemoUniqueNumX(%d,%d)->%d", x, y, k);
					bRet = YES;
				}
			}
		}
	}
	return bRet;
}

- (BOOL) deleteAutoMemoUniqueNumY
{
	int x,y,k;
	int	countFound;
	int posFirstFound;
	BOOL bRet = NO;
	
	for (y=0; y<size; y++)
	{	//k = num;
		for (k=1; k<=size; k++)
		{
			countFound = 0;
			posFirstFound = -1;
			
			for (x=0; x<size; x++)
			{
				if ([self getPuzzleNums:x y:y] == k ||	// 메모 중에서만 찾아야 한다.
					[self getFixNums:x y:y] == k)
				{
					countFound = 0;
					break;
				} else
				if ([self beMemoNums:k x:x y:y] == YES)	// 이미 한글자 메모는 처리 할 필요가 없다.
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
				if ([self setMemoNumsForAutoMemo:k x:x y:y])
				{
					//DLog(@"deleteAutoMemoUniqueNumY(%d,%d)->%d", x, y, k);
					bRet = YES;
				}
			}
		}
	}
	return bRet;
}

- (BOOL) deleteAutoMemoUniqueNumXY
{
	int x,y,k,i,numMap;//,i,j;
	int	countFound;
	int posXFirstFound;
	int posYFirstFound;
	sXY* sub;
	BOOL bRet = NO;
	
    //NSInteger numMap = [map getMapNum:xPos y:yPos];
	
	for (numMap = 1; numMap <= size; numMap++)
	{
		//k = num;
		for (k=1; k<=size; k++)
		{
			countFound = 0;
			posXFirstFound = -1;
			posYFirstFound = -1;
			
			sub = [map getSubNum:numMap];
			
			
			for (i=0; i<size; i++)
			{

				x = sub[i].x;
				y = sub[i].y;
				if ([self getPuzzleNums:x y:y] == k ||	// 메모 중에서만 찾아야 한다.
					[self getFixNums:x y:y] == k)
				{
					countFound = 0;
					break;
				} else
				if ([self beMemoNums:k x:x y:y] == YES)	// 이미 한글자 메모는 처리 할 필요가 없다.
				{
					countFound++;
					if (countFound == 1)
					{
						posXFirstFound = x;
						posYFirstFound = y;

					}
				}
			}
			
			if (countFound == 1)
			{

				
				x = posXFirstFound;
				y = posYFirstFound;

				if ([self setMemoNumsForAutoMemo:k x:x y:y])
				{
					DLog(@"deleteAutoMemoUniqueNumXY(%d,%d)->%d", x, y, k);
					bRet = YES;
				} else {
					//DLog(@"[self setMemoNumsForAutoMemo:%d x:%d y:%d] == NO", k, x, y);
				}
			}
		}
	}
	return bRet;
}

- (BOOL) deleteAutoMemoUniqueNum
{
	BOOL bRetX, bRetY, bRetXY;
	
	bRetX = [self deleteAutoMemoUniqueNumX];
	bRetY =	[self deleteAutoMemoUniqueNumY];
	bRetXY = [self deleteAutoMemoUniqueNumXY];
	
	return bRetX || bRetY || bRetXY;
}

- (void) updateAutoMemoOnlyUnique
{
#ifdef SUDOKU9	// 나머지 에서는 너무 쉬워진다.
#if (defined GTSUDOKU) || (defined KILLERSUDOKU)
	if (1)	// GTSudoku와 Killer Sudoku는 어렵기 때문에 항상 모든 Auto기능을 다 사용한다.
#else
		if (gameLevel == GAMELEVEL_VERYHARD || gameLevel == GAMELEVEL_HARD)
#endif
		{
			while ([self deleteAutoMemoUniqueNum] == YES)
			{
				
			}
		}
#endif
}

- (void) updateAutoMemo:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	if (bAutoMemo == NO)
		return;
	
	if (num > 0)
	{
		[self deleteAutoMemoX:num xPos:xPos yPos:yPos];
		[self deleteAutoMemoY:num xPos:xPos yPos:yPos];
		[self deleteAutoMemoXY:num xPos:xPos yPos:yPos];
#ifdef KILLERSUDOKU
		[self deleteAutoMemoCage:num xPos:xPos yPos:yPos];
#endif
		
	}
	
	[self updateAutoMemoOnlyUnique];

	// [self deleteAutoMemoSingleNum:]
	// Single num은 굳이 처리하지 않아도 사용자가 입력할 것이다.
#ifdef KILLERSUDOKU
	// zzz 합계상 나올 수 없는 숫자는 지우기....
#endif
	
}

- (void) initAutoMemo
{
	if (bAutoMemo == NO)
		return;
	
	bAutoMemoUndoLog = NO;

	char defaultMemo[16+1];
	
	int i;
	for (i=0; i<size; i++)
    {
		defaultMemo[i] = '1'+i;
    }
	defaultMemo[i] = '\0';
	
	for (int y=0; y<size; y++)
	{
		for (int x=0; x<size; x++)
		{
			strcpy(memoNums[x][y], defaultMemo);
		}
	}
	for (int y=0; y<size; y++)
	{
		for (int x=0; x<size; x++)
		{
			if (puzzleNums[x][y])
			{
				memoNums[x][y][0] = '\0';
				[self updateAutoMemo:puzzleNums[x][y] xPos:x yPos:y];
			} else if (fixNums[x][y]) {
				//memoNums[x][y][0] = '\0';	
				[self updateAutoMemo:fixNums[x][y] xPos:x yPos:y];
			}
		}
	}
	bAutoMemoUndoLog = YES;
}

- (void) postData
{
	[self applyHandy];
    sudokuUndo = [[SudokuUndo alloc] init];
    
#ifdef KILLERSUDOKU
	//kmap = [[KillerMap alloc] initWithSize:size];
	KillerCage *cell;
	for (int i=0; (cell = [kmap getCageData:i]) != NULL; i++)
	{
		cell->sum = 0;
		cell->sign = CS_PLUS;	// killersudoku는 Plus만 지원한다.

		int n=0;
		NSInteger arNum[4];		// Cage는 최대 4개 셀만 지원

		for (int y=0; y<size; y++)
		{
			for (int x=0; x<size; x++)
			{
				if ([kmap getCageNumber:x yPos:y] == i)
				{
					DAssert(n < 4, @"n must be less than 4");
					cell->sum += answerNums[x][y];
					arNum[n] = answerNums[x][y];
					n++;
				}
			}
		}
#ifdef CALCUDOKU
		if (n == 1)
		{
			//pass
		}
		else if (n == 2)
		{
			if ((MAX(arNum[0], arNum[1]) % MIN(arNum[0], arNum[1])) == 0)	// 나누기 가능
			{
				NSInteger Rand = ((unsigned int)arc4random()) % 100;
				if (Rand >= 30)
				{
					cell->sum = (MAX(arNum[0], arNum[1]) / MIN(arNum[0], arNum[1]));
					cell->sign = CS_DIVIDE;
					continue;
				}					
			}
			NSInteger Rand = ((unsigned int)arc4random()) % 100;
			if (Rand >= 65)
			{
				cell->sum = arNum[0] * arNum[1];
				cell->sign = CS_MULTIPLE;
			}
			else if (Rand >= 50)
			{
				cell->sum = (MAX(arNum[0], arNum[1]) - MIN(arNum[0], arNum[1]));
				cell->sign = CS_MINUS;
			}
		}
		else if (n == 3)
		{
			NSInteger Rand = ((unsigned int)arc4random()) % 100;
			if (Rand >= 50)
			{
				cell->sum = arNum[0] * arNum[1] * arNum[2];
				cell->sign = CS_MULTIPLE;
			}
		}
		else if (n == 4)
		{
			NSInteger Rand = ((unsigned int)arc4random()) % 100;
			if (Rand >= 50)
			{
				NSInteger sum = arNum[0] * arNum[1] * arNum[2] * arNum[3];
				if (sum < 1000)
				{
					cell->sum = sum;
					cell->sign = CS_MULTIPLE;
				}
			}
		}
		else
		{
			DAssert(n < 4, @"n must be less than 4");
		}
#endif
		
	}
	
#endif
	
	
	[self initAutoMemo];
	
	
	//[self saveData];

}

- (id) initWithSudokuBoard:(SudokuBoard*)sudoku level:(GAMELEVEL)level automemo:(BOOL)automemo
{
	if ((super.init) == nil)
		return nil;
	
	size = SIZE_9;
	bAutoMemo = automemo;
	[self initData:level];
	map = [[SudokuMap alloc] initWithSize:size defmap:YES];
	
	NSInteger num;
    for (int y=0; y<size; y++) {
		for (int x=0; x<size; x++) {
            mapNums[x][y] = [map getMapNum:x y:y];
            num = ((int*)[sudoku getPuzzle])[y*size+x];
            
            if (num > 0) {		// fixed cell
				puzzleNums[x][y] = num;
				answerNums[x][y] = num; // 0
			} else {
				num = ((int*)[sudoku getSolution])[y*size+x];
                DAssert(num > 0, @"getAnswerNum(%d) should be bigger than 0", num);
				puzzleNums[x][y] = 0;				// blank
				answerNums[x][y] = num;
			}
            
			fixNums[x][y] = 0;
			memoNums[x][y][0] = '\0';
		}
	}

	[self postData];
	
	
	return self;
	
}


- (id) initWithSudokuNum:(SudokuNum*)sudoku level:(GAMELEVEL)level automemo:(BOOL)automemo
{
	if ((super.init) == nil) 
		return nil;
	
    size = [sudoku getCellSize];
	[self initData:level];
	bAutoMemo = automemo;
	map = [[SudokuMap alloc] initWithMap:[sudoku getMap]];
#ifdef KILLERSUDOKU
	kmap = [[KillerMap alloc] initWithMap:[sudoku getKillerMap]];
#endif
	NSInteger num;
    for (int y=0; y<size; y++) {
		for (int x=0; x<size; x++) {
            mapNums[x][y] = [[sudoku getMap] getMapNum:x y:y];
            num = [sudoku getPuzzleNum:x y:y];
            
            if (num > 0) {		// fixed cell
				puzzleNums[x][y] = num;
				answerNums[x][y] = num; // 0
			} else {
				num = [sudoku getAnswerNum:x y:y];
                DAssert(num > 0, @"getAnswerNum(%d) should be bigger than 0", num);
				puzzleNums[x][y] = 0;				// blank
				answerNums[x][y] = num;
			}
            
			fixNums[x][y] = 0;
			memoNums[x][y][0] = '\0';
		}
	}
	
	[self postData];
	return self;

}

- (void) printNums
{
	NSString *str = [[NSString alloc] init];
	
	str = [str stringByAppendingString:@"\n"];
	str = [str stringByAppendingString:@"-------------------------------------\n"];
	for (int y=0; y<size; y++)
	{
		str = [str stringByAppendingString:@"|"];
		for (int x=0; x<size; x++)
		{
			if (puzzleNums[x][y] > 0)
				str = [str stringByAppendingFormat:@"[%d]", puzzleNums[x][y]];
			else
				str = [str stringByAppendingFormat:@"-%d-", answerNums[x][y]];
			str = [str stringByAppendingString:x%3 == 2?@"|":@" "];
			
		}
		str = [str stringByAppendingString:@"\n"];
		
		if ((y%3) == 2)
			str = [str stringByAppendingString:@"-------------------------------------\n"];
		
	}
	DLog(@"puzzle & answer = %@", str);
}


- (id)initWithSavedString:(NSString *)str
{
	NSString *strTemp;
	
	if ((super.init) == nil) 
		return nil;
	
	NSArray *listItems = [str componentsSeparatedByString:@","];
	
	gameLevel = [[listItems objectAtIndex:0] integerValue];
	if (gameLevel < GAMELEVEL_VERYHARD || gameLevel > GAMELEVEL_VERYEASY)
	{
		DAssert(gameLevel >= GAMELEVEL_VERYHARD && gameLevel <= GAMELEVEL_VERYEASY, @"initWithSavedString:gameLevel = %d", gameLevel);
		return nil;
	}
	startTime = [[listItems objectAtIndex:1] floatValue];
	lastTime = [[listItems objectAtIndex:2] floatValue];
	gameTime = [[listItems objectAtIndex:3] floatValue];
	isGameFinished = [[listItems objectAtIndex:4] integerValue] == 1 ? YES : NO;

	if ([listItems count] > 10) {
		countHint = [[listItems objectAtIndex:10] integerValue];
	} else {
		countHint = [self getDefHintCount:9];
	}
	if ([listItems count] > 11) {
        size = [[listItems objectAtIndex:11] integerValue];
		if (size < SIZE_6 || size > SIZE_9)
		{
			DAssert(size >= SIZE_6 && size <= SIZE_9, @"initWithSavedString:size = %d", size);
			return nil;
		}
    } else {
        size = 9;
    }
	
	strTemp = [listItems objectAtIndex:5];
	if ([strTemp length] != size*size)
	{
		DAssert([strTemp length] == size*size, @"initWithSavedString:puzzleNums length=%d", [strTemp length]);
		return nil;
	}
	[SudokuGame set9x9Nums:strTemp size:size nums:&puzzleNums[0][0]];
	strTemp = [listItems objectAtIndex:6];
	if ([strTemp length] != size*size)
	{
		DAssert([strTemp length] == size*size, @"initWithSavedString:answerNums length=%d", [strTemp length]);
		return nil;
	}
	[SudokuGame set9x9Nums:strTemp size:size nums:&answerNums[0][0]];
	strTemp = [listItems objectAtIndex:7];
	if ([strTemp length] != size*size)
	{
		DAssert([strTemp length] == size*size, @"initWithSavedString:fixNums length=%d", [strTemp length]);
		return nil;
	}
	[SudokuGame set9x9Nums:strTemp size:size nums:&fixNums[0][0]];
	
	[self printNums];
/*
#ifdef DEBUG
	isGameFinished = NO;
	fixNums[0][0] = 0;
#endif
*/
	
	strTemp = [listItems objectAtIndex:8];
	[SudokuGame set9x9Strs:strTemp size:size strs:&memoNums[0][0][0]];
	
    if ([listItems count] > 12) {
        [SudokuGame set9x9Nums:[listItems objectAtIndex:12]	size:size nums:&mapNums[0][0]];
    } else {	// 하위호환을 위해서 default map을 제공한다.
        NSString *default9x9Map = @"111222333111222333111222333444555666444555666444555666777888999777888999777888999";
        [SudokuGame set9x9Nums:default9x9Map size:size nums:&mapNums[0][0]];
    }
	// zzzzzzzzzzzzzzzzzzzzz
	map = [[SudokuMap alloc] initWithMapArray:(NSInteger*)mapNums size:size];
	if (!map)
		return nil;
		
	if ([listItems count] > 13)	// bAutoMemo
	{
		bAutoMemo = [[listItems objectAtIndex:13] integerValue] == 1 ? YES : NO;
	} else {
		bAutoMemo = NO;
	}
	bAutoMemoUndoLog = YES;
	
	if ([listItems count] > 14)	// hint counter
	{
		hintTime = [[listItems objectAtIndex:14] floatValue];
	} else {
		hintTime = SECONDSFORFREEHINT;
	}
	
	

	
	sudokuUndo = [[SudokuUndo alloc] initWithSaveData];
#ifdef KILLERSUDOKU
	kmap = [[KillerMap alloc] initWithSaveData];
	if (!kmap)
		return nil;
#endif

	return self;
	
}



- (void) clearAllNums
{

	for (int y=0; y<size; y++) {
		for (int x=0; x<size; x++) {
			fixNums[x][y] = 0;
			memoNums[x][y][0] = '\0';
		}
	}
	[self initAutoMemo];
    [sudokuUndo clear];

}

- (NSInteger) countBlankCells
{
	NSInteger num = 0;
	for (int y=0; y<size; y++) {
		for (int x=0; x<size; x++) {
			if (puzzleNums[x][y] == 0 && fixNums[x][y] == 0)
				num++;
		}
	}	
	
	countBlank = num;
	
	return num;
}

- (NSInteger) countFixCells
{
	NSInteger num = 0;
	for (int y=0; y<size; y++) {
		for (int x=0; x<size; x++) {
			if (fixNums[x][y] > 0)
				num++;
		}
	}	
	
	countFixNums = num;
	
	return num;
}

- (BOOL) checkUniqueNumXYAndMap:(NSInteger)xPos y:(NSInteger)yPos
{
	NSInteger numCheck = fixNums[xPos][yPos];
    NSInteger numCompare;
    int x, y;
	
	//가로,세로,Map 같은 숫자 비교
	
	for (y=0; y<size; y++) {
		for (x=0; x<size; x++) {
			if (x == xPos && y == yPos)
				continue;   // 같은 셀은 비교할 필요가 없음
			if (x == xPos || y == yPos || [self isSameMap:xPos y:yPos x2:x y2:y])   // 중복되면 안되는 셀
			{
				numCompare = fixNums[x][y] ? fixNums[x][y] : puzzleNums[x][y];
				if (numCheck == numCompare)
					return NO;  // 중복된 셀이 출현했다.
			}
		}
	}
	return YES;
}

#ifdef GTSUDOKU

- (BOOL) checkGreatThan:(NSInteger)xPos y:(NSInteger)yPos
{
    NSInteger numCheck = fixNums[xPos][yPos];
    NSInteger numCompare;
    int x, y;
    BOOL bCheck;
    BOOL bCompare;
    
    x = xPos;
    y = yPos;
    if (x > 0 && [self isSameMap:xPos y:yPos x2:x-1 y2:y])  // 왼쪽
    {
        bCheck = answerNums[x][y] > answerNums[x-1][y];     // 문제로 제시한 부등호
        numCompare = [self getDisplayNum:x-1 y:y];
        bCompare = numCheck > numCompare;
        if (numCompare && bCheck != bCompare)
        {
            return NO;  // 부등호가 안맞다.
        }
    }
    if (x < size-1 && [self isSameMap:xPos y:yPos x2:x+1 y2:y])  // 오른쪽
    {
        bCheck = answerNums[x][y] > answerNums[x+1][y];     // 문제로 제시한 부등호
        numCompare = [self getDisplayNum:x+1 y:y];    // 화면의 숫자
        bCompare = numCheck > numCompare;
        if (numCompare && bCheck != bCompare)
            return NO;  // 부등호가 안맞다.
    }
    if (y > 0 && [self isSameMap:xPos y:yPos x2:x y2:y-1])  // 위쪽
    {
        bCheck = answerNums[x][y] > answerNums[x][y-1];     // 문제로 제시한 부등호
        numCompare = [self getDisplayNum:x y:y-1];    // 화면의 숫자
        bCompare = numCheck > numCompare;
        if (numCompare && bCheck != bCompare)
            return NO;  // 부등호가 안맞다.
    }
    if (y < size-1 && [self isSameMap:xPos y:yPos x2:x y2:y+1])  // 아래쪽
    {
        bCheck = answerNums[x][y] > answerNums[x][y+1];     // 문제로 제시한 부등호
        numCompare = [self getDisplayNum:x y:y+1];    // 화면의 숫자
        bCompare = numCheck > numCompare;
        if (numCompare && bCheck != bCompare)
            return NO;  // 부등호가 안맞다.
    }

    return YES;
}

    
- (BOOL) checkGreatThanCorrect:(NSInteger)xPos y:(NSInteger)yPos
{
    NSInteger numCheck = fixNums[xPos][yPos];
    
    if (puzzleNums[xPos][yPos] > 0)
        return YES; // 문제는 언제나 참
    
    if (numCheck == 0)
        return YES; // 아직 끝난 게임이 아님
    
	
	if ([self checkUniqueNumXYAndMap:xPos y:yPos] == NO)
		return NO;
	

    if ([self checkGreatThan:xPos y:yPos] == NO)
        return NO;
    
    return YES;
}
#endif


#ifdef KILLERSUDOKU

- (BOOL) isWrongSumCell:(NSInteger)num cell:(KillerCage*) cell
{
	if (cell == NULL)
	{
		DAssert(cell, @"[kmap getCageData:%d] => NULL", num);
		return NO;
	}
	
	int n=0;
	NSInteger arNum[4];		// Cage는 최대 4개 셀만 지원
	NSInteger value;
	NSInteger sum = 0, multi = 1;
	
	for (int y=0; y<size; y++)
	{
		for (int x=0; x<size; x++)
		{
			if ([kmap getCageNumber:x yPos:y] == num)
			{
				if (fixNums[x][y] == 0 && puzzleNums[x][y] == 0)
					return NO;
				value = fixNums[x][y] ? fixNums[x][y] : puzzleNums[x][y];
				
				sum += value;
				multi *= value;
				arNum[n] = value;
				n++;
			}
		}
	}
	
#ifdef CALCUDOKU
	if (cell->sign == CS_MULTIPLE)
	{
		return (cell->sum != multi);
	}
	else if (cell->sign == CS_MINUS)
	{
		DAssert(n == 2, @"n must be 2");
		return (cell->sum != (MAX(arNum[0], arNum[1]) - MIN(arNum[0], arNum[1])));
	}
	else if (cell->sign == CS_DIVIDE)
	{
		DAssert(n == 2, @"n must be 2");
		return (cell->sum != (MAX(arNum[0], arNum[1]) / MIN(arNum[0], arNum[1])));
	}
	
#endif
	
	
	if (cell->sum != sum)
		return YES;
	
	return NO;
}


- (BOOL) isWrongSumCellXY:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSInteger num = [kmap getCageNumber:xPos yPos:yPos];
	KillerCage *cell = [kmap getCageData:num];
	
	return [self isWrongSumCell:num cell:cell];
	

}

// 나중에 셀의 후보 숫자를 보기 위해서 사용한다.
- (NSInteger) countCellInSum:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSInteger num = [kmap getCageNumber:xPos yPos:yPos];
	NSInteger count = 0;
	
	for (int y=0; y<size; y++)
	{
		for (int x=0; x<size; x++)
		{
			if ([kmap getCageNumber:x yPos:y] == num)
			{
				count++;
			}
		}
	}
	return count;
}


- (NSInteger) countUncorrectSum
{
	KillerCage *cell;
	NSInteger uncorrect=0;
	
	for (int i=0; (cell = [kmap getCageData:i]) != NULL; i++)
	{
		if ([self isWrongSumCell:i cell:cell] == YES)
		{
			uncorrect++;
		}
	}
	
	return uncorrect;
}

#endif



#ifdef KILLERSUDOKU
- (NSInteger) clearGameCheckAllCells:(NSInteger*)wrongSums
#else
- (NSInteger) clearGameCheckAllCells
#endif
{
	NSInteger unfixedCells = 0;
	NSInteger wrongCells = 0;
    NSInteger strangeCells = 0;

    
    for (int y=0; y<size; y++) {
		for (int x=0; x<size; x++) {
			if (fixNums[x][y] == 0 && puzzleNums[x][y] == 0) {
				//DLog(@"unFixedCell: fixNums[%d][%d] = %d, answerNums[%d][%d] = %d", x, y, fixNums[x][y], x, y, answerNums[x][y]);
				unfixedCells++;
			}
        }
    }
    if (unfixedCells > 0)
		return -1; // not fixed yet;
    
	for (int y=0; y<size; y++) {
		for (int x=0; x<size; x++) {
			if (puzzleNums[x][y] == 0)
            {
#ifdef GTSUDOKU // 답이 2개일지도 모르니
                if ([self checkGreatThanCorrect:x y:y] == NO)
                {
                    DLog(@"wrongCell: fixNums[%d][%d] = %d, answerNums[%d][%d] = %d", x, y, fixNums[x][y], x, y, answerNums[x][y]);
                    wrongCells++;
                } else {
                    if (answerNums[x][y] != fixNums[x][y])
                    {
                        strangeCells++;
                        DLog(@"StangeCell 발견");
                    }
                }
#elif (defined KILLERSUDOKU)
                if ([self checkUniqueNumXYAndMap:x y:y] == NO)
                {
                    DLog(@"wrongCell: fixNums[%d][%d] = %d, answerNums[%d][%d] = %d", x, y, fixNums[x][y], x, y, answerNums[x][y]);
                    wrongCells++;
                } else {
                    if (answerNums[x][y] != fixNums[x][y])
                    {
                        strangeCells++;
                        DLog(@"StangeCell 발견");
                    }
                }
#else
				if (answerNums[x][y] != fixNums[x][y]) {
					DLog(@"wrongCell: fixNums[%d][%d] = %d, answerNums[%d][%d] = %d", x, y, fixNums[x][y], x, y, answerNums[x][y]);
					wrongCells++;
				}
#endif
			}
		}
	}
	
#ifdef KILLERSUDOKU
	if (wrongCells == 0)
	{
		*wrongSums = [self countUncorrectSum];
		if (*wrongSums > 0)
			return 0;		// wrong sum갯수는 paprameter로 넘겨준다.
	}
#endif

	if (wrongCells > 0)
		return wrongCells;	// You've finisehd but You have wrong cell;
	
	lastTime = [[NSDate date]timeIntervalSince1970];
	isGameFinished = YES;

	[self saveData];
	return 0;	
}



- (NSInteger) getMapNums:(NSInteger)x y:(NSInteger)y;
{
    return mapNums[x][y];
}

- (BOOL) isSameMap:(NSInteger)x y:(NSInteger)y x2:(NSInteger)x2 y2:(NSInteger)y2
{
	if (x < 0 || x >= size) return NO;
	if (y < 0 || y >= size) return NO;
	if (x2 < 0 || x2 >= size) return NO;
	if (y2 < 0 || y2 >= size) return NO;
	
    return mapNums[x][y] == mapNums[x2][y2];
}
#ifdef KILLERSUDOKU
- (BOOL) isSameColor:(NSInteger)x y:(NSInteger)y x2:(NSInteger)x2 y2:(NSInteger)y2
{
	if (x < 0 || x >= size) return NO;
	if (y < 0 || y >= size) return NO;
	if (x2 < 0 || x2 >= size) return NO;
	if (y2 < 0 || y2 >= size) return NO;
	
    return [kmap getColor:x yPos:y] == [kmap getColor:x2 yPos:y2];
}
#endif

- (NSInteger) getPuzzleNums:(NSInteger)x y:(NSInteger)y
{
	return puzzleNums[x][y];
}

- (NSInteger) getAnswerNums:(NSInteger)x y:(NSInteger)y
{
    return answerNums[x][y];
}

- (NSInteger) getDisplayNum:(NSInteger)x y:(NSInteger)y
{
    if (puzzleNums[x][y])
        return puzzleNums[x][y];
    else if (fixNums[x][y])
        return fixNums[x][y];
    else
        return 0;

}

- (BOOL) isPuzzleNum:(NSInteger)x y:(NSInteger)y
{
	return puzzleNums[x][y] > 0;
}

- (NSInteger) getFixNums:(NSInteger)x y:(NSInteger)y
{
	return fixNums[x][y];	
}



- (void) setHintNum:(NSInteger)x y:(NSInteger)y
{
	if (puzzleNums[x][y] == 0)
	{
		//fixNums[x][y] = answerNums[x][y];
		[self setFixNums:answerNums[x][y] x:x y:y];
	}	
}


- (BOOL)conflictNumber:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
    int x, y;
    for (x = 0, y = yPos; x < size; x++)
    {
        if (x != xPos && [self getDisplayNum:x y:y] == num)
            return YES;
    }
    for (x = xPos, y = 0; y < size; y++)
    {
        if (y != yPos && [self getDisplayNum:x y:y] == num)
            return YES;
    }
    
    
    for (int x=0; x<size; x++)
    {
        for (int y=0; y<size; y++)
        {
            if ((x != xPos || y != yPos) &&
                [self isSameMap:x y:y x2:xPos y2:yPos] == YES &&
                [self getDisplayNum:x y:y] == num)
            {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void) setFixNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	//DLog(@"### setFixNums(%d,%d)->%d", x, y, num);
	
    if (puzzleNums[x][y] > 0)               // 문제칸은 Set할 수 없다.
        return;
    
    
	if (fixNums[x][y] == num)				// 이미 같은 숫자로 fix되어 있음
		return;

	NSInteger oldnum = fixNums[x][y];
	fixNums[x][y] = num;
    if (num == 0)   // del num
    {
        [sudokuUndo delNum:oldnum x:x y:y];
    } else {
        [sudokuUndo addNum:num oldnum:oldnum x:x y:y];
    }

	if (oldnum > 0)		// 복구 필요
	{
		NSMutableArray	*arrayAutoUndo = [sudokuUndo getAutoUndo:oldnum x:x y:y];
		NSInteger count = [arrayAutoUndo count];
		UndoData* data;
		
		for (int i=0; i<count; i++)
		{
			data = [arrayAutoUndo objectAtIndex:i];
			if (data.mode == UNDOMODE_AUTOMEMO_DEL)
			{
				// 비교해야할 셀에서 입력된 메모는 입력하면 안된다.
				if ([self conflictNumber:data.num xPos:data.x yPos:data.y] == NO)
				{
					[self addMemoNums:data.num x:data.x y:data.y];
					[sudokuUndo addAutoMemo:data.num x:data.x y:data.y];
				}
			}
			else if (data.mode == UNDOMODE_AUTOMEMO_ADD)
			{
				[self delMemoNums:data.num x:data.x y:data.y];
				[sudokuUndo delAutoMemo:data.num x:data.x y:data.y];
			}
		}
		
		[arrayAutoUndo release];		
	}
	
	// ???
	if (num > 0)
		[self updateAutoMemo:num xPos:x yPos:y];

	
	
	//[self saveData];
}

- (BOOL) conflictMemoCompare:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	sXY	xy2[4];
	BOOL bComapare0, bComapare1;
	NSInteger numDispaly;
	
	if (xPos == 0 && yPos == 0)
	{
		DLog(@"");
	}
	
	xy2[0].x = xPos-1;	xy2[0].y = yPos;
	xy2[1].x = xPos+1;	xy2[1].y = yPos;
	xy2[2].x = xPos;	xy2[2].y = yPos+1;
	xy2[3].x = xPos;	xy2[3].y = yPos-1;
	
	for (int i=0; i<4; i++)
	{
		if ([self isSameMap:xPos y:yPos x2:xy2[i].x y2:xy2[i].y] == NO)
			continue;
		
		bComapare0 = [self getAnswerNums:xPos y:yPos] >
		[self getAnswerNums:xy2[i].x y:xy2[i].y];
		numDispaly = [self getDisplayNum:xy2[i].x y:xy2[i].y];
		if (numDispaly > 0)	// 고정된 번호와는 메모를 비교한다. (자동 삭제 시도?)
		{
			bComapare1 = num > numDispaly;
			
			if (bComapare0 != bComapare1)
				return YES;
			/*} else if ([sudokuGame emptyMemo:xy2[i].x y:xy2[i].y] == NO) {	// 메모와 비교
			 if (bComapare0)	// 원래 위치가 큰 것
			 {
			 if (num <= [sudokuGame smallestMemo:xy2[i].x y:xy2[i].y])
			 return YES;
			 } else {
			 if (num >= [sudokuGame biggestMemo:xy2[i].x y:xy2[i].y])
			 return YES;
			 }	*/
		} else {
			// empty memo
		}
		
	}
	return NO;
}


- (void) cancelFixNums:(NSInteger)x y:(NSInteger)y
{
	[self setFixNums:0 x:x y:y];
	[self saveData];
}

- (BOOL) emptyMemo:(NSInteger)x y:(NSInteger)y
{
	return memoNums[x][y][0] == '\0';
}

- (NSInteger) smallestMemo:(NSInteger)x y:(NSInteger)y
{
	return memoNums[x][y][0] - '0';
}

- (NSInteger) biggestMemo:(NSInteger)x y:(NSInteger)y
{
	NSInteger len = strlen(memoNums[x][y]);
	
	return memoNums[x][y][MAX(len-1, 0)]  - '0';
}

- (char*) getMemoNums:(NSInteger)x y:(NSInteger)y
{
    if ([self isPuzzleNum:x y:y])               // 문제칸은 Memo가 있을 수 없다.
        return "";
    
    
	return (char*)(memoNums[x][y]);
}

- (BOOL) beMemoNums:(NSInteger)num  x:(NSInteger)x y:(NSInteger)y
{
    if ([self isPuzzleNum:x y:y])              // 문제칸은 Memo가 있을 수 없다.
        return FALSE;
 
	if ([self getFixNums:x y:y] > 0)			// 사용자가 입력한 칸은 Memo가 아니다.
		return FALSE;
    
    
	char *s = memoNums[x][y];
	char *p = strchr(s, num+'0');

	return p != NULL;
}

- (void) addMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    if ([self isPuzzleNum:x y:y])           // 문제칸은 Memo 할 수 없다.
        return;
    
    [SudokuNum insertNumToStr:memoNums[x][y] num:num];

	//[self saveData];
}

- (BOOL) setMemoNumsForAutoMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    if ([self isPuzzleNum:x y:y])           // 문제칸은 Memo 할 수 없다.
        return NO;
    if ([self getFixNums:x y:y] > 0)           // 문제칸은 Memo 할 수 없다.
        return NO;
    
	if (strlen(memoNums[x][y]) == 1)
		return NO;
	
	char *p = memoNums[x][y];
	NSInteger delNum;
	
	if (bAutoMemoUndoLog)
	{
		while (*p)
		{
			delNum = *p - '0';
			if (delNum != num)
			{
				[sudokuUndo delAutoMemo:delNum x:x y:y];
			}
			p++;
		}
	}
	
	
    memoNums[x][y][0] = '0' + num;
    memoNums[x][y][1] = '\0';
	
	
	return YES;
}

- (void) delMemoNumsForAutoMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    if ([self isPuzzleNum:x y:y])               // 문제칸은 Memo를 지울 수 없다.
        return;
    
	if (strlen(memoNums[x][y]) > 1)	// 하나 남은 메모는 지우지 않는다.
	{
		if ([SudokuNum deleteNumFromStr:memoNums[x][y] num:num])
		{
			if (bAutoMemoUndoLog)
			{
				[sudokuUndo delAutoMemo:num x:x y:y];
			}
		}
	}
}


- (void) delMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    if ([self isPuzzleNum:x y:y])               // 문제칸은 Memo를 지울 수 없다.
        return;
    
	if (strlen(memoNums[x][y]) <= 1)
	{
		DLog(@"############(%d,%d,%s)", x, y, memoNums[x][y]);
	}
	
	//DLog(@"delMemoNums(%d-%d,%d)%s", num, x, y, memoNums[x][y]);
	[SudokuNum deleteNumFromStr:memoNums[x][y] num:num];
	//DLog(@"	=> %s", memoNums[x][y]);
	
	[self updateAutoMemoOnlyUnique];	// 메모를 삭제할 때만 자동으로 삭제할 메모가 생긴다.


	//[self saveData];
}


- (void) revertMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    if ([self isPuzzleNum:x y:y])                // 문제칸은 Memo 할 수 없다.
        return;
    
    
	char *s = memoNums[x][y];
	char c = num + '0';
	
	if (strchr(s, c)) {
		[self delMemoNums:num x:x y:y];
        [sudokuUndo delMemo:num x:x y:y];;
	} else {
		[self addMemoNums:num x:x y:y];
        [sudokuUndo addMemo:num x:x y:y];;
	}
}

- (void) clearMemoNums:(NSInteger)x y:(NSInteger)y
{
   if ([self isPuzzleNum:x y:y])                // 문제칸은 Memo 할 수 없다.
        return;
    
    
	char *s = memoNums[x][y];
	*s = '\0';
}

#define kSudokuGame		@"sudokugame"


+ (void) get9x9Nums:(char*)str	size:(NSInteger)size nums:(NSInteger*)nums
{
	int x, y;
    
    for (y=0; y<size; y++)
    {
        for (x=0; x<size; x++)     // 호환을 위해서 순서를 맞춘다.
        {
            *str++ = ('0' + nums[x + y*MAXMAPSIZE]);
        }
    }
    
    
	*str = '\0';
}

+ (void) set9x9Nums:(NSString *)str	size:(NSInteger)size nums:(NSInteger*)nums
{
	char *s	= (char*)[str cStringUsingEncoding:NSASCIIStringEncoding];
	int x, y;
    
    for (y=0; y<size; y++)
    {
        for (x=0; x<size; x++)
        {
            nums[x + y*MAXMAPSIZE] = *s++ - '0';
        }
    }

}




+ (void) get9x9Strs:(char*)str	size:(NSInteger)size strs:(char*)strs
{
	int len;
	
	for (int i=0; i<MAXMAPSIZE*MAXMAPSIZE; i++)	// 호환을 위해서 사용하지 않는 메모도 저장하고 가져온다.
	{
		len = strlen(strs);
		if (len)
			strcpy(str, strs);
		strcat(str, "|");
		str += len+1;
		strs += MAXMAPSIZE+1;	// 메모의 최대 길이
	}
	*str = '\0';
}

+ (void) set9x9Strs:(NSString *)str	size:(NSInteger)size strs:(char*)strs
{
	NSArray *listItems = [str componentsSeparatedByString:@"|"];

	for (int i=0; i<MAXMAPSIZE*MAXMAPSIZE && i<listItems.count; i++)		// 호환을 위해서 사용하지 않는 메모도 저장하고 가져온다.
	{
		strcpy(strs, [[listItems objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding]);
		strs += MAXMAPSIZE+1;
	}
}


- (void) saveData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	char zStrMapNum[MAXMAPSIZE*MAXMAPSIZE+1] = "";
	char zStrPuzzleNum[MAXMAPSIZE*MAXMAPSIZE+1] = "";
	char zStrAnswerNum[MAXMAPSIZE*MAXMAPSIZE+1] = "";
	char zStrFixNum[MAXMAPSIZE*MAXMAPSIZE+1] = "";
	char zStrMemoNum[MAXMAPSIZE*MAXMAPSIZE*(MAXMAPSIZE*MAXMAPSIZE+1)+1] = "";
	
	[SudokuGame get9x9Nums:zStrMapNum       size:size   nums:&mapNums[0][0]];
	[SudokuGame get9x9Nums:zStrPuzzleNum	size:size   nums:&puzzleNums[0][0]];
	[SudokuGame get9x9Nums:zStrAnswerNum	size:size   nums:&answerNums[0][0]];
	[SudokuGame get9x9Nums:zStrFixNum		size:size   nums:&fixNums[0][0]];
	[SudokuGame get9x9Strs:zStrMemoNum		size:size   strs:&memoNums[0][0][0]];
	
	NSString *str = [NSString stringWithFormat:
					 @"%d,%f,%f,%f,%d,%s,%s,%s,%s,%@,%d,%d,%s,%d,%f",
					 gameLevel,	
					 startTime,	
					 lastTime,	
					 gameTime,	
					 isGameFinished ? 1 : 0,
					 (char*)zStrPuzzleNum,
					 (char*)zStrAnswerNum,
					 (char*)zStrFixNum,
					 (char*)zStrMemoNum,
					 @"",//strUndo,
					 countHint,
                     size,                  // 9칸?
                     (char*)zStrMapNum,
					 bAutoMemo?1:0,
					 hintTime];
					 
	//DLog(@"saveData(%@)", str);
	
	[defaults setObject:str forKey:kSudokuGame];

	[sudokuUndo saveData];
#ifdef KILLERSUDOKU
	[kmap saveData];
#endif

}

+ (SudokuGame*) loadData
{
 //   return nil;
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *str = (NSString*)[defaults stringForKey:kSudokuGame];	
	if (str == nil) {
		DLog(@"loadData Failed");
		return nil;
	}
	
	DLog(@"loadData(%@)", str);
	
	SudokuGame* sudokuGame = [[SudokuGame alloc] initWithSavedString:str];
	
	// sudokuGame.bAutoMemo = YES;
	//[sudokuGame initAutoMemo]; 메모를 그대로 읽어들여야 한다.
	
	return sudokuGame;
}

- (NSInteger) updateGameElapsedTime
{
	if (!isGameFinished)
		gameTime += 1;
	
	return (NSInteger) gameTime;
}

- (NSInteger) updateHintElapsedTime
{
	if (!isGameFinished)
		hintTime -= 1;
	
	return (NSInteger) hintTime;
}

- (void) resetHintTime
{
	hintTime = SECONDSFORFREEHINT;
	countHint += 1;
	[self saveData];
}

- (void) addUndoLog:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
/*	NSString *str = [strUndo stringByAppendingFormat:@"%d%d%d", xPos, yPos, num];

	[strUndo release];
	strUndo = str;
	
	[strUndo retain];	// zzzzzzzzzzzzzzzzzzz
 */
}

- (NSInteger) getIntegerAtIndexFromString:(NSString *)str index:(NSUInteger)index
{
	unichar c = [str characterAtIndex:index];
	
	return c-'0';
}



- (CGPoint) runUndo
{
	BOOL bAuto = NO;
    CGPoint pointLastUndoPos;
    
    UndoData *undoData = [[UndoData alloc] init];
    
	do 
	{
		bAuto = NO;
		if ([sudokuUndo getUndo:undoData] == NO)
		{
			// undo failure
			pointLastUndoPos.x = -1;
			pointLastUndoPos.y = -1;
		} else {
			pointLastUndoPos.x = (CGFloat)undoData.x;
			pointLastUndoPos.y = (CGFloat)undoData.y;
			
			switch (undoData.mode) {
				case UNDOMODE_NUM_ADD:
					fixNums[undoData.x][undoData.y] = undoData.oldnum;
					break;
				case UNDOMODE_NUM_DEL:
					fixNums[undoData.x][undoData.y] = undoData.oldnum;
					break;
				case UNDOMODE_MEMO_ADD:
					[self delMemoNums:undoData.num x:undoData.x y:undoData.y];
					break;
				case UNDOMODE_MEMO_DEL:
					[self addMemoNums:undoData.num x:undoData.x y:undoData.y];
					break;
				case UNDOMODE_AUTOMEMO_ADD:
					[self delMemoNums:undoData.num x:undoData.x y:undoData.y];
					bAuto = YES;
					break;
				case UNDOMODE_AUTOMEMO_DEL:
					[self addMemoNums:undoData.num x:undoData.x y:undoData.y];
					bAuto = YES;
					break;
				default:
					break;
			}
		}
	} while (bAuto);
	//[self initAutoMemo];
	// automemo 일괄 undo를 해야 한다.
	
	[undoData release];
	
    return pointLastUndoPos;
    

}



- (CGPoint) runRedo
{
	BOOL bAutoCheck = NO;
    CGPoint pointLastUndoPos;
    
    UndoData *undoData = [[UndoData alloc] init];
    
    if ([sudokuUndo getRedo:undoData] == NO)
    {
        // redo failure
        pointLastUndoPos.x = -1;
        pointLastUndoPos.y = -1;
    } else {
        pointLastUndoPos.x = (CGFloat)undoData.x;
        pointLastUndoPos.y = (CGFloat)undoData.y;
        
        switch (undoData.mode) {
            case UNDOMODE_NUM_ADD:
                fixNums[undoData.x][undoData.y] = undoData.num;
				bAutoCheck = YES;
                break;
            case UNDOMODE_NUM_DEL:
                fixNums[undoData.x][undoData.y] = 0;
				// automemo 일괄 redo를 해야 한다.
				bAutoCheck = YES;
                break;
            case UNDOMODE_MEMO_ADD:
                [self addMemoNums:undoData.num x:undoData.x y:undoData.y];
                break;
            case UNDOMODE_MEMO_DEL:
                [self delMemoNums:undoData.num x:undoData.x y:undoData.y];
                break;
            case UNDOMODE_AUTOMEMO_ADD:
				[sudokuUndo printData];
				//DAssert(0, @"runRedo");		// redo시는 처음부터 auto memo를 만나면 안된다.
                [self addMemoNums:undoData.num x:undoData.x y:undoData.y];
				bAutoCheck = YES; // ???
                break;
            case UNDOMODE_AUTOMEMO_DEL:
				[sudokuUndo printData];
				//DAssert(0, @"runRedo");		// redo시는 처음부터 auto memo를 만나면 안된다.
                [self delMemoNums:undoData.num x:undoData.x y:undoData.y];
				bAutoCheck = YES; // ???
                break;
            default:
                break;
		}
    }
	
	if (bAutoCheck)
	{
		BOOL bFinished = NO;
		
		while (bFinished == NO)
		{
			if ([sudokuUndo getRedo:undoData] == NO)
			{
				bFinished = YES;
			} else {
				switch (undoData.mode) {
					case UNDOMODE_AUTOMEMO_ADD:
						[self addMemoNums:undoData.num x:undoData.x y:undoData.y];
						//pointLastUndoPos.x = (CGFloat)undoData.x;
						//pointLastUndoPos.y = (CGFloat)undoData.y;
						break;
					case UNDOMODE_AUTOMEMO_DEL:
						[self delMemoNums:undoData.num x:undoData.x y:undoData.y];
						//pointLastUndoPos.x = (CGFloat)undoData.x;
						//pointLastUndoPos.y = (CGFloat)undoData.y;
						break;
					default:
						[sudokuUndo getUndo:undoData];	// 마지막 redo 되돌리기
						bFinished = YES;
						break;
				}
			}
		}
	}
	
	[undoData release];
    
    return pointLastUndoPos;
   
}



@end
