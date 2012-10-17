//
//  MainView.m
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import "Constants.h"
#import "MainView.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "Locale.h"
#import "SudokuBoard.h"

@implementation MainView
@synthesize tableBgColor;
@synthesize selectedTableBgColor;
@synthesize selectedCellBorderColor;
@synthesize selectedMemoModeCellBorderColor;
@synthesize HintBgColor;
@synthesize MemoModeHintBgColor;
@synthesize choosingOkColor;
@synthesize choosingNoColor;
@synthesize tableLineColor;
@synthesize fixedByUserColor;
@synthesize fixedByAutoColor;
@synthesize candidateColor;
@synthesize candidateTwoColor;
@synthesize cellFailColor;
@synthesize cellWarnColor;
@synthesize cellConflictColor;

@synthesize numButtonColor;
@synthesize memoButtonColor;
@synthesize bgButtonColor;
@synthesize pressedButtonColor;


@synthesize sudokuGame;
@synthesize selectedXPos;
@synthesize selectedYPos;
@synthesize pushedButton;
@synthesize bTouch;
@synthesize bPressedInButton;
@synthesize bPressedInCell;
@synthesize bMemoMode;
@synthesize bMenuMode;
@synthesize bDupWarn;
@synthesize bSettingSoundOff;
@synthesize bSettingGuideline;
@synthesize bSettingDuplicationWarning;
@synthesize bSettingMarkingEqual;
@synthesize bSettingDefMap;
@synthesize bSettingAutoMemo;


@synthesize cellOneSmallFont;
@synthesize cellOneBigFont;
@synthesize cellFailFont;
@synthesize cellTwoFont;
@synthesize cellFourFont;
@synthesize cellSixFont;
@synthesize cellNineFont;
@synthesize buttonSmallFont;
@synthesize buttonBigFont;
@synthesize buttonTextFont;
@synthesize buttonMemoSmallFont;
@synthesize buttonMemoBigFont;
@synthesize buttonMemoTextFont;


//@synthesize lastOrientation;




#define cWidthScreen cTableWidth
#define cYButtonStart [self getNumButtonAreaY]


#define cResizeRatioW			(isIpad ? 768/320 : 1) 
//#define cResizeRatioH			(isIpad ? 1004/460 : 1)
#define cTableStartX [self getTableX]
#define cTableStartY [self getTableY]
#define cTableWidth	 [self getTableW]
#define cTableHeight [self getTableH]

#define cCellWidth				(cTableWidth/sudokuGame.size) 
#define cCellHeight				(cTableHeight/sudokuGame.size) 

#define cLineWidth				1.0f*cResizeRatioW
#define cLineDrawWidth			0.8f*cResizeRatioW
#define cConflictLineWidth		1.5f*cResizeRatioW
#define cBoldLine				4.0f*cResizeRatioW

#define fontAdjust   0.60

#define bSettingCompareWarning      bSettingDuplicationWarning
#define GTDEPTH 0.10
#define GTWIDTH 0.30

- (void)initData
{
	NSLog(@"initData");
	
	self.tableBgColor = [UIColor colorWithWhite:240.f/255.f alpha:1.f];
	self.selectedTableBgColor = [UIColor whiteColor];
	self.selectedCellBorderColor = [UIColor colorWithRed:0.6f green:0.9f blue:0.7f alpha:0.7f];
	self.selectedMemoModeCellBorderColor = [UIColor colorWithRed:243.0/256.0 green:243.0/256.0 blue:192.0/256.0 alpha:0.8f];
    
	self.HintBgColor = [UIColor colorWithRed:243.0/256.0 green:243.0/256.0 blue:192.0/256.0 alpha:1.0f];
	self.MemoModeHintBgColor = [UIColor colorWithRed:192.0/256.0 green:243.0/256.0 blue:202.0/256 alpha:1.0f];
	self.choosingOkColor = [UIColor colorWithRed:0.5f green:0.8f blue:0.6f alpha:1.f];
	self.choosingNoColor = [UIColor colorWithRed:0.6f green:0.9f blue:0.7f alpha:0.2f];
	self.tableLineColor = [UIColor colorWithRed:128.f/255.f green:154.f/255.f blue:224.f/255.f alpha:1.f];
	
	self.fixedByUserColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.6f alpha:1.f];
	self.fixedByAutoColor = [UIColor colorWithRed:0.5f green:0.7f blue:0.5f alpha:1.f];
	self.candidateColor = [UIColor colorWithRed:0.5f green:0.6f blue:0.7f alpha:1.f];
	self.candidateTwoColor = [UIColor colorWithRed:0.5f green:0.6f blue:0.7f alpha:1.f];
	self.cellFailColor = [UIColor colorWithRed:1.f green:0.0f blue:0.0f alpha:0.8f];
	self.cellWarnColor = [UIColor colorWithRed:1.f green:0.3f blue:0.0f alpha:0.9f];
	self.cellConflictColor = [UIColor colorWithRed:0.7f green:0.0f blue:0.5f alpha:0.9f];
	
	self.bgButtonColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:0.5f];
	self.pressedButtonColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:0.9f];
	self.numButtonColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.4f alpha:0.7f];
	self.memoButtonColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.4f alpha:0.7f];
	
	self.selectedXPos = 0;
	self.selectedYPos = 0;
	self.pushedButton = -1;
	self.bTouch = NO;
	self.bPressedInButton = NO;
	self.bPressedInCell = NO;
	self.bDupWarn = YES;
	self.bSettingSoundOff = YES;
    self.bSettingGuideline = YES;
    self.bSettingDuplicationWarning = YES;
    self.bSettingMarkingEqual = YES;
#ifdef GTSUDOKU
    self.bSettingDefMap = YES;
#else
#ifdef SUDOKU6
    self.bSettingDefMap = NO;
#else  // SODUKU9
    self.bSettingDefMap = YES;
#endif
#endif
	
	self.bSettingAutoMemo = NO;
	
//	self.fPress = 1.f;
	
	
	
	
	NSString *path;
	
	path = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundClickID);
	path = [[NSBundle mainBundle] pathForResource:@"clear" ofType:@"wav"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundClearID);
	path = [[NSBundle mainBundle] pathForResource:@"Sosumi" ofType:@"aiff"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundFailID);
	
	bMemoMode = NO;
    

    
}





- (id)initWithCoder:(NSCoder*)coder
{
	NSLog(@"initWithCoder");	
	
    if ( (self = [super initWithCoder:coder] ) ) {
		[self initData];
    }

    return self;
}


- (id)initWithFrame:(CGRect)frame {
	NSLog(@"initWithFrame");	
	
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

- (CGRect) getTableRect
{
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
    return ctrl.areaPuzzleTable.frame;
}

- (CGFloat) getTableX
{
    return [self getTableRect].origin.x;
}

- (CGFloat) getTableY
{
    return [self getTableRect].origin.y;
}

- (CGFloat) getTableW
{
    return [self getTableRect].size.width;
}

- (CGFloat) getTableH
{
    return [self getTableRect].size.height;
}



- (CGRect) getNumButtonAreaRect
{
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
/*    NSLog(@"ctrl.areaNumButton.frame = %f,%f,%f,%f\n",
          ctrl.areaNumButton.frame.origin.x,
          ctrl.areaNumButton.frame.origin.y,
          ctrl.areaNumButton.frame.size.width,
          ctrl.areaNumButton.frame.size.height);
*/
    return ctrl.areaNumButton.frame;
}

- (CGFloat) getNumButtonAreaX
{
    return [self getNumButtonAreaRect].origin.x;
}

- (CGFloat) getNumButtonAreaY
{
    return [self getNumButtonAreaRect].origin.y;
}

- (CGFloat) getNumButtonAreaW
{
    return [self getNumButtonAreaRect].size.width;
}

- (CGFloat) getNumButtonAreaH
{
    return [self getNumButtonAreaRect].size.height;
}

- (CGFloat) getNumButtonCenterX
{
    return [self getNumButtonAreaX] + [self getNumButtonAreaW]/2;
}

- (CGFloat) getNumButtonCenterY
{
    return [self getNumButtonAreaY] + [self getNumButtonAreaH]/2;
}

- (void) drawStrRect:(CGContextRef)context str:(NSString*)str rect:(CGRect)rect color:(CGColorRef)color font:(UIFont*)font
{
    CGContextSetFillColorWithColor(context, color);
    
    [str drawInRect:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height/2 - font.pointSize*fontAdjust, rect.size.width, font.pointSize)
           withFont:font
      lineBreakMode:NSLineBreakByClipping
          alignment:UITextAlignmentCenter];
}


