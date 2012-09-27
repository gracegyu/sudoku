//
//  MainView.m
//  SudokuHelper
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Constants.h"
#import "MainView.h"
#import "AppDelegate.h"
#import "MainViewController.h"

@implementation MainView
@synthesize tableBgColor;
@synthesize selectedTableBgColor;
@synthesize selectedTableBorderColor;
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
@synthesize bSoundOn;


@synthesize cellOneSmallFont;
@synthesize cellOneBigFont;
@synthesize cellFailFont;
@synthesize cellTwoFont;
@synthesize cellFourFont;
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

#define cCellWidth				(cTableWidth/sudokuGame.size) 
#define cCellHeight				(cTableHeight/sudokuGame.size) 

#define cLineWidth				1.f*cResizeRatioW
#define cLineDrawWidth			0.5f*cResizeRatioW
#define cBoldLine				4.f*cResizeRatioW
//#define cBorderButton			5


#define cButtonSmallFontSize        30*cResizeRatioW
#define cButtonBigFontSize          40*cResizeRatioW
#define cButtonTextFontSize         20*cResizeRatioW
#define cButtonMemoSmallFontSize	25*cResizeRatioW
#define cButtonMemoBigFontSize		35*cResizeRatioW
#define cButtonMemoTextFontSize		17*cResizeRatioW

#define cCellOneSmallFontSize       27*cResizeRatioW
#define cCellOneBigFontSize         36*cResizeRatioW
#define cCellTwoFontSize            20*cResizeRatioW
#define cCellFourFontSize           15*cResizeRatioW
#define cCellNineFontSize           11*cResizeRatioW

#define fontAdjust   0.63



- (void)initData
{
	NSLog(@"initData");
	
	self.tableBgColor = [UIColor colorWithWhite:240.f/255.f alpha:1.f];
	self.selectedTableBgColor = [UIColor whiteColor];
	self.selectedTableBorderColor = [UIColor colorWithRed:0.6f green:0.9f blue:0.7f alpha:0.8f];
	self.HintBgColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:0.2f];
	self.MemoModeHintBgColor = [UIColor colorWithRed:0.0f green:1.0f blue:0.2f alpha:0.2f];
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
	self.bSoundOn = NO;
	
//	self.fPress = 1.f;
	
	
	
	
	NSString *path;
	
	path = [[NSBundle mainBundle] pathForResource:@"Funk" ofType:@"aiff"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundClickID);
	path = [[NSBundle mainBundle] pathForResource:@"clear" ofType:@"wav"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundClearID);
	path = [[NSBundle mainBundle] pathForResource:@"Sosumi" ofType:@"aiff"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundFailID);
	
	bMemoMode = NO;
}



- (void) setFont
{
	NSLog(@"setFont");
	self.cellOneSmallFont       = [UIFont fontWithName:@"Trebuchet MS" size:cCellOneSmallFontSize];
	self.cellOneBigFont         = [UIFont fontWithName:@"Trebuchet MS" size:cCellOneBigFontSize];			
	self.cellTwoFont            = [UIFont fontWithName:@"Trebuchet MS" size:cCellTwoFontSize];		
	self.cellFourFont           = [UIFont fontWithName:@"Trebuchet MS" size:cCellFourFontSize];				
	self.cellNineFont           = [UIFont fontWithName:@"Trebuchet MS" size:cCellNineFontSize];		
	self.buttonSmallFont        = [UIFont fontWithName:@"Trebuchet MS" size:cButtonSmallFontSize];	
	self.buttonBigFont          = [UIFont fontWithName:@"Trebuchet MS" size:cButtonBigFontSize];		
	self.buttonTextFont         = [UIFont fontWithName:@"Trebuchet MS" size:cButtonTextFontSize];
	self.buttonMemoSmallFont	= [UIFont fontWithName:@"Trebuchet MS" size:cButtonMemoSmallFontSize];	
	self.buttonMemoBigFont		= [UIFont fontWithName:@"Trebuchet MS" size:cButtonMemoBigFontSize];		
	self.buttonMemoTextFont		= [UIFont fontWithName:@"Trebuchet MS" size:cButtonMemoTextFontSize];		

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

    [self setFont];
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


#define cTableStartX [self getTableX]
#define cTableStartY [self getTableY]
#define cTableWidth	 [self getTableW]
#define cTableHeight [self getTableH]

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
	
    CGContextSetStrokeColorWithColor(context, tableLineColor.CGColor);
    CGContextSetFillColorWithColor(context, tableLineColor.CGColor);

    CGContextSetLineCap(context, kCGLineCapRound);
    
    // 수직선
	for (i=1; i<sudokuGame.size; i++)
	{
		x = cTableStartX + i*cCellWidth;
        for (j=0; j<sudokuGame.size; j++)
        {
            y = cTableStartY + j*cCellHeight;
			CGContextMoveToPoint(context, x, y);
            CGContextAddLineToPoint(context, x, y+cCellHeight);
            CGContextSetLineWidth(context, [sudokuGame isSameMap:i-1 y:j x2:i y2:j] ? cLineDrawWidth : cBoldLine);
            CGContextStrokePath(context);
		}
	}

    // 수평선
	for (i=1; i<sudokuGame.size; i++)
	{
		y = cTableStartY + i*cCellHeight;
        for (j=0; j<sudokuGame.size; j++)
        {
            x = cTableStartX + j*cCellWidth;
			CGContextMoveToPoint(context, x, y);
            CGContextAddLineToPoint(context, x+cCellWidth, y);
            CGContextSetLineWidth(context, [sudokuGame isSameMap:j y:i-1 x2:j y2:i] ? cLineDrawWidth : cBoldLine);
            CGContextStrokePath(context);
		}
	}
	
	
}



