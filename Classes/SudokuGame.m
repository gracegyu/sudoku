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
#import "Locale.h"

@implementation SudokuGame

//@synthesize strUndo;
@synthesize sudokuUndo;
@synthesize size;
@synthesize sudokuType;
@synthesize gameLevel;
@synthesize startTime;
@synthesize lastTime;
@synthesize gameTime;
@synthesize hintTime;
@synthesize isGameFinished;
@synthesize isCloseButton;
@synthesize countBlank;
@synthesize countFixNums;
@synthesize countHint;
@synthesize bAutoMemo;
@synthesize kmap;
@synthesize bDailyPuzzle;
@synthesize bUserInputStart;
@synthesize bFinishAlert;



- (void)dealloc
{
    
    [sudokuUndo release];
    [map release];
    if (kmap)
        [kmap release];
	
	[super dealloc];
}

- (NSInteger) randNum:(NSInteger) num
{
    return ((unsigned int)arc4random()) % num;
}


- (NSInteger) getDefHintCount:(NSInteger)sizeTable
{
    return sizeTable > 6 ? NUM_DEFHINT9 : NUM_DEFHINT6;

}

- (NSInteger) countPuzzleNum
{
	NSInteger num = 0;
	
	for (NSInteger y=0; y<size; y++)
	{
		for (NSInteger x=0; x<size; x++)
		{
			if (puzzleNums[x][y] > 0)
				num += 1;
		}
	}
	return num;
}

- (NSInteger) countUserFixedNumX:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSInteger x = xPos;
	NSInteger y = yPos;
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
	NSInteger x = xPos;
	NSInteger y = yPos;
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
	NSInteger x = xPos;
	NSInteger y = yPos;
	NSInteger count = 0;
	
	NSInteger mapNum = mapNums[xPos][yPos];
	
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

static int	HandyCount[SUDOKUTYPE_MAX][10][5] = {
    { //SUDOKU_SUDOKU
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
    },
    { //SUDOKU_GT
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
    },
    { //SUDOKU_KILLER
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
    },
    { //SUDOKU_CALCU
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
    },
    { //SUDOKU_SYMBOL
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
    }
};
static int	HandyCountAuto[SUDOKUTYPE_MAX][10][5] = {
    { //SUDOKU_SUDOKU
        { 0, 0, 0, 0, 0 },   // 0
        { 0, 0, 0, 0, 0 },   // 1
        { 0, 0, 0, 0, 0 },   // 2
        { 0, 0, 0, 0, 0 },   // 3
        { 0, 1, 2, 3, 4 },   // 4
        { 0, 2, 4, 10, 15 }, // 5
#ifdef DEBUG
        { 0, 3, 5, 8, 30 },  // 6 ok
#else
        { 0, 3, 5, 8, 12 },  // 6 ok
#endif
        { 0, 3, 8, 16, 22 }, // 7
        { 0, 4, 9, 18, 25 }, // 8
#ifdef DEBUG
        { 0, 3, 5, 10, 55 }  // 9 ok
#else
        { 0, 3, 5, 10, 15 }  // 9 ok
#endif
    },
    { //SUDOKU_GT
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
    },
    { //SUDOKU_KILLER
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
    },
    { //SUDOKU_CALCU
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
    },
    { //SUDOKU_SYMBOL
        { 0, 0, 0, 0, 0 },   // 0
        { 0, 0, 0, 0, 0 },   // 1
        { 0, 0, 0, 0, 0 },   // 2
        { 0, 0, 0, 0, 0 },   // 3
        { 0, 1, 2, 3, 4 },   // 4
        { 0, 2, 4, 10, 15 }, // 5
#ifdef DEBUG
        { 0, 3, 5, 8, 30 },  // 6 ok
#else
        { 0, 3, 5, 8, 12 },  // 6 ok
#endif
        { 0, 3, 8, 16, 22 }, // 7
        { 0, 4, 9, 18, 25 }, // 8
#ifdef DEBUG
        { 0, 3, 5, 10, 55 }  // 9 ok
#else
        { 0, 3, 5, 10, 15 }  // 9 ok
#endif
    }
};

