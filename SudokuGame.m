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
@synthesize strUndo;
@synthesize gameLevel;	
@synthesize startTime;
@synthesize lastTime;
@synthesize gameTime;
@synthesize gameFinished;
@synthesize countBlank;
@synthesize countFixNums;
@synthesize countHint;


- (id)initWithSudokuNum:(SudokuNum*)sudoku
{
	if ((super.init) == nil) 
		return nil;
	
	SudokuNum *sudokuNum = sudoku;
	
	gameLevel = GAMELEVEL_NORMAL;
	startTime = [[NSDate date]timeIntervalSince1970];
	lastTime = [[NSDate date]timeIntervalSince1970];
	gameTime = 0;
	gameFinished = NO;
	countHint = cDefaultHintCount;
	NSMutableArray *array = sudokuNum.nums;	
	
	NSString *str;	
	for (int y=0; y<9; y++) {
		for (int x=0; x<9; x++) {
			str = [[array objectAtIndex:x] objectAtIndex:y];
			if ([SudokuNum fixedByUser:str]) {		// fixed cell
				puzzleNums[x][y] = [str integerValue];
				answerNums[x][y] = 0;
			} else {
				puzzleNums[x][y] = 0;				// blank
				answerNums[x][y] = [str integerValue];
			}
			fixNums[x][y] = 0;
			memoNums[x][y][0] = '\0';
		}
	}		
	
	strUndo = [[NSString alloc] initWithString:@""];
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

	
	[SudokuGame set9x9Nums:[listItems objectAtIndex:5]	nums:&puzzleNums[0][0]];
	[SudokuGame set9x9Nums:[listItems objectAtIndex:6]	nums:&answerNums[0][0]];
	[SudokuGame set9x9Nums:[listItems objectAtIndex:7]	nums:&fixNums[0][0]];
	[SudokuGame set9x9Strs:[listItems objectAtIndex:8]	strs:&memoNums[0][0][0]];
	
	strUndo = [[NSString alloc] initWithString:[listItems objectAtIndex:9]];
	if ([listItems count] > 10) {
		countHint = [[listItems objectAtIndex:10] integerValue];
	} else {
		countHint = cDefaultHintCount;
	}

//	[self countBlankCells];

	return self;
	
}



- (void) clearAllNums
{

	for (int y=0; y<9; y++) {
		for (int x=0; x<9; x++) {
			fixNums[x][y] = 0;
			memoNums[x][y][0] = '\0';
		}
	}		
	[strUndo release];
	strUndo = [[NSString alloc] initWithString:@""];
	[self saveData];
}

- (NSInteger) countBlankCells
{
	NSInteger num = 0;
	for (int y=0; y<9; y++) {
		for (int x=0; x<9; x++) {
			if (answerNums[x][y] > 0 && fixNums[x][y] == 0)
				num++;
		}
	}	
	
	countBlank = num;
	
	return num;
}

- (NSInteger) countFixCells
{
	NSInteger num = 0;
	for (int y=0; y<9; y++) {
		for (int x=0; x<9; x++) {
			if (fixNums[x][y] > 0)
				num++;
		}
	}	
	
	countFixNums = num;
	
	return num;
}


- (NSInteger) clearGame
{
	NSInteger unfixedCells = 0;
	NSInteger wrongCells = 0;
	
	for (int y=0; y<9; y++) {
		for (int x=0; x<9; x++) {
			if (fixNums[x][y] == 0 && answerNums[x][y] != 0) {
				NSLog(@"unFixedCell: fixNums[%d][%d] = %d, answerNums[%d][%d] = %d", x, y, fixNums[x][y], x, y, answerNums[x][y]);
				unfixedCells++;
			}
			
			if (answerNums[x][y] > 0 && answerNums[x][y] !=	fixNums[x][y]) {
				NSLog(@"wrongCell: fixNums[%d][%d] = %d, answerNums[%d][%d] = %d", x, y, fixNums[x][y], x, y, answerNums[x][y]);
				wrongCells++;
			}
		}
	}	
	
	if (unfixedCells > 0)
		return -1; // not fixed yet;
	else if (wrongCells > 0)
		return wrongCells;	// You've finisehd but You have wrong cell;
	
	lastTime = [[NSDate date]timeIntervalSince1970];
	gameFinished = YES;
	// zzzzz    should lock the game
	
	MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
	[ctrl writeScore:self];

	[self saveData];
	return 0;	
}


- (void)dealloc {

	[strUndo release];
	
	[super dealloc];
}


- (NSInteger) getPuzzleNums:(NSInteger)x y:(NSInteger)y
{
	return puzzleNums[x][y];
}

- (NSInteger) getFixNums:(NSInteger)x y:(NSInteger)y
{
	return fixNums[x][y];	
}

- (void) setHintNum:(NSInteger)x y:(NSInteger)y
{
	if (puzzleNums[x][y] == 0)
	{
		puzzleNums[x][y] = answerNums[x][y];
		answerNums[x][y] = 0;		
	}	
}


- (void) setFixNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	if (fixNums[x][y] == num)
		return;

	fixNums[x][y] = num;
//	if (num > 0)							// 숫자를 지정했으니 후보 숫자는 제거?
//		[self clearMemoNums:x y:y];
	// 주변 후보 자동으로 뺴기 기능 ? 옵션 처리
	
	[self addUndoLog:num xPos:x yPos:y];
	
	[self saveData];
}



- (void) cancelFixNums:(NSInteger)x y:(NSInteger)y
{
	[self setFixNums:0 x:x y:y];
	[self saveData];
}