- (void) drawNumRect:(CGContextRef)context num:(NSInteger)num rect:(CGRect)rect color:(CGColorRef)color font:(UIFont*)font
{
    NSAssert(num > 0 && num <= sudokuGame.size, @"drawNumRect(%d)", num);

    NSString *str = [[NSString alloc] initWithFormat:@"%d", num];
    [self drawStrRect:context
                  str:str
                 rect:rect
                color:color
                 font:font];
//    NSLog(@"str.retainCount = %d", str.retainCount);
    [str release];
/*
    [self drawStrRect:context
                  str:[NSString stringWithFormat:@"%d", num]
                 rect:rect
                color:color
                 font:font];
*/
}


- (void)drawRectTableBackground:(CGContextRef) context
{
//	NSLog(@"drawRectTable(%f, cTableWidth=%f)", self.fPress, cTableWidth);
	
	
	CGRect currentRect;
    
    CGContextSetLineWidth(context, cLineDrawWidth);
    CGContextSetStrokeColorWithColor(context, tableBgColor.CGColor);
    CGContextSetFillColorWithColor(context, tableBgColor.CGColor);
	currentRect = CGRectMake (cTableStartX, cTableStartY,cTableWidth-1,cTableHeight-1);
	
	CGContextAddRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFillStroke);
}



- (void)drawRectTableLine:(CGContextRef) context
{
	int x,y,i,j;
#ifdef GTSUDOKU
    BOOL bGT, bUserGT;
#endif
    
    CGContextSetLineCap(context, kCGLineCapRound);
    
    // 수직선
	for (i=1; i<sudokuGame.size; i++)
	{
		x = cTableStartX + i*cCellWidth;
        for (j=0; j<sudokuGame.size; j++)
        {
            CGContextSetLineWidth(context, cLineDrawWidth);
            CGContextSetStrokeColorWithColor(context, tableLineColor.CGColor);
            CGContextSetFillColorWithColor(context, tableLineColor.CGColor);

            y = cTableStartY + j*cCellHeight;
			CGContextMoveToPoint(context, x, y);
            if ([sudokuGame isSameMap:i-1 y:j x2:i y2:j])
            {
#ifdef GTSUDOKU

                bGT = [sudokuGame getAnswerNums:i-1 y:j] > [sudokuGame getAnswerNums:i y:j];
                
                
                // 부등호 오류 표시
                if (bSettingCompareWarning)
                {
                    if ([sudokuGame getDisplayNum:i-1 y:j] && [sudokuGame getDisplayNum:i y:j])
                    {
                        bUserGT = [sudokuGame getDisplayNum:i-1 y:j] > [sudokuGame getDisplayNum:i y:j];
                        if (bGT != bUserGT)
                        {
                            CGContextSetLineWidth(context, cConflictLineWidth);
                            CGContextSetStrokeColorWithColor(context, cellConflictColor.CGColor);
                            CGContextSetFillColorWithColor(context, cellConflictColor.CGColor);
                        }
                        
                    }
                }
                CGContextAddLineToPoint(context, x, y+cCellHeight*GTWIDTH);
                CGContextAddLineToPoint(context, x+(bGT?GTDEPTH:-GTDEPTH)*cCellWidth, y+cCellHeight*0.5);
                CGContextAddLineToPoint(context, x, y+cCellHeight*(1-GTWIDTH));
#endif
                CGContextAddLineToPoint(context, x, y+cCellHeight);
                CGContextStrokePath(context);
                
                
            } else {
                CGContextAddLineToPoint(context, x, y+cCellHeight);
                CGContextSetLineWidth(context, cBoldLine);
                CGContextStrokePath(context);
            }
		}
	}

    // 수평선
	for (i=1; i<sudokuGame.size; i++)
	{
		y = cTableStartY + i*cCellHeight;
        for (j=0; j<sudokuGame.size; j++)
        {
            CGContextSetLineWidth(context, cLineDrawWidth);
            CGContextSetStrokeColorWithColor(context, tableLineColor.CGColor);
            CGContextSetFillColorWithColor(context, tableLineColor.CGColor);

            x = cTableStartX + j*cCellWidth;
			CGContextMoveToPoint(context, x, y);
            if ([sudokuGame isSameMap:j y:i-1 x2:j y2:i])
            {
#ifdef GTSUDOKU
                bGT = [sudokuGame getAnswerNums:j y:i-1] > [sudokuGame getAnswerNums:j y:i];
                if ([sudokuGame getDisplayNum:j y:i-1] && [sudokuGame getDisplayNum:j y:i])
                {
                    bUserGT = [sudokuGame getDisplayNum:j y:i-1] > [sudokuGame getDisplayNum:j y:i];
                    if (bGT != bUserGT)
                    {
                        CGContextSetLineWidth(context, cConflictLineWidth);
                        CGContextSetStrokeColorWithColor(context, cellConflictColor.CGColor);
                        CGContextSetFillColorWithColor(context, cellConflictColor.CGColor);
                    }
                    
                }

                CGContextAddLineToPoint(context, x+cCellWidth*GTWIDTH, y);
                CGContextAddLineToPoint(context, x+cCellWidth*0.5, y+(bGT?GTDEPTH:-GTDEPTH)*cCellHeight);
                CGContextAddLineToPoint(context, x+cCellWidth*(1-GTWIDTH), y);
#endif
                CGContextAddLineToPoint(context, x+cCellWidth, y);
                CGContextStrokePath(context);
            } else {
                CGContextAddLineToPoint(context, x+cCellWidth, y);
                CGContextSetLineWidth(context, cBoldLine);
                CGContextStrokePath(context);
            }
		}
	}
	
	
}



// what color?
- (void)drawRectCellOneChoosing:(CGContextRef)context rect:(CGRect)rect
{
	//NSLog(@"drawRectCellOneChoosing");
	if (pushedButton == 0)
	{
		NSLog(@"pushedButton == 0");
		return;					// delete cell
	}
		
    [self drawNumRect:context
                  num:pushedButton
                 rect:rect
                color:choosingOkColor.CGColor
                 font:cellOneBigFont];
}

// 검정
- (void)drawRectCellOnePuzzle:(CGContextRef)context num:(NSInteger)num rect:(CGRect)rect dupwarn:(BOOL)bDupWarnArea
{
    [self drawNumRect:context
                  num:num
                 rect:rect
                color:bDupWarnArea ? cellWarnColor.CGColor : fixedByUserColor.CGColor
                 font:cellOneSmallFont];
    
    if (bDupWarnArea)
        bFailCell = YES;
}


// 나머지는 파스텔톤
- (void)drawRectCellOneUserFixed:(CGContextRef)context num:(NSInteger)num rect:(CGRect)rect dupwarn:(BOOL)bDupWarnArea conflict:(BOOL)bConflict
{
    CGColorRef color;
    
	if (bDupWarnArea)
	{
        bFailCell = YES;
		color = cellWarnColor.CGColor;
	} else if (bConflict) {     // conflict number 처리
		color = cellConflictColor.CGColor;
    } else {
        color = fixedByAutoColor.CGColor;
	}

    [self drawNumRect:context
                  num:num
                 rect:rect
                color:color
                 font:cellOneSmallFont];

}




