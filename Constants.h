#define cStdWidth				320.f
#define cResizeRatioW			(cTableWidth/cStdWidth)
#define cResizeRatioH			(cTableHeight/cStdWidth)

#define cCellWidth				(cTableWidth-cBoldLine*2-cLineWidth*6)/9	//34
#define cCellHeight				(cTableHeight-cBoldLine*2-cLineWidth*6)/9	//34

#define cLineWidth				1.f*cResizeRatioW
#define cLineDrawWidth			0.5f*cResizeRatioW
#define cBoldLine				4.f*cResizeRatioW
#define cTableWidth				fTableWidth	
#define cTableHeight			(fTableWidth*fPress)
#define cBorderButton			5

#define cCellOneSmallFontSize	30*cResizeRatioW*0.9f
#define cCellOneBigFontSize		40*cResizeRatioW*0.9f
#define cCellFailFontSize		16*cResizeRatioW*0.9f
#define cCellTwoFontSize		22*cResizeRatioW*0.9f	
#define cCellFourFontSize		16*cResizeRatioW*0.9f	
#define cCellNineFontSize		12*cResizeRatioW*0.9f
#define cButtonSmallFontSize	25*cResizeRatioW//20
#define cButtonBigFontSize		35*cResizeRatioW
#define cButtonTextFontSize		20*cResizeRatioW
#define cButtonMemoSmallFontSize	22*cResizeRatioW
#define cButtonMemoBigFontSize		33*cResizeRatioW
#define cButtonMemoTextFontSize		18*cResizeRatioW


enum GAMELEVEL {
	GAMELEVEL_VERYHARD = 0,		// handy 0
	GAMELEVEL_HARD,
	GAMELEVEL_NORMAL,
	GAMELEVEL_EASY,
	GAMELEVEL_VERYEASY
};

enum {
	DEVICETYPE_UNKNOWN = 0,
	DEVICETYPE_ANDROID,
	DEVICETYPE_IPHONE,
	DEVICETYPE_IPAD,
	DEVICETYPE_BLACKBERRY,
	DEVICETYPE_WINDOWPHONE7
};

#define cDeviceType					((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? DEVICETYPE_IPAD : DEVICETYPE_IPHONE)
#define cOSType						@"iOS"
#define cOSVersion					[[[UIDevice currentDevice] systemVersion] floatValue]