- (void) applyHandy
{
	NSInteger numRandom;
	NSInteger num;
	NSInteger handy = bAutoMemo ? HandyCountAuto[sudokuType][size][gameLevel] : HandyCount[sudokuType][size][gameLevel];
	
	
    if (sudokuType != SUDOKUTYPE_SUDOKU && sudokuType != SUDOKUTYPE_SYMBOL)
        memset(puzzleNums, 0, sizeof(puzzleNums));

	NSInteger countPuzzle = [self countPuzzleNum];
	NSInteger countBlankCell = size*size - countPuzzle;
	NSInteger countHandyTryFailed=0;

	for (NSInteger i=0; i<handy && countBlankCell>0 && countHandyTryFailed < MAX_HANDYTRAYFAIL; i++)
	{
		numRandom = [self randNum:countBlankCell];
		num = 0;
		
		// 자동Fix된 셀중에서 Random 번째의 셀을 찾는다.
		for (NSInteger y=0; y<size && num <= numRandom; y++)
		{
			for (NSInteger x=0; x<size && num <= numRandom; x++)
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

- (void) initData:(SUDOKUTYPE)type level:(GAMELEVEL)level
{
    sudokuType = SUDOKUTYPE_SUDOKU;     // default
	gameLevel = GAMELEVEL_NORMAL;       // default
	startTime = [[NSDate date]timeIntervalSince1970];
	lastTime = [[NSDate date]timeIntervalSince1970];
	gameTime = 0;
	hintTime = SECONDSFORFREEHINT;
	isGameFinished = NO;
	isCloseButton = NO;
	countHint = [self getDefHintCount:size];
    sudokuType = type;
	gameLevel = level;
	
	bAutoMemoUndoLog = YES;
    bDailyPuzzle = NO;
    bUserInputStart = NO;
    bFinishAlert = NO;
    
}

- (void) initGameTime
{
    startTime = [[NSDate date]timeIntervalSince1970];
    lastTime = [[NSDate date]timeIntervalSince1970];
    gameTime = 0;
}

- (void) initUndo
{
    [sudokuUndo clear];
}


- (void) deleteAutoMemoX:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	NSInteger x, y;
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
	NSInteger x, y;
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
	NSInteger x, y;
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


- (void) deleteAutoMemoCage:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
    if (sudokuType != SUDOKUTYPE_KILLER && sudokuType != SUDOKUTYPE_CALCU)
        return;
    
	NSInteger x, y;
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


- (BOOL) deleteAutoMemoUniqueNumX
{
	NSInteger x,y,k;
	NSInteger	countFound;
	NSInteger posFirstFound;
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
					DLog(@"deleteAutoMemoUniqueNumX(%ld,%ld)->%ld", (long)x, (long)y, (long)k);
					bRet = YES;
				}
			}
		}
	}
	return bRet;
}

- (BOOL) deleteAutoMemoUniqueNumY
{
	NSInteger x,y,k;
	NSInteger	countFound;
	NSInteger posFirstFound;
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
	NSInteger x,y,k,i,numMap;//,i,j;
	NSInteger	countFound;
	NSInteger posXFirstFound;
	NSInteger posYFirstFound;
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
					DLog(@"deleteAutoMemoUniqueNumXY(%ld,%ld)->%ld", (long)x, (long)y, (long)k);
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
    if (bAutoMemo == NO)
		return;
    
    if (size == SIZE_9 &&   // 나머지 에서는 너무 쉬워진다.
        (gameLevel == GAMELEVEL_VERYHARD || gameLevel == GAMELEVEL_HARD || sudokuType != SUDOKUTYPE_SUDOKU))
    {   // GTSudoku와 Killer Sudoku는 어렵기 때문에 항상 모든 Auto기능을 다 사용한다.
        while ([self deleteAutoMemoUniqueNum] == YES)
        {
            
        }
    }
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
		[self deleteAutoMemoCage:num xPos:xPos yPos:yPos];
		
	}
	
	[self updateAutoMemoOnlyUnique];

	// [self deleteAutoMemoSingleNum:]
	// Single num은 굳이 처리하지 않아도 사용자가 입력할 것이다.
    if (sudokuType == SUDOKUTYPE_KILLER || sudokuType == SUDOKUTYPE_CALCU)
    {
        // zzz 합계상 나올 수 없는 숫자는 지우기....
    }
}