- (NSInteger) CharToNum:(char) ch
{
    return (NSInteger) ch - '0';
}



- (void)drawRectCellOneMemo:(CGContextRef)context memo:(char*)memo rect:(CGRect)rect xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
    int len = strlen(memo);
	int i = 0;
	int x, y;
    int countW = (len <= 1 ? 1 : (len <= 4 ? 2 : 3));
    int countH = (len <= 2 ? 1 : (len <= 6 ? 2 : 3));
    BOOL bConflict;
    
#ifdef GTSUDOKU
    CGFloat margin = 0.12f;
#else
    CGFloat margin = 0.10f;
#endif
	
	for (y=0; y<countH; y++)
	{
		for (x=0; x<countW; x++)
		{
			if (i < len)
			{
                bConflict = [self conflictNumber:[self CharToNum:memo[i]] xPos:xPos yPos:yPos];
#ifdef GTSUDOKU
				if (!bConflict)
				{
					bConflict = [self conflictMemoCompare:[self CharToNum:memo[i]] xPos:xPos yPos:yPos];
				}
#endif
                
                [self drawNumRect:context
                              num:[self CharToNum:memo[i]]
                             rect:CGRectMake(rect.origin.x+rect.size.width*margin+(rect.size.width*(1-2*margin))*x/countW,
                                             rect.origin.y+rect.size.height*margin+(rect.size.height*(1-2*margin))*y/countH,
                                             (rect.size.width*(1-2*margin))/countW,
                                             (rect.size.height*(1-2*margin))/countH)
                            color:bConflict? cellConflictColor.CGColor : candidateColor.CGColor
                             font:len <= 4 ? cellFourFont : (len <= 6 ? cellSixFont : cellNineFont)];
                i++;
			}
		}
	}
}

