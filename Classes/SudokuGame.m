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
@synthesize gameFinished;
@synthesize countBlank;
@synthesize countFixNums;
@synthesize countHint;
@synthesize bAutoMemo;




- (void)dealloc
{
    
    [sudokuUndo release];
    [map release];
    
	
	[super dealloc];
}

- (NSInteger) randNum:(NSInteger) num
{
    return ((unsigned int)arc4random()) % num;
}


- (NSInteger) getDefHintCount:(NSInteger)sizeTable
{
#ifdef GTSUDOKU
    return sizeTable > 6 ? 3 : 2;
#else
    return sizeTable > 6 ? 2 : 1;
#endif
    
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
	//NSLog(@"countUserFixedNumX(%d,%d) => %d", xPos, yPos, count);
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
	//NSLog(@"countUserFixedNumY(%d,%d) => %d", xPos, yPos, count);
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
	//NSLog(@"countUserFixedNumXY(%d,%d) => %d", xPos, yPos, count);
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

- (void) applyHandy
{
	int numRandom;
	int num;
	int handy = HandyCount[size][gameLevel];
	
	
#ifdef GTSUDOKU
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
			NSLog(@"countHandyTryFailed == MAX_HANDYTRAYFAIL");
		
	}
	
}

- (void) initData:(GAMELEVEL)level
{
	gameLevel = GAMELEVEL_NORMAL;       // default
	startTime = [[NSDate date]timeIntervalSince1970];
	lastTime = [[NSDate date]timeIntervalSince1970];
	gameTime = 0;
	gameFinished = NO;
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
			//NSLog(@"deleteAutoMemoX(%d,%d)->%d", x, y, num);
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
			//NSLog(@"deleteAutoMemoY(%d,%d)->%d", x, y, num);

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
					//NSLog(@"deleteAutoMemoXY(%d,%d)->%d", x, y, num);
				}
			}
		}
	}
}

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
					NSLog(@"deleteAutoMemoUniqueNumX(%d,%d)->%d", x, y, k);
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
					NSLog(@"deleteAutoMemoUniqueNumY(%d,%d)->%d", x, y, k);
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
					NSLog(@"deleteAutoMemoUniqueNumXY(%d,%d)->%d", x, y, k);
					bRet = YES;
				} else {
					//NSLog(@"[self setMemoNumsForAutoMemo:%d x:%d y:%d] == NO", k, x, y);
				}
			}
		}
	}
	return bRet;
}

- (BOOL) deleteAutoMemoUniqueNum:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	BOOL bRetX, bRetY, bRetXY;
	
	bRetX = [self deleteAutoMemoUniqueNumX];
	bRetY =	[self deleteAutoMemoUniqueNumY];
	bRetXY = [self deleteAutoMemoUniqueNumXY];
	
	return bRetX || bRetY; ///|| bRetXY;
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
	}
#ifdef SUDOKU9	// 나머지 에서는 너무 쉬워진다.
	if (gameLevel == GAMELEVEL_VERYHARD || gameLevel == GAMELEVEL_HARD)
	{
		while ([self deleteAutoMemoUniqueNum:num xPos:xPos yPos:yPos] == YES)
		{
			
		}
	}
#endif
	// [self deleteAutoMemoSingleNum:]
	// Single num은 굳이 처리하지 않아도 사용자가 입력할 것이다.
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
                NSAssert(num > 0, @"getAnswerNum(%d) should be bigger than 0", num);
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
                NSAssert(num > 0, @"getAnswerNum(%d) should be bigger than 0", num);
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


