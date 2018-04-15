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
#import "Flurry.h"



@implementation MainView


@synthesize sudokuGame;
@synthesize skin;
@synthesize selectedXPos;
@synthesize selectedYPos;
@synthesize pushedButton;
@synthesize bTouch;
@synthesize bPressedInButton;
@synthesize bPressedInCell;
@synthesize bMemoMode;
@synthesize bMenuMode;
@synthesize bDupWarn;
@synthesize nSettingSoundOff;
@synthesize bSettingGuideline;
@synthesize bSettingDuplicationWarning;
@synthesize bSettingMarkingEqual;
@synthesize bSettingDefMap;
@synthesize bSettingAutoMemo;
@synthesize nSettingSudokuType;
@synthesize nSettingGameLevel;
@synthesize bSharedThisOnFacebook;
@synthesize paidHintCount;


@synthesize cellOneSmallFont;
@synthesize cellOneBigFont;
@synthesize cellFailFont;
@synthesize cellTwoFont;
@synthesize cellFourFont;
@synthesize cellSixFont;
@synthesize cellNineFont;
@synthesize cellBookmarkFont;
@synthesize cellSumFont;
@synthesize cellWrongSumFont;
@synthesize cellSignFont;
@synthesize buttonSmallFont;
@synthesize buttonBigFont;
//@synthesize buttonTextFont;
@synthesize buttonMemoSmallFont;
@synthesize buttonMemoBigFont;
//@synthesize buttonMemoTextFont;






#define cWidthScreen cTableWidth
#define cYButtonStart [self getNumButtonAreaY]


#define cResizeRatioW			(cTableWidth/300)
//#define cResizeRatioH			(isIpad ? 1004/460 : 1)
#define cTableStartX [self getTableX]
#define cTableStartY [self getTableY]
#define cTableWidth	 [self getTableW]
#define cTableHeight [self getTableH]

#define cCellWidth				(cTableWidth/sudokuGame.size) 
#define cCellHeight				(cTableHeight/sudokuGame.size) 

#define cLineWidth				1.0f*cResizeRatioW
#define cLineDrawWidth			0.8f*cResizeRatioW
#define cConflictLineWidth		1.0f*cResizeRatioW
#define cBoldLine				3.0f*cResizeRatioW
#define cKillerBoldLine			5.0f*cResizeRatioW

#define fontAdjust   0//0.60

#define bSettingCompareWarning      bSettingDuplicationWarning
#define GTDEPTH 0.10
#define GTWIDTH 0.30


#define DEFAULT_SKIN_NUM 0