- (BOOL)conflictNumber:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
    int x, y;
    for (x = 0, y = yPos; x < sudokuGame.size; x++)
    {
        if (x != xPos && [sudokuGame getDisplayNum:x y:y] == num)
            return YES;
    }
    for (x = xPos, y = 0; y < sudokuGame.size; y++)
    {
        if (y != yPos && [sudokuGame getDisplayNum:x y:y] == num)
            return YES;
    }
    
    
    for (int x=0; x<sudokuGame.size; x++)
    {
        for (int y=0; y<sudokuGame.size; y++)
        {
            if ((x != xPos || y != yPos) &&
                [sudokuGame isSameMap:x y:y x2:xPos y2:yPos] == YES &&
                [sudokuGame getDisplayNum:x y:y] == num)
            {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL) conflictMemoCompare:(NSInteger)num xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
	sXY	xy2[4];
	BOOL bComapare0, bComapare1;
	NSInteger numDispaly;
	
	if (xPos == 0 && yPos == 0)
	{
		NSLog(@"");
	}
	
	xy2[0].x = xPos-1;	xy2[0].y = yPos;
	xy2[1].x = xPos+1;	xy2[1].y = yPos;
	xy2[2].x = xPos;	xy2[2].y = yPos+1;
	xy2[3].x = xPos;	xy2[3].y = yPos-1;

	for (int i=0; i<4; i++)
	{
		if ([sudokuGame isSameMap:xPos y:yPos x2:xy2[i].x y2:xy2[i].y] == NO)
			continue;
		
		bComapare0 = [sudokuGame getAnswerNums:xPos y:yPos] >
					 [sudokuGame getAnswerNums:xy2[i].x y:xy2[i].y];
		numDispaly = [sudokuGame getDisplayNum:xy2[i].x y:xy2[i].y];
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


- (BOOL)conflictCell:(NSInteger)xPos yPos:(NSInteger)yPos
{
    NSInteger fixNum = [sudokuGame getFixNums:xPos y:yPos];
    
    if (fixNum == 0)
        return NO;
    
    return [self conflictNumber:fixNum xPos:xPos yPos:yPos];
}

- (void)drawRectCell:(CGContextRef)context xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{


    
	BOOL bDupWarnArea = NO;
	if (bSettingDuplicationWarning == YES)
	{	// zzz 사용자가 누를 수 있는 버튼인 경우도 조건에 추가를 해야 한다.
		if (bPressedInButton &&
            pushedButton >= 1 &&
            pushedButton <=sudokuGame.size)	// 현재 버튼을 누르는 중, 중복 번호 경고 on
		{
			if (selectedXPos == xPos || selectedYPos == yPos ||
                [sudokuGame isSameMap:selectedXPos y:selectedYPos x2:xPos y2:yPos]) // 중복 검사 영역
			{
                //bFailCell = YES;
				bDupWarnArea = YES;
			}		
		}
	}
    CGRect rect = CGRectMake(cTableStartX + xPos*cCellWidth,
                             cTableStartY + yPos*cCellHeight,
                             cCellWidth,
                             cCellHeight);

	NSInteger puzzleNum = [sudokuGame getPuzzleNums:xPos y:yPos];
	NSInteger fixNum = [sudokuGame getFixNums:xPos y:yPos];
	char *pMemo = [sudokuGame getMemoNums:xPos y:yPos];
	if (xPos==0 && yPos==0)
	{
		//NSLog(@"pMemo=%s", pMemo);
	}
	
	if (puzzleNum > 0)	{
		// 원래 문제에 있던 번호 
		[self drawRectCellOnePuzzle:context num:puzzleNum rect:rect dupwarn:bDupWarnArea&&(puzzleNum==pushedButton)];
	} else if (bMemoMode == NO &&
               bPressedInButton &&
               selectedXPos == xPos &&
               selectedYPos == yPos &&
               pushedButton >= 0 &&
               pushedButton <= sudokuGame.size) {
		// 선택중인 번호 - 큰 글씨로 나온다.
		[self drawRectCellOneChoosing:context rect:rect];
	} else if (fixNum > 0)	{		// 사용자가 입력해 넣은 번호
        BOOL bConflict = bSettingDuplicationWarning == YES && [self conflictCell:xPos yPos:yPos];
        
//        if ([sudokuGame checkGreatThan:xPos y:yPos] == NO)  // 부등호 오류 표시
//            bConflict = YES;
        
		[self drawRectCellOneUserFixed:context num:fixNum rect:rect dupwarn:bDupWarnArea&&(fixNum==pushedButton) conflict:bConflict];
	}
#ifndef VERBOSE	// 숫자와 메모도 같이 출력하기 위한 장치
	else
#endif
	if (pMemo) {
		// 메모 중인 번호 
		[self drawRectCellOneMemo:context memo:pMemo rect:rect xPos:xPos yPos:yPos];
	}
		

	
	

}

- (void) playSound:(SystemSoundID) inSystemSoundID
{
    if (bSettingSoundOff)
        AudioServicesPlaySystemSound(inSystemSoundID);
}

- (void) playSoundClick
{
    [self playSound:soundClickID];
}

- (void)drawCellNums:(CGContextRef)context
{
	int x, y;


	bFailCell = NO;
	
	for (x=0; x<sudokuGame.size; x++)
	{
		for (y=0; y<sudokuGame.size; y++)
		{ 
			[self drawRectCell:context xPos:x yPos:y]; 	
		}		
	}
	
	if (bFailCell)  //bSetThisTime &&
	{
		//[self playSound:soundFailID];
	}
	
	bSetThisTime = NO;
}

// 숫자가 중복되면 안되는 바닥을 보여줌


- (void)drawOneCellBackground:(CGContextRef)context color:(UIColor*)color x:(NSInteger)x y:(NSInteger)y
{    
    //NSLog(@"drawOneCellBackground(%d,%d)", x, y);
    
    NSInteger xPos = cTableStartX + x*cCellWidth;
    NSInteger yPos = cTableStartY + y*cCellHeight;
    
    CGContextSetLineWidth(context, cLineDrawWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextBeginPath(context);

#ifdef GTSUDOKU
    BOOL bGT;
    
//    if (x != 4 || y != 3) return;
    CGContextMoveToPoint(context, xPos, yPos);
    // 시계 방향으로 회전
    
    if (y > 0 && [sudokuGame isSameMap:x y:y x2:x y2:y-1])
    {
        bGT = [sudokuGame getAnswerNums:x y:y] > [sudokuGame getAnswerNums:x y:y-1];
        CGContextAddLineToPoint(context, xPos+cCellWidth*GTWIDTH, yPos);
        CGContextAddLineToPoint(context, xPos+cCellWidth*0.5, yPos+cCellHeight*(bGT ? 0-GTDEPTH : GTDEPTH));
        CGContextAddLineToPoint(context, xPos+cCellWidth*(1-GTWIDTH), yPos);
    }
    CGContextAddLineToPoint(context, xPos+cCellWidth, yPos);
    
    if (x < sudokuGame.size-1 && [sudokuGame isSameMap:x y:y x2:x+1 y2:y])
    {
        bGT = [sudokuGame getAnswerNums:x y:y] > [sudokuGame getAnswerNums:x+1 y:y];
        CGContextAddLineToPoint(context, xPos+cCellWidth, yPos+cCellHeight*GTWIDTH);
        CGContextAddLineToPoint(context, xPos+cCellWidth*(bGT ? (1 + GTDEPTH) : (1 - GTDEPTH)), yPos+cCellHeight*0.5);
        CGContextAddLineToPoint(context, xPos+cCellWidth, yPos+cCellHeight*(1-GTWIDTH));
    }
    CGContextAddLineToPoint(context, xPos+cCellWidth, yPos+cCellHeight);
    
    if (y < sudokuGame.size-1 && [sudokuGame isSameMap:x y:y x2:x y2:y+1])
    {
        bGT = [sudokuGame getAnswerNums:x y:y] > [sudokuGame getAnswerNums:x y:y+1];
        CGContextAddLineToPoint(context, xPos+cCellWidth*(1-GTWIDTH), yPos+cCellHeight);
        CGContextAddLineToPoint(context, xPos+cCellWidth*0.5, yPos+cCellHeight*(bGT ? (1 + GTDEPTH) : (1 - GTDEPTH)));
        CGContextAddLineToPoint(context, xPos+cCellWidth*GTWIDTH, yPos+cCellHeight);
    }
    CGContextAddLineToPoint(context, xPos, yPos+cCellHeight);
    
    if (x > 0 && [sudokuGame isSameMap:x y:y x2:x-1 y2:y])
    {
        bGT = [sudokuGame getAnswerNums:x y:y] > [sudokuGame getAnswerNums:x-1 y:y];
        CGContextAddLineToPoint(context, xPos, yPos+cCellHeight*(1-GTWIDTH));
        CGContextAddLineToPoint(context, xPos+cCellWidth*(bGT ? 0-GTDEPTH : GTDEPTH), yPos+cCellHeight*0.5);
        CGContextAddLineToPoint(context, xPos, yPos+cCellHeight*GTWIDTH);
    }
    CGContextAddLineToPoint(context, xPos, yPos);
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);

#else
    CGRect currentRect;
    currentRect = CGRectMake(xPos,yPos,cCellWidth-1,cCellHeight-1);
    CGContextAddRect(context, currentRect);
    CGContextDrawPath(context, kCGPathFillStroke);
#endif


}

- (BOOL) isSameMapWithSelectedCell:(NSInteger)x y:(NSInteger)y
{
    if (selectedXPos < 0 || selectedXPos >= sudokuGame.size ||
        selectedYPos < 0 || selectedYPos >= sudokuGame.size)	// no selectec cell
		return NO;
    
    NSInteger i = [sudokuGame getMapNums:x y:y];
    NSInteger j = [sudokuGame getMapNums:selectedXPos y:selectedYPos];
    
    return i>0 && j>0 && i == j;
}




- (void) drawGuidelineBackground:(CGContextRef)context
{
    if (bSettingGuideline == NO)
        return;
    
    if (selectedXPos < 0 || selectedXPos >= sudokuGame.size ||
        selectedYPos < 0 || selectedYPos >= sudokuGame.size)	// no selectec cell
		return;
    
    for (int y=0; y<sudokuGame.size; y++)
    {
        for (int x=0; x<sudokuGame.size; x++)
        {
            // 같은 맵 영역 같은 색으로 칠하기
            if (selectedXPos == x ||
                selectedYPos == y ||
                [self isSameMapWithSelectedCell:x y:y])
            {
                [self drawOneCellBackground:context color:(bMemoMode ? MemoModeHintBgColor : HintBgColor) x:x y:y];
            }            
        } //y
	} //x
}

- (void) drawMarkingEqualBackgound:(CGContextRef)context
{
    if (bSettingMarkingEqual == NO)
        return;
    
    if (selectedXPos < 0 || selectedXPos >= sudokuGame.size ||
        selectedYPos < 0 || selectedYPos >= sudokuGame.size)	// no selectec cell
		return;
    
	for (int x=0; x<sudokuGame.size; x++)
    {
        for (int y=0; y<sudokuGame.size; y++)
        {
            // 같은 숫자는 충돌이 되므로 바탕을 다르게 표시하기
            if ([sudokuGame getDisplayNum:selectedXPos y:selectedYPos] > 0)
            {
                if ([sudokuGame getDisplayNum:selectedXPos y:selectedYPos] == [sudokuGame getDisplayNum:x y:y])
                {
                    [self drawOneCellBackground:context color:selectedTableBgColor x:x y:y];
                }
            }
        } //y
	} //x
}

- (void)drawHighlightCellBackground:(CGContextRef)context
{
	if (selectedXPos >= 0 && selectedXPos < sudokuGame.size &&
        selectedYPos >= 0 && selectedYPos < sudokuGame.size)
	{
        [self drawOneCellBackground:context color:selectedTableBgColor x:selectedXPos y:selectedYPos];
	}
}

- (void)drawBookmarkInCell:(CGContextRef)context
{
	if ([sudokuGame.sudokuUndo isBookmarked] == NO)	// 북마크가 -1이면 좌표가 있어도 표시를 하지 않는다.
		return;
	
    NSInteger x = sudokuGame.sudokuUndo.bookmarkX;
    NSInteger y = sudokuGame.sudokuUndo.bookmarkY;
    
    if (x >= 0 && x < sudokuGame.size &&
        y >= 0 && y < sudokuGame.size)
	{
        NSInteger xPos = cTableStartX + x*cCellWidth;
        NSInteger yPos = cTableStartY + y*cCellHeight;
        
        UIImage *imageBookmark = [UIImage imageNamed:@"bookmark"];
        CGRect rect = CGRectMake(xPos+cCellWidth*0.1f, yPos, cCellWidth*0.2f, cCellHeight*0.3f);
        
        [imageBookmark drawInRect:rect blendMode:kCGBlendModeNormal alpha:0.3f];
    }

}

- (void)drawHighlightCell:(CGContextRef)context
{
	if (selectedXPos >= 0 && selectedXPos < sudokuGame.size &&
        selectedYPos >= 0 && selectedYPos < sudokuGame.size)
	{
		CGRect currentRect;
		NSInteger xPos = cTableStartX + selectedXPos*cCellWidth;
		NSInteger yPos = cTableStartY + selectedYPos*cCellHeight;
		
		CGContextSetLineWidth(context, 4*cResizeRatioW);
		CGContextSetStrokeColorWithColor(context,
                                         bMemoMode ?
                                         selectedMemoModeCellBorderColor.CGColor :
                                         selectedCellBorderColor.CGColor);
		currentRect = CGRectMake (xPos-cBoldLine,yPos-cBoldLine,
                                  cCellWidth+cBoldLine*2,cCellHeight+cBoldLine*2);
		
		CGContextAddRect(context, currentRect);
		CGContextDrawPath(context, kCGPathStroke);
	}
	
}

- (BOOL) isButtonBox
{
    return [self getNumButtonAreaX]/[self getNumButtonAreaY] > 1.5;
}

#ifdef SUDOKU9
#define cButtonWidth (![self isButtonBox]?[self getNumButtonAreaW]/5.1:[self getNumButtonAreaW]/3.1)
#define cButtonHeight (![self isButtonBox]?[self getNumButtonAreaH]/1.95:[self getNumButtonAreaH]/3.1)
#else // SUDOKU6
#define cButtonWidth (![self isButtonBox]?[self getNumButtonAreaW]/4.3:[self getNumButtonAreaW]/3.1)
#define cButtonHeight (![self isButtonBox]?[self getNumButtonAreaH]/1.9:[self getNumButtonAreaH]/3.1)
#endif

#define cDistXButton cButtonWidth/2
#define cDistYButton cButtonHeight

- (NSInteger) numButtonX
{
    if (sudokuGame.size == SIZE_4)
    {
        return [self isButtonBox] ? 2 : 4;
    }
    else if (sudokuGame.size == SIZE_5)
    {
        return [self isButtonBox] ? 5 : 5;
    }
    else if (sudokuGame.size == SIZE_6)
    {
        return [self isButtonBox] ? 3 : 6;
    }
    else if (sudokuGame.size == SIZE_7)
    {
        return [self isButtonBox] ? 5 : 7;
    }
    else if (sudokuGame.size == SIZE_8)
    {
        return [self isButtonBox] ? 5 : 8;
    }
    else // if (sudokuGame.size == SIZE_9)
    {
        return [self isButtonBox] ? 3 : 9;
    }
}

- (NSInteger) numButtonY
{
    if (sudokuGame.size == SIZE_4)
    {
        return [self isButtonBox] ? 2 : 1;
    }
    else if (sudokuGame.size == SIZE_5)
    {
        return [self isButtonBox] ? 2 : 2;
    }
    else if (sudokuGame.size == SIZE_6)
    {
        return [self isButtonBox] ? 2 : 2;
    }
    else if (sudokuGame.size == SIZE_7)
    {
        return [self isButtonBox] ? 3 : 2;
    }
    else if (sudokuGame.size == SIZE_8)
    {
        return [self isButtonBox] ? 3 : 2;
    }
    else // if (sudokuGame.size == SIZE_9)
    {
        return [self isButtonBox] ? 3 : 2;
    }
}

- (CGFloat) buttonXCenter:(NSInteger)i
{
	CGFloat x;
    NSInteger numX = [self numButtonX];
    CGFloat margin = .0f;
    
    if (numX == 2)
        margin = [self isButtonBox] ? 0.2 : 0;
    else if (numX == 8)
        margin = [self isButtonBox] ? 0 : 0.05;
    else if (numX < 7)
        margin = [self isButtonBox] ? 0 : 0.15;
    
    // 엇갈리에 배치하기 위해서
    if (sudokuGame.size == 8 && [self isButtonBox])
        i = i*2 - 1;
    else if (sudokuGame.size == 7 && [self isButtonBox])
        i = i*2;
    else if (sudokuGame.size == 5 && [self isButtonBox])
        i = i*2 - 1;
    
    
    if (numX == 1)
    {
        x = [self getNumButtonAreaX] + [self getNumButtonAreaW]/2;        
    }
    else
    {
        x = [self getNumButtonAreaX] +
        [self getNumButtonAreaW]*margin/2 +
        cButtonWidth/2 +
        (([self getNumButtonAreaW]*(1-margin) - cButtonWidth) / (numX-1)) * ((i-1)%numX);
    }
    
	return x;
}

- (CGFloat) buttonYCenter:(NSInteger)i
{
	CGFloat y;
    NSInteger numX = [self numButtonX];
    NSInteger numY = [self numButtonY];
    CGFloat margin = .0f;
    
    if ([self isButtonBox] == YES && numY < 3)
        margin = 0.2;
    
    // 엇갈리에 배치하기 위해서
    if (sudokuGame.size == 8 && [self isButtonBox])
        i = i*2 - 1;
    else if (sudokuGame.size == 7 && [self isButtonBox])
        i = i*2;
    else if (sudokuGame.size == 5 && [self isButtonBox])
        i = i*2 - 1;
    
    if (numY == 1)
    {
        y = [self getNumButtonAreaY] + [self getNumButtonAreaH]/2;
    
    } else  if ([self isButtonBox])
    {
        y = [self getNumButtonAreaY] +
            [self getNumButtonAreaH]*margin/2 +
            cButtonHeight/2 +
            (([self getNumButtonAreaH]*(1-margin) - cButtonHeight) / (numY-1)) * ((i-1)/numX);   // 세개씩 /3
    } else {
        y = [self getNumButtonAreaY] + cButtonHeight/2 +
            (([self getNumButtonAreaH] - cButtonHeight) / (numY-1)) * ((i-1)%numY);   // 교대로 나옴 %
    }
//   	NSLog(@"buttonYCenter(%d) -> %f", i, y);
	return y;
}

- (void)drawNumButton:(CGContextRef)context
{
	int i;

	CGRect currentRect;
	BOOL bPuzzleNum = NO;
	BOOL bMemoNum = NO;
	CGFloat x, y;
	
	
	if (selectedXPos >= 0 && selectedXPos < sudokuGame.size &&
        selectedYPos >= 0 && selectedYPos < sudokuGame.size)
    {
		if ([sudokuGame getPuzzleNums:selectedXPos y:selectedYPos] > 0)
			bPuzzleNum = YES;
		if ([sudokuGame getFixNums:selectedXPos y:selectedYPos] == 0 &&
			[sudokuGame getMemoNums:selectedXPos y:selectedYPos] != NULL)
			bMemoNum = YES;
	}
	
	
	for (i=1; i<=sudokuGame.size; i++)    // 버튼 모양 그리기
	{
		x = [self buttonXCenter:i] - cButtonWidth/2;
		y = [self buttonYCenter:i] - cButtonHeight/2; 
		
		CGContextSetLineWidth(context, cLineDrawWidth);
		if (bMemoNum && i>0 && i<=sudokuGame.size && [sudokuGame beMemoNums:i x:selectedXPos y:selectedYPos])
		{
			CGContextSetStrokeColorWithColor(context, pressedButtonColor.CGColor);
			CGContextSetFillColorWithColor(context, pressedButtonColor.CGColor);
		} else {
			CGContextSetStrokeColorWithColor(context, bgButtonColor.CGColor);
			CGContextSetFillColorWithColor(context, bgButtonColor.CGColor);
		}	

		currentRect = CGRectMake(x,y,cButtonWidth,cButtonHeight);
		//NSLog(@"currentRect=%f,%f", currentRect.origin.x, currentRect.origin.y);
        
		CGContextAddEllipseInRect(context, currentRect);
		CGContextDrawPath(context, kCGPathFillStroke);		

		if ((bPuzzleNum && pushedButton <= sudokuGame.size) || i != pushedButton)
		{
            CGColorRef color;
            if (bPuzzleNum && i <= sudokuGame.size)	{
				color = bgButtonColor.CGColor;
			} else {
				color = bMemoMode ? memoButtonColor.CGColor : numButtonColor.CGColor;
			}
            
            // 버튼에 숫자를 적기
            [self drawNumRect:context
                          num:i
                         rect:CGRectMake(x, y, cButtonWidth, cButtonHeight)
                        color:color
                         font:bMemoMode ? buttonMemoSmallFont : buttonSmallFont];
		}
	}

	if ((bPuzzleNum == NO) &&
		pushedButton > 0 && pushedButton <= sudokuGame.size)
	{
		i = pushedButton;
		x = [self buttonXCenter:i] - cButtonWidth/2; 
		y = [self buttonYCenter:i] - cButtonHeight/2; 
		
		
		CGContextSetLineWidth(context, cLineDrawWidth);
		CGContextSetStrokeColorWithColor(context, pressedButtonColor.CGColor);
		CGContextSetFillColorWithColor(context, pressedButtonColor.CGColor);
		currentRect = CGRectMake(x,y,cButtonWidth,cButtonHeight);
		
		CGContextAddEllipseInRect(context, currentRect);
		CGContextDrawPath(context, kCGPathFillStroke);		
		
		
        // 버튼에 숫자를 적기
        [self drawNumRect:context
                      num:i
                     rect:CGRectMake(x, y, cButtonWidth, cButtonHeight)
                    color:numButtonColor.CGColor
                     font:bMemoMode ? buttonMemoBigFont : buttonBigFont];

	}

	
	
}




- (void)dealloc {
    [super dealloc];
}

- (NSInteger) TouchToPosX:(CGFloat)floatTouch
{
    floatTouch -= cTableStartX;
/*
    if (floatTouch >= (cCellWidth*3 + cLineWidth*2))
		floatTouch -= (cBoldLine - cLineWidth);
	if (floatTouch >= (cCellWidth*6 + cLineWidth*5))
		floatTouch -= (cBoldLine - cLineWidth);
*/	
	NSInteger pos = floatTouch/(cCellWidth);// + cLineWidth);
 	
	//NSLog(@"TouchToPosX(%f) -> %d", floatTouch, pos);
	
	return pos;
}

- (NSInteger) TouchToPosY:(CGFloat)floatTouch
{
    floatTouch -= cTableStartY;
/*
	if (floatTouch >= (cCellHeight*3 + cLineWidth*2))
		floatTouch -= (cBoldLine - cLineWidth);
	if (floatTouch >= (cCellHeight*6 + cLineWidth*5))
		floatTouch -= (cBoldLine - cLineWidth);
*/	
	NSInteger pos = floatTouch/(cCellHeight);// + cLineWidth);
 	
	//NSLog(@"TouchToPosY(%f) -> %d", floatTouch, pos);
	
	return pos;
	
	
}


- (NSInteger) pressedButtonNum:(NSSet *)touches
{
	int i;
	NSInteger dist = cButtonHeight*cButtonHeight/4;
	NSInteger dist1;
	NSInteger dist2;
	NSInteger xButtonCenter;
	NSInteger yButtonCenter;
	UITouch *touch = [touches anyObject];
	CGPoint	firstTouch = [touch locationInView:self];
	CGFloat fX = firstTouch.x;
	CGFloat fY = firstTouch.y;
	
	for (i=1; i<=sudokuGame.size; i++)
	{

		xButtonCenter = [self buttonXCenter:i]; 
		yButtonCenter = [self buttonYCenter:i]; 

		
		
		dist1 = ((fX-xButtonCenter)*(fX-xButtonCenter)+(fY-yButtonCenter)*(fY-yButtonCenter));
		if (dist1 <= dist)
		{
			if (i<sudokuGame.size)
			{
				xButtonCenter = [self buttonXCenter:i+1]; 
				yButtonCenter = [self buttonYCenter:i+1]; 
				dist2 = ((fX-xButtonCenter)*(fX-xButtonCenter)+(fY-yButtonCenter)*(fY-yButtonCenter));
				if (dist2 < dist1)
				{
//					if (i<9)
						i++;
				}
			}
			
			//NSLog(@"ButtonChoose(%d)", i);
			return i;
		}
	}
	return -1;
	
}

- (void)touchesDo:(NSSet *)touches bEnd:(BOOL)bEnd
{
	MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
	
	UITouch *touch = [touches anyObject];
	CGPoint	firstTouch = [touch locationInView:self];
	CGFloat fX = firstTouch.x;
	CGFloat fY = firstTouch.y;
	
	NSInteger xPos = [self TouchToPosX:fX];
	NSInteger yPos = [self TouchToPosY:fY];

	
    //NSLog(@"touchesDo(%f,%f,end=%d,tapcount=%d)", fX, fY, bEnd, [touch tapCount]);
    if (bEnd && [touch tapCount] == 2 && xPos < sudokuGame.size && yPos < sudokuGame.size) {
        [ctrl memoOnOff];
        return;             // double tab 후에는 아무런 세팅을 하지 않는다.
    }
        
		
    
    if (xPos >= 0 && xPos < sudokuGame.size && yPos >= 0 && yPos < sudokuGame.size) {
        if ([sudokuGame isPuzzleNum:xPos y:yPos]) {
            // do nothing
        } else if (bPressedInCell) {
			if (xPos != selectedXPos || yPos != selectedYPos)
			{
				selectedXPos = xPos;	
				selectedYPos = yPos;
				[self playSound:soundClickID];	// drag
				[self setNeedsDisplay];
			}
		}
        pushedButton = -1; // button을 누른 것이 아니다.
	} else if (bPressedInButton == YES) {
//		NSLog(@"pressedInButton => YES");		
		
		NSInteger buttonNum = [self pressedButtonNum:touches];
		if (bEnd || pushedButton != buttonNum)
		{
			pushedButton = buttonNum;
//			NSLog(@"pushedButton = %d", pushedButton);
                if (buttonNum > 0) {	// button chose
//				NSLog(@"bEnd=%d", bEnd);
				if (bEnd && selectedXPos >=0 && selectedYPos >=0)
				{
                    if ([sudokuGame isPuzzleNum:selectedXPos y:selectedYPos]) {
                        // do nothing
                    } else {
                        if (bMemoMode) {
                            if (buttonNum > 0) {
                                if ([sudokuGame getFixNums:selectedXPos y:selectedYPos] > 0)
                                {
                                    [sudokuGame cancelFixNums:selectedXPos y:selectedYPos];
                                    [sudokuGame addMemoNums:buttonNum x:selectedXPos y:selectedYPos];
                                } else {
                                    [sudokuGame revertMemoNums:buttonNum x:selectedXPos y:selectedYPos];
                            
                                }
                            }
                        } else {
                            //NSLog(@"CellNumChoose(%d,%d <= %d)", selectedXPos, selectedYPos, buttonNum);
                            [sudokuGame setFixNums:buttonNum x:selectedXPos y:selectedYPos];
                            [self checkClearGame];
                        }
                        pushedButton = -1;
                        
                        if (bFailCell)
                            [self playSound:soundFailID];   // 강력한 기능이라서 Setting으로 빼야 한다.
                        else
                            [self playSound:soundClickID];
                        
                        [ctrl updateBlankCellCount];
                        [ctrl updateHintCount];
                        [ctrl updateButtonUndo];
                        [ctrl updateButtonClear];
                    }

				}
			}
			if (bEnd)
			{
				pushedButton = -1;
			}
			[self setNeedsDisplay];
			
		}

	}

	[ctrl updateButtonDel];
	[ctrl updateButtonHint];
	[sudokuGame saveData];

}


- (void) checkClearGame
{
	NSInteger ret = [sudokuGame clearGame];
	
	if (ret == 0) {
        MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
        [ctrl writeScoreAfterFinishGame:sudokuGame];
	} else if (ret > 0) {
		NSString *msg = [[NSString alloc] initWithFormat:gettext(@"There are %d wrong cell(s)", nil), ret];
		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:gettext(@"Alert!", nil)
														message:msg
													   delegate:self 
											  cancelButtonTitle:gettext(@"Ok", nil) 
											  otherButtonTitles:nil];
		[msg release];
		[alert show];
		[alert release];		
	}
	
}

- (void) runUndo
{ 
	NSLog(@"[sudokuGame.sudokuUndo countUndo] = %d", [sudokuGame.sudokuUndo countUndo]);
	
	if (sudokuGame.gameFinished || [sudokuGame.sudokuUndo countUndo] == 0)
		return;
	
	
	CGPoint pointLastUndoPos = [sudokuGame runUndo];

	
	if (pointLastUndoPos.x >= 0 && pointLastUndoPos.y >= 0)
	{
		selectedXPos = (NSInteger) pointLastUndoPos.x;
		selectedYPos = (NSInteger) pointLastUndoPos.y;
        [self playSound:soundClickID];
	}
	[sudokuGame saveData];	
	[self setNeedsDisplay];
}

- (void) runRedo
{
	NSLog(@"[sudokuGame.sudokuUndo countRedo] = %d", [sudokuGame.sudokuUndo countRedo]);
	
	if (sudokuGame.gameFinished || [sudokuGame.sudokuUndo countRedo] == 0)
		return;
	
	
	CGPoint pointLastUndoPos = [sudokuGame runRedo];
    
	
	if (pointLastUndoPos.x >= 0 && pointLastUndoPos.y >= 0)
	{
		selectedXPos = (NSInteger) pointLastUndoPos.x;
		selectedYPos = (NSInteger) pointLastUndoPos.y;
        [self playSound:soundClickID];
	}
    
	[sudokuGame saveData];
	[self setNeedsDisplay];
}

- (void) runBookmark
{
	NSLog(@"[sudokuGame.sudokuUndo countGoBookmark] = %d", [sudokuGame.sudokuUndo countGoBookmark]);

    if ([sudokuGame.sudokuUndo isBookmarked] == NO)
    {
        [sudokuGame.sudokuUndo addBookmark];
        [self playSound:soundClickID];
    } else {
        
        alertMode = ALELRT_BOOKMARK;
        
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:gettext(@"Confirm", nil)];
        //[alert setMessage:@"Do you pick Yes or No?"];
        [alert setDelegate:self];
        [alert addButtonWithTitle:gettext(@"Go to bookmark", nil)];
        [alert addButtonWithTitle:gettext(@"Reset bookmark", nil)];
        [alert addButtonWithTitle:gettext(@"Delete bookmark", nil)];
        [alert addButtonWithTitle:gettext(@"Cancel", nil)];
        [alert show];
        [alert release];
        [self playSound:soundClickID];
    }
	[sudokuGame saveData];

	
	[self setNeedsDisplay];
}


- (BOOL) memoOnOff
{
    if (sudokuGame.gameFinished)
        return bMemoMode;
    
	if (bMemoMode) {
		bMemoMode = NO;
	} else {
		bMemoMode = YES;
	}
	
	[self setNeedsDisplay];	// button re-display
	
	return bMemoMode;
}


- (void) checkClearAndUpdateButton
{
	[self checkClearGame];	
	
	[self playSound:soundClickID];
	MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
	[ctrl updateBlankCellCount];
    [ctrl updateHintCount];
	[ctrl updateButtonUndo];
	[ctrl updateButtonClear];
	[ctrl updateButtonDel];
	[ctrl updateButtonHint];
	
	[self setNeedsDisplay];	
}


- (void) delNumber
{
    if (sudokuGame.gameFinished)
        return;
    
	[sudokuGame setFixNums:0 x:selectedXPos y:selectedYPos];
	[self checkClearAndUpdateButton];

	[sudokuGame saveData];
}

- (void) clearNumbers
{
    if (sudokuGame.gameFinished)
        return;
    
    alertMode = ALELRT_INIT;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:gettext(@"Alert", nil)
													message:gettext(@"Do you want to delete all numbers?", nil)
												   delegate:self 
										  cancelButtonTitle:gettext(@"No", nil) 
										  otherButtonTitles:gettext(@"Yes", nil), nil];
	[alert show];
	[alert release];
	[sudokuGame saveData];
}

