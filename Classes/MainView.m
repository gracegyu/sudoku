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


@synthesize rectLandscape;
@synthesize rectPortrait;
@synthesize rectCurrent;
@synthesize lastOrientation;
@synthesize fTableWidth;
@synthesize fButtonStart;
@synthesize fPress;


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
	
	self.fPress = 1.f;
	
	
	
	
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
	self.cellFailFont           = [UIFont fontWithName:@"Trebuchet MS" size:cCellFailFontSize];		
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
	

    return self;
}

- (void)drawRectTableBackground:(CGContextRef) context 
{
	NSLog(@"drawRectTable(%f)", self.fPress);
	
	
	CGRect currentRect;
    
    CGContextSetLineWidth(context, cLineDrawWidth);
    CGContextSetStrokeColorWithColor(context, tableBgColor.CGColor);
    CGContextSetFillColorWithColor(context, tableBgColor.CGColor);
	currentRect = CGRectMake (0,0,cTableWidth-1,cTableHeight-1);
	
	CGContextAddRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFillStroke);
}


- (void)drawRectTableLine:(CGContextRef) context 
{
	NSLog(@"drawRectTable(%f)", self.fPress);


	CGRect currentRect;
    
	int x,y,i;
	
    CGContextSetStrokeColorWithColor(context, tableLineColor.CGColor);
    CGContextSetFillColorWithColor(context, tableLineColor.CGColor);
	
	x = cCellWidth*3 + cLineWidth*2;
    currentRect = CGRectMake (x,0,cBoldLine-1,cTableHeight-1);
	CGContextAddRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFillStroke);

	x = cCellWidth*6 + cLineWidth*4 + cBoldLine;
    currentRect = CGRectMake (x,0,cBoldLine-1,cTableHeight-1);
	CGContextAddRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFillStroke);

	y = cCellHeight*3 + cLineWidth*2;
    currentRect = CGRectMake (0,y,cTableWidth-1,cBoldLine-1);
	CGContextAddRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFillStroke);
	
	y = cCellHeight*6 + cLineWidth*4 + cBoldLine;
    currentRect = CGRectMake (0,y,cTableWidth-1,cBoldLine-1);
	CGContextAddRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFillStroke);

	for (i=1; i<9; i++)
	{
		if (i%3 != 0)
		{
			x = i*cCellWidth + (i-1)*cLineWidth + (i/3)*(cBoldLine-cLineWidth);
			CGContextMoveToPoint(context, x, 0);
            CGContextAddLineToPoint(context, x, cTableHeight-1);
		}
	}

	for (i=1; i<9; i++)
	{
		if (i%3 != 0)
		{
			y = i*cCellHeight + (i-1)*cLineWidth + (i/3)*(cBoldLine-cLineWidth);
			CGContextMoveToPoint(context, 0, y);
            CGContextAddLineToPoint(context, cTableWidth-1, y);
		}
	}
	CGContextStrokePath(context);	
	
}

// what color?
- (void)drawRectCellOneChoosing:(CGContextRef)context zeroX:(CGFloat)zeroX zeroY:(CGFloat)zeroY
{
	NSLog(@"drawRectCellOneChoosing");
	if (pushedButton == 0)
	{
		NSLog(@"pushedButton == 0");
		return;					// delete cell
	}
		
	NSString *str = [[NSString alloc] initWithFormat:@"%d", pushedButton];
/*	NSRange range = [strNum rangeOfString:@"*"];
	BOOL bFixedCellByUser = NO;
	
	if (range.location != NSNotFound)
		bFixedCellByUser = YES;
	
	range = [strNum rangeOfString:str];
	if ((bFixedCellByUser == NO && range.location == NSNotFound) ||
		(bFixedCellByUser == YES && range.location != NSNotFound))	// 후보군의 숫자가 아님, 설정 불가능
	{
		CGContextSetFillColorWithColor(context, choosingNoColor.CGColor);
	} else*/ {
		CGContextSetFillColorWithColor(context, choosingOkColor.CGColor);
	}

	
	
	[str drawAtPoint:CGPointMake(zeroX+8*cResizeRatioW, zeroY-6*cResizeRatioH) 
			withFont:cellOneBigFont];
	[str release];
	
}