- (id)initWithSavedString:(NSString *)str
{
	if ((super.init) == nil) 
		return nil;
	
	NSArray *listItems = [str componentsSeparatedByString:@","];
	
	gameLevel = [[listItems objectAtIndex:0] integerValue];
	startTime = [[listItems objectAtIndex:1] floatValue];
	lastTime = [[listItems objectAtIndex:2] floatValue];
	gameTime = [[listItems objectAtIndex:3] floatValue];
	gameFinished = [[listItems objectAtIndex:4] integerValue] == 1 ? YES : NO;

	if ([listItems count] > 10) {
		countHint = [[listItems objectAtIndex:10] integerValue];
	} else {
		countHint = [self getDefHintCount:9];
	}
	if ([listItems count] > 11) {
        size = [[listItems objectAtIndex:11] integerValue];
    } else {
        size = 9;
    }
    
	
	[SudokuGame set9x9Nums:[listItems objectAtIndex:5] size:size nums:&puzzleNums[0][0]];
	[SudokuGame set9x9Nums:[listItems objectAtIndex:6] size:size nums:&answerNums[0][0]];
	[SudokuGame set9x9Nums:[listItems objectAtIndex:7] size:size nums:&fixNums[0][0]];
	[SudokuGame set9x9Strs:[listItems objectAtIndex:8] size:size strs:&memoNums[0][0][0]];
	
    if ([listItems count] > 12) {
        [SudokuGame set9x9Nums:[listItems objectAtIndex:12]	size:size nums:&mapNums[0][0]];
    } else {
        NSString *default9x9Map = @"111222333111222333111222333444555666444555666444555666777888999777888999777888999";
        [SudokuGame set9x9Nums:default9x9Map size:size nums:&mapNums[0][0]];
    }
	// zzzzzzzzzzzzzzzzzzzzz
	map = [[SudokuMap alloc] initWithMapArray:(NSInteger*)mapNums size:size];
		
	if ([listItems count] > 13)	// bAutoMemo
	{
		bAutoMemo = [[listItems objectAtIndex:13] integerValue] == 1 ? YES : NO;
	} else {
		bAutoMemo = NO;
	}
	bAutoMemoUndoLog = YES;
	
	sudokuUndo = [[SudokuUndo alloc] initWithSaveData];

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

    
- (BOOL) checkCorrect:(NSInteger)xPos y:(NSInteger)yPos
{
    NSInteger numCheck = fixNums[xPos][yPos];
    NSInteger numCompare;
    int x, y;

    
    if (puzzleNums[xPos][yPos] > 0)
        return YES; // 문제는 언제나 참
    
    if (numCheck == 0)
        return YES; // 아직 끝난 게임이 아님
    
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

    if ([self checkGreatThan:xPos y:yPos] == NO)
        return NO;
    
    return YES;
}
#endif


- (NSInteger) clearGame
{
	NSInteger unfixedCells = 0;
	NSInteger wrongCells = 0;
#ifdef GTSUDOKU
    NSInteger strangeCells = 0;
#endif
    
    for (int y=0; y<size; y++) {
		for (int x=0; x<size; x++) {
			if (fixNums[x][y] == 0 && puzzleNums[x][y] == 0) {
				//NSLog(@"unFixedCell: fixNums[%d][%d] = %d, answerNums[%d][%d] = %d", x, y, fixNums[x][y], x, y, answerNums[x][y]);
				unfixedCells++;
			}
        }
    }
    if (unfixedCells > 0)
		return -1; // not fixed yet;
    
	for (int y=0; y<size; y++) {
		for (int x=0; x<size; x++) {
#ifdef GTSUDOKU // 답이 2개일지도 모르니
			if (puzzleNums[x][y] == 0)
            {
                if ([self checkCorrect:x y:y] == NO)
                {
                    NSLog(@"wrongCell: fixNums[%d][%d] = %d, answerNums[%d][%d] = %d", x, y, fixNums[x][y], x, y, answerNums[x][y]);
                    wrongCells++;
                } else {
                    if (answerNums[x][y] != fixNums[x][y])
                    {
                        strangeCells++;
                        NSLog(@"StangeCell 발견");
/*
                        NSString *msg = [NSString stringWithFormat:@"Strange Cell(%d,%d)Answer(%d)fix(%d)",
                                         x, y, answerNums[x][y], fixNums[x][y]];

                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                                        message:msg
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                        [alert show];
                        [alert release];
*/                        
                        
                        
                    }
                }
                
			}
#else
			if (puzzleNums[x][y] == 0 && answerNums[x][y] != fixNums[x][y]) {
				NSLog(@"wrongCell: fixNums[%d][%d] = %d, answerNums[%d][%d] = %d", x, y, fixNums[x][y], x, y, answerNums[x][y]);
				wrongCells++;
			}
#endif
		}
	}	
	

	if (wrongCells > 0)
		return wrongCells;	// You've finisehd but You have wrong cell;
	
	lastTime = [[NSDate date]timeIntervalSince1970];
	gameFinished = YES;

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


- (void) setFixNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	NSLog(@"### setFixNums(%d,%d)->%d", x, y, num);
	
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
				[self addMemoNums:data.num x:data.x y:data.y];
				[sudokuUndo addAutoMemo:data.num x:data.x y:data.y];
			} else if (data.mode == UNDOMODE_AUTOMEMO_ADD)
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
		NSLog(@"############(%d,%d,%s)", x, y, memoNums[x][y]);
	}
	
	//NSLog(@"delMemoNums(%d-%d,%d)%s", num, x, y, memoNums[x][y]);
	[SudokuNum deleteNumFromStr:memoNums[x][y] num:num];
	//NSLog(@"	=> %s", memoNums[x][y]);
	

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
            *str++ = ('0' + nums[x + y*SIZE_9]);
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
            nums[x + y*SIZE_9] = *s++ - '0';
        }
    }

}