- (void) doHint
{
    if (sudokuGame.gameFinished)
        return;
    
	if (sudokuGame.countHint > 0) {
		sudokuGame.countHint -= 1;
		[sudokuGame setHintNum:selectedXPos y:selectedYPos];
	}

	[self checkClearAndUpdateButton];
	[sudokuGame saveData];
}




- (BOOL) loadGame
{
	NSLog(@"loadGame");
	sudokuGame = [SudokuGame loadData];
	
	if (sudokuGame != NULL)
	{
        
		[sudokuGame saveData];
        
		[self setNeedsDisplay];
		return YES;
	}
	return NO;
}



- (void) newGame:(NSInteger)level size:(NSInteger)sizePuzzle
{
	BOOL bUseQQ=NO;
#ifdef SUDOKU9
#ifndef GTSUDOKU
	bUseQQ = YES;
#endif
#endif
	

	if (bUseQQ)
	{
		SudokuBoard* board = GenerateSudoku(DIFF_EXPERT); 
		sudokuGame = [[SudokuGame alloc] initWithSudokuBoard:board level:level automemo:bSettingAutoMemo];
		[board release];
	} else {
		SudokuNum *sudokuNum = sudokuNumGenerate(level, sizePuzzle, bSettingDefMap);
		sudokuGame = [[SudokuGame alloc] initWithSudokuNum:sudokuNum level:level automemo:bSettingAutoMemo];
		[sudokuNum release];
	}
	
	// zzz turn off activityIndicator
    [sudokuGame saveData];          // save Sudoku data as soon as making new game
	[self setNeedsDisplay];
}