- (void) initAutoMemo
{
	if (bAutoMemo == NO)
		return;
	
	bAutoMemoUndoLog = NO;

	char defaultMemo[16+1];
	
	NSInteger i;
	for (i=0; i<size; i++)
    {
		defaultMemo[i] = '1'+i;
    }
	defaultMemo[i] = '\0';
	
	for (NSInteger y=0; y<size; y++)
	{
		for (NSInteger x=0; x<size; x++)
		{
			strcpy(memoNums[x][y], defaultMemo);
		}
	}
	for (NSInteger y=0; y<size; y++)
	{
		for (NSInteger x=0; x<size; x++)
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

- (void) postData:(BOOL)handy
{
    if (handy)
        [self applyHandy];
    sudokuUndo = [[SudokuUndo alloc] init];
    
	
    if (sudokuType == SUDOKUTYPE_KILLER || sudokuType == SUDOKUTYPE_CALCU)
    {
        KillerCage *cell;
        for (NSInteger i=0; (cell = [kmap getCageData:i]) != NULL; i++)
        {
            cell->sum = 0;
            cell->sign = CS_PLUS;	// killer sudoku는 Plus만 지원한다.
            
            NSInteger n=0;
            NSInteger arNum[4];		// Cage는 최대 4개 셀만 지원
            
            for (NSInteger y=0; y<size; y++)
            {
                for (NSInteger x=0; x<size; x++)
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
            if (sudokuType == SUDOKUTYPE_CALCU)
            {
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
            }   // CALCU
            
        }   // KILLER
	
    }
	
	
	[self initAutoMemo];
	
	
	//[self saveData];

}

- (id) initWithSudokuBoard:(SudokuBoard*)sudoku type:(SUDOKUTYPE)type level:(GAMELEVEL)level automemo:(BOOL)automemo
{
	if ((self = [super init]) == nil)
		return nil;
	
	size = SIZE_9;
	bAutoMemo = automemo;
	[self initData:type level:level];
	map = [[SudokuMap alloc] initWithSize:size defmap:YES];
	
	NSInteger num;
    for (NSInteger y=0; y<size; y++) {
		for (NSInteger x=0; x<size; x++) {
            mapNums[x][y] = [map getMapNum:x y:y];
            num = ((int*)[sudoku getPuzzle])[y*size+x];
            
            if (num > 0) {		// fixed cell
				puzzleNums[x][y] = num;
				answerNums[x][y] = num; // 0
			} else {
				num = ((int*)[sudoku getSolution])[y*size+x];
                DAssert(num > 0, @"getAnswerNum(%ld) should be bigger than 0", (long)num);
				puzzleNums[x][y] = 0;				// blank
				answerNums[x][y] = num;
			}
            
			fixNums[x][y] = 0;
			memoNums[x][y][0] = '\0';
		}
	}

	[self postData:YES];
	
	
	return self;
	
}


- (id) initWithSudokuNum:(SudokuNum*)sudoku type:(SUDOKUTYPE)type level:(GAMELEVEL)level automemo:(BOOL)automemo
{
	if (!(self = [super init]))
		return nil;

	
    size = [sudoku getCellSize];
	[self initData:type level:level];
	bAutoMemo = automemo;
	map = [[SudokuMap alloc] initWithMap:[sudoku getMap]];
    if (sudokuType == SUDOKUTYPE_KILLER || sudokuType == SUDOKUTYPE_CALCU)
    {
        kmap = [[KillerMap alloc] initWithMap:[sudoku getKillerMap]];
    }
	NSInteger num;
    for (NSInteger y=0; y<size; y++) {
		for (NSInteger x=0; x<size; x++) {
            mapNums[x][y] = [[sudoku getMap] getMapNum:x y:y];
            num = [sudoku getPuzzleNum:x y:y];
            
            if (num > 0) {		// fixed cell
				puzzleNums[x][y] = num;
				answerNums[x][y] = num; // 0
			} else {
				num = [sudoku getAnswerNum:x y:y];
                if (level != GAMELEVEL_USERINPUT) {
                    // user input 게임은 answer 정보가 없다.
                    DAssert(num > 0, @"getAnswerNum(%ld) should be bigger than 0", (long)num);
                }
                puzzleNums[x][y] = 0;				// blank
				answerNums[x][y] = num;
			}
            
			fixNums[x][y] = 0;
			memoNums[x][y][0] = '\0';
		}
	}
	
	[self postData:YES];
	return self;

}


- (id) initWithFromServer:(NSString*)strData type:(SUDOKUTYPE)type  automemo:(BOOL)automemo
{
	if (!(self = [super init]))
		return nil;


// zzz 에러 처리 필요
    NSArray *listItems = [strData componentsSeparatedByString:@"\n"];
    
    if ([listItems count] < 6)
        return nil;
	
	size = [[listItems objectAtIndex:0] integerValue];
    SUDOKUTYPE nType = type;//[[listItems objectAtIndex:1] integerValue];
    GAMELEVEL nLevel = (GAMELEVEL)[[listItems objectAtIndex:2] integerValue];
    if (size != SIZE_6 && size != SIZE_9)
        return nil;    
    
    
	[self initData:nType level:nLevel];
	bAutoMemo = automemo;//NO;
    bDailyPuzzle = YES;
    bUserInputStart = NO;
    
    map = [[SudokuMap alloc] initWithSize:size defmap:YES]; // for automemo

    [SudokuGame set9x9Nums:[listItems objectAtIndex:3]	size:size nums:&mapNums[0][0]];
    [SudokuGame set9x9Nums:[listItems objectAtIndex:4]	size:size nums:&puzzleNums[0][0]];
    [SudokuGame set9x9Nums:[listItems objectAtIndex:5]	size:size nums:&answerNums[0][0]];
    
    
    if (nType == SUDOKUTYPE_KILLER || nType == SUDOKUTYPE_CALCU)
    {
        if ([listItems count] < 9)
            return nil;

        kmap = [[KillerMap alloc] initWithSize:size  randomFill:NO];
        [KillerMap setNumsPipeSize:[listItems objectAtIndex:6] size:MAXMAPSIZE*MAXMAPSIZE	nums:[kmap getMapArray]];
        [KillerMap setNumsPipeSize:[listItems objectAtIndex:7] size:MAXMAPSIZE*MAXMAPSIZE	nums:[kmap getColorArray]];
        [KillerMap setNumsPipe:[listItems objectAtIndex:8] size:MAXMAPSIZE*MAXMAPSIZE/2*sizeof(KillerCage)	nums:(NSInteger*)[kmap getCageArray]];
    }
    
	[self postData:NO];
	return self;
    
}

- (void) printNums
{
	NSString *str = [[NSString alloc] init];
	
	str = [str stringByAppendingString:@"\n"];
	str = [str stringByAppendingString:@"-------------------------------------\n"];
	for (NSInteger y=0; y<size; y++)
	{
		str = [str stringByAppendingString:@"|"];
		for (NSInteger x=0; x<size; x++)
		{
			if (puzzleNums[x][y] > 0)
				str = [str stringByAppendingFormat:@"[%ld]", (long)puzzleNums[x][y]];
			else
				str = [str stringByAppendingFormat:@"-%ld-", (long)answerNums[x][y]];
			str = [str stringByAppendingString:x%GRIDX == GRIDX-1?@"|":@" "];
			
		}
		str = [str stringByAppendingString:@"\n"];
		
		if ((y%GRIDY) == GRIDY-1)
			str = [str stringByAppendingString:@"-------------------------------------\n"];
		
	}
	DLog(@"puzzle & answer = %@", str);
}


- (id)initWithSavedString:(NSString *)str
{
	NSString *strTemp;
	
	if (!(self = [super init]))
		return nil;

	
	NSArray *listItems = [str componentsSeparatedByString:@","];
	
	gameLevel = (GAMELEVEL)[[listItems objectAtIndex:0] integerValue];
	if (gameLevel < GAMELEVEL_VERYHARD || gameLevel > GAMELEVEL_USERINPUT)
	{
		DAssert(gameLevel >= GAMELEVEL_VERYHARD && gameLevel <= GAMELEVEL_USERINPUT, @"initWithSavedString:gameLevel = %d", gameLevel);
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
		if ((size < SIZE_6 || size > SIZE_9) && size != SIZE_12 && size != SIZE_16)
		{
			//DAssert(size >= SIZE_6 && size <= SIZE_9, @"initWithSavedString:size = %d", size);
			return nil;
		}
    } else {
        size = 9;
    }
	
	strTemp = [listItems objectAtIndex:5];
	if ([strTemp length] != size*size)
	{
		//DAssert([strTemp length] == size*size, @"initWithSavedString:puzzleNums length=%d", [strTemp length]);
		return nil;
	}
	[SudokuGame set9x9Nums:strTemp size:size nums:&puzzleNums[0][0]];
	strTemp = [listItems objectAtIndex:6];
	if ([strTemp length] != size*size)
	{
		//DAssert([strTemp length] == size*size, @"initWithSavedString:answerNums length=%d", [strTemp length]);
		return nil;
	}
	[SudokuGame set9x9Nums:strTemp size:size nums:&answerNums[0][0]];
	strTemp = [listItems objectAtIndex:7];
	if ([strTemp length] != size*size)
	{
		//DAssert([strTemp length] == size*size, @"initWithSavedString:fixNums length=%d", [strTemp length]);
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
#ifdef SUDOKU16
        NSString *default9x9Map = @"111122223333444411112222333344441111222233334444111122223333444455556666777788885555666677778888555566667777888855556666777788889999::::;;;;<<<<9999::::;;;;<<<<9999::::;;;;<<<<9999::::;;;;<<<<====>>>>????@@@@====>>>>????@@@@====>>>>????@@@@====>>>>????@@@@";
#elif defined(SUDOKU12)
        NSString *default9x9Map = @"1111222233334444111122223333444411112222333344445555666677778888555566667777888855556666777788889999::::;;;;<<<<9999::::;;;;<<<<9999::::;;;;<<<<";
#else
        NSString *default9x9Map = @"111222333111222333111222333444555666444555666444555666777888999777888999777888999";
#endif
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
	
	if ([listItems count] > 15)	// sudokutype
	{
		sudokuType = (SUDOKUTYPE)[[listItems objectAtIndex:15] integerValue];
	} else {
		sudokuType = SUDOKUTYPE_SUDOKU;
	}

    if ([listItems count] > 16)	// is daily puzzle?
	{
		bDailyPuzzle = [[listItems objectAtIndex:16] integerValue] == 1 ? YES : NO;
	} else {
		bDailyPuzzle = NO;
	}

    if ([listItems count] > 17)	// is user input?
    {
        bUserInputStart = [[listItems objectAtIndex:17] integerValue] == 1 ? YES : NO;
    } else {
        bUserInputStart = NO;
    }
    
    
	sudokuUndo = [[SudokuUndo alloc] initWithSaveData];
    if (sudokuType == SUDOKUTYPE_KILLER || sudokuType == SUDOKUTYPE_CALCU)
    {
        kmap = [[KillerMap alloc] initWithSaveData];
        if (!kmap)
            return nil;
    }
	return self;
	
}


- (void) replayGames
{
    [self clearAllNums];
    [self initData:sudokuType level:gameLevel];
}


- (void) gotoFirst
{
	for (NSInteger y=0; y<size; y++) {
		for (NSInteger x=0; x<size; x++) {
			fixNums[x][y] = 0;
			memoNums[x][y][0] = '\0';
		}
	}
	[self initAutoMemo];
}

- (void) readyToReplay
{
    [self gotoFirst];
    
    [sudokuUndo gotoFirst];
        
}

- (void) clearAllNums
{
    [self gotoFirst];

    [sudokuUndo clear];

}

- (NSInteger) countBlankCells
{
	NSInteger num = 0;
	for (NSInteger y=0; y<size; y++) {
		for (NSInteger x=0; x<size; x++) {
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
	for (NSInteger y=0; y<size; y++) {
		for (NSInteger x=0; x<size; x++) {
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
    NSInteger x, y;
	
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



- (BOOL) checkGreatThan:(NSInteger)xPos y:(NSInteger)yPos
{
    NSInteger numCheck = fixNums[xPos][yPos];
    NSInteger numCompare;
    NSInteger x, y;
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





- (BOOL) isWrongSumCell:(NSInteger)num cell:(KillerCage*) cell
{
	if (cell == NULL)
	{
		DAssert(cell, @"[kmap getCageData:%ld] => NULL", (long)num);
		return NO;
	}
	
	NSInteger n=0;
	NSInteger arNum[4];		// Cage는 최대 4개 셀만 지원
	NSInteger value;
	NSInteger sum = 0, multi = 1;
	
	for (NSInteger y=0; y<size; y++)
	{
		for (NSInteger x=0; x<size; x++)
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
	
    if (sudokuType == SUDOKUTYPE_CALCU)
	{
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
    }
		
	
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
	
	for (NSInteger y=0; y<size; y++)
	{
		for (NSInteger x=0; x<size; x++)
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
	
	for (NSInteger i=0; (cell = [kmap getCageData:i]) != NULL; i++)
	{
		if ([self isWrongSumCell:i cell:cell] == YES)
		{
			uncorrect++;
		}
	}
	
	return uncorrect;
}





- (NSInteger) clearGameCheckAllCells:(NSInteger*)wrongSums
{
	NSInteger unfixedCells = 0;
	NSInteger wrongCells = 0;
    NSInteger strangeCells = 0;

    
    for (NSInteger y=0; y<size; y++)
    {
		for (NSInteger x=0; x<size; x++)
        {
			if (fixNums[x][y] == 0 && puzzleNums[x][y] == 0)
            {
				//DLog(@"unFixedCell: fixNums[%d][%d] = %d, answerNums[%d][%d] = %d", x, y, fixNums[x][y], x, y, answerNums[x][y]);
				unfixedCells++;
			}
        }
    }
    if (unfixedCells > 0)
		return -1; // not fixed yet;
    
	for (NSInteger y=0; y<size; y++)
    {
		for (NSInteger x=0; x<size; x++)
        {
			if (puzzleNums[x][y] == 0)
            {
                if (sudokuType == SUDOKUTYPE_SUDOKU && gameLevel == GAMELEVEL_USERINPUT)    // 사용자 정의 문제 종료 검사 방법
                {
                    if ([self checkUniqueNumXYAndMap:x y:y] == NO)
                    {
                        DLog(@"wrongCell: fixNums[%ld][%ld] = %ld, answerNums[%ld][%ld] = %ld", (long)x, (long)y, (long)fixNums[x][y], (long)x, (long)y, (long)answerNums[x][y]);
                        wrongCells++;
                    }
                }
                else if (sudokuType == SUDOKUTYPE_GT)    // 답이 2개일지도 모르니
                {
                    if ([self checkGreatThanCorrect:x y:y] == NO)
                    {
                        DLog(@"wrongCell: fixNums[%ld][%ld] = %ld, answerNums[%ld][%ld] = %ld", (long)x, (long)y, (long)fixNums[x][y], (long)x, (long)y, (long)answerNums[x][y]);
                        wrongCells++;
                    } else {
                        if (answerNums[x][y] != fixNums[x][y])
                        {
                            strangeCells++;
                            DLog(@"StangeCell 발견");
                        }
                    }
                }
                else if (sudokuType == SUDOKUTYPE_KILLER || sudokuType == SUDOKUTYPE_CALCU)
                {
                    if ([self checkUniqueNumXYAndMap:x y:y] == NO)
                    {
                        DLog(@"wrongCell: fixNums[%ld][%ld] = %ld, answerNums[%ld][%ld] = %ld", (long)x, (long)y, (long)fixNums[x][y], (long)x, (long)y, (long)answerNums[x][y]);
                        wrongCells++;
                    } else {
                        if (answerNums[x][y] != fixNums[x][y])
                        {
                            strangeCells++;
                            DLog(@"StangeCell 발견");
                        }
                    }
                }
                else if (sudokuType == SUDOKUTYPE_SUDOKU || sudokuType == SUDOKUTYPE_SYMBOL)
                {
                    if (answerNums[x][y] != fixNums[x][y]) {
                        DLog(@"wrongCell: fixNums[%ld][%ld] = %ld, answerNums[%ld][%ld] = %ld", (long)x, (long)y, (long)fixNums[x][y], (long)x, (long)y, (long)answerNums[x][y]);
                        wrongCells++;
                    }
                }
			}
		}
	}
	
    if (sudokuType == SUDOKUTYPE_KILLER || sudokuType == SUDOKUTYPE_CALCU)
    {
        if (wrongCells == 0)
        {
            *wrongSums = [self countUncorrectSum];
            if (*wrongSums > 0)
                return 0;		// wrong sum갯수는 paprameter로 넘겨준다.
        }
    }
    
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
- (BOOL) isSameColor:(NSInteger)x y:(NSInteger)y x2:(NSInteger)x2 y2:(NSInteger)y2
{
    if (sudokuType != SUDOKUTYPE_KILLER && sudokuType != SUDOKUTYPE_CALCU)
        return YES; // 무시
    
	if (x < 0 || x >= size) return NO;
	if (y < 0 || y >= size) return NO;
	if (x2 < 0 || x2 >= size) return NO;
	if (y2 < 0 || y2 >= size) return NO;
	
    return [kmap getColor:x yPos:y] == [kmap getColor:x2 yPos:y2];
}

- (NSInteger) getPuzzleNums:(NSInteger)x y:(NSInteger)y
{
	return puzzleNums[x][y];
}

- (NSInteger) getAnswerNums:(NSInteger)x y:(NSInteger)y
{
    return answerNums[x][y];
}

- (NSInteger*) getMapNumsArray
{
    return (NSInteger*) &(mapNums[0][0]);
}
- (NSInteger*) getPuzzleNumsArray
{
    return (NSInteger*) &(puzzleNums[0][0]);
}
- (NSInteger*) getAnswerNumsArray
{
    return (NSInteger*) &(answerNums[0][0]);
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
    NSInteger x, y;
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
    
    
    for (x=0; x<size; x++)
    {
        for (y=0; y<size; y++)
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
		
		for (NSInteger i=0; i<count; i++)
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
				[self delMemoNums:data.num x:data.x y:data.y bUndo:NO];
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

- (void) StartUserInputPuzzle
{
    for (NSInteger y=0; y<size; y++)
    {
        for (NSInteger x=0; x<size; x++)
        {
            if (fixNums[x][y] > 0)
            {
                puzzleNums[x][y] = fixNums[x][y];
                fixNums[x][y] = 0;
            }
        }
    }
    bUserInputStart = YES;
    
    
}

- (BOOL) conflictMemoCompare:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	sXY	xy2[4];
	BOOL bComapare0, bComapare1;
	NSInteger numDisplay;
	
	if (xPos == 0 && yPos == 0)
	{
		DLog(@"");
	}
	
	xy2[0].x = xPos-1;	xy2[0].y = yPos;
	xy2[1].x = xPos+1;	xy2[1].y = yPos;
	xy2[2].x = xPos;	xy2[2].y = yPos+1;
	xy2[3].x = xPos;	xy2[3].y = yPos-1;
	
	for (NSInteger i=0; i<4; i++)
	{
		if ([self isSameMap:xPos y:yPos x2:xy2[i].x y2:xy2[i].y] == NO)
			continue;
		
		bComapare0 = [self getAnswerNums:xPos y:yPos] >
		[self getAnswerNums:xy2[i].x y:xy2[i].y];
		numDisplay = [self getDisplayNum:xy2[i].x y:xy2[i].y];
		if (numDisplay > 0)	// 고정된 번호와는 메모를 비교한다. (자동 삭제 시도?)
		{
			bComapare1 = num > numDisplay;
			
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
	char *p = strchr(s, (char)num+'0');

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


- (void) delMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y bUndo:(BOOL)bUndo
{
    if ([self isPuzzleNum:x y:y])               // 문제칸은 Memo를 지울 수 없다.
        return;
    
	if (strlen(memoNums[x][y]) <= 1)
	{
		DLog(@"############(%ld,%ld,%s)", (long)x, (long)y, memoNums[x][y]);
	}
	
	//DLog(@"delMemoNums(%d-%d,%d)%s", num, x, y, memoNums[x][y]);
	[SudokuNum deleteNumFromStr:memoNums[x][y] num:num];
	//DLog(@"	=> %s", memoNums[x][y]);
	
    if (bUndo == NO)
        [self updateAutoMemoOnlyUnique];	// 메모를 삭제할 때만 자동으로 삭제할 메모가 생긴다.
}


- (void) revertMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    if ([self isPuzzleNum:x y:y])                // 문제칸은 Memo 할 수 없다.
        return;
    
    
	char *s = memoNums[x][y];
	char c = num + '0';
	
	if (strchr(s, c)) {
		[self delMemoNums:num x:x y:y bUndo:NO];
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
	NSInteger x, y;
    
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
	NSInteger x, y;
    
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
	NSInteger len;
	
	for (NSInteger i=0; i<MAXMAPSIZE*MAXMAPSIZE; i++)	// 호환을 위해서 사용하지 않는 메모도 저장하고 가져온다.
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

	for (NSInteger i=0; i<MAXMAPSIZE*MAXMAPSIZE && i<listItems.count; i++)		// 호환을 위해서 사용하지 않는 메모도 저장하고 가져온다.
	{
		strcpy(strs, [[listItems objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding]);
		strs += MAXMAPSIZE+1;
	}
}

#define kSudokuGameSaving		@"sudokugamesaving"


- (void) saveData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kSudokuGameSaving]) {      // Crashed last time
        [defaults setBool:NO forKey:kSudokuGameSaving];
        [defaults synchronize];
        return ;
    }
    [defaults setBool:YES forKey:kSudokuGameSaving];
    [defaults synchronize];

    
	char zStrMapNum[MAXMAPSIZE*MAXMAPSIZE+100] = "";            // for safe
	char zStrPuzzleNum[MAXMAPSIZE*MAXMAPSIZE+100] = "";         // for safe
	char zStrAnswerNum[MAXMAPSIZE*MAXMAPSIZE+100] = "";         // for safe
	char zStrFixNum[MAXMAPSIZE*MAXMAPSIZE+100] = "";            // for safe
	char zStrMemoNum[MAXMAPSIZE*MAXMAPSIZE*(MAXMAPSIZE*MAXMAPSIZE+1)+100] = ""; // for safe
	
	[SudokuGame get9x9Nums:zStrMapNum       size:size   nums:&mapNums[0][0]];
	[SudokuGame get9x9Nums:zStrPuzzleNum	size:size   nums:&puzzleNums[0][0]];
	[SudokuGame get9x9Nums:zStrAnswerNum	size:size   nums:&answerNums[0][0]];
	[SudokuGame get9x9Nums:zStrFixNum		size:size   nums:&fixNums[0][0]];
	[SudokuGame get9x9Strs:zStrMemoNum		size:size   strs:&memoNums[0][0][0]];
	
    NSString *str = [[NSString alloc] initWithFormat:
					 @"%d,%f,%f,%f,%d,%s,%s,%s,%s,,%ld,%ld,%s,%d,%f,%d,%d,%d",
					 gameLevel,	
					 startTime,	
					 lastTime,	
					 gameTime,	
					 isGameFinished ? 1 : 0,
					 (char*)zStrPuzzleNum,
					 (char*)zStrAnswerNum,
					 (char*)zStrFixNum,
					 (char*)zStrMemoNum,
					 //@"",//strUndo,
					 (long)countHint,
                     (long)size,                  // 9칸?
                     (char*)zStrMapNum,
					 bAutoMemo?1:0,
					 hintTime,
                     sudokuType,
                     bDailyPuzzle ? 1 : 0,
                     bUserInputStart ? 1 : 0];
					 
	DLog(@"saveData(%@)", str);
	
	[defaults setObject:str forKey:kSudokuGame];
    
	[sudokuUndo saveData];
    if (sudokuType == SUDOKUTYPE_KILLER || sudokuType == SUDOKUTYPE_CALCU)
    {
        [kmap saveData];
    }
    [defaults setBool:NO forKey:kSudokuGameSaving];
    [defaults synchronize];

    [str release];

}

#define kSudokuGameLoading		@"sudokugameloading"

+ (SudokuGame*) loadData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *str = (NSString*)[defaults stringForKey:kSudokuGame];
	if (str == nil) {
		DLog(@"loadData Failed");
		return nil;
	}
	
	DLog(@"loadData(%@)", str);
    if ([defaults boolForKey:kSudokuGameLoading]) { // Crashed last time
        [defaults setBool:NO forKey:kSudokuGameLoading];
        [defaults synchronize];
        return nil;
    }
    [defaults setBool:YES forKey:kSudokuGameLoading];
    [defaults synchronize];
    SudokuGame* sudokuGame = [[SudokuGame alloc] initWithSavedString:str];
    [defaults setBool:NO forKey:kSudokuGameLoading];
    [defaults synchronize];
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

- (void) bonusGameElapsedTime
{
	if (!isGameFinished)
	{
        if (gameTime > 5)
            gameTime -= 3;
        else
            gameTime /= 2;
    }
	
}

- (void) bonusHintElapsedTime
{
	if (!isGameFinished)
    {
        if (hintTime > 8)
            hintTime -= 5;
        else
            hintTime /= 2;
    }

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
					[self delMemoNums:undoData.num x:undoData.x y:undoData.y bUndo:YES];
					break;
				case UNDOMODE_MEMO_DEL:
					[self addMemoNums:undoData.num x:undoData.x y:undoData.y];
					break;
				case UNDOMODE_AUTOMEMO_ADD:
					[self delMemoNums:undoData.num x:undoData.x y:undoData.y bUndo:YES];
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
    
    DLog(@"runRedo (%ld/%ld)", (long)[sudokuUndo getIndex], (long)sudokuUndo.count);
    
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
                [self delMemoNums:undoData.num x:undoData.x y:undoData.y bUndo:YES];
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
                [self delMemoNums:undoData.num x:undoData.x y:undoData.y bUndo:YES];
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
						[self delMemoNums:undoData.num x:undoData.x y:undoData.y bUndo:YES];
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

- (void) calcuCountNum
{
    memset(countNums, 0, sizeof(countNums));
    
    for (NSInteger y=0; y<size; y++)
    {
        for (NSInteger x=0; x<size; x++)
        {
            NSInteger num = fixNums[x][y] ? fixNums[x][y] : puzzleNums[x][y];
            
            if (num > 0)
                countNums[num-1] += 1;
        }
    }
}

- (NSInteger) getCountNum:(NSInteger)num
{
    if (num < 1 || num > size)
        return 0;
    
    return countNums[num-1]; 
}

+ (NSString*) getSudokuTypeName:(SUDOKUTYPE)type
{
    switch (type) {
        case SUDOKUTYPE_SUDOKU :    return gettext(@"sudoku", nil);
        case SUDOKUTYPE_GT :        return gettext(@"greater than sudoku", nil);
        case SUDOKUTYPE_KILLER :    return gettext(@"sumdoku", nil);
        case SUDOKUTYPE_CALCU :     return gettext(@"calcudoku", nil);
        case SUDOKUTYPE_SYMBOL :    return gettext(@"symbol sudoku", nil);
        default: return @"";
    }
}

+ (NSString*) getSudokuTypeNameNoop:(SUDOKUTYPE)type
{
    switch (type) {
        case SUDOKUTYPE_SUDOKU :    return @"sudoku";
        case SUDOKUTYPE_GT :        return @"greater than sudoku";
        case SUDOKUTYPE_KILLER :    return @"sumdoku";
        case SUDOKUTYPE_CALCU :     return @"calcudoku";
        case SUDOKUTYPE_SYMBOL :    return @"symbol sudoku";
        default: return @"";
    }
}


+ (NSString*) getGameLevelNameNoop:(GAMELEVEL)level
{
    switch (level) {
        case GAMELEVEL_USERINPUT :  return @"user input";
        case GAMELEVEL_VERYEASY :   return @"very easy";
        case GAMELEVEL_EASY :       return @"easy";
        case GAMELEVEL_NORMAL :     return @"normal";
        case GAMELEVEL_HARD :       return @"hard";
        case GAMELEVEL_VERYHARD :   return @"very hard";
        default: return @"";
    }
}


- (BOOL) isGtCell:(NSInteger)sign x:(NSInteger)x1 y:(NSInteger)y1 x2:(NSInteger)x2 y2:(NSInteger)y2
{
    if (sign > 0)
    {
        return [self getAnswerNums:x2 y:y2] > [self getAnswerNums:x1 y:y1];
    } else {
        return [self getAnswerNums:x2 y:y2] < [self getAnswerNums:x1 y:y1];
    }
}

- (BOOL) setGtCellNum:(NSInteger)depth x:(NSInteger)xPos y:(NSInteger)yPos
{
    if (xPos == selectedXPos && yPos == selectedYPos)
        return NO;
    if (gtNums[xPos][yPos] != 0)
        return NO;
    gtNums[xPos][yPos] = depth;
    
    return YES;
}

- (void) setGtCellColorsDepth:(NSInteger)depth x:(NSInteger)xPos y:(NSInteger)yPos
{
    BOOL bSucc[4] = { NO, NO, NO, NO };
    
    if (xPos-1 >= 0 && [self isSameMap:xPos y:yPos x2:xPos-1 y2:yPos])
    {
        if ([self isGtCell:depth x:xPos y:yPos x2:xPos-1 y2:yPos])
        {
            if ([self setGtCellNum:depth x:xPos-1 y:yPos])
            {
                bSucc[0] = YES;
            }
        }
    }
    if (xPos+1 < size && [self isSameMap:xPos y:yPos x2:xPos+1 y2:yPos])
    {
        if ([self isGtCell:depth x:xPos y:yPos x2:xPos+1 y2:yPos])
        {
            if ([self setGtCellNum:depth x:xPos+1 y:yPos])
            {
                bSucc[1] = YES;
            }
        }
    }
    if (yPos-1 >= 0 && [self isSameMap:xPos y:yPos x2:xPos y2:yPos-1])
    {
        if ([self isGtCell:depth x:xPos y:yPos x2:xPos y2:yPos-1])
        {
            if ([self setGtCellNum:depth x:xPos y:yPos-1])
            {
                bSucc[2] = YES;
            }
        }
    }
    if (yPos+1 < size && [self isSameMap:xPos y:yPos x2:xPos y2:yPos+1])
    {
        if ([self isGtCell:depth x:xPos y:yPos x2:xPos y2:yPos+1])
        {
            if ([self setGtCellNum:depth x:xPos y:yPos+1])
            {
                bSucc[3] = YES;
            }
        }
    }
    depth += (depth > 0 ? +1 : -1);
    if (bSucc[0]) [self setGtCellColorsDepth:depth x:xPos-1 y:yPos];
    if (bSucc[1]) [self setGtCellColorsDepth:depth x:xPos+1 y:yPos];
    if (bSucc[2]) [self setGtCellColorsDepth:depth x:xPos y:yPos-1];
    if (bSucc[3]) [self setGtCellColorsDepth:depth x:xPos y:yPos+1];
}


// GTSudoku용 주변 셀 비교 색 칠하기
- (void) setGtCellColors:(NSInteger)xPos y:(NSInteger)yPos
{
    memset(gtNums, 0, sizeof(gtNums));
    
    selectedXPos = xPos;
    selectedYPos = yPos;
    
    [self setGtCellColorsDepth:+1 x:xPos y:yPos];
    [self setGtCellColorsDepth:-1 x:xPos y:yPos];
    
    
    //[self printgtNums];
}

- (NSInteger) getGtCellColor:(NSInteger)xPos y:(NSInteger)yPos
{
    return gtNums[xPos][yPos];
}


- (void) printgtNums
{
	NSString *str = [[NSString alloc] init];
	
	str = [str stringByAppendingString:@"\n"];
	str = [str stringByAppendingString:@"----------------------------\n"];
	for (NSInteger y=0; y<size; y++)
	{
		str = [str stringByAppendingString:@"|"];
		for (NSInteger x=0; x<size; x++)
		{
			if (gtNums[x][y] != 0)
				str = [str stringByAppendingFormat:@"%2ld", (long)gtNums[x][y]];
			else
				str = [str stringByAppendingFormat:@".."];
			str = [str stringByAppendingString:x%3 == 2?@"|":@" "];
			
		}
		str = [str stringByAppendingString:@"\n"];
		
		if ((y%3) == 2)
			str = [str stringByAppendingString:@"----------------------------\n"];
		
	}
	DLog(@"puzzle & answer = %@", str);
}


@end