// 검정
- (void)drawRectCellOnePuzzle:(CGContextRef)context num:(NSInteger)num zeroX:(CGFloat)zeroX zeroY:(CGFloat)zeroY dupwarn:(BOOL)bDupWarnArea
{
	NSString *str;

	if (bDupWarnArea)
	{
		CGContextSetFillColorWithColor(context, cellWarnColor.CGColor);
	} else {
		CGContextSetFillColorWithColor(context, fixedByUserColor.CGColor);
	}


	
	str = [[NSString alloc] initWithFormat:@"%d", num];
	[str drawAtPoint:CGPointMake(10*cResizeRatioW+zeroX, zeroY-1*cResizeRatioH) 
						withFont:cellOneSmallFont];
	[str release];
}


// 나머지는 파스텔톤
- (void)drawRectCellOneUserFixed:(CGContextRef)context num:(NSInteger)num zeroX:(CGFloat)zeroX zeroY:(CGFloat)zeroY dupwarn:(BOOL)bDupWarnArea conflict:(BOOL)bConflict
{
	if (bDupWarnArea)
	{
		CGContextSetFillColorWithColor(context, cellWarnColor.CGColor);
	} else if (bConflict) {     // conflict number 처리
		CGContextSetFillColorWithColor(context, cellConflictColor.CGColor);
    } else {
        CGContextSetFillColorWithColor(context, fixedByAutoColor.CGColor);
	}

	
	NSString *str = [[NSString alloc] initWithFormat:@"%d", num];
	[str drawAtPoint:CGPointMake(10*cResizeRatioW+zeroX, zeroY-1*cResizeRatioH) 
			withFont:cellOneSmallFont];
	[str release];
}

- (void)drawRectCellZero:(CGContextRef)context strNum:(NSString*)strNum zeroX:(CGFloat)zeroX zeroY:(CGFloat)zeroY
{
	NSString *str;
	
    CGContextSetFillColorWithColor(context, cellFailColor.CGColor);
	
	str = @"Fail";
	[str drawAtPoint:CGPointMake(zeroX+5*cResizeRatioW, zeroY+6*cResizeRatioH) 
			withFont:cellFailFont];


}


- (void)drawRectCellTwo:(CGContextRef)context strNum:(NSString*)strNum zeroX:(CGFloat)zeroX zeroY:(CGFloat)zeroY
{
	int x;
	NSString *str;
	
    CGContextSetFillColorWithColor(context, candidateTwoColor.CGColor);
	
	for (x=0; x<2; x++)
	{ 
		unichar c = [strNum characterAtIndex:x];
		str = [[NSString alloc] initWithFormat:@"%c", c];
		
		[str drawAtPoint:CGPointMake(zeroX+4*cResizeRatioW+(cCellWidth*x)/2, zeroY+4*cResizeRatioH) 
				withFont:cellTwoFont];
		[str release];
	}
	
}


- (void)drawRectCellFour:(CGContextRef)context memo:(char*)memo zeroX:(CGFloat)zeroX zeroY:(CGFloat)zeroY
{
	int len = strlen(memo);
	int i = 0;
	int x, y;
	NSString *str;
	char c;

    CGContextSetFillColorWithColor(context, candidateColor.CGColor);
	
	for (y=0; y<2; y++)
	{
		for (x=0; x<2; x++)
		{ 
			if (i < len)
			{
				c = memo[i];
				str = [[NSString alloc] initWithFormat:@"%c", c];
				
				[str drawAtPoint:CGPointMake(zeroX+3*cResizeRatioW+(cCellWidth-0)/2*x, zeroY+0+(cCellHeight-0)/2*y-2*cResizeRatioH) 
					   withFont:cellFourFont];
				i++;
				[str release];
			}
		}
	}
	
}

- (void)drawRectCellNine:(CGContextRef)context memo:(char*)memo zeroX:(CGFloat)zeroX zeroY:(CGFloat)zeroY
{
	int len = strlen(memo);
	int i = 0;
	int x, y;
	NSString *str;
	char c;

    CGContextSetFillColorWithColor(context, candidateColor.CGColor);
	
	for (y=0; y<3; y++)
	{
		for (x=0; x<3; x++)
		{ 
			if (i < len)
			{
				c = memo[i];
				str = [[NSString alloc] initWithFormat:@"%c", c];
				
				[str drawAtPoint:CGPointMake(zeroX+2*cResizeRatioW+(cCellWidth-0)/3*x, zeroY+0+(cCellHeight-0)/3*y-2*cResizeRatioH) 
						withFont:cellNineFont];
				i++;
				[str release];
			}
		}
	}
	
}