#pragma mark -
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertMode)
    {
        case ALELRT_INIT :
            if (buttonIndex == 1) // "확인" 버튼
            {
                [sudokuGame clearAllNums];
                
                MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
                [ctrl updateBlankCellCount];
                [ctrl updateHintCount];
                
                
                [self playSound:soundClearID];
				[sudokuGame saveData];
            }
            break;
        case ALELRT_BOOKMARK :
            if (buttonIndex == 0)
            {
                NSInteger countBookmark = [sudokuGame.sudokuUndo countGoBookmark];
                
                if (countBookmark)
                {
                    CGPoint pointLastUndoPos;
                    selectedXPos = sudokuGame.sudokuUndo.bookmarkX;
                    selectedYPos = sudokuGame.sudokuUndo.bookmarkY;
                    
					if (countBookmark < 0)
					{
						while ([sudokuGame.sudokuUndo getIndex] > [sudokuGame.sudokuUndo getBookmark])
							pointLastUndoPos = [sudokuGame runUndo];
					} else {
						while ([sudokuGame.sudokuUndo getIndex] <= [sudokuGame.sudokuUndo getBookmark])
							pointLastUndoPos = [sudokuGame runRedo];
					}
                }
                [sudokuGame.sudokuUndo delBookmark];
                [self playSound:soundClickID];
            } else if (buttonIndex == 1) {
                [sudokuGame.sudokuUndo addBookmark];
                [self playSound:soundClickID];
            } else if (buttonIndex == 2) {
                [sudokuGame.sudokuUndo delBookmark];
                [self playSound:soundClearID];	
            } else if (buttonIndex == 3) {              // cancel
                
            }
            MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
            [ctrl updateButtonUndo];
			[sudokuGame saveData];

            break;
        default:
            break;
    }
	[self setNeedsDisplay];
}


