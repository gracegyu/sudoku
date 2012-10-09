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

- (void)dealloc
{
    
    [sudokuUndo release];
//	[strUndo release];
    
	
	[super dealloc];
}



- (id)initWithSudokuNum:(SudokuNum*)sudoku
{
	if ((super.init) == nil) 
		return nil;
	
    size = [sudoku getCellSize];
	gameLevel = GAMELEVEL_NORMAL;       // default
	startTime = [[NSDate date]timeIntervalSince1970];
	lastTime = [[NSDate date]timeIntervalSince1970];
	gameTime = 0;
	gameFinished = NO;
	countHint = cDefaultHintCount;

	NSInteger num;
    for (int y=0; y<size; y++) {
		for (int x=0; x<size; x++) {
            mapNums[x][y] = [[sudoku getMap] getMapNum:x y:y];
            num = [sudoku getCellNum:x y:y];
            
            if ([sudoku fixedByUser:x y:y]) {		// fixed cell
				puzzleNums[x][y] = num;
				answerNums[x][y] = num; // 0
			} else {
                NSAssert(num > 0, @"Puzzlenum(%d) should be bigger than 0", num);
				puzzleNums[x][y] = 0;				// blank
				answerNums[x][y] = num;
			}
            
			fixNums[x][y] = 0;
			memoNums[x][y][0] = '\0';
		}
	}		
	
//	strUndo = [[NSString alloc] initWithString:@""];
    sudokuUndo = [[SudokuUndo alloc] init];
    
	[self saveData];
	
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

//	strUndo = [[NSString alloc] initWithString:[listItems objectAtIndex:9]];
    sudokuUndo = [[SudokuUndo alloc] init];
	if ([listItems count] > 10) {
		countHint = [[listItems objectAtIndex:10] integerValue];
	} else {
		countHint = cDefaultHintCount;
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
    
    
    [self saveData];
    
//	[self countBlankCells];

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
    [sudokuUndo clear];

//	[strUndo release];
//	strUndo = [[NSString alloc] initWithString:@""];
	[self saveData];
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
				NSLog(@"unFixedCell: fixNums[%d][%d] = %d, answerNums[%d][%d] = %d", x, y, fixNums[x][y], x, y, answerNums[x][y]);
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
                        
                        NSString *msg = [[NSString alloc] initWithFormat:@"Strange Cell(%d,%d)Answer(%d)fix(%d)",
                                         x, y, answerNums[x][y], fixNums[x][y]];

                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                                        message:msg
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                        [msg release];
                        [alert show];
                        [alert release];
                        
                        
                        
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
		fixNums[x][y] = answerNums[x][y];
//		puzzleNums[x][y] = answerNums[x][y];
		//answerNums[x][y] = 0;
	}	
}


- (void) setFixNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    if (puzzleNums[x][y] > 0)               // 문제칸은 Set할 수 없다.
        return;
    
    
	if (fixNums[x][y] == num)
		return;

    if (num == 0)   // del num
    {
        [sudokuUndo delNum:fixNums[x][y] x:x y:y];
    } else {
        [sudokuUndo addNum:num oldnum:fixNums[x][y] x:x y:y];
    }
	fixNums[x][y] = num;

	
//	[self addUndoLog:num xPos:x yPos:y];
	
	[self saveData];
}



- (void) cancelFixNums:(NSInteger)x y:(NSInteger)y
{
	[self setFixNums:0 x:x y:y];
	[self saveData];
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
    
    
    
	char *s = memoNums[x][y];
	char *p = strchr(s, num+'0');

	return p != NULL;
}

- (void) addMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    if ([self isPuzzleNum:x y:y])           // 문제칸은 Memo 할 수 없다.
        return;
    
    
	char *s = memoNums[x][y];
	NSLog(@"addMemoNums => org num : '%s'", s);
	char *p;
	char c = num + '0';
	char cTemp;
	
    if (strchr(s, c))
        return;         // 이미 있는 번호
    
	for (p = s; *p && *p < c; p++) {}
	
	do {
		cTemp = c;
		c = *p;
		*p = cTemp;
	} while (*p++);
	NSLog(@"addMemoNums => '%s'", s);
	
	[self saveData];
}

- (void) delMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
    if ([self isPuzzleNum:x y:y])               // 문제칸은 Memo를 지울 수 없다.
        return;
    
    
	char *s = memoNums[x][y];
	char *p = strchr(s, num+'0');
	
	strcpy(p, p+1);
	[self saveData];
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
	
	for (int i=0; i<size*size; i++)
	{
		len = strlen(strs);
		if (len)
			strcpy(str, strs);
		strcat(str, "|");
		str += len+1;
		strs += MAXMAPSIZE+1;
	}
	*str = '\0';
}

+ (void) set9x9Strs:(NSString *)str	size:(NSInteger)size strs:(char*)strs
{
	NSArray *listItems = [str componentsSeparatedByString:@"|"];

	for (int i=0; i<size*size; i++)
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
	
	NSString *str = [[NSString alloc] initWithFormat:
					 @"%d,%f,%f,%f,%d,%s,%s,%s,%s,%@,%d,%d,%s",
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
                     (char*)zStrMapNum];
					 
//	NSLog(@"saveData(%@)", str);
	
	[defaults setObject:str forKey:kSudokuGame];
	
	[str release];
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
    CGPoint pointLastUndoPos;
    
    UndoData *undoData = [[UndoData alloc] init];
    
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
            default:
                break;
        }
    }
    
    return pointLastUndoPos;
    

}

- (CGPoint) runRedo
{
    CGPoint pointLastUndoPos;
    
    UndoData *undoData = [[UndoData alloc] init];
    
    if ([sudokuUndo getRedo:undoData] == NO)
    {
        // undo failure
        pointLastUndoPos.x = -1;
        pointLastUndoPos.y = -1;
    } else {
        pointLastUndoPos.x = (CGFloat)undoData.x;
        pointLastUndoPos.y = (CGFloat)undoData.y;
        
        switch (undoData.mode) {
            case UNDOMODE_NUM_ADD:
                fixNums[undoData.x][undoData.y] = undoData.num;
                break;
            case UNDOMODE_NUM_DEL:
                fixNums[undoData.x][undoData.y] = 0;
                break;
            case UNDOMODE_MEMO_ADD:
                [self addMemoNums:undoData.num x:undoData.x y:undoData.y];
                break;
            case UNDOMODE_MEMO_DEL:
                [self delMemoNums:undoData.num x:undoData.x y:undoData.y];
                break;
            default:
                break;
        }
    }
    
    return pointLastUndoPos;
    
    
}



@end