- (void)drawRectCellOneMemo:(CGContextRef)context memo:(char*)memo zeroX:(CGFloat)zeroX zeroY:(CGFloat)zeroY
{
	int len = strlen(memo);
	
	if (len <= 4)
		[self drawRectCellFour:context memo:memo zeroX:zeroX zeroY:zeroY];
	else
		[self drawRectCellNine:context memo:memo zeroX:zeroX zeroY:zeroY];
}

- (BOOL)conflictCell:(NSInteger)xPos yPos:(NSInteger)yPos
{
    NSInteger fixNum = [sudokuGame getFixNums:xPos y:yPos];
    
    if (fixNum == 0)
        return false;
    
    int x, y;
    for (x = 0, y = yPos; x < 9; x++)
    {
        if (x != xPos && [sudokuGame getDisplayNums:x y:y] == fixNum) 
            return true;
    }
    for (x = xPos, y = 0; y < 9; y++)
    {
        if (y != yPos && [sudokuGame getDisplayNums:x y:y] == fixNum) 
            return true;
    }
    for (x = (xPos/3)*3; x < (xPos/3)*3+3; x++)
    for (y = (yPos/3)*3; y < (yPos/3)*3+3; y++)
    {
        if ((x != xPos || y != yPos) && [sudokuGame getDisplayNums:x y:y] == fixNum) 
            return true;
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
			if (selectedXPos == xPos || selectedYPos == yPos || (selectedXPos/3 == xPos/3 && selectedYPos/3 == yPos/3)) // 중복 검사 영역
			{
				bDupWarnArea = YES;
			}		
		}
	}
	
	CGFloat zeroX = xPos*cCellWidth + (xPos-1)*cLineWidth + (xPos/3)*(cBoldLine-cLineWidth); 
	CGFloat zeroY = yPos*cCellHeight + (yPos-1)*cLineWidth + (yPos/3)*(cBoldLine-cLineWidth);

	NSInteger puzzleNum = [sudokuGame getPuzzleNums:xPos y:yPos];
	NSInteger fixNum = [sudokuGame getFixNums:xPos y:yPos];
	char *pMemo = [sudokuGame getMemoNums:xPos y:yPos];
	
	if (puzzleNum > 0)	{
		// 원래 문제에 있던 번호 
		[self drawRectCellOnePuzzle:context num:puzzleNum zeroX:zeroX zeroY:zeroY dupwarn:bDupWarnArea&&(puzzleNum==pushedButton)];
	} else if (bMemoMode == NO && bPressedInButton && selectedXPos == xPos && selectedYPos == yPos && pushedButton >= 0 && pushedButton <= 9) {
		// 선택중인 번호 - 큰 글씨로 나온다.
		[self drawRectCellOneChoosing:context zeroX:zeroX zeroY:zeroY];
	} else if (fixNum > 0)	{
		// 사용자가 입력해 넣은 번호
        
        
        BOOL bConflict = [self conflictCell:xPos yPos:yPos];
        
        
        
		[self drawRectCellOneUserFixed:context num:fixNum zeroX:zeroX zeroY:zeroY dupwarn:bDupWarnArea&&(fixNum==pushedButton) conflict:bConflict];
	} else if (pMemo) {
		// 메모 중인 번호 
		[self drawRectCellOneMemo:context memo:pMemo zeroX:zeroX zeroY:zeroY];	
	}
		

	
	
/*	
		
	}  else if (len == 0)	// fail cell
	{	
		bFailCell = YES;
		[self drawRectCellZero:context strNum:strNum zeroX:zeroX zeroY:zeroY];
	} else if (len == 2)
	{
		[self drawRectCellTwo:context strNum:strNum zeroX:zeroX zeroY:zeroY];
	} else if (len <= 4)
	{
		[self drawRectCellFour:context strNum:strNum zeroX:zeroX zeroY:zeroY];
	} else  // 5~9
	{
		[self drawRectCellNine:context strNum:strNum zeroX:zeroX zeroY:zeroY];
	}
*/	
}