- (char*) getMemoNums:(NSInteger)x y:(NSInteger)y
{
	return (char*)(memoNums[x][y]);
}

- (BOOL) beMemoNums:(NSInteger)num  x:(NSInteger)x y:(NSInteger)y
{
	char *s = memoNums[x][y];
	char *p = strchr(s, num+'0');

	return p != NULL;
}

- (void) addMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	char *s = memoNums[x][y];
	NSLog(@"addMemoNums => org num : '%s'", s);
	char *p;
	char c = num + '0';
	char cTemp;
	
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
	char *s = memoNums[x][y];
	char *p = strchr(s, num+'0');
	
	strcpy(p, p+1);
	[self saveData];
}


- (void) revertMemoNums:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	char *s = memoNums[x][y];
	char c = num + '0';
	
	if (strchr(s, c)) {
		[self delMemoNums:num x:x y:y];
	} else {
		[self addMemoNums:num x:x y:y];
	}
}

- (void) clearMemoNums:(NSInteger)x y:(NSInteger)y
{
	char *s = memoNums[x][y];
	*s = '\0';
}

#define kSudokuGame		@"sudokugame"


+ (void) get9x9Nums:(char*)str	nums:(NSInteger*)nums
{
	for (int i=0; i<81; i++)
	{
		*str++ = ('0' + *nums++);	// y first

	}
	*str = '\0';
}

+ (void) set9x9Nums:(NSString *)str	nums:(NSInteger*)nums
{
	char *s	= (char*)[str cStringUsingEncoding:NSASCIIStringEncoding];
	
	for (int i=0; i<81; i++)
	{
		*nums++ = *s++ - '0';
	}
}




+ (void) get9x9Strs:(char*)str	strs:(char*)strs
{
	int len;
	
	for (int i=0; i<81; i++)
	{
		len = strlen(strs);
		if (len)
			strcpy(str, strs);
		strcat(str, "|");
		str += len+1;
		strs += 10;
	}
	*str = '\0';
}

+ (void) set9x9Strs:(NSString *)str	strs:(char*)strs
{
	NSArray *listItems = [str componentsSeparatedByString:@"|"];

	for (int i=0; i<81; i++)
	{
		strcpy(strs, [[listItems objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding]);
		strs += 10;
	}
}


- (void) saveData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	char zStrPuzzleNum[9*9+1] = "";
	char zStrAnswerNum[9*9+1] = "";
	char zStrFixNum[9*9+1] = "";
	char zStrMemoNum[9*9*10+1] = "";
	
	[SudokuGame get9x9Nums:zStrPuzzleNum	nums:&puzzleNums[0][0]];
	[SudokuGame get9x9Nums:zStrAnswerNum	nums:&answerNums[0][0]];
	[SudokuGame get9x9Nums:zStrFixNum		nums:&fixNums[0][0]];
	[SudokuGame get9x9Strs:zStrMemoNum		strs:&memoNums[0][0][0]];
	
	NSString *str = [[NSString alloc] initWithFormat:
					 @"%d,%f,%f,%f,%d,%s,%s,%s,%s,%@,%d",
					 gameLevel,	
					 startTime,	
					 lastTime,	
					 gameTime,	
					 gameFinished ? 1 : 0,
					 (char*)zStrPuzzleNum,
					 (char*)zStrAnswerNum,
					 (char*)zStrFixNum,
					 (char*)zStrMemoNum,
					 strUndo,
					 countHint];
					 
	NSLog(@"saveData(%@)", str);
	
	[defaults setObject:str forKey:kSudokuGame];
	
	[str release];
}

+ (SudokuGame*) loadData
{
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
	NSString *str = [strUndo stringByAppendingFormat:@"%d%d%d", xPos, yPos, num];

	[strUndo release];
	strUndo = str;
	
	[strUndo retain];	// zzzzzzzzzzzzzzzzzzz
}

- (NSInteger) getIntegerAtIndexFromString:(NSString *)str index:(NSUInteger)index
{
	unichar c = [str characterAtIndex:index];
	
	return c-'0';
}



- (CGPoint) runUndo
{
	NSInteger len = strUndo.length;
	NSInteger count = len/3;
	CGPoint pointLastUndoPos;
	NSInteger num, prevnum=0, tempnum, x, y;
	
	
	pointLastUndoPos.x = -1;
	pointLastUndoPos.y = -1;

	if (count > 0) {
		pointLastUndoPos.x = [self getIntegerAtIndexFromString:strUndo index:(count-1)*3+0];
		pointLastUndoPos.y = [self getIntegerAtIndexFromString:strUndo index:(count-1)*3+1];
		num = [self getIntegerAtIndexFromString:strUndo index:(count-1)*3+2];

		for (int i=0; i<count-1; i++) {
			x = [self getIntegerAtIndexFromString:strUndo index:i*3+0];
			y = [self getIntegerAtIndexFromString:strUndo index:i*3+1];
			tempnum = [self getIntegerAtIndexFromString:strUndo index:i*3+2];
			if (x == pointLastUndoPos.x && y == pointLastUndoPos.y)
			{
				prevnum = tempnum;
			}
		}
		fixNums[(NSInteger)pointLastUndoPos.x][(NSInteger)pointLastUndoPos.y] = prevnum;
		
		NSString *str;
		
		str = [strUndo substringToIndex:(count-1)*3];
		[strUndo release];	
		strUndo = str;
		[strUndo retain];

		[self saveData];

	}
	return pointLastUndoPos;
}



@end