+ (void) get9x9Strs:(char*)str	size:(NSInteger)size strs:(char*)strs
{
	int len;
	
	for (int i=0; i<SIZE_9*SIZE_9; i++)	// 호환을 위해서 사용하지 않는 메모도 저장하고 가져온다.
	{
		len = strlen(strs);
		if (len)
			strcpy(str, strs);
		strcat(str, "|");
		str += len+1;
		strs += SIZE_9+1;	// 메모의 최대 길이
	}
	*str = '\0';
}

+ (void) set9x9Strs:(NSString *)str	size:(NSInteger)size strs:(char*)strs
{
	NSArray *listItems = [str componentsSeparatedByString:@"|"];

	for (int i=0; i<SIZE_9*SIZE_9 && i<listItems.count; i++)		// 호환을 위해서 사용하지 않는 메모도 저장하고 가져온다.
	{
		strcpy(strs, [[listItems objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding]);
		strs += SIZE_9+1;
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
					 @"%d,%f,%f,%f,%d,%s,%s,%s,%s,%@,%d,%d,%s,%d",
					 gameLevel,	
					 startTime,	
					 lastTime,	
					 gameTime,	
					 gameFinished ? 1 : 0,
					 (char*)zStrPuzzleNum,
					 (char*)zStrAnswerNum,
					 (char*)zStrFixNum,
					 (char*)zStrMemoNum,
					 @"",//strUndo,
					 countHint,
                     size,                  // 9칸?
                     (char*)zStrMapNum,
					 bAutoMemo?1:0];
					 
	//NSLog(@"saveData(%@)", str);
	
	[defaults setObject:str forKey:kSudokuGame];

	[sudokuUndo saveData];

}

+ (SudokuGame*) loadData
{
 //   return nil;
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *str = (NSString*)[defaults stringForKey:kSudokuGame];	
	if (str == nil) {
		NSLog(@"loadData Failed");
		return nil;
	}
	
	NSLog(@"loadData(%@)", str);
	
	SudokuGame* sudokuGame = [[SudokuGame alloc] initWithSavedString:str];
	
	// sudokuGame.bAutoMemo = YES;
	//[sudokuGame initAutoMemo]; 메모를 그대로 읽어들여야 한다.
	
	return sudokuGame;
}

- (NSInteger) add1sec
{
	if (!gameFinished)
		gameTime += 1;
	
	return (NSInteger) gameTime;
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
				//[self updateAutoMemo:undoData.num xPos:undoData.x yPos:undoData.y];
				bAutoCheck = YES;
                break;
            case UNDOMODE_NUM_DEL:
                fixNums[undoData.x][undoData.y] = 0;
				//[self initAutoMemo];
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
				NSAssert(0, @"runRedo");
                [self addMemoNums:undoData.num x:undoData.x y:undoData.y];
				bAutoCheck = YES; // ???
                break;
            case UNDOMODE_AUTOMEMO_DEL:
				NSAssert(0, @"runRedo");
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
    
    return pointLastUndoPos;
   
}



@end