- (void)drawRectNums:(CGContextRef)context
{
	int x, y;


	bFailCell = NO;
	
	for (x=0; x<9; x++)
	{
		for (y=0; y<9; y++)
		{ 
			[self drawRectCell:context xPos:x yPos:y]; 	
		}		
	}
	
	if (bSetThisTime && bFailCell)
	{
		AudioServicesPlaySystemSound (soundFailID);
	}
	
	bSetThisTime = NO;
}

// 숫자가 중복되면 안되는 바닥을 보여줌


- (void)drawOneCelBackground:(CGContextRef)context color:(UIColor*)color x:(NSInteger)x y:(NSInteger)y
{
    CGRect currentRect;
    NSInteger xPos = x*cCellWidth + (x-1)*cLineWidth + (x/3)*(cBoldLine-cLineWidth); 
    NSInteger yPos = y*cCellHeight + (y-1)*cLineWidth + (y/3)*(cBoldLine-cLineWidth);
    
    CGContextSetLineWidth(context, cLineDrawWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
    currentRect = CGRectMake (xPos+1,yPos+1,cCellWidth-1,cCellHeight-1);
    
    CGContextAddRect(context, currentRect);
    CGContextDrawPath(context, kCGPathFillStroke);
}



- (void)drawHintBackground:(CGContextRef)context
{
	if (selectedXPos < 0 || selectedXPos >= 9 || selectedYPos < 0 || selectedYPos >= 9)	// no selectec cell
		return;
		
	for (int x=0; x<9; x++) {
	for (int y=0; y<9; y++) {
        if (selectedXPos == x ||
            selectedYPos == y ||
            (selectedXPos/3 == x/3 && selectedYPos/3 == y/3)) {
            [self drawOneCelBackground:context color:(bMemoMode ? MemoModeHintBgColor : HintBgColor) x:x y:y];
            /*
            CGRect currentRect;
            NSInteger xPos = x*cCellWidth + (x-1)*cLineWidth + (x/3)*(cBoldLine-cLineWidth); 
            NSInteger yPos = y*cCellHeight + (y-1)*cLineWidth + (y/3)*(cBoldLine-cLineWidth);
		
            CGContextSetLineWidth(context, cLineDrawWidth);
            CGContextSetStrokeColorWithColor(context, bMemoMode ? MemoModeHintBgColor.CGColor : HintBgColor.CGColor);
            CGContextSetFillColorWithColor(context, bMemoMode ? MemoModeHintBgColor.CGColor : HintBgColor.CGColor);
            currentRect = CGRectMake (xPos+1,yPos+1,cCellWidth-1,cCellHeight-1);
		
            CGContextAddRect(context, currentRect);
            CGContextDrawPath(context, kCGPathFillStroke);
             */
		}
        
        if ([sudokuGame getDisplayNums:selectedXPos y:selectedYPos] > 0)
        {
            if ([sudokuGame getDisplayNums:selectedXPos y:selectedYPos] == [sudokuGame getDisplayNums:x y:y])
            {    
                [self drawOneCelBackground:context color:selectedTableBgColor x:x y:y];
            }
        }
        
		//////
        
        
        
	} //y
	} //x
}


- (void)drawHighlightCell:(CGContextRef)context
{
	if (selectedXPos >= 0 && selectedXPos < 9 && selectedYPos >= 0 && selectedYPos < 9)
	{
		CGRect currentRect;
		NSInteger xPos = selectedXPos*cCellWidth + (selectedXPos-1)*cLineWidth + (selectedXPos/3)*(cBoldLine-cLineWidth); 
		NSInteger yPos = selectedYPos*cCellHeight + (selectedYPos-1)*cLineWidth + (selectedYPos/3)*(cBoldLine-cLineWidth);
    
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

#define cWidthButton 46*cResizeRatioW
#define cHeightButton (53*cResizeRatioW*fPress)
#define cDistXButton 23*cResizeRatioW
#define cDistYButton ((rectCurrent.size.height*fPress-cYButtonStart)*0.98-cHeightButton)

#define cWidthScreen fTableWidth
#define cYButtonStart (fButtonStart)

- (NSInteger) buttonXCenter:(NSInteger)i
{
	NSInteger centerX, centerY, x;
	
	if (lastOrientation == UIInterfaceOrientationPortrait ||
		lastOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		centerX = cWidthScreen/2;
	} else {
        centerX = fTableWidth + (rectCurrent.size.width - fTableWidth)/2;
#ifdef ADMOB_FREEVERSION
		centerY = (fTableWidth/fPress)/2 + 1;
#else
		centerY = fTableWidth/2 + 1;
#endif        
//		centerX = fTableWidth + (rectCurrent.size.width - fTableWidth)/2;
//		centerY = fTableWidth/2 + 1;
	}	
	
	if (lastOrientation == UIInterfaceOrientationPortrait ||
		lastOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		x = centerX + (i-5)*cDistXButton;	
	} else {
		if (cDeviceType == DEVICETYPE_IPHONE) {
			x = centerX + (((i-1)%3)-1) * cWidthButton * 1.3;
		} else {
			x = centerX + (((i+1)%2)*2-1)*cWidthButton/2;
		}
	}
	
	return x;	
}

- (NSInteger) buttonYCenter:(NSInteger)i
{
	NSInteger centerX, centerY, y;
	
	if (lastOrientation == UIInterfaceOrientationPortrait ||
		lastOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		centerX = cWidthScreen/2;
	} else {
		centerX = cTableWidth + (rectCurrent.size.width - fTableWidth)/2;
#ifdef ADMOB_FREEVERSION
		centerY = (cTableHeight/fPress)/2;
#else
		centerY = cTableHeight/2;
#endif
	}	
	
	if (lastOrientation == UIInterfaceOrientationPortrait ||
		lastOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		y = cYButtonStart+((i+1)%2)*cDistYButton + cHeightButton/2;
	} else {
		if (cDeviceType == DEVICETYPE_IPHONE) {
			y = cTableHeight/2 - cHeightButton*1.2 + (i-1)/3 * cHeightButton*1.2;
		} else {
			y = centerY + (i-5)*(cHeightButton*0.43);
		}
	}
	
	return y;	
}

- (void)drawNumButton:(CGContextRef)context
{
	int i;
	NSString *str;
	CGRect currentRect;
	BOOL bPuzzleNum = NO;
	BOOL bMemoNum = NO;
	NSInteger x, y;	
	
//	MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
//	CGRect frameButtonDel = ctrl.buttonDel.frame;
	
	if (selectedXPos >= 0 && selectedXPos < 9 && selectedYPos >= 0 && selectedYPos < 9) {
		if ([sudokuGame getPuzzleNums:selectedXPos y:selectedYPos] > 0)
			bPuzzleNum = YES;
		if ([sudokuGame getFixNums:selectedXPos y:selectedYPos] == 0 &&
			[sudokuGame getMemoNums:selectedXPos y:selectedYPos] != NULL)
			bMemoNum = YES;
	}
	
	
	for (i=1; i<=9; i++)
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
		
		CGContextAddEllipseInRect(context, currentRect);
		CGContextDrawPath(context, kCGPathFillStroke);		

		if ((bPuzzleNum && pushedButton != 10) || i != pushedButton)
		{
			if (bPuzzleNum && i < 10)	{
				CGContextSetFillColorWithColor(context, bgButtonColor.CGColor);
			} else {
				CGContextSetFillColorWithColor(context, bMemoMode ? memoButtonColor.CGColor : numButtonColor.CGColor);
			}
            
            NSInteger iFontSize = bMemoMode? cButtonMemoSmallFontSize : cButtonSmallFontSize;
            
			x = x + cWidthButton/2 - iFontSize/2+iFontSize/5;
			y = y + cHeightButton/2 - iFontSize/2-iFontSize/10;
			
			str = [[NSString alloc] initWithFormat:@"%d", i];
            [str drawAtPoint:CGPointMake(x, y) withFont:bMemoMode ? buttonMemoSmallFont : buttonSmallFont];
			[str release];
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
		
		
		CGContextSetFillColorWithColor(context, numButtonColor.CGColor);
		{
            NSInteger iFontSize = bMemoMode? cButtonMemoBigFontSize : cButtonBigFontSize;

			x = x + cWidthButton/2 - iFontSize/2+iFontSize/5-1;
			y = y + cHeightButton/2 - iFontSize/2-iFontSize/10-1;
			
			str = [[NSString alloc] initWithFormat:@"%d", i];
			[str drawAtPoint:CGPointMake(x, y) withFont:bMemoMode ? buttonMemoBigFont : buttonBigFont];	
		}
		
		[str release];
	}

	
	
}

// Draw screen again

- (void)drawRect:(CGRect)rect 
{
//	NSString* s;
	
//	NSLog(@"%@", [sudokuNum getNums]);
//		NSLog(@"s = %@", [self.sudokuNum getCellNumX:0 yPos:0]);
	CGContextRef context = UIGraphicsGetCurrentContext();

	NSLog(@"drawRect ---------- refresh");

	[self drawRectTableBackground:context];     // 기본 테이블 바탕 색
	[self drawHintBackground:context];          // 힌트 바탕 색
	[self drawRectTableLine:context];           // 테이블 라인 긎기
	[self drawHighlightCell:context];           // 선택된 셀 표시
	[self drawRectNums:context];                // 9*9 칸에 숫자를 출력
	[self drawNumButton:context];


}


- (void)dealloc {
    [super dealloc];
}

- (NSInteger) TouchToPosX:(CGFloat)floatTouch
{
	if (floatTouch >= (cCellWidth*3 + cLineWidth*2))
		floatTouch -= (cBoldLine - cLineWidth);
	if (floatTouch >= (cCellWidth*6 + cLineWidth*5))
		floatTouch -= (cBoldLine - cLineWidth);
	
	NSInteger pos = floatTouch/(cCellWidth + cLineWidth);
 	
	NSLog(@"TouchToPosX(%f) -> %d", floatTouch, pos);
	
	return pos;
}

- (NSInteger) TouchToPosY:(CGFloat)floatTouch
{
	if (floatTouch >= (cCellHeight*3 + cLineWidth*2))
		floatTouch -= (cBoldLine - cLineWidth);
	if (floatTouch >= (cCellHeight*6 + cLineWidth*5))
		floatTouch -= (cBoldLine - cLineWidth);
	
	NSInteger pos = floatTouch/(cCellHeight + cLineWidth);
 	
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
		if (bPressedInCell) {
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
/*			if (buttonNum == 10)
			{

				if (bEnd) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", nil)
																	message:NSLocalizedString(@"Do you want to delete all numbers?", nil)
																   delegate:self 
														  cancelButtonTitle:NSLocalizedString(@"No", nil) 
														  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
					[alert show];
					[alert release];					
				}
			} else */if (buttonNum > 0) {	// button chose
//				NSLog(@"bEnd=%d", bEnd);
				if (bEnd && selectedXPos >=0 && selectedYPos >=0)
				{
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


static int	HandyCount[] = { 0, 5, 10, 20, 30 };

- (void) newGame:(NSInteger)level
{
	SudokuNum *sudokuNum = [[SudokuNum alloc] init];

	// turn on activityIndicator
	
	[sudokuNum countCell];
	NSInteger i = 0;
	while ([sudokuNum setCellAuto:HandyCount[level]])
	{
		i++;
		[sudokuNum printNums];
		[sudokuNum countCell];
	}	
	NSLog(@"%d times loop", i);
	
	
	// zzzz release previous game
	sudokuGame = [[SudokuGame alloc] initWithSudokuNum:sudokuNum];
	sudokuGame.gameLevel = level;
	
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
	if (bMenuMode)
		return;
	if (sudokuGame.gameFinished)	// lock the screen
		return;
	
	bTouch = YES;
	NSInteger buttonNum = [self pressedButtonNum:touches];	
	if (buttonNum >= 0) {
		bPressedInButton = YES;
//		NSLog(@"pressedInButton = YES");
	} else {
		UITouch *touch = [touches anyObject];
		CGPoint	firstTouch = [touch locationInView:self];
		if (firstTouch.y < cTableWidth)
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

- (BOOL) selectedCellisFixed
{
	if (selectedXPos >= 0 && selectedXPos < 9 && selectedYPos >= 0 && selectedYPos < 9) {
		if ([sudokuGame getFixNums:selectedXPos y:selectedYPos] > 0)
			return YES;
	}

	return NO;
}

- (BOOL) selectedCellisableHint
{
	if (selectedXPos >= 0 && selectedXPos < 9 && selectedYPos >= 0 && selectedYPos < 9) {
		if ([sudokuGame getPuzzleNums:selectedXPos y:selectedYPos] == 0) {// 사용자가 입력하는 칸이다.
			if ([sudokuGame countHint] > 0)		// 아직 Hint item이 남아 있다.
				return YES;
		}
	}
	
	return NO;
}



@end