static NSUInteger SkinColorTemplate[][COUNT_SKINCOLOR] = {
	{	0x88A6CAFF,0x95B5DBFF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,             // old:0x809AE0FF
		0x88A6CAFF,0xFF0C59FF,0xB9BAB2BB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E680,0xE6E6E6E6,0xCCE6CC80,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{	0x7188BAFF,0x7A93C9FF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,
		0x7188BAFF,0xFF0C59FF,0xB9BAB2BB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E680,0xE6E6E6E6,0xCCE6CC80,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{	0xB6B5B1FF,0xC6C6C2FF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,
		0xB6B5B1FF,0xFF0C59FF,0x80BBB7BB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E680,0xE6E6E6E6,0xCCE6CC80,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{	0x9891AEFF,0xA7A0BFFF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,
		0x9891AEFF,0xFF0C59FF,0xFFABA0BB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E680,0xE6E6E6E6,0xCCE6CC80,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{	0xE78F99FF,0xF799A4FF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,
		0xE78F99FF,0xFF0C59FF,0xB9BAB2BB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E680,0xE6E6E6E6,0xCCE6CC80,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{	0xD3B89CFF,0xE2C5A7FF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,
		0xD3B89CFF,0xFF0C59FF,0x9AAED1BB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E680,0xE6E6E6E6,0xCCE6CC80,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{	0xDBCD3DFF,0xEAD941FF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,
		0xDBCD3DFF,0xFF0C59FF,0x59B2F9BB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E6A0,0xE6E6E6E6,0xCCE6CCA0,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{	0xACC547FF,0xBDD64FFF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,
		0xACC547FF,0xFF0C59FF,0xB6B5CEBB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E680,0xE6E6E6E6,0xCCE6CC80,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{	0x7CAD6DFF,0x89BC78FF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,
		0x7CAD6DFF,0xFF0C59FF,0xB9BAB2BB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E680,0xE6E6E6E6,0xCCE6CC80,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{	0x50938BFF,0x59A399FF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,
		0x50938BFF,0xFF0C59FF,0xB9BAB2BB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E680,0xE6E6E6E6,0xCCE6CC80,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{	0x727AB7FF,0x7D85C6FF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,
		0x727AB7FF,0xFF0C59FF,0xB9BAB2BB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E680,0xE6E6E6E6,0xCCE6CC80,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{	0x2B9FE3FF,0x2EACF4FF,0xE8E8E8FF,0xFFFFFFFF,0xFFFF80FF,0xB6FFC8FF,
		0x2B9FE3FF,0xFF0C59FF,0xB9BAB2BB,0x99E6B3CC,0xFFF093EE,
		0x606070FF,0x5DB581FF,0x80CC99FF,0x3E7BC1FF,0xFF4D00E6,0xB30080E6,0x000000FF,
		0xE6E6E680,0xE6E6E6E6,0xCCE6CC80,0xCCE6CCE6,0x1A1A66B3,0x1A1A66B3
    },
	{0}
};

static NSUInteger RainbowColorTemplate[7] = {
		0xFDE1DCFF,0xF4E7CEFF,0xF3FCDDFF,0xD2F5E0FF,0xDBE6F0FF,0xE6DDEAFF, 0xD1FFECFF
};

static NSUInteger BiggerColorTemplate[9] = {
    0xFFFFFF,0xFFE8E2FF,0xFFDDD6FF,0xFFCFC4FF,0xFFC0B2FF,0xFFB19EFF,0xFFA58EFF,0xFF997FFF,0xFF8C70FF
};
static NSUInteger SmallerColorTemplate[9] = {
    0xFFFFFF,0xDBFAFFFF,0xD1F8FFFF,0xBFF6FFFF,0xAFF4FFFF,0xA0F2FFFF,0x91F0FFFF,0x82EEFFFF,0x72ECFFFF
};



- (NSInteger) getRGBA:(NSInteger)skinnum num:(NSUInteger) num
{
	return  SkinColorTemplate[skinnum][num];
}



- (UIColor*) getUIColorFromRGBA:(NSUInteger) num
{
	NSInteger RGBA = SkinColorTemplate[skin][num];
	CGFloat fAlpha = 1.f;
    
    if (sudokuGame.sudokuType == SUDOKUTYPE_KILLER || sudokuGame.sudokuType == SUDOKUTYPE_CALCU)
    {
        if (num == SC_BACKGROUND_GUIDELINE_NORMAL ||
            num == SC_BACKGROUND_GUIDELINE_MEMO)
            fAlpha = 0.0f;
    } else if (sudokuGame.sudokuType == SUDOKUTYPE_SUDOKU || sudokuGame.sudokuType == SUDOKUTYPE_SYMBOL) {
        if (num == SC_BACKGROUND_GUIDELINE_NORMAL ||
            num == SC_BACKGROUND_GUIDELINE_MEMO)
            fAlpha = 0.5f;
    }

	
	CGFloat R = ((CGFloat)((RGBA & 0xFF000000) >> 8*3))/255.f;
	CGFloat G = ((CGFloat)((RGBA & 0x00FF0000) >> 8*2))/255.f;
	CGFloat B = ((CGFloat)((RGBA & 0x0000FF00) >> 8*1))/255.f;
	CGFloat A = ((CGFloat)((RGBA & 0x000000FF) >> 8*0))/255.f*fAlpha;
	
	return [[UIColor colorWithRed:R green:G blue:B alpha:A] retain];
}

- (UIColor*) getRainbowColorFromRGBA:(NSUInteger) num
{
	NSInteger RGBA = RainbowColorTemplate[num];
	
	CGFloat R = ((CGFloat)((RGBA & 0xFF000000) >> 8*3))/255.f;
	CGFloat G = ((CGFloat)((RGBA & 0x00FF0000) >> 8*2))/255.f;
	CGFloat B = ((CGFloat)((RGBA & 0x0000FF00) >> 8*1))/255.f;
	CGFloat A = ((CGFloat)((RGBA & 0x000000FF) >> 8*0))/255.f;
	
	return [[UIColor colorWithRed:R green:G blue:B alpha:A] retain];
}

- (UIColor*) getBiggerColorFromRGBA:(NSUInteger) num
{
	NSInteger RGBA = BiggerColorTemplate[num];
	
	CGFloat R = ((CGFloat)((RGBA & 0xFF000000) >> 8*3))/255.f;
	CGFloat G = ((CGFloat)((RGBA & 0x00FF0000) >> 8*2))/255.f;
	CGFloat B = ((CGFloat)((RGBA & 0x0000FF00) >> 8*1))/255.f;
	CGFloat A = ((CGFloat)((RGBA & 0x000000FF) >> 8*0))/255.f;
	
	return [[UIColor colorWithRed:R green:G blue:B alpha:A] retain];
}

- (UIColor*) getSmallerColorFromRGBA:(NSUInteger) num
{
	NSInteger RGBA = SmallerColorTemplate[num];
	
	CGFloat R = ((CGFloat)((RGBA & 0xFF000000) >> 8*3))/255.f;
	CGFloat G = ((CGFloat)((RGBA & 0x00FF0000) >> 8*2))/255.f;
	CGFloat B = ((CGFloat)((RGBA & 0x0000FF00) >> 8*1))/255.f;
	CGFloat A = ((CGFloat)((RGBA & 0x000000FF) >> 8*0))/255.f;
	
	return [[UIColor colorWithRed:R green:G blue:B alpha:A] retain];
}

- (UIColor *) getSkinColor:(SKINCOLOR)skinnum
{
    return skincolor[skinnum];
}



- (void) setNextSkinColor
{
    skin += 1;
    
    if (SkinColorTemplate[skin][0] == 0)
        skin = 0;
    
    // 메모리 해제
    [self initSkinColorDataAgain];
}

- (void) setSkinColorNum:(NSInteger)num
{
    if (num >= MAX_SKIN_COUNT)
        num = 0;
    
    skin = num;
        
    
    // 메모리 해제
    [self initSkinColorDataAgain];
    
}



- (UIColor*) getUIColor:(SKINCOLOR)num
{
	UIColor *color = skincolor[num];
	
	return color;
}




- (CGColorRef) getColor:(SKINCOLOR)num
{
	UIColor *color = skincolor[num];
	
	return color.CGColor;
}

- (void)initSkinColorDataAgain
{
    
	for (int i=0; i<COUNT_SKINCOLOR; i++)
	{
        [skincolor[i] release];
		skincolor[i] = [self getUIColorFromRGBA:i];
	}	
	[self setBackgroundColor:skincolor[SC_BACKGROUND_VIEW]];
    
    [self setViewBackgroundColor];
}


- (void)setViewBackgroundColor
{
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
    
    if (ctrl)
    {
        [ctrl.viewMenu setBackgroundColor:skincolor[SC_BACKGROUND_MENU]];
        [ctrl.viewNewGame setBackgroundColor:skincolor[SC_BACKGROUND_MENU]];
        [ctrl.viewDailyGame setBackgroundColor:skincolor[SC_BACKGROUND_MENU]];
    }
	[self setBackgroundColor:skincolor[SC_BACKGROUND_VIEW]];
    

    
    //	[self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_0.png"]]];
	

}

- (void)initSkinColorData
{

	for (int i=0; i<COUNT_SKINCOLOR; i++)
	{
		skincolor[i] = [self getUIColorFromRGBA:i];
	}	

	[self setViewBackgroundColor];
}

- (void)initRainbowColorData
{
    for (int i=0; i<7; i++)
	{
		rainbowcolor[i] = [self getRainbowColorFromRGBA:i];
	}
}

- (void)initBiggerSmallerColorData
{
    for (int i=0; i<9; i++)
	{
		biggercolor[i] = [self getBiggerColorFromRGBA:i];
	}
    for (int i=0; i<9; i++)
	{
		smallercolor[i] = [self getSmallerColorFromRGBA:i];
	}
    
    
}


- (void)initData
{
	DLog(@"MainView initData");
	
	skin = DEFAULT_SKIN_NUM;
	bBlur = NO;
    bDrawOnImage = NO;
	
	//[self initSkinColorData];
	//[self initRainbowColorData];
	
	self.selectedXPos = 0;
	self.selectedYPos = 0;
	self.pushedButton = -1;
	self.bTouch = NO;
	self.bPressedInButton = NO;
	self.bPressedInCell = NO;
	self.bDupWarn = YES;
	self.nSettingSoundOff = 1;  // default
    self.bSettingGuideline = YES;
    self.bSettingDuplicationWarning = YES;
    self.bSettingMarkingEqual = YES;
    
    self.bSettingDefMap = NO;   // deprecated
	
	self.bSettingAutoMemo = NO;
    self.bSharedThisOnFacebook = NO;
    self.nSettingSudokuType = SUDOKUTYPE_SUDOKU;
    self.nSettingGameLevel = GAMELEVEL_NORMAL;
    self.paidHintCount = 0;
	
//	self.fPress = 1.f;
	
	
	
	
	NSString *path;
	
	path = [[NSBundle mainBundle] pathForResource:@"click-1" ofType:@"wav"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundClickID1);
	path = [[NSBundle mainBundle] pathForResource:@"click-2" ofType:@"wav"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundClickID2);
	path = [[NSBundle mainBundle] pathForResource:@"clear" ofType:@"wav"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundClearID);
	path = [[NSBundle mainBundle] pathForResource:@"Sosumi" ofType:@"aiff"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundFailID);
	
	bMemoMode = NO;
    

    
}





- (id)initWithCoder:(NSCoder*)coder
{
	DLog(@"initWithCoder");	
	
    if ( (self = [super initWithCoder:coder] ) ) {
		[self initData];		
    }

    return self;
}

/*
- (id)initWithFrame:(CGRect)frame {
	DLog(@"initWithFrame");	
	
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}
*/
- (CGRect) getTableRect
{
    if (bDrawOnImage)
        return frameDrawOnImage;
    
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
/*    DLog(@"ctrl.areaNumButton.frame = %f,%f,%f,%f\n",
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
 
- (void) drawStrRect:(CGContextRef)context str:(NSString*)str rect:(CGRect)rect color:(UIColor*)color font:(UIFont*)font align:(UITextAlignment)align
{
	CGSize sizeText = [str sizeWithFont:font forWidth:rect.size.width lineBreakMode:NSLineBreakByClipping];
	
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        NSMutableParagraphStyle *textStyle = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        textStyle.lineBreakMode = NSLineBreakByClipping;
        textStyle.alignment = align;

        [str drawInRect:CGRectMake(rect.origin.x,
                                   rect.origin.y + (rect.size.height - sizeText.height)/2,
                                   rect.size.width,
                                   sizeText.height)
         withAttributes:@{ NSFontAttributeName: font,
                           NSParagraphStyleAttributeName: textStyle,
                           NSForegroundColorAttributeName: color} ];
    } else {    // less than 7.0
        CGContextSetFillColorWithColor(context, color.CGColor);
        [str drawInRect:CGRectMake(rect.origin.x,
                                   rect.origin.y + (rect.size.height - sizeText.height)/2,
                                   rect.size.width,
                                   sizeText.height)
               withFont:font
          lineBreakMode:NSLineBreakByClipping
              alignment:align];
    }
}


- (NSString*) getNumberString:(NSInteger)num
{
    if (sudokuGame.sudokuType == SUDOKUTYPE_SYMBOL) {
        switch (num) {
            case 1 : return @"♥";
            case 2 : return @"☘";
            case 3 : return @"⚖";
            case 4 : return @"⛄";
            case 5 : return @"❄";
            case 6 : return @"☺";
            case 7 : return @"⚜";
            case 8 : return @"⚙";
            case 9 : return @"☂";
        }
    }
    return [NSString stringWithFormat:@"%ld", (long)num];

}

- (void) drawGameNumRect:(CGContextRef)context num:(NSInteger)num rect:(CGRect)rect color:(UIColor*)color font:(UIFont*)font
{
    [self drawStrRect:context
                  str:[self getNumberString:num]
                 rect:rect
                color:color
                 font:font
				align:NSTextAlignmentCenter];
}

- (void) drawNumRect:(CGContextRef)context num:(NSInteger)num rect:(CGRect)rect color:(UIColor*)color font:(UIFont*)font
{
    [self drawStrRect:context
                  str:[NSString stringWithFormat:@"%ld", (long)num]
                 rect:rect
                color:color
                 font:font
                align:NSTextAlignmentCenter];
}


- (void) drawNumRect3D:(CGContextRef)context num:(NSInteger)num rect:(CGRect)rect color:(UIColor*)color font:(UIFont*)font
{
    NSString *str = [self getNumberString:num];
    NSInteger ratio = 70;
    
    CGRect rectBlack = CGRectMake(rect.origin.x-rect.size.width/ratio, rect.origin.y-rect.size.height/ratio, rect.size.width, rect.size.height);
    CGRect rectWhite1 = CGRectMake(rect.origin.x+rect.size.width/ratio, rect.origin.y+rect.size.height/ratio, rect.size.width, rect.size.height);
    CGRect rectWhite2 = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height/ratio, rect.size.width, rect.size.height);
    CGRect rectWhite3 = CGRectMake(rect.origin.x+rect.size.width/ratio, rect.origin.y, rect.size.width, rect.size.height);
    UIColor *colorBlack = [UIColor colorWithRed:.5f green:.5f blue:.5f alpha:0.5f];
    UIColor *colorWhite = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.f];

    if (sudokuGame.sudokuType != SUDOKUTYPE_SYMBOL) {
        [self drawStrRect:context
                      str:str
                     rect:rectBlack
                    color:colorBlack
                     font:font
                    align:NSTextAlignmentCenter];
        
        [self drawStrRect:context
                      str:str
                     rect:rectWhite1
                    color:colorWhite
                     font:font
                    align:NSTextAlignmentCenter];
        
        [self drawStrRect:context
                      str:str
                     rect:rectWhite2
                    color:colorWhite
                     font:font
                    align:NSTextAlignmentCenter];
        
        [self drawStrRect:context
                      str:str
                     rect:rectWhite3
                    color:colorWhite
                     font:font
                    align:NSTextAlignmentCenter];
    }
    
    [self drawStrRect:context
                  str:str
                 rect:rect
                color:color
                 font:font
				align:NSTextAlignmentCenter];

    
}


- (void) drawNumRectLeft:(CGContextRef)context num:(NSInteger)num rect:(CGRect)rect color:(UIColor*)color font:(UIFont*)font
{

    [self drawStrRect:context
                  str:[NSString stringWithFormat:@"%ld", (long)num]
                 rect:rect
                color:color
                 font:font
				align:NSTextAlignmentLeft];
	
}

- (void) drawNumRectRight:(CGContextRef)context num:(NSInteger)num rect:(CGRect)rect color:(UIColor*)color font:(UIFont*)font
{
    
    [self drawStrRect:context
                  str:[NSString stringWithFormat:@"%ld", (long)num]
                 rect:rect
                color:color
                 font:font
				align:NSTextAlignmentRight];
	
}

- (void)drawWindowsBackground:(CGContextRef) context
{
    UIImage *imageBackground = [UIImage imageNamed:@"background_border.png"];

   // DLog(@"self.frame = %f,%f", self.bounds.size.width, self.bounds.size.height);
    CGRect rect = CGRectMake(0,0,self.bounds.size.width, self.bounds.size.height);
    [imageBackground drawInRect:rect];
    
    
}



- (void)drawRectTableBackground:(CGContextRef) context
{
	CGRect currentRect = CGRectMake (cTableStartX, cTableStartY,cTableWidth-1,cTableHeight-1);
    
    CGContextSetFillColorWithColor(context, skincolor[SC_BACKGROUND_NORMAL_CELL].CGColor);
    CGContextFillRect(context, currentRect);
}

- (void)drawRectTableBackgroundBorder:(CGContextRef) context
{
	CGRect currentRect = CGRectMake (cTableStartX-cBoldLine/2, cTableStartY-cBoldLine/2,cTableWidth-1+cBoldLine,cTableHeight-1+cBoldLine);
    
    CGContextSetLineWidth(context, cBoldLine);
    CGContextSetStrokeColorWithColor(context, skincolor[SC_BACKGROUND_VIEW].CGColor);
    CGContextStrokeRect(context, currentRect);
}


- (void)drawBlurTable:(CGContextRef) context
{
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;

    if ([ctrl isReplaying])
        return;
    
    
	if (!bBlur && !sudokuGame.isGameFinished)
		return;
    
    if (sudokuGame.isCloseButton)
        return;
    
	
	CGRect currentRect;
	
	UIColor *colorBlur = [UIColor colorWithRed:.7f green:.7f blue:.7f alpha:.7f];
    
    CGContextSetLineWidth(context, cLineDrawWidth);
    CGContextSetStrokeColorWithColor(context, colorBlur.CGColor);
    CGContextSetFillColorWithColor(context, colorBlur.CGColor);
	currentRect = CGRectMake (cTableStartX, cTableStartY,cTableWidth-1,cTableHeight-1);
	
	CGContextAddRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFillStroke);
}

- (void) setBlur:(BOOL)blur
{
	bBlur =  blur;
	[self setNeedsDisplay];
}


- (void)drawKillerLine:(CGContextRef) context
{
	int x,y,i,j;
    
    if (sudokuGame.sudokuType != SUDOKUTYPE_KILLER && sudokuGame.sudokuType != SUDOKUTYPE_CALCU)
        return;


    CGContextSetLineCap(context, kCGLineCapRound);
    
    // 수직선
	for (i=1; i<sudokuGame.size; i++)
	{
		x = cTableStartX + i*cCellWidth;
        for (j=0; j<sudokuGame.size; j++)
        {
            CGContextSetLineWidth(context, cLineDrawWidth);
            CGContextSetStrokeColorWithColor(context, skincolor[SC_LINE_CELL_KILLER].CGColor);
            CGContextSetFillColorWithColor(context, skincolor[SC_LINE_CELL_KILLER].CGColor);
			
            y = cTableStartY + j*cCellHeight;
			CGContextMoveToPoint(context, x, y);
            if ([sudokuGame isSameColor:i-1 y:j x2:i y2:j] == NO)
            {
                CGContextAddLineToPoint(context, x, y+cCellHeight);
                CGContextSetLineWidth(context, cKillerBoldLine);
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
            CGContextSetStrokeColorWithColor(context, skincolor[SC_LINE_CELL_KILLER].CGColor);
            CGContextSetFillColorWithColor(context, skincolor[SC_LINE_CELL_KILLER].CGColor);
			
            x = cTableStartX + j*cCellWidth;
			CGContextMoveToPoint(context, x, y);
            if ([sudokuGame isSameColor:j y:i-1 x2:j y2:i] == NO)
            {
                CGContextAddLineToPoint(context, x+cCellWidth, y);
                CGContextSetLineWidth(context, cKillerBoldLine);
                CGContextStrokePath(context);
            }
		}
	}
	
	
}

- (void)drawSymbolLine_____:(CGContextRef) context
{
    if (sudokuGame.sudokuType != SUDOKUTYPE_SYMBOL)
        return;
    
    int x, y, xPos, yPos;

    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, cLineDrawWidth);
    CGContextSetStrokeColorWithColor(context, skincolor[SC_LINE_CELL_NORMAL].CGColor);
    CGContextSetFillColorWithColor(context, skincolor[SC_LINE_CELL_NORMAL].CGColor);

    for (xPos=0; xPos<sudokuGame.size; xPos++)
    {
        for (yPos=0; yPos<sudokuGame.size; yPos++)
        {
            NSInteger puzzleNum = [sudokuGame getPuzzleNums:xPos y:yPos];
            if (puzzleNum > 0) {    // 원래 문제에 있는 숫자
                x = cTableStartX + xPos*cCellWidth;
                y = cTableStartY + yPos*cCellHeight;
                CGContextMoveToPoint(context, x, y);
                CGContextAddLineToPoint(context, x+cCellWidth, y+cCellHeight);
                CGContextStrokePath(context);
                x = cTableStartX + (xPos+1)*cCellWidth;
                y = cTableStartY + yPos*cCellHeight;
                CGContextMoveToPoint(context, x, y);
                CGContextAddLineToPoint(context, x-cCellWidth, y+cCellHeight);
                CGContextStrokePath(context);
            }
        }
    }
}

- (void)drawSymbolLine:(CGContextRef) context
{
    if (sudokuGame.sudokuType != SUDOKUTYPE_SYMBOL)
        return;
    
    int x, y, xPos, yPos;
    UIImage *imgButton = [UIImage imageNamed:@"buttonsymbol.png"];
    CGRect rect;
    
    for (xPos=0; xPos<sudokuGame.size; xPos++)
    {
        for (yPos=0; yPos<sudokuGame.size; yPos++)
        {
            NSInteger puzzleNum = [sudokuGame getPuzzleNums:xPos y:yPos];
            if (puzzleNum > 0) {    // 원래 문제에 있는 숫자
                x = cTableStartX + xPos*cCellWidth;
                y = cTableStartY + yPos*cCellHeight;
                
                rect = CGRectMake(x,y,cCellWidth,cCellHeight);
                [imgButton drawInRect:rect];
            }
        }
    }
}




- (void)drawRectTableLine:(CGContextRef) context
{
	int x,y,i,j;

    BOOL bGT, bUserGT;

    
    CGContextSetLineCap(context, kCGLineCapRound);
    
    // 수직선
	for (i=1; i<sudokuGame.size; i++)
	{
		x = cTableStartX + i*cCellWidth;
        for (j=0; j<sudokuGame.size; j++)
        {
            CGContextSetLineWidth(context, cLineDrawWidth);
            CGContextSetStrokeColorWithColor(context, skincolor[SC_LINE_CELL_NORMAL].CGColor);
            CGContextSetFillColorWithColor(context, skincolor[SC_LINE_CELL_NORMAL].CGColor);

            y = cTableStartY + j*cCellHeight;
			CGContextMoveToPoint(context, x, y);
            if ([sudokuGame isSameMap:i-1 y:j x2:i y2:j])
            {
                if (sudokuGame.sudokuType == SUDOKUTYPE_GT)
                {
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
                                CGContextSetStrokeColorWithColor(context, skincolor[SC_LINE_CELL_WRONG].CGColor);
                                CGContextSetFillColorWithColor(context, skincolor[SC_LINE_CELL_WRONG].CGColor);
                            }
                            
                        }
                    }
                    CGContextAddLineToPoint(context, x, y+cCellHeight*GTWIDTH);
                    CGContextAddLineToPoint(context, x+(bGT?GTDEPTH:-GTDEPTH)*cCellWidth, y+cCellHeight*0.5);
                    CGContextAddLineToPoint(context, x, y+cCellHeight*(1-GTWIDTH));
                }
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
            CGContextSetStrokeColorWithColor(context, skincolor[SC_LINE_CELL_NORMAL].CGColor);
            CGContextSetFillColorWithColor(context, skincolor[SC_LINE_CELL_NORMAL].CGColor);

            x = cTableStartX + j*cCellWidth;
			CGContextMoveToPoint(context, x, y);
            if ([sudokuGame isSameMap:j y:i-1 x2:j y2:i])
            {
                if (sudokuGame.sudokuType == SUDOKUTYPE_GT)
                {
                    bGT = [sudokuGame getAnswerNums:j y:i-1] > [sudokuGame getAnswerNums:j y:i];
                    if ([sudokuGame getDisplayNum:j y:i-1] && [sudokuGame getDisplayNum:j y:i])
                    {
                        bUserGT = [sudokuGame getDisplayNum:j y:i-1] > [sudokuGame getDisplayNum:j y:i];
                        if (bGT != bUserGT)
                        {
                            CGContextSetLineWidth(context, cConflictLineWidth);
                            CGContextSetStrokeColorWithColor(context, skincolor[SC_LINE_CELL_WRONG].CGColor);
                            CGContextSetFillColorWithColor(context, skincolor[SC_LINE_CELL_WRONG].CGColor);
                        }
                        
                    }
                    
                    CGContextAddLineToPoint(context, x+cCellWidth*GTWIDTH, y);
                    CGContextAddLineToPoint(context, x+cCellWidth*0.5, y+(bGT?GTDEPTH:-GTDEPTH)*cCellHeight);
                    CGContextAddLineToPoint(context, x+cCellWidth*(1-GTWIDTH), y);
                }

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
	//DLog(@"drawRectCellOneChoosing");
	if (pushedButton == 0)
	{
		DLog(@"pushedButton == 0");
		return;					// delete cell
	}
		
    [self drawGameNumRect:context
                  num:pushedButton
                 rect:rect
                color:skincolor[SC_TEXT_CELL_CHOOSING_OK]
                 font:cellOneBigFont];
}

// 검정
- (void)drawRectCellOnePuzzle:(CGContextRef)context num:(NSInteger)num rect:(CGRect)rect dupwarn:(BOOL)bDupWarnArea
{
    
    [self drawGameNumRect:context
                  num:num
                 rect:rect
                color:bDupWarnArea ? skincolor[SC_TEXT_CELL_MEMO_WARN]: skincolor[SC_TEXT_CELL_PUZZLE]
                 font:cellOneSmallFont];
    if (bDupWarnArea)
        bFailCell = YES;
}


// 나머지는 파스텔톤
- (void)drawRectCellOneUserFixed:(CGContextRef)context num:(NSInteger)num rect:(CGRect)rect dupwarn:(BOOL)bDupWarnArea conflict:(BOOL)bConflict
{
    UIColor *color;
    
	if (bDupWarnArea)
	{
        bFailCell = YES;
		color = skincolor[SC_TEXT_CELL_MEMO_WARN];
	} else if (bConflict) {     // conflict number 처리
		color = skincolor[SC_TEXT_CELL_MEMO_CONFLICT];
    } else {
        color = skincolor[SC_TEXT_CELL_INPUT];
	}

    [self drawGameNumRect:context
                  num:num
                 rect:rect
                color:color
                 font:cellOneSmallFont];
    
    if (sudokuGame.sudokuType == SUDOKUTYPE_SYMBOL && bConflict) {
        rect.origin.x += cCellWidth*0.02;
        rect.origin.y -= cCellHeight*0.05;
        
        [self drawStrRect:context
                      str:@"⨯"
                     rect:rect
                    color:num == 1 ? skincolor[SC_BACKGROUND_SELECTED_CELL] : skincolor[SC_TEXT_CELL_MEMO_WARN]
                     font:cellOneSmallFont
                    align:NSTextAlignmentCenter];
    }

}




- (NSInteger) CharToNum:(char) ch
{
    return (NSInteger) ch - '0';
}



- (void)drawRectCellOneMemo:(CGContextRef)context memo:(char*)memo rect:(CGRect)rect xPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
    NSInteger len = strlen(memo);
	NSInteger i = 0;
	NSInteger x, y;
//    int countW = (len <= 1 ? 1 : (len <= 4 ? 2 : 3));
    NSInteger countW = (len <= 4 ? 2 : 3);
//    int countH = (len <= 2 ? 1 : (len <= 6 ? 2 : 3));
    NSInteger countH = (len <= 6 ? 2 : 3);
    BOOL bConflict;
	CGRect rectNum;    
    CGFloat margin;
    UIColor *colorMemo;
    
    if (sudokuGame.sudokuType == SUDOKUTYPE_GT)
        margin = 0.12f; // 부등호를 위한 공간이 조금 더 필요하다.
    else if (sudokuGame.sudokuType == SUDOKUTYPE_SYMBOL)
        margin = 0.00f;
    else
        margin = 0.10f;
        
        
	CGFloat topmargin = 0.0f;
	CGFloat leftmargin = 0.0f;
	
	if (sudokuGame.sudokuType == SUDOKUTYPE_KILLER || sudokuGame.sudokuType == SUDOKUTYPE_CALCU)
    {
        leftmargin = 0.2f;  // 합계 표시를 위한 공간이 조금 더 필요하다.
        if (len == 8)
            i = -1;
        else if (len == 7)
            i = -2;
        else if (len == 5)
            i = -1;
        else if (len == 3)
            i = -1;
        else if (len == 2)
            i = -2;
        else if (len == 1)
            i = -3;
    }
    
	CGFloat x0 = rect.origin.x+rect.size.width*(margin+leftmargin);
	CGFloat y0 = rect.origin.y+rect.size.height*(margin+topmargin);
	CGFloat width = rect.size.width*(1-2*margin-leftmargin);
	CGFloat height = rect.size.height*(1-2*margin-topmargin);
    
	for (y=0; y<countH; y++)
	{
		for (x=0; x<countW; x++)
		{
			if (i >= 0 && i < len)
			{
                bConflict = [sudokuGame conflictNumber:[self CharToNum:memo[i]] xPos:xPos yPos:yPos];
                if (sudokuGame.sudokuType == SUDOKUTYPE_GT)
                {
                    if (!bConflict)
                    {
                        bConflict = [sudokuGame conflictMemoCompare:[self CharToNum:memo[i]] xPos:xPos yPos:yPos];
                    }
                }

                rectNum = CGRectMake(x0+width*x/countW,
									 y0+height*y/countH,
									 width/countW,
									 height/countH);
                if (bSettingDuplicationWarning == YES) {
                    colorMemo = bConflict? skincolor[SC_TEXT_CELL_MEMO_CONFLICT] : skincolor[SC_TEXT_CELL_MEMO_OK];
                } else {
                    colorMemo = skincolor[SC_TEXT_CELL_MEMO_OK];
                }
                [self drawGameNumRect:context
                              num:[self CharToNum:memo[i]]
                             rect:rectNum
                            color:colorMemo
                             font:len <= 4 ? cellFourFont : (len <= 6 ? cellSixFont : cellNineFont)];
                if (bSettingDuplicationWarning == YES && sudokuGame.sudokuType == SUDOKUTYPE_SYMBOL && bConflict) {
                    rectNum.origin.x += rectNum.size.width*0.07;
                    rectNum.origin.y -= rectNum.size.height*0.09;

                    [self drawStrRect:context
                                  str:@"⨯"
                                 rect:rectNum
                                color:[self CharToNum:memo[i]] == 1 ? skincolor[SC_BACKGROUND_SELECTED_CELL] : skincolor[SC_TEXT_CELL_MEMO_WARN]
                                 font:len <= 4 ? cellFourFont : (len <= 6 ? cellSixFont : cellNineFont)
                                align:NSTextAlignmentCenter];
                }
                
                i++;
			}
			else if (i < 0)
			{
				i++;
			}
		}
	}
}




- (BOOL)conflictCell:(NSInteger)xPos yPos:(NSInteger)yPos
{
    NSInteger fixNum = [sudokuGame getFixNums:xPos y:yPos];
    
    if (fixNum == 0)
        return NO;
    
    return [sudokuGame conflictNumber:fixNum xPos:xPos yPos:yPos];
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
		//DLog(@"pMemo=%s", pMemo);
	}
	
	if (puzzleNum > 0)	{
		// 원래 문제에 있던 번호 
		[self drawRectCellOnePuzzle:context num:puzzleNum rect:rect dupwarn:bDupWarnArea&&(puzzleNum==pushedButton)];
    } else if (bDrawOnImage) {
        return;
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
    if (nSettingSoundOff > 0)
        AudioServicesPlaySystemSound(inSystemSoundID);
}

- (void) playSoundClick
{
    if (nSettingSoundOff == 1)
        [self playSound:soundClickID1];
    else
        [self playSound:soundClickID2];
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


- (void)drawKillerSumNum:(CGContextRef)context
{
    if (sudokuGame.sudokuType != SUDOKUTYPE_KILLER && sudokuGame.sudokuType != SUDOKUTYPE_CALCU)
        return;
    
	KillerMap *kmap = sudokuGame.kmap;
	KillerCage *cell;
	NSInteger x, y, sum;
	CGRect rect;
	BOOL isWrongSum;


	for (int i=0; (cell = [kmap getCageData:i]) != NULL; i++)
	{
		x = cell->x0;
		y = cell->y0;
		sum = cell->sum;
		if (sum == 0)
			break;
		isWrongSum = [sudokuGame isWrongSumCellXY:x yPos:y] && bSettingDuplicationWarning;
		rect = CGRectMake(cTableStartX + x*cCellWidth + cCellWidth*0.03,
						  cTableStartY + y*cCellHeight + cCellHeight*0.03,
						  cCellWidth,
						  cCellHeight/4);
		[self drawNumRectLeft:context
						  num:sum
						 rect:rect
						color:skincolor[isWrongSum?SC_TEXT_CELL_MEMO_CONFLICT:SC_TEXT_CELL_KILLER_SUM]
						 font:isWrongSum?cellWrongSumFont:cellSumFont];
        if (sudokuGame.sudokuType == SUDOKUTYPE_CALCU)
        {
            if ([sudokuGame	countCellInSum:x yPos:y] > 1)
            {
                rect = CGRectMake(cTableStartX + x*cCellWidth - cCellWidth*(cell->sign == CS_MINUS ? 0.05 : 0.00),
                                  cTableStartY + y*cCellHeight + cCellHeight/4,
                                  cCellWidth/4,
                                  cCellHeight/4);
                [self drawStrRect:context
                              str:[KillerMap getSign:cell->sign]
                             rect:rect
                            color:skincolor[isWrongSum?SC_TEXT_CELL_MEMO_CONFLICT:SC_TEXT_CELL_KILLER_SUM]
                             font:cellSignFont
                            align:NSTextAlignmentCenter];
            }
        }
		
	}

}


// 숫자가 중복되면 안되는 바닥을 보여줌


- (void)drawOneCellBackground:(CGContextRef)context color:(UIColor*)color x:(NSInteger)x y:(NSInteger)y
{
    //DLog(@"drawOneCellBackground(%d,%d)", x, y);
    
    NSInteger xPos = cTableStartX + x*cCellWidth;
    NSInteger yPos = cTableStartY + y*cCellHeight;
    
    CGContextSetLineWidth(context, cLineDrawWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextBeginPath(context);

    if (sudokuGame.sudokuType == SUDOKUTYPE_GT)
    {
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
    } else  {
        CGRect currentRect;
        currentRect = CGRectMake(xPos,yPos,cCellWidth-1,cCellHeight-1);
        CGContextAddRect(context, currentRect);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
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

- (void) drawKillerBackground:(CGContextRef)context
{
    if (sudokuGame.sudokuType != SUDOKUTYPE_KILLER && sudokuGame.sudokuType != SUDOKUTYPE_CALCU)
        return;
    
    for (int y=0; y<sudokuGame.size; y++)
    {
        for (int x=0; x<sudokuGame.size; x++)
        {
			//DLog(@"%d,%d", x, y);
			NSInteger colorCell = [sudokuGame.kmap getColor:x yPos:y];
			if (colorCell >= 0 && colorCell < 7)
			{
				[self drawOneCellBackground:context color:rainbowcolor[colorCell] x:x y:y];
			} else {
				DLog(@"colorCell(%ld,%ld):%ld",(long)x, (long)y, (long)colorCell);
				//DAssert(colorCell >= 0 && colorCell < 7, @"colorCell(%d,%d):%d", x, y, colorCell);
			}
				

        } //y
	} //x
	
	
}

- (void) drawGuidelineBackground:(CGContextRef)context
{
    if (sudokuGame.sudokuType == SUDOKUTYPE_KILLER || sudokuGame.sudokuType == SUDOKUTYPE_CALCU)
        return;

    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
    
    if (sudokuGame.isGameFinished && [ctrl isReplaying] == NO)
        return;

    
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
                [self drawOneCellBackground:context color:(bMemoMode ? skincolor[SC_BACKGROUND_GUIDELINE_MEMO] : skincolor[SC_BACKGROUND_GUIDELINE_NORMAL]) x:x y:y];
            }            
        } //y
	} //x
}

- (void) drawMarkingEqualBackgound:(CGContextRef)context
{
    if (sudokuGame.isGameFinished)
        return;
    
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
                    [self drawOneCellBackground:context color:skincolor[SC_BACKGROUND_SELECTED_CELL] x:x y:y];
                    
                    CGRect currentRect;
                    NSInteger xPos = cTableStartX + x*cCellWidth;
                    NSInteger yPos = cTableStartY + y*cCellHeight;
                    
                    CGContextSetLineWidth(context, 2*cResizeRatioW);
                    CGContextSetStrokeColorWithColor(context,
                                                     bMemoMode ?
                                                     skincolor[SC_LINE_SECLECTED_CELL_MEMO].CGColor :
                                                     skincolor[SC_LINE_SECLECTED_CELL_NORMAL].CGColor);
                    currentRect = CGRectMake (xPos+cBoldLine,yPos+cBoldLine,
                                              cCellWidth-cBoldLine*2,cCellHeight-cBoldLine*2);
                    
                    CGContextAddRect(context, currentRect);
                    CGContextDrawPath(context, kCGPathStroke);
                }
            }
        } //y
	} //x
}

- (void)drawHighlightCellBackground:(CGContextRef)context
{
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
    
    if (sudokuGame.isGameFinished && [ctrl isReplaying] == NO)
        return;
    
    
	if (selectedXPos >= 0 && selectedXPos < sudokuGame.size &&
        selectedYPos >= 0 && selectedYPos < sudokuGame.size)
	{
        [self drawOneCellBackground:context color:skincolor[SC_BACKGROUND_SELECTED_CELL] x:selectedXPos y:selectedYPos];
	}
}

- (void)drawGtComapreCellColor:(CGContextRef)context
{
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
    
    if (sudokuGame.isGameFinished && [ctrl isReplaying] == NO)
        return;
    
    if (sudokuGame.sudokuType != SUDOKUTYPE_GT || bSettingGuideline == NO)
        return;
    
    NSInteger num;
        
    for (int y=0; y<sudokuGame.size; y++)
    {
        for (int x=0; x<sudokuGame.size; x++)
        {
            num = [sudokuGame getGtCellColor:x y:y];
            if (num > 0 && num < 9)
            {
                [self drawOneCellBackground:context color:biggercolor[num] x:x y:y];
            } else if (num < 0 && num > -9) {
                [self drawOneCellBackground:context color:smallercolor[-num] x:x y:y];
            }
        }
    }
}

#define BM_LEFTMARGIN	0.05f
#define BM_W			0.2f
#define BM_H			0.25f
#define BM_H_TEXT		0.20f

- (void)drawBookmarkInCell:(CGContextRef)context
{
    if (sudokuGame.isGameFinished)
        return;    
    
	NSInteger count = [sudokuGame.sudokuUndo countBookmarked];
	NSInteger x, y;
	
	for (int i=0; i<count; i++)
	{
		Bookmark* bm = [sudokuGame.sudokuUndo getBookmark:i];
		if (bm == NULL)
		{
			DAssert(bm, @"[sudokuGame.sudokuUndo getBookmark:%d]", i);
			continue;
		}
			
		x = bm->x;
		y = bm->y;
		if (x >= 0 && x < sudokuGame.size &&
			y >= 0 && y < sudokuGame.size)
		{
			NSInteger xPos = cTableStartX + x*cCellWidth;
			NSInteger yPos = cTableStartY + y*cCellHeight;
			UIImage *imageBookmark;
            CGRect rect;
            if (sudokuGame.sudokuType == SUDOKUTYPE_KILLER || sudokuGame.sudokuType == SUDOKUTYPE_CALCU)
			{
                imageBookmark = [UIImage imageNamed:@"bookmark2"];
                rect = CGRectMake(xPos+cCellWidth*BM_LEFTMARGIN, yPos+cCellHeight*(1-BM_H), cCellWidth*BM_W, cCellHeight*BM_H);
            } else {
                imageBookmark = [UIImage imageNamed:@"bookmark"];
                rect = CGRectMake(xPos+cCellWidth*BM_LEFTMARGIN, yPos, cCellWidth*BM_W, cCellHeight*BM_H);
            }
			[imageBookmark drawInRect:rect blendMode:kCGBlendModeNormal alpha:0.5f];
			// 북마크 번호(i+1)를 적어야 한다.
            if (sudokuGame.sudokuType == SUDOKUTYPE_KILLER || sudokuGame.sudokuType == SUDOKUTYPE_CALCU)
            {
                rect = CGRectMake(xPos+cCellWidth*BM_LEFTMARGIN, yPos+cCellHeight*(1-BM_H_TEXT), cCellWidth*BM_W, cCellHeight*BM_H_TEXT);
            } else {
                rect = CGRectMake(xPos+cCellWidth*BM_LEFTMARGIN, yPos, cCellWidth*BM_W, cCellHeight*BM_H_TEXT);
            }
			[self drawNumRect:context num:i+1 rect:rect color:[UIColor colorWithWhite:1.0f alpha:1.0f] font:cellBookmarkFont];

		}
	}
}

- (void)drawHighlightCell:(CGContextRef)context
{
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
    
    if (sudokuGame.isGameFinished && [ctrl isReplaying] == NO)
        return;


	if (selectedXPos >= 0 && selectedXPos < sudokuGame.size &&
        selectedYPos >= 0 && selectedYPos < sudokuGame.size)
	{
		CGRect currentRect;
		NSInteger xPos = cTableStartX + selectedXPos*cCellWidth;
		NSInteger yPos = cTableStartY + selectedYPos*cCellHeight;
/*
        // 곱셈 후보수 보여주기
        //DLog(@"drawHighlightCell(%ld,%ld)", selectedXPos, selectedYPos);
        if (sudokuGame.sudokuType == SUDOKUTYPE_CALCU) {
            KillerMap *kmap = sudokuGame.kmap;
            KillerCage *cage = [kmap getCageData:[kmap getCageNumber:selectedXPos yPos:selectedYPos]];
            if (cage->sign == CS_MULTIPLE) {
                DLog(@"CageSumCell(%ld,%ld)", cage->sum, [kmap getCageNumberCount:selectedXPos yPos:selectedYPos]);
                NSInteger cellcount = [kmap getCageNumberCount:selectedXPos yPos:selectedYPos];
                NSInteger num[4];
                BOOL cand[9];
                for (num[0]=1; num[0]<=10-cellcount; num[0]++) {
                    for (num[1]=num[0]+1; num[1]<=11-cellcount; num[1]++) {
                        for (num[2]=cellcount>2?num[1]+1:12-cellcount; num[2]<=12-cellcount; num[2]++) {
                            for (num[3]=cellcount>3?num[2]+1:13-cellcount; num[3]<=13-cellcount; num[3]++) {
                                NSInteger sumMulti = 1;
                                for (NSInteger i=0; i<cellcount; i++) {
                                    sumMulti *= num[i];
                                }
                                if (sumMulti == cage->sum) {
                                    for (NSInteger i=0; i<cellcount; i++) { cand[i] = YES; }
                                    if (cellcount == 2) { DLog(@"HintNum(%ld,%ld)", num[0], num[1]); }
                                    if (cellcount == 3) { DLog(@"HintNum(%ld,%ld,%ld)", num[0], num[1], num[2]); }
                                    if (cellcount == 4) { DLog(@"HintNum(%ld,%ld,%ld,%ld)", num[0], num[1], num[2], num[3]); }
                                }
                            }
                        }
                    }
                }
            }
        }
*/
		CGContextSetLineWidth(context, 4*cResizeRatioW);
		CGContextSetStrokeColorWithColor(context,
                                         bMemoMode ?
                                         skincolor[SC_LINE_SECLECTED_CELL_MEMO].CGColor :
                                         skincolor[SC_LINE_SECLECTED_CELL_NORMAL].CGColor);
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

#ifdef SUDOKU16
#define cButtonWidth (![self isButtonBox]?[self getNumButtonAreaW]/5.1:[self getNumButtonAreaW]/3.1)
#define cButtonHeight (![self isButtonBox]?[self getNumButtonAreaH]/1.95:[self getNumButtonAreaH]/3.1)
#elif defined(SUDOKU12)
#define cButtonWidth (![self isButtonBox]?[self getNumButtonAreaW]/5.1:[self getNumButtonAreaW]/3.1)
#define cButtonHeight (![self isButtonBox]?[self getNumButtonAreaH]/1.95:[self getNumButtonAreaH]/3.1)
#elif defined(SUDOKU9)
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
    else  if (sudokuGame.size == SIZE_9)
    {
        return [self isButtonBox] ? 3 : 9;
    }
    else  if (sudokuGame.size == SIZE_12)
    {
        return [self isButtonBox] ? 3 : 12;
    }
    else  if (sudokuGame.size == SIZE_16)
    {
        return [self isButtonBox] ? 4 : 16;
    } else{
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
    else  if (sudokuGame.size == SIZE_9)
    {
        return [self isButtonBox] ? 3 : 2;
    }
    else  if (sudokuGame.size == SIZE_12)
    {
        return [self isButtonBox] ? 4 : 3;
    }
    else  if (sudokuGame.size == SIZE_16)
    {
        return [self isButtonBox] ? 4 : 3;
    } else{
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
//   	DLog(@"buttonYCenter(%d) -> %f", i, y);
	return y;
}

- (void)drawNumButton:(CGContextRef)context
{
	NSInteger i;

	CGRect currentRect;
	BOOL bPuzzleNum = NO;
	BOOL bMemoNum = NO;
	CGFloat x, y;
	NSInteger numColor;
    UIImage *imgButton;
    UIImage *imgButtonBase;
    
    if (isIpad) {
        imgButton = [UIImage imageNamed:bMemoMode ? @"button_num_memo.png" : @"button_num_base.png"];
        imgButtonBase = [UIImage imageNamed:@"button_num_base.png"];
    } else {
        imgButton = [UIImage imageNamed:bMemoMode ? @"button_num_memo_small.png" : @"button_num_base_small.png"];
        imgButtonBase = [UIImage imageNamed:@"button_num_base_small.png"];
    }
//    if (sudokuGame.isGameFinished)
//        return;
    
	
	if (selectedXPos >= 0 && selectedXPos < sudokuGame.size &&
        selectedYPos >= 0 && selectedYPos < sudokuGame.size)
    {
		if ([sudokuGame getPuzzleNums:selectedXPos y:selectedYPos] > 0)
			bPuzzleNum = YES;
		if ([sudokuGame getFixNums:selectedXPos y:selectedYPos] == 0 &&
			[sudokuGame getMemoNums:selectedXPos y:selectedYPos] != NULL)
			bMemoNum = YES;
	}
	
    [sudokuGame calcuCountNum];
    
    // 곱셈 후보수 보여주기
    BOOL cand[9];
    // 기간 아이템으로 구매하기
    for (i=0; i<9; i++) cand[i] = NO;
#ifdef __HINT_ITEM__
    //DLog(@"drawHighlightCell(%ld,%ld)", selectedXPos, selectedYPos);
    if (sudokuGame.sudokuType == SUDOKUTYPE_CALCU) {
        KillerMap *kmap = sudokuGame.kmap;
        KillerCage *cage = [kmap getCageData:[kmap getCageNumber:selectedXPos yPos:selectedYPos]];
        NSInteger cellcount = [kmap getCageNumberCount:selectedXPos yPos:selectedYPos];
        NSInteger num[4];
        DLog(@"CageSumCell(%ld,%ld)", cage->sum, [kmap getCageNumberCount:selectedXPos yPos:selectedYPos]);
        if (cage->sign == CS_MULTIPLE || cage->sign == CS_PLUS) {
            for (num[0]=1; num[0]<=10-cellcount; num[0]++) {
                for (num[1]=cellcount>1?num[0]+1:11-cellcount; num[1]<=11-cellcount; num[1]++) {
                    for (num[2]=cellcount>2?num[1]+1:12-cellcount; num[2]<=12-cellcount; num[2]++) {
                        for (num[3]=cellcount>3?num[2]+1:13-cellcount; num[3]<=13-cellcount; num[3]++) {
                            NSInteger sumMulti = cage->sign == CS_MULTIPLE ? 1 : 0;
                            for (i=0; i<cellcount; i++) {
                                if (cage->sign == CS_MULTIPLE)
                                    sumMulti *= num[i];
                                else
                                    sumMulti += num[i];
                            }
                            if (sumMulti == cage->sum) {
                                for (i=0; i<cellcount; i++) { cand[num[i]] = YES; }
                                if (cellcount == 2) { DLog(@"HintNum(%ld,%ld)", num[0], num[1]); }
                                if (cellcount == 3) { DLog(@"HintNum(%ld,%ld,%ld)", num[0], num[1], num[2]); }
                                if (cellcount == 4) { DLog(@"HintNum(%ld,%ld,%ld,%ld)", num[0], num[1], num[2], num[3]); }
                            }
                        }
                    }
                }
            }
        } else if (cage->sign == CS_DIVIDE || cage->sign == CS_MINUS) {
            for (num[0]=1; num[0]<=10-cellcount; num[0]++) {
                for (num[1]=num[0]; num[1]<=11-cellcount; num[1]++) {
                    if (cage->sign == CS_DIVIDE) {
                        if (cage->sum * num[0] == num[1]) { cand[num[0]] = YES; cand[num[1]] = YES; }
                    } else {
                        if (cage->sum + num[0] == num[1]) { cand[num[0]] = YES; cand[num[1]] = YES; }
                    }
                }
            }
        }
    }
#endif // __HINT_ITEM__
    
	
	for (i=1; i<=sudokuGame.size; i++)    // 버튼 모양 그리기
	{
        if ((bPuzzleNum == NO) && i == pushedButton)
            continue;
        
        
		x = [self buttonXCenter:i] - cButtonWidth/2;
		y = [self buttonYCenter:i] - cButtonHeight/2;
				
		currentRect = CGRectMake(x,y,cButtonWidth,cButtonHeight);

        
        // 현재 누른 버튼 제외
		if ((bPuzzleNum && pushedButton <= sudokuGame.size) || i != pushedButton)
		{
            UIColor *color = skincolor[SC_TEXT_BUTTON_NUMBER];
            BOOL bGray = NO;
            
            if (bPuzzleNum && i <= sudokuGame.size) {
                bGray = YES;
            } else  if (bMemoMode == NO && [sudokuGame getCountNum:i] >= sudokuGame.size) {
                bGray = YES;
            } else if (bMemoMode == YES && ![sudokuGame beMemoNums:i x:selectedXPos y:selectedYPos]) {
                bGray = YES;
            }
            if (bGray) {
                if (cand[i])    // 곱셈 후보 숫자
                    color = [UIColor colorWithRed:.72f green:.72f blue:.72f alpha:8.f];
                else
                    color = [UIColor colorWithRed:.85f green:.85f blue:.85f alpha:8.f];
            }
            
            if (bGray)
                [imgButtonBase drawInRect:currentRect];
            else
                [imgButton drawInRect:currentRect];
            
            // 버튼에 숫자를 적기
            [self drawNumRect3D:context
                          num:i
                         rect:CGRectMake(x, y, cButtonWidth, cButtonHeight)
                        color:color
                         font:buttonSmallFont];// bMemoMode ? buttonMemoSmallFont : buttonSmallFont];
            
            [self drawNumRect:context
                          num:[sudokuGame getCountNum:i]
                         rect:CGRectMake(currentRect.origin.x+cButtonWidth*0.65f, currentRect.origin.y+cButtonHeight*0.63f, cButtonWidth/4, cButtonHeight/4)
                        color:skincolor[SC_TEXT_BUTTON_NUMBER]
                         font:cellNineFont];
        } else {
            [imgButton drawInRect:currentRect];
        }
        
        
	}

    // 현재 누른 버튼 표시
	if ((bPuzzleNum == NO) &&
		pushedButton > 0 && pushedButton <= sudokuGame.size)
	{
		i = pushedButton;
		x = [self buttonXCenter:i] - cButtonWidth/2; 
		y = [self buttonYCenter:i] - cButtonHeight/2; 
		
		
		numColor = bMemoMode ? SC_BACKGROUND_BUTTON_MEMO_PRESSED : SC_BACKGROUND_BUTTON_PRESSED;
		
		CGContextSetLineWidth(context, cLineDrawWidth);
		CGContextSetStrokeColorWithColor(context, skincolor[numColor].CGColor);
		CGContextSetFillColorWithColor(context, skincolor[numColor].CGColor);
		currentRect = CGRectMake(x,y,cButtonWidth,cButtonHeight);
//		currentRect = CGRectMake(x+cButtonWidth/30,y+cButtonHeight/30,cButtonWidth,cButtonHeight);
		
//		CGContextAddEllipseInRect(context, currentRect);
//		CGContextDrawPath(context, kCGPathFillStroke);
        UIImage *imgPushedButton = [UIImage imageNamed:isIpad ? @"button_num_push.png" : @"button_num_push_small.png"];

        [imgPushedButton drawInRect:currentRect];

		
		
        // 버튼에 숫자를 적기
        [self drawNumRect3D:context
                      num:i
                     rect:currentRect
                    color:skincolor[SC_TEXT_BUTTON_NUMBER]
                     font:buttonSmallFont];//bMemoMode ? buttonMemoBigFont : buttonBigFont];
        
        //DLog(@"[sudokuGame getCountNum:%d] = %d", i, [sudokuGame getCountNum:i]);
        [self drawNumRect:context
                      num:[sudokuGame getCountNum:i]
                     rect:CGRectMake(currentRect.origin.x+cButtonWidth*0.65f, currentRect.origin.y+cButtonHeight*0.63f, cButtonWidth/4, cButtonHeight/4)
                    color:[UIColor colorWithWhite:1.0f alpha:.7f]
                     font:cellNineFont];


	}

	
	
}


- (void) drawCongratulations:(CGContextRef)context
{

    
}



- (void)dealloc
{
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
 	
	//DLog(@"TouchToPosX(%f) -> %d", floatTouch, pos);
	
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
 	
	//DLog(@"TouchToPosY(%f) -> %d", floatTouch, pos);
	
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
			
			//DLog(@"ButtonChoose(%d)", i);
			return i;
		}
	}
	return -1;
	
}

- (void)setSelectedXYPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
    selectedXPos = xPos;
    selectedYPos = yPos;
    
    if (sudokuGame.sudokuType == SUDOKUTYPE_GT) // 주변셀 대소비교 로직 시작
    {
        [sudokuGame setGtCellColors:selectedXPos y:selectedYPos];
    }
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
	
	BOOL bShouldSave = NO;

	
    //DLog(@"touchesDo(%f,%f,end=%d,tapcount=%d)", fX, fY, bEnd, [touch tapCount]);
    if (bEnd && [touch tapCount] == 2 && xPos < sudokuGame.size && yPos < sudokuGame.size) {
        [ctrl memoOnOff];
        [ctrl DoneQuest:eQuestDoubleTap];
        return;             // double tap 후에는 아무런 세팅을 하지 않는다.
    }
        
		
    
    if (xPos >= 0 && xPos < sudokuGame.size && yPos >= 0 && yPos < sudokuGame.size) {
        if (0){//[sudokuGame isPuzzleNum:xPos y:yPos]) {
            // puzzle cell도 선택할 수 있도록 수정
        } else if (bPressedInCell) {
			if (xPos != selectedXPos || yPos != selectedYPos)
			{
                [self setSelectedXYPos:xPos yPos:yPos];
				[self playSoundClick];	// drag
				[self setNeedsDisplay];
			}
		}
        pushedButton = -1; // button을 누른 것이 아니다.
	} else if (bPressedInButton == YES) {
//		DLog(@"pressedInButton => YES");		
		
		NSInteger buttonNum = [self pressedButtonNum:touches];
		if (bEnd || pushedButton != buttonNum)
		{
			pushedButton = buttonNum;
//			DLog(@"pushedButton = %d", pushedButton);
                if (buttonNum > 0) {	// button chose
//				DLog(@"bEnd=%d", bEnd);
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
								bShouldSave = YES;
                            }
                        } else {
                            //DLog(@"CellNumChoose(%d,%d <= %d)", selectedXPos, selectedYPos, buttonNum);
                            [sudokuGame setFixNums:buttonNum x:selectedXPos y:selectedYPos];
                            [self checkClearGame];
							bShouldSave = YES;
                        }
                        pushedButton = -1;
                        
                        if (bFailCell)
                            [self playSound:soundFailID];   // 강력한 기능이라서 Setting으로 빼야 한다.
                        else
                            [self playSoundClick];
                        
                        [ctrl updateButtons];
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
	if (bShouldSave)
		[sudokuGame saveData];

}


- (void) checkClearGame
{
	NSInteger wrongSums = 0;
	NSInteger ret = [sudokuGame clearGameCheckAllCells:&wrongSums];
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;

	
    if (ret == 0) {
        if (sudokuGame.sudokuType == SUDOKUTYPE_KILLER || sudokuGame.sudokuType == SUDOKUTYPE_CALCU)
        {
            if (wrongSums > 0)
            {
                NSString *msg = [NSString stringWithFormat:gettext(@"There are %d wrong sum(s)", nil), wrongSums];
                
                [ctrl alertMessageOk:gettext(@"Alert!", nil) msg:msg];
                return;
            }
        }

        
        bMemoMode = NO;
        [ctrl writeScoreAfterFinishGame:sudokuGame];
	} else if (ret > 0) {
		NSString *msg = [NSString stringWithFormat:gettext(@"There are %d wrong cell(s)", nil), ret];
		
        [ctrl alertMessageOk:gettext(@"Alert!", nil) msg:msg];
	}
	
}

- (void) runUndo
{ 
	//DLog(@"[sudokuGame.sudokuUndo countUndo] = %d", [sudokuGame.sudokuUndo countUndo]);
	
	if (sudokuGame.isGameFinished || [sudokuGame.sudokuUndo countUndo] == 0)
		return;
	
	
	CGPoint pointLastUndoPos = [sudokuGame runUndo];

	
	if (pointLastUndoPos.x >= 0 && pointLastUndoPos.y >= 0)
	{
        [self setSelectedXYPos:(NSInteger) pointLastUndoPos.x yPos:(NSInteger) pointLastUndoPos.y];
       // [self playSoundClick];
	}
	[sudokuGame saveData];	
	[self setNeedsDisplay];
}

- (void) runRedo
{
	//DLog(@"[sudokuGame.sudokuUndo countRedo] = %d", [sudokuGame.sudokuUndo countRedo]);
	
	if (sudokuGame.isGameFinished || [sudokuGame.sudokuUndo countRedo] == 0)
		return;
	
	
	CGPoint pointLastUndoPos = [sudokuGame runRedo];
    
	
	if (pointLastUndoPos.x >= 0 && pointLastUndoPos.y >= 0)
	{
        [self setSelectedXYPos:(NSInteger) pointLastUndoPos.x yPos:(NSInteger) pointLastUndoPos.y];
        //[self playSoundClick];
	}
    
	[sudokuGame saveData];
	[self setNeedsDisplay];
}

- (BOOL) runRedo4Replay
{
    CGPoint pointLastUndoPos = [sudokuGame runRedo];
    
	
	if (pointLastUndoPos.x >= 0 && pointLastUndoPos.y >= 0)
	{
        [self setSelectedXYPos:(NSInteger) pointLastUndoPos.x yPos:(NSInteger) pointLastUndoPos.y];
        //[self playSoundClick];
	}
    
	[self setNeedsDisplay];
    
    if (pointLastUndoPos.x == -1)
        return NO;
    else
        return YES;
}


- (void) PushBookmarkButton:(NSInteger) buttonIndex
{
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;

    if (buttonIndex == 0)		// goto last bookmark
    {
        NSInteger countBookmark = [sudokuGame.sudokuUndo countGoBookmark];
        
        if (countBookmark)
        {
            CGPoint pointLastUndoPos;
            Bookmark *bm = [sudokuGame.sudokuUndo getLastBookmark];
            
            if (bm)
            {
                [self setSelectedXYPos:bm->x yPos:bm->y];
                
                if (countBookmark < 0)
                {
                    while ([sudokuGame.sudokuUndo getIndex] > bm->pos)
                        pointLastUndoPos = [sudokuGame runUndo];
                } else {
                    while ([sudokuGame.sudokuUndo getIndex] <= bm->pos)
                        pointLastUndoPos = [sudokuGame runRedo];
                }
            }
        }
        // delete last bookmark;
        [sudokuGame.sudokuUndo delLastBookmark];
        [self playSoundClick];
        [ctrl DoneQuest:eQuestGoBack];
        
    } else if (buttonIndex == 1) {
        [sudokuGame.sudokuUndo addBookmark];
        [self playSoundClick];
        [ctrl DoneQuest:eQuestBookmarking];
    } else if (buttonIndex == 2) {
        [sudokuGame.sudokuUndo delAllBookmarks];
        [self playSound:soundClearID];
    } else if (buttonIndex == 3) {              // cancel
        
    }
    [ctrl updateButtonUndo];
    [ctrl updateButtonBookmark];
    [sudokuGame saveData];
    [self setNeedsDisplay];

}


- (void) runBookmark
{
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;

	DLog(@"[sudokuGame.sudokuUndo countGoBookmark] = %ld", (long)[sudokuGame.sudokuUndo countGoBookmark]);

	
    if ([sudokuGame.sudokuUndo countBookmarked] == 0)	// 아직 북마크가 추가된 것이 하나도 없다면 무조건 북마크를 추가한다.
    {
        [sudokuGame.sudokuUndo addBookmark];
        [ctrl DoneQuest:eQuestBookmarking];

        [self playSoundClick];
    } else {
        
        alertMode = ALELRT_BOOKMARK;
        
        MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:nil
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* goback = [UIAlertAction
                             actionWithTitle:gettext(@"Go back last bookmark", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self PushBookmarkButton:0];
                                 
                             }];
        [alert addAction:goback];
        UIAlertAction* add = [UIAlertAction
                                 actionWithTitle:gettext(@"Add bookmark", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self PushBookmarkButton:1];
                                     
                                 }];
        [alert addAction:add];
        UIAlertAction* delete = [UIAlertAction
                              actionWithTitle:gettext(@"Delete all bookmarks", nil)
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self PushBookmarkButton:2];
                                  
                              }];
        [alert addAction:delete];
        UIAlertAction* cancel = [UIAlertAction
                              actionWithTitle:gettext(@"Cancel", nil)
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self PushBookmarkButton:3];
                                  
                              }];
        [alert addAction:cancel];

        
        [ctrl presentViewController:alert animated:YES completion:nil];
        
        
        [self playSoundClick];
    }
	//[sudokuGame saveData];

	
	[self setNeedsDisplay];
}


- (BOOL) memoOnOff
{
    if (sudokuGame.isGameFinished)
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
	
	[self playSoundClick];
	MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;

	[ctrl updateButtons];
	
	[self setNeedsDisplay];	
}


- (void) delNumber
{
    if (sudokuGame.isGameFinished)
        return;
    
	[sudokuGame setFixNums:0 x:selectedXPos y:selectedYPos];
	[self checkClearAndUpdateButton];

	[sudokuGame saveData];
}




- (void) clearNumbers
{
    if (sudokuGame.isGameFinished)
        return;

    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;
    alertMode = ALELRT_INIT;
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:gettext(@"Alert", nil)
                                  message:gettext(@"Do you want to initialize the puzzle?", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:gettext(@"No", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                         }];
    
    [alert addAction:no];

    UIAlertAction* yes = [UIAlertAction
                         actionWithTitle:gettext(@"Yes", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [sudokuGame clearAllNums];
                             
                             [ctrl updateButtons];
                             [ctrl updateHintCount];
                             
                             [self playSound:soundClearID];
                             [sudokuGame saveData];
                             
                             [ctrl DoneQuest:eQuestResetGame];
                             
                             [self setNeedsDisplay];
                             
                         }];
    
    [alert addAction:yes];
    
    [ctrl presentViewController:alert animated:YES completion:nil];

	[sudokuGame saveData];
}

- (void) doHint
{
    if (sudokuGame.isGameFinished)
        return;
/*
    for (int i=0; i<sudokuGame.size; i++)
    {
        for (int j=0; j<sudokuGame.size; j++)
        {
            [sudokuGame setHintNum:i y:j];
        }
        
    }
*/    
    
	if (sudokuGame.countHint > 0) {
		sudokuGame.countHint -= 1;
		[sudokuGame setHintNum:selectedXPos y:selectedYPos];
	} else if (paidHintCount > 0) {
		paidHintCount -= 1;
		[sudokuGame setHintNum:selectedXPos y:selectedYPos];
    } else  {
        // no hint
    }

	
	
	[self checkClearAndUpdateButton];
	[sudokuGame saveData];
}




- (BOOL) loadGame
{
	DLog(@"loadGame");
	sudokuGame = [SudokuGame loadData];
	
	if (sudokuGame != NULL)
	{
        [self setSelectedXYPos:0 yPos:0];
		[sudokuGame saveData];
        
		[self setNeedsDisplay];
		return YES;
	}
	return NO;
}


- (void) newGame:(NSInteger)level size:(NSInteger)sizePuzzle
{
	BOOL bUseQQ=NO;
    NSString *str;
    
    if (level == GAMELEVEL_USERINPUT)           // only original is allowed
        nSettingSudokuType = SUDOKUTYPE_SUDOKU;

    [Flurry logEvent:@"NewGame"];
    
    str = [NSString stringWithFormat:@"GameSize(%ld)", (long)sizePuzzle];
    [Flurry logEvent:str];
    
    str = [NSString stringWithFormat:@"NewGame(%@)", [SudokuGame getSudokuTypeNameNoop:nSettingSudokuType]];
    [Flurry logEvent:str];

    str = [NSString stringWithFormat:@"GameLevel(%@)", [SudokuGame getGameLevelNameNoop:(GAMELEVEL)level]];
    [Flurry logEvent:str];
    
    str = [NSString stringWithFormat:@"AutoMemo(%@)", bSettingAutoMemo ? @"Yes" : @"No"];
    [Flurry logEvent:str];

    
    
    if ((nSettingSudokuType == SUDOKUTYPE_SUDOKU || nSettingSudokuType == SUDOKUTYPE_SYMBOL)
        && sizePuzzle == SIZE_9 && level != GAMELEVEL_USERINPUT)    // QQWing은 9x9 일반 sudoku만 지원한다.
        bUseQQ = YES;	

	if (bUseQQ)
	{
		SudokuBoard* board = GenerateSudoku(DIFF_EXPERT); 
		sudokuGame = [[SudokuGame alloc] initWithSudokuBoard:board type:nSettingSudokuType level:(GAMELEVEL)level automemo:bSettingAutoMemo];
		[board release];
	} else {
		SudokuNum *sudokuNum = sudokuNumGenerate(nSettingSudokuType, level, sizePuzzle, bSettingDefMap);
		sudokuGame = [[SudokuGame alloc] initWithSudokuNum:sudokuNum type:nSettingSudokuType level:(GAMELEVEL)level automemo:bSettingAutoMemo];
		[sudokuNum release];
	}
	
	// zzz turn off activityIndicator
    [self setSelectedXYPos:0 yPos:0];
    [sudokuGame saveData];          // save Sudoku data as soon as making new game
	[self setNeedsDisplay];
}

- (BOOL) newGameFromServer:(NSString*)strData
{
    NSString *str;
    SudokuGame *newGame;
    
    str = [NSString stringWithFormat:@"DailyPuzzle(%@)", [SudokuGame getSudokuTypeNameNoop:nSettingSudokuType]];
    [Flurry logEvent:str];
    
    newGame = [[SudokuGame alloc] initWithFromServer:strData type:nSettingSudokuType automemo:bSettingAutoMemo];
    if (!newGame)
        return NO;
    
    sudokuGame = newGame;
	
	// zzz turn off activityIndicator
    [self setSelectedXYPos:0 yPos:0];
    [sudokuGame saveData];          // save Sudoku data as soon as making new game
	[self setNeedsDisplay];
    
    return YES;
}



#pragma mark - Alert
/*
 - (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;

    switch (alertMode)
    {
        case ALELRT_INIT :
            if (buttonIndex == 1) // "확인" 버튼
            {
                [sudokuGame clearAllNums];
                
                [ctrl updateButtons];
                [ctrl updateHintCount];
                
                [self playSound:soundClearID];
				[sudokuGame saveData];
                
                [ctrl DoneQuest:eQuestResetGame];
            }
            
            break;
        case ALELRT_BOOKMARK :
            if (buttonIndex == 0)		// goto last bookmark
            {
                NSInteger countBookmark = [sudokuGame.sudokuUndo countGoBookmark];
                
                if (countBookmark)
                {
                    CGPoint pointLastUndoPos;
					Bookmark *bm = [sudokuGame.sudokuUndo getLastBookmark];
					
					if (bm)
					{
                        [self setSelectedXYPos:bm->x yPos:bm->y];
						
						if (countBookmark < 0)
						{
							while ([sudokuGame.sudokuUndo getIndex] > bm->pos)
								pointLastUndoPos = [sudokuGame runUndo];
						} else {
							while ([sudokuGame.sudokuUndo getIndex] <= bm->pos)
								pointLastUndoPos = [sudokuGame runRedo];
						}
					}
                }
				// delete last bookmark;
                [sudokuGame.sudokuUndo delLastBookmark];
                [self playSoundClick];
                [ctrl DoneQuest:eQuestGoBack];

            } else if (buttonIndex == 1) {
                [sudokuGame.sudokuUndo addBookmark];
                [self playSoundClick];
                [ctrl DoneQuest:eQuestBookmarking];
            } else if (buttonIndex == 2) {
                [sudokuGame.sudokuUndo delAllBookmarks];
                [self playSound:soundClearID];	
            } else if (buttonIndex == 3) {              // cancel
                
            }
            [ctrl updateButtonUndo];
            [ctrl updateButtonBookmark];
			[sudokuGame saveData];

            break;
        default:
            break;
    }
	[self setNeedsDisplay];
}
*/

- (void) OnTimer:(NSTimer *)timer
{
	//DLog(@"OnTimger");
    MainViewController *ctrl = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController;

    
    [sudokuGame setFixNums:pressedButtonNum x:selectedXPos y:selectedYPos];
    [self checkClearGame];
    
    
    
    if ([self conflictCell:selectedXPos yPos:selectedYPos])
        [self playSound:soundFailID];   // 강력한 기능이라서 Setting으로 빼야 한다.
    else
        [self playSoundClick];

    [ctrl updateButtons];

    timerTouch = nil;
    bPressedInButton = NO;
    bHoldAndChoice = YES;       // 누르고 있는 버튼을 크게 표시한다.
    pushedButton = pressedButtonNum;
	
	[sudokuGame saveData];

    [self setNeedsDisplay];
    
    [ctrl DoneQuest:eQuestLongTouch];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //DLog(@"touchesBegan(cTableWidth=%f)", cTableWidth);
    
	if (sudokuGame.isGameFinished)	// lock the screen
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
			//DLog(@"touchesBegan-MemoMode timerTouch(%f)", TIME_HOLDANDCHOICE);
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
	if (bMenuMode || sudokuGame.isGameFinished)	// lock the screen
		return;	
	bTouch = NO;
//    DLog(@"Touches Cancelled");
	bPressedInButton = NO;
	bPressedInCell = NO;
//	DLog(@"pressedInButton = NO");
	
	[self setNeedsDisplay];
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (bMenuMode || sudokuGame.isGameFinished)	// lock the screen
		return;
    
	if (bMemoMode)
    {
        if (timerTouch)
        {
            //DLog(@"[timerTouch invalidate] <= touchesEnded");
            [timerTouch invalidate];
            timerTouch = nil;
        }
    }

	bTouch = NO;
    bHoldAndChoice = NO;
	
	[self touchesDo:touches bEnd:YES];
	bPressedInButton = NO;
	bPressedInCell = NO;
//	DLog(@"pressedInButton = NO");
	
	[self setNeedsDisplay];
}	

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (bMenuMode || sudokuGame.isGameFinished)	// lock the screen
		return;
    
	if (bMemoMode)
    {
        if (timerTouch)
        {
			UITouch *touch = [touches anyObject];
			CGPoint	firstTouch = [touch previousLocationInView:self];
			CGPoint	secodTouch = [touch locationInView:self];
			
			if (ABS(firstTouch.x-secodTouch.x) >= 3 ||
				ABS(firstTouch.y-secodTouch.y) >= 3)
			{
				//DLog(@"[timerTouch invalidate] <= touchesMoved");
				
				[timerTouch invalidate];
				timerTouch = nil;
				return;
			} else {
				DLog(@"small move (%f,%f)",
					 ABS(firstTouch.x-secodTouch.x),
					 ABS(firstTouch.y-secodTouch.y));
			}
        }
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
		if ([sudokuGame getPuzzleNums:selectedXPos y:selectedYPos] == 0 &&  // 사용자가 입력하는 칸이다.
            [sudokuGame getFixNums:selectedXPos y:selectedYPos] == 0) {     // 사용자가 입력한 칸이다.
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
#define cCellBookmarkFontSize       (0.6f * MINWHT / 3) //11*cResizeRatioW
#define cCellSumFontSize            (0.8f * MINWHT / 3) //11*cResizeRatioW
#define cCellWrongSumFontSize       (0.9f * MINWHT / 3) //11*cResizeRatioW
#define cCellSignFontSize           (1.1f * MINWHT / 3) //11*cResizeRatioW

#define cButtonBigFontSize          (1.0f * MINWHB) //40*cResizeRatioW
#define cButtonSmallFontSize        (0.7f * MINWHB) //30*cResizeRatioW
//#define cButtonTextFontSize         (0.8f * MINWHB) //20*cResizeRatioW
#define cButtonMemoBigFontSize		(0.7f * MINWHB) //35*cResizeRatioW
#define cButtonMemoSmallFontSize	(0.6f * MINWHB) //25*cResizeRatioW
//#define cButtonMemoTextFontSize		(0.7f * MINWHB) //17*cResizeRatioW



// Trebuchet MS
// Helvetica
// Chalkboard SE

- (void) setFont
{
	//DLog(@"setFont(%f)", cCellWidth);
	self.cellOneSmallFont       = [UIFont fontWithName:@"Trebuchet MS" size:cCellOneSmallFontSize];
	self.cellOneBigFont         = [UIFont fontWithName:@"Trebuchet MS" size:cCellOneBigFontSize];
	self.cellTwoFont            = [UIFont fontWithName:@"Trebuchet MS" size:cCellTwoFontSize];
	self.cellFourFont           = [UIFont fontWithName:@"Trebuchet MS" size:cCellFourFontSize];
	self.cellSixFont            = [UIFont fontWithName:@"Trebuchet MS" size:cCellSixFontSize];
	self.cellNineFont           = [UIFont fontWithName:@"Trebuchet MS" size:cCellNineFontSize];
	self.cellBookmarkFont       = [UIFont fontWithName:@"Trebuchet MS" size:cCellBookmarkFontSize];
	self.cellSumFont            = [UIFont fontWithName:@"Trebuchet MS" size:cCellSumFontSize];
    self.cellWrongSumFont       = [UIFont fontWithName:@"Trebuchet MS" size:cCellWrongSumFontSize];
    self.cellSignFont           = [UIFont fontWithName:@"Trebuchet MS" size:cCellSignFontSize];
	self.buttonSmallFont        = [UIFont fontWithName:@"Trebuchet MS" size:cButtonSmallFontSize];
	self.buttonBigFont          = [UIFont fontWithName:@"Trebuchet MS" size:cButtonBigFontSize];
//	self.buttonTextFont         = [UIFont fontWithName:@"Trebuchet MS" size:cButtonTextFontSize];
	self.buttonMemoSmallFont	= [UIFont fontWithName:@"Trebuchet MS" size:cButtonMemoSmallFontSize];
	self.buttonMemoBigFont		= [UIFont fontWithName:@"Trebuchet MS" size:cButtonMemoBigFontSize];
//	self.buttonMemoTextFont		= [UIFont fontWithName:@"Trebuchet MS" size:cButtonMemoTextFontSize];
    
}





- (void) drawBackgroundDrawOnImage:(CGContextRef) context strTime:(NSString*) strTime
{
    CGRect rect = CGRectMake(0, 0, DRAWONIMAGE_W, DRAWONIMAGE_H);
    
    CGContextSetFillColorWithColor(context, skincolor[SC_BACKGROUND_VIEW].CGColor);
    CGContextFillRect(context,rect);
        
    NSArray *value = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIconFiles"];
    UIImage *img = nil;
    NSString *strIcon;
    for (int i=0; i<[value count]; i++)
    {
        strIcon = [value objectAtIndex:i];
        NSRange range = [strIcon rangeOfString:@"Small-50"];
        if (range.length > 0)
        {
            img = [UIImage imageNamed:[value objectAtIndex:i]];
            break;
        }
    }
    
    rect = CGRectMake(DRAWONIMAGE_TABLE_X, DRAWONIMAGE_TABLE_Y*2+DRAWONIMAGE_TABLE_H, DRAWONIMAGE_ICONSIZE, DRAWONIMAGE_ICONSIZE);
    if (img)
        [img drawInRect:rect];

    NSString *appName = gettexttable(@"CFBundleDisplayName", @"InfoPlist");
    NSString *str;
    
    if (sudokuGame.sudokuType != SUDOKUTYPE_SUDOKU)
    {
        appName = [appName stringByAppendingFormat:@"(%@)", [SudokuGame getSudokuTypeName:sudokuGame.sudokuType]];
    }
    
    if (sudokuGame.isGameFinished)
    {
        str = [NSString stringWithFormat:gettext(@"%@: My record is %@", nil), appName, strTime];
    } else {
        str = appName;
    }
    
    rect = CGRectMake(DRAWONIMAGE_TABLE_X*2+DRAWONIMAGE_ICONSIZE,
                      DRAWONIMAGE_TABLE_Y*2+DRAWONIMAGE_TABLE_H,
                      DRAWONIMAGE_TABLE_W - DRAWONIMAGE_TABLE_X - DRAWONIMAGE_ICONSIZE,
                      DRAWONIMAGE_ICONSIZE);
    
    [self drawStrRect:context
                  str:str
                 rect:rect
                color:[UIColor colorWithWhite:1.0f alpha:1.0f]
                 font:[UIFont fontWithName:@"Trebuchet MS" size:DRAWONIMAGE_ICONSIZE*0.7f]
				align:NSTextAlignmentLeft];

    if (sudokuGame.isGameFinished)
    {
        [self drawStrRect:context
                      str:sudokuGame.bAutoMemo?@"Auto":@"Orginal"
                     rect:rect
                    color:[UIColor colorWithWhite:1.0f alpha:1.0f]
                     font:[UIFont fontWithName:@"Trebuchet MS" size:DRAWONIMAGE_ICONSIZE*0.8f]
                    align:NSTextAlignmentRight];
    }
}

- (void) drawOnImage:(CGContextRef) context strTime:(NSString*) strTime
{
    bDrawOnImage = YES;
    frameDrawOnImage = CGRectMake(DRAWONIMAGE_TABLE_X, DRAWONIMAGE_TABLE_Y, DRAWONIMAGE_TABLE_W, DRAWONIMAGE_TABLE_H);
    
    [self setFont];
    
    [self drawBackgroundDrawOnImage:context strTime:strTime];
	[self drawRectTableBackground:context];     // 기본 테이블 바탕 색
	[self drawKillerBackground:context];		// killer sudoku의 바탕색
    [self drawKillerLine:context];				// 테이블 라인 긎기
	[self drawRectTableLine:context];           // 테이블 라인 긎기
	[self drawRectTableBackgroundBorder:context];
	[self drawCellNums:context];                // n*n 칸에 숫자를 출력
	[self drawKillerSumNum:context];			// 합계 표시하기
    
    bDrawOnImage = NO;

}

// Draw screen again

- (void)drawRect:(CGRect)rect
{
    
    //DLog(@"self.bounds(%f,%f)",          self.bounds.size.width, self.bounds.size.height);
    
    
    //	NSString* s;
    
    //	DLog(@"%@", [sudokuNum getNums]);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //DLog(@"drawRect ---------- refresh");
    
    [self setFont];
    
    //    [self drawWindowsBackground:context];       // 전체 바탕 색
    [self drawRectTableBackground:context];     // 기본 테이블 바탕 색

    [self drawSymbolLine:context];				// Symbol 테이블 라인 긎기

    [self drawKillerBackground:context];		// killer sudoku의 바탕색
    [self drawGuidelineBackground:context];     // 힌트 바탕 색
    [self drawMarkingEqualBackgound:context];   // 같은 숫자 표시 바탕색 표시
    [self drawHighlightCellBackground:context]; // 선택된 셀 바탕색
    [self drawGtComapreCellColor:context];      // 선택된 셀 바탕색
    [self drawKillerLine:context];				// 테이블 라인 긎기
    [self drawRectTableLine:context];           // 테이블 라인 긎기
    
    [self drawBookmarkInCell:context];          // 북마크 표시
    [self drawCellNums:context];                // n*n 칸에 숫자를 출력
    [self drawRectTableBackgroundBorder:context];
    [self drawKillerSumNum:context];			// 합계 표시하기
    [self drawHighlightCell:context];           // 선택된 셀 표시
    [self drawNumButton:context];
    
    [self drawCongratulations:context];                 // 축하 표시
    
    [self drawBlurTable:context];               // 기본 테이블 바탕 색
}



@end