// what color?
- (void)drawRectCellOneChoosing:(CGContextRef)context rect:(CGRect)rect
{
	NSLog(@"drawRectCellOneChoosing");
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
}


// 나머지는 파스텔톤
- (void)drawRectCellOneUserFixed:(CGContextRef)context num:(NSInteger)num rect:(CGRect)rect dupwarn:(BOOL)bDupWarnArea conflict:(BOOL)bConflict
{
    CGColorRef color;
    
	if (bDupWarnArea)
	{
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



- (void)drawRectCellOneMemo:(CGContextRef)context memo:(char*)memo rect:(CGRect)rect
{
    int len = strlen(memo);
	int i = 0;
	int x, y;
    int count = (len <= 4 ? 2 : 3);
    
	
	for (y=0; y<count; y++)
	{
		for (x=0; x<count; x++)
		{
			if (i < len)
			{
                [self drawNumRect:context
                              num:[self CharToNum:memo[i]]
                             rect:CGRectMake(rect.origin.x+rect.size.width*x/count,
                                             rect.origin.y+rect.size.height*y/count,
                                             rect.size.width/count,
                                             rect.size.height/count)
                            color:candidateColor.CGColor
                             font:len <= 4 ? cellFourFont : cellNineFont];
                i++;
			}
		}
	}
}

- (BOOL)conflictCell:(NSInteger)xPos yPos:(NSInteger)yPos
{
    NSInteger fixNum = [sudokuGame getFixNums:xPos y:yPos];
    
    if (fixNum == 0)
        return false;
    
    int x, y;
    for (x = 0, y = yPos; x < sudokuGame.size; x++)
    {
        if (x != xPos && [sudokuGame getDisplayNums:x y:y] == fixNum) 
            return true;
    }
    for (x = xPos, y = 0; y < sudokuGame.size; y++)
    {
        if (y != yPos && [sudokuGame getDisplayNums:x y:y] == fixNum) 
            return true;
    }
    
    
    for (int x=0; x<9; x++)
    {
        for (int y=0; y<9; y++)
        {
            if ((x != xPos || y != yPos) &&
                [sudokuGame isSameMap:x y:y x2:xPos y2:yPos] == YES &&
                [sudokuGame getDisplayNums:x y:y] == fixNum)
            {
                return true;
            }
        }
    }
    
    return false;
    
}

- (void)drawRectCell:(CGContextRef)context xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{


    
	BOOL bDupWarnArea = NO;
	if (sudokuGame.gameLevel >= GAMELEVEL_VERYHARD)
	{	// zzz 사용자가 누를 수 있는 버튼인 경우도 조건에 추가를 해야 한다.
		if (bPressedInButton && pushedButton >= 1 && pushedButton <=9)	// 현재 버튼을 누르는 중, 중복 번호 경고 on
		{
			if (selectedXPos == xPos || selectedYPos == yPos ||
                [sudokuGame isSameMap:selectedXPos y:selectedYPos x2:xPos y2:yPos]) // 중복 검사 영역
			{
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
	
	if (puzzleNum > 0)	{
		// 원래 문제에 있던 번호 
		[self drawRectCellOnePuzzle:context num:puzzleNum rect:rect dupwarn:bDupWarnArea&&(puzzleNum==pushedButton)];
	} else if (bMemoMode == NO && bPressedInButton && selectedXPos == xPos && selectedYPos == yPos && pushedButton >= 0 && pushedButton <= 9) {
		// 선택중인 번호 - 큰 글씨로 나온다.
		[self drawRectCellOneChoosing:context rect:rect];
	} else if (fixNum > 0)	{		// 사용자가 입력해 넣은 번호
        BOOL bConflict = [self conflictCell:xPos yPos:yPos];
		[self drawRectCellOneUserFixed:context num:fixNum rect:rect dupwarn:bDupWarnArea&&(fixNum==pushedButton) conflict:bConflict];
	} else if (pMemo) {
		// 메모 중인 번호 
		[self drawRectCellOneMemo:context memo:pMemo rect:rect];
	}
		

	
	

}


- (void)drawCellNums:(CGContextRef)context
{
	int x, y;


//	bFailCell = NO;
	
	for (x=0; x<9; x++)
	{
		for (y=0; y<9; y++)
		{ 
			[self drawRectCell:context xPos:x yPos:y]; 	
		}		
	}
	
	if (bSetThisTime)// && bFailCell)
	{
		AudioServicesPlaySystemSound (soundFailID);
	}
	
	bSetThisTime = NO;
}

// 숫자가 중복되면 안되는 바닥을 보여줌


- (void)drawOneCellBackground:(CGContextRef)context color:(UIColor*)color x:(NSInteger)x y:(NSInteger)y
{
    CGRect currentRect;
    NSInteger xPos = cTableStartX + x*cCellWidth;
    NSInteger yPos = cTableStartY + y*cCellHeight;
    
    CGContextSetLineWidth(context, cLineDrawWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
    currentRect = CGRectMake (xPos,yPos,cCellWidth,cCellHeight);
    
    CGContextAddRect(context, currentRect);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (BOOL) isSameMapWithSelectedCell:(NSInteger)x y:(NSInteger)y
{
    if (selectedXPos < 0 || selectedXPos >= 9 || selectedYPos < 0 || selectedYPos >= 9)	// no selectec cell
		return NO;
    
    NSInteger i = [sudokuGame getMapNums:x y:y];
    NSInteger j = [sudokuGame getMapNums:selectedXPos y:selectedYPos];
    
    return i>0 && j>0 && i == j;
}


- (void)drawHintBackground:(CGContextRef)context
{
	if (selectedXPos < 0 || selectedXPos >= 9 || selectedYPos < 0 || selectedYPos >= 9)	// no selectec cell
		return;
    
	for (int x=0; x<9; x++) {
        for (int y=0; y<9; y++) {
            // 같은 맵 영역 같은 색으로 칠하기
            if (selectedXPos == x ||
                selectedYPos == y ||
                [self isSameMapWithSelectedCell:x y:y]) {
                [self drawOneCellBackground:context color:(bMemoMode ? MemoModeHintBgColor : HintBgColor) x:x y:y];
            }
            
            // 같은 영역에 같은 숫자는 충돌이 되므로 바탕을 다르게 표시하기
            if ([sudokuGame getDisplayNums:selectedXPos y:selectedYPos] > 0)
            {
                if ([sudokuGame getDisplayNums:selectedXPos y:selectedYPos] == [sudokuGame getDisplayNums:x y:y])
                {
                    [self drawOneCellBackground:context color:selectedTableBgColor x:x y:y];
                }
            }
        } //y
	} //x
}


- (void)drawHighlightCell:(CGContextRef)context
{
	if (selectedXPos >= 0 && selectedXPos < 9 && selectedYPos >= 0 && selectedYPos < 9)
	{
		CGRect currentRect;
		NSInteger xPos = cTableStartX + selectedXPos*cCellWidth;
		NSInteger yPos = cTableStartY + selectedYPos*cCellHeight;
    
		CGContextSetLineWidth(context, cLineDrawWidth);
		CGContextSetStrokeColorWithColor(context, selectedTableBgColor.CGColor);
		CGContextSetFillColorWithColor(context, selectedTableBgColor.CGColor);
		currentRect = CGRectMake (xPos+1,yPos+1,cCellWidth-1,cCellHeight-1);
		
		CGContextAddRect(context, currentRect);
		CGContextDrawPath(context, kCGPathFillStroke);


		
		CGContextSetLineWidth(context, 4*cResizeRatioW);
		CGContextSetStrokeColorWithColor(context, selectedTableBorderColor.CGColor);
		currentRect = CGRectMake (xPos+1-4,yPos+1-4,cCellWidth-1+8,cCellHeight-1+8);
		
		CGContextAddRect(context, currentRect);
		CGContextDrawPath(context, kCGPathStroke);
		
	
	
	}
	
}

- (BOOL) isButtonBox
{
    return [self getNumButtonAreaX]/[self getNumButtonAreaY] > 1.5;
}

#define cWidthButton (![self isButtonBox]?[self getNumButtonAreaW]/5.1:[self getNumButtonAreaW]/3.1)
#define cHeightButton (![self isButtonBox]?[self getNumButtonAreaH]/1.95:[self getNumButtonAreaH]/3.1)
#define cDistXButton cWidthButton/2
#define cDistYButton cHeightButton


- (CGFloat) buttonXCenter:(NSInteger)i
{
	CGFloat x;
    NSInteger numButton = [self isButtonBox] ? 3 : 9;
	
    x = [self getNumButtonAreaX] + cWidthButton/2 +
        (([self getNumButtonAreaW] - cWidthButton) / (numButton-1)) * ((i-1)%numButton);
//	NSLog(@"buttonXCenter(%d) -> %f", i, x);
	return x;	
}

- (CGFloat) buttonYCenter:(NSInteger)i
{
	CGFloat y;
    NSInteger numButton = [self isButtonBox] ? 3 : 2;
    
    if ([self isButtonBox])
    {
        y = [self getNumButtonAreaY] + cHeightButton/2 +
            (([self getNumButtonAreaH] - cHeightButton) / (numButton-1)) * ((i-1)/numButton);   // 세개씩 /3
    } else {
        y = [self getNumButtonAreaY] + cHeightButton/2 +
            (([self getNumButtonAreaH] - cHeightButton) / (numButton-1)) * ((i-1)%numButton);   // 교대로 나옴 %
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
	
	
	if (selectedXPos >= 0 && selectedXPos < 9 && selectedYPos >= 0 && selectedYPos < 9) {
		if ([sudokuGame getPuzzleNums:selectedXPos y:selectedYPos] > 0)
			bPuzzleNum = YES;
		if ([sudokuGame getFixNums:selectedXPos y:selectedYPos] == 0 &&
			[sudokuGame getMemoNums:selectedXPos y:selectedYPos] != NULL)
			bMemoNum = YES;
	}
	
	
	for (i=1; i<=9; i++)    // 버튼 모양 그리기
	{
		x = [self buttonXCenter:i] - cWidthButton/2;
		y = [self buttonYCenter:i] - cHeightButton/2; 
		
		CGContextSetLineWidth(context, cLineDrawWidth);
		if (bMemoNum && i>0 && i<10 && [sudokuGame beMemoNums:i x:selectedXPos y:selectedYPos])
		{
			CGContextSetStrokeColorWithColor(context, pressedButtonColor.CGColor);
			CGContextSetFillColorWithColor(context, pressedButtonColor.CGColor);
		} else {
			CGContextSetStrokeColorWithColor(context, bgButtonColor.CGColor);
			CGContextSetFillColorWithColor(context, bgButtonColor.CGColor);
		}	

		currentRect = CGRectMake(x,y,cWidthButton,cHeightButton);
		//NSLog(@"currentRect=%f,%f", currentRect.origin.x, currentRect.origin.y);
        
		CGContextAddEllipseInRect(context, currentRect);
		CGContextDrawPath(context, kCGPathFillStroke);		

		if ((bPuzzleNum && pushedButton != 10) || i != pushedButton)
		{
            CGColorRef color;
            if (bPuzzleNum && i < 10)	{
				color = bgButtonColor.CGColor;
			} else {
				color = bMemoMode ? memoButtonColor.CGColor : numButtonColor.CGColor;
			}
            
            // 버튼에 숫자를 적기
            [self drawNumRect:context
                          num:i
                         rect:CGRectMake(x, y, cWidthButton, cHeightButton)
                        color:color
                         font:bMemoMode ? buttonMemoSmallFont : buttonSmallFont];
		}
	}

	if ((bPuzzleNum == NO) &&
		pushedButton > 0 && pushedButton < 10)
	{
		i = pushedButton;
		x = [self buttonXCenter:i] - cWidthButton/2; 
		y = [self buttonYCenter:i] - cHeightButton/2; 
		
		
		CGContextSetLineWidth(context, cLineDrawWidth);
		CGContextSetStrokeColorWithColor(context, pressedButtonColor.CGColor);
		CGContextSetFillColorWithColor(context, pressedButtonColor.CGColor);
		currentRect = CGRectMake(x,y,cWidthButton,cHeightButton);
		
		CGContextAddEllipseInRect(context, currentRect);
		CGContextDrawPath(context, kCGPathFillStroke);		
		
		
        // 버튼에 숫자를 적기
        [self drawNumRect:context
                      num:i
                     rect:CGRectMake(x, y, cWidthButton, cHeightButton)
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
 	
	NSLog(@"TouchToPosX(%f) -> %d", floatTouch, pos);
	
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
 	
	NSLog(@"TouchToPosY(%f) -> %d", floatTouch, pos);
	
	return pos;
	
	
}


- (NSInteger) pressedButtonNum:(NSSet *)touches
{
	int i;
	NSInteger dist = cHeightButton*cHeightButton/4;
	NSInteger dist1;
	NSInteger dist2;
	NSInteger xButtonCenter;
	NSInteger yButtonCenter;
	UITouch *touch = [touches anyObject];
	CGPoint	firstTouch = [touch locationInView:self];
	CGFloat fX = firstTouch.x;
	CGFloat fY = firstTouch.y;
	
	for (i=1; i<=9; i++)
	{

		xButtonCenter = [self buttonXCenter:i]; 
		yButtonCenter = [self buttonYCenter:i]; 

		
		
		dist1 = ((fX-xButtonCenter)*(fX-xButtonCenter)+(fY-yButtonCenter)*(fY-yButtonCenter));
		if (dist1 <= dist)
		{
			if (i<9)
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
			
			NSLog(@"ButtonChoose(%d)", i);
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
	
	NSLog(@"touchesDo(%f,%f,end=%d,tapcount=%d)", fX, fY, bEnd, [touch tapCount]);
    if (bEnd && [touch tapCount] == 2) { 
        [ctrl memoOnOff];   
    }
        
		
	NSInteger xPos = [self TouchToPosX:fX];
	NSInteger yPos = [self TouchToPosY:fY];
    
    if (xPos < 9 && yPos < 9) {
        if ([sudokuGame isPuzzleNum:xPos y:yPos]) {
            // do nothing
        } else if (bPressedInCell) {
			if (xPos != selectedXPos || yPos != selectedYPos)
			{
				selectedXPos = xPos;	
				selectedYPos = yPos;
				AudioServicesPlaySystemSound (soundClickID);	// drag 
				[self setNeedsDisplay];
			}
		}	
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
							[sudokuGame cancelFixNums:selectedXPos y:selectedYPos];
							[sudokuGame revertMemoNums:buttonNum x:selectedXPos y:selectedYPos];
						}
					} else {
						NSLog(@"CellNumChoose(%d,%d <= %d)", selectedXPos, selectedYPos, buttonNum);
						[sudokuGame setFixNums:buttonNum x:selectedXPos y:selectedYPos];
						[self checkClearGame];	
					}
					pushedButton = -1;
					bSetThisTime = YES;
					
					AudioServicesPlaySystemSound (soundClickID);	
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

}


- (void) checkClearGame
{
	NSInteger ret = [sudokuGame clearGame];
	
	if (ret == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Conglaturations!", nil)
														message:NSLocalizedString(@"You cleared this game.", nil)
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Ok", nil) 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];		
	} else if (ret > 0) {
		NSString *msg = [[NSString alloc] initWithFormat:NSLocalizedString(@"There are %d wrong cell(s)", nil), ret];
		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert!", nil)
														message:msg
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Ok", nil) 
											  otherButtonTitles:nil];
		[msg release];
		[alert show];
		[alert release];		
	}
	
}

- (void) runUndo
{ 
	NSLog(@"sudokuGame.strUndo.length = %d", sudokuGame.strUndo.length);
	
	if (sudokuGame.gameFinished || sudokuGame.strUndo.length == 0)
		return;
	
	
	CGPoint pointLastUndoPos = [sudokuGame runUndo];

	
	if (pointLastUndoPos.x >= 0 && pointLastUndoPos.y >= 0)
	{
		selectedXPos = (NSInteger) pointLastUndoPos.x;
		selectedYPos = (NSInteger) pointLastUndoPos.y;
	}

	AudioServicesPlaySystemSound (soundClickID);
	
	[self setNeedsDisplay];
}

- (BOOL) memoOnOff
{
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
	
	AudioServicesPlaySystemSound (soundClickID);	
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
	[sudokuGame setFixNums:0 x:selectedXPos y:selectedYPos];
	[self checkClearAndUpdateButton];

}

- (void) clearNumbers
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", nil)
													message:NSLocalizedString(@"Do you want to delete all numbers?", nil)
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"No", nil) 
										  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
	[alert show];
	[alert release];			
}

- (void) doHint
{
	if (sudokuGame.countHint > 0) {
		sudokuGame.countHint -= 1;
		[sudokuGame setHintNum:selectedXPos y:selectedYPos];
	}

	[self checkClearAndUpdateButton];

}

- (BOOL) loadGame
{
	NSLog(@"loadGame");
	sudokuGame = [SudokuGame loadData];
	
	if (sudokuGame != NULL) {
		[self setNeedsDisplay];
		return YES;
	}
	return NO;
}


static int	HandyCount[][5] = {
    { 0, 0, 0, 0, 0 },   // 0
    { 0, 0, 0, 0, 0 },   // 1
    { 0, 0, 0, 0, 0 },   // 2
    { 0, 0, 0, 0, 0 },   // 3
    { 0, 1, 2, 3, 4 },   // 4
    { 0, 2, 4, 10, 15 }, // 5
    { 0, 2, 6, 13, 20 }, // 6
    { 0, 3, 8, 16, 22 }, // 7
    { 0, 4, 9, 18, 25 }, // 8
    { 0, 5, 10, 24, 37 } // 9
};

- (void) newGame:(NSInteger)level
{
    NSInteger sizePuzzle = SIZE_9;
    
	SudokuNum *sudokuNum = [[SudokuNum alloc] init];

	[sudokuNum initPuzzle:sizePuzzle];
	[sudokuNum countCell];
	NSInteger i = 0;
	while ([sudokuNum setCellAuto:HandyCount[sizePuzzle][level]])   // Sudoku 게임 생성 시도, 실패시 Backtracking으로 반복
	{
		i++;
        //NSLog(@"############### i = %d", i);
		[sudokuNum printNums];
		[sudokuNum countCell];
	}	
	NSLog(@"%d times loop", i);
	[sudokuNum printNums];
    
	
	// zzzz release previous game
	sudokuGame = [[SudokuGame alloc] initWithSudokuNum:sudokuNum];
	sudokuGame.gameLevel = level;
    [sudokuGame saveData];          // save Sudoku data as soon as making new game
	
	[sudokuNum release];

	// zzz turn off activityIndicator
	
	[self setNeedsDisplay];
}

#pragma mark -
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) // "확인" 버튼
    {
		[sudokuGame clearAllNums];
		
		MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
		[ctrl updateBlankCellCount];
        [ctrl updateHintCount];


		AudioServicesPlaySystemSound(soundClearID);	
	}
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"touchesBegan(cTableWidth=%f)", cTableWidth);
    
	if (bMenuMode)
		return;
	if (sudokuGame.gameFinished)	// lock the screen
		return;
	
	bTouch = YES;
	NSInteger buttonNum = [self pressedButtonNum:touches];	
	if (buttonNum >= 0) {
		bPressedInButton = YES;

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

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	if (bMenuMode)
		return;
	if (sudokuGame.gameFinished)	// lock the screen
		return;	
	bTouch = NO;
//    NSLog(@"Touches Cancelled");
	bPressedInButton = NO;
	bPressedInCell = NO;
//	NSLog(@"pressedInButton = NO");
	
	[self setNeedsDisplay];
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (bMenuMode)
		return;
	if (sudokuGame.gameFinished)	// lock the screen
		return;
	
	bTouch = NO;
	
	[self touchesDo:touches bEnd:YES];
	bPressedInButton = NO;
	bPressedInCell = NO;
//	NSLog(@"pressedInButton = NO");
	
	[self setNeedsDisplay];
}	

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (bMenuMode)
		return;
	if (sudokuGame.gameFinished)	// lock the screen
		return;
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

// Draw screen again

- (void)drawRect:(CGRect)rect
{
    //	NSString* s;
	
    //	NSLog(@"%@", [sudokuNum getNums]);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	//NSLog(@"drawRect ---------- refresh");
    
	[self drawRectTableBackground:context];     // 기본 테이블 바탕 색
	[self drawHintBackground:context];          // 힌트 바탕 색
	[self drawRectTableLine:context];           // 테이블 라인 긎기
	[self drawHighlightCell:context];           // 선택된 셀 표시
	[self drawCellNums:context];                // n*n 칸에 숫자를 출력
	[self drawNumButton:context];
    
    
}

@end