- (void) OnTimer:(NSTimer *)timer
{
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;

    
    [sudokuGame setFixNums:pressedButtonNum x:selectedXPos y:selectedYPos];
    [self checkClearGame];
    
    
    
    if ([self conflictCell:selectedXPos yPos:selectedYPos])
        [self playSound:soundFailID];   // 강력한 기능이라서 Setting으로 빼야 한다.
    else
        [self playSound:soundClickID];

    [ctrl updateBlankCellCount];
    [ctrl updateHintCount];
    [ctrl updateButtonUndo];
    [ctrl updateButtonClear];
    [ctrl updateButtonDel];
    [ctrl updateButtonHint];


    timerTouch = nil;
    bPressedInButton = NO;
    bHoldAndChoice = YES;       // 누르고 있는 버튼을 크게 표시한다.
    pushedButton = pressedButtonNum;
	
	[sudokuGame saveData];

    [self setNeedsDisplay];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //NSLog(@"touchesBegan(cTableWidth=%f)", cTableWidth);
    
	if (sudokuGame.gameFinished)	// lock the screen
		return;
    if (bMenuMode)
        return;
    
	bTouch = YES;
	NSInteger buttonNum = [self pressedButtonNum:touches];
	if (buttonNum >= 0) {
		bPressedInButton = YES;
        pressedButtonNum = buttonNum;
        if (bMemoMode)
        {
            timerTouch = [NSTimer scheduledTimerWithTimeInterval:TIME_HOLDANDCHOICE
                                                         target:self
                                                       selector:@selector(OnTimer:)
                                                       userInfo:nil
                                                        repeats:NO];
            return;
        }
        
	} else {
		UITouch *touch = [touches anyObject];
		CGPoint	firstTouch = [touch locationInView:self];

        if (firstTouch.x >= cTableStartX && firstTouch.x < cTableStartX+cTableWidth &&
            firstTouch.y >= cTableStartY && firstTouch.y < cTableStartY+cTableHeight)
		{
			bPressedInCell = YES;
		}
	}

	
	[self touchesDo:touches bEnd:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (bMenuMode || sudokuGame.gameFinished)	// lock the screen
		return;	
	bTouch = NO;
//    NSLog(@"Touches Cancelled");
	bPressedInButton = NO;
	bPressedInCell = NO;
//	NSLog(@"pressedInButton = NO");
	
	[self setNeedsDisplay];
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (bMenuMode || sudokuGame.gameFinished)	// lock the screen
		return;
    
	if (bMemoMode)
    {
        if (timerTouch)
        {
            NSLog(@"@@@@@@@@@@@@@@@@ Cancell timer");
            [timerTouch invalidate];
//            [timerTouch release];
            timerTouch = nil;
        }
    }

	bTouch = NO;
    bHoldAndChoice = NO;
	
	[self touchesDo:touches bEnd:YES];
	bPressedInButton = NO;
	bPressedInCell = NO;
//	NSLog(@"pressedInButton = NO");
	
	[self setNeedsDisplay];
}	

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (bMenuMode || sudokuGame.gameFinished)	// lock the screen
		return;
    
	if (bMemoMode)
    {
        if (timerTouch)
        {
            NSLog(@"@@@@@@@@@@@@@@@@ Cancell timer");

            [timerTouch invalidate];
//            [timerTouch release];
            timerTouch = nil;
        }
		return;
    }

	bTouch = YES;
	
	[self touchesDo:touches bEnd:NO];
}

- (BOOL) isSelectedCellisFixed
{
	if (selectedXPos >= 0 && selectedXPos < sudokuGame.size  &&
        selectedYPos >= 0 && selectedYPos < sudokuGame.size) {
		if ([sudokuGame getFixNums:selectedXPos y:selectedYPos] > 0)
			return YES;
	}

	return NO;
}

- (BOOL) isSelectedCellisableHint
{
	if (selectedXPos >= 0 && selectedXPos < sudokuGame.size &&
        selectedYPos >= 0 && selectedYPos < sudokuGame.size) {
		if ([sudokuGame getPuzzleNums:selectedXPos y:selectedYPos] == 0) {// 사용자가 입력하는 칸이다.
			if ([sudokuGame countHint] > 0)		// 아직 Hint item이 남아 있다.
				return YES;
		}
	}
	
	return NO;
}


#define MINWHT   MIN(cCellWidth, cCellHeight)
#define MINWHB   MIN(cButtonWidth, cButtonHeight)


#define cCellOneBigFontSize         (1.0f * MINWHT) //36*cResizeRatioW
#define cCellOneSmallFontSize       (0.8f * MINWHT) //27*cResizeRatioW
#define cCellTwoFontSize            (0.9f * MINWHT / 2) //20*cResizeRatioW
#define cCellFourFontSize           (0.9f * MINWHT / 2) //15*cResizeRatioW
#define cCellSixFontSize            (0.8f * MINWHT / 2) //15*cResizeRatioW
#define cCellNineFontSize           (0.9f * MINWHT / 3) //11*cResizeRatioW

#define cButtonBigFontSize          (1.0f * MINWHB) //40*cResizeRatioW
#define cButtonSmallFontSize        (0.8f * MINWHB) //30*cResizeRatioW
#define cButtonTextFontSize         (0.8f * MINWHB) //20*cResizeRatioW
#define cButtonMemoBigFontSize		(0.8f * MINWHB) //35*cResizeRatioW
#define cButtonMemoSmallFontSize	(0.7f * MINWHB) //25*cResizeRatioW
#define cButtonMemoTextFontSize		(0.7f * MINWHB) //17*cResizeRatioW





- (void) setFont
{
	//NSLog(@"setFont(%f)", cCellWidth);
	self.cellOneSmallFont       = [UIFont fontWithName:@"Trebuchet MS" size:cCellOneSmallFontSize];
	self.cellOneBigFont         = [UIFont fontWithName:@"Trebuchet MS" size:cCellOneBigFontSize];
	self.cellTwoFont            = [UIFont fontWithName:@"Trebuchet MS" size:cCellTwoFontSize];
	self.cellFourFont           = [UIFont fontWithName:@"Trebuchet MS" size:cCellFourFontSize];
	self.cellSixFont            = [UIFont fontWithName:@"Trebuchet MS" size:cCellSixFontSize];
	self.cellNineFont           = [UIFont fontWithName:@"Trebuchet MS" size:cCellNineFontSize];
	self.buttonSmallFont        = [UIFont fontWithName:@"Trebuchet MS" size:cButtonSmallFontSize];
	self.buttonBigFont          = [UIFont fontWithName:@"Trebuchet MS" size:cButtonBigFontSize];
	self.buttonTextFont         = [UIFont fontWithName:@"Trebuchet MS" size:cButtonTextFontSize];
	self.buttonMemoSmallFont	= [UIFont fontWithName:@"Trebuchet MS" size:cButtonMemoSmallFontSize];
	self.buttonMemoBigFont		= [UIFont fontWithName:@"Trebuchet MS" size:cButtonMemoBigFontSize];
	self.buttonMemoTextFont		= [UIFont fontWithName:@"Trebuchet MS" size:cButtonMemoTextFontSize];
    
}

// Draw screen again

- (void)drawRect:(CGRect)rect
{
    
    //NSLog(@"self.bounds(%f,%f)",          self.bounds.size.width, self.bounds.size.height);

    
    //	NSString* s;
	
    //	NSLog(@"%@", [sudokuNum getNums]);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	//NSLog(@"drawRect ---------- refresh");
    
    [self setFont];
    
	[self drawRectTableBackground:context];     // 기본 테이블 바탕 색
	[self drawGuidelineBackground:context];          // 힌트 바탕 색
    [self drawMarkingEqualBackgound:context];   // 같은 숫자 표시 바탕색 표시
	[self drawHighlightCellBackground:context]; // 선택된 셀 바탕색
    [self drawBookmarkInCell:context];          // 북마크 표시
	[self drawRectTableLine:context];           // 테이블 라인 긎기
	[self drawCellNums:context];                // n*n 칸에 숫자를 출력
	[self drawHighlightCell:context];           // 선택된 셀 표시
	[self drawNumButton:context];
    

}

@end
