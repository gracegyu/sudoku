
#define ADDTHIS_MYPUBID     @"ra-5064495f594cc950"
#define ADDTHIS_MYAPPID     @"50988413246ba277"



#ifdef SUDOKU9
#ifdef ADMOB_FREEVERSION
#define APP_ID      @"403191170"  // SUDOKU9 Free
#define SHORTENURL  @"http://goo.gl/VQUlv"
#define JMC_PRJKEY  @"SDSDKNINEF"
#define JMC_APIKEY  @"0d51a400-def2-4d60-b866-31d16d4af924"
#define FACEBOOK_ID @"302256366555317"
#define FLURRY_KEY  @"FDJCSXX9BND2Z34G43VB"
#else
#define APP_ID      @"386917779"  // SUDOKU9 Paid
//#define SHORTENURL  @"http://goo.gl/chLcy"    // blacklist URL?
#define SHORTENURL  @"http://goo.gl/7tcTc"
#define JMC_PRJKEY  @"SDSDKNINEP"
#define JMC_APIKEY  @"0c18415e-2e1c-47a3-a61b-cd5cf322703b"
#define FACEBOOK_ID @"116121415220692"
#define FLURRY_KEY  @"K288GF64Z2CMHD39MQQY"
#endif
//sudoku9
#define MY_BANNER_UNIT_ID_IPHONE5   (@"ca-app-pub-1077680179839843/2276477598")
#define MY_BANNER_UNIT_ID_IPHONE    (@"ca-app-pub-1077680179839843/8462611996")
#define MY_BANNER_UNIT_ID_IPAD      (@"ca-app-pub-1077680179839843/2416078397")
#elif defined(SUDOKU6)
#ifdef ADMOB_FREEVERSION
#define APP_ID      @"568783854"  // SUDOKU6 Free
#define SHORTENURL  @"http://goo.gl/Mofwx"
#define JMC_PRJKEY  @"SDSDKSIXF"
#define JMC_APIKEY  @"e1a7b32b-2a9d-4cf4-818e-efdd886034b9"
#define FACEBOOK_ID @"126906610795923"
#define FLURRY_KEY  @"MKQK34DRFGKTTSXVS5BY"
#else
#define APP_ID      @"574356934"  // SUDOKU6 Paid
#define SHORTENURL  @"http://goo.gl/DtLbw"
#define JMC_PRJKEY  @"SDSDKSIXP"
#define JMC_APIKEY  @"e914b167-d0f2-4501-be8a-fdbb9d7e30ba"
#define FACEBOOK_ID @"381531935263532"
#define FLURRY_KEY  @"DVDSHVZT8QXB8MPC4RH2"
#endif
//sudoku6
#define MY_BANNER_UNIT_ID_IPHONE5   (@"ca-app-pub-1077680179839843/8602212795")
#define MY_BANNER_UNIT_ID_IPHONE    (@"ca-app-pub-1077680179839843/6985878793")
#define MY_BANNER_UNIT_ID_IPAD      (@"ca-app-pub-1077680179839843/2555679190")

#else   // etc. SUDOKU7 etc

#define APP_ID      @"386917779"  // SUDOKU9 Paid
#define SHORTENURL  @"http://goo.gl/chLcy"
#define JMC_PRJKEY  @"SDALL"
#define JMC_APIKEY  @"bfa9e7a3-208c-4200-add4-55a5d8970e5e"
#define FACEBOOK_ID @"560258597334326"
#define FLURRY_KEY  @"DVDSHVZT8QXB8MPC4RH2"
#define MY_BANNER_UNIT_ID_IPHONE5   (@"ca-app-pub-1077680179839843/8602212795")
#define MY_BANNER_UNIT_ID_IPHONE    (@"ca-app-pub-1077680179839843/6985878793")
#define MY_BANNER_UNIT_ID_IPAD      (@"ca-app-pub-1077680179839843/2555679190")

#endif 



#ifdef SUDOKU16
#define STR_MATRIXSIZE  @"16x16"
#elif defined(SUDOKU12)
#define STR_MATRIXSIZE  @"12x12"
#elif defined(SUDOKU9)
#define STR_MATRIXSIZE  @"9x9"
#elif defined(SUDOKU8)
#define STR_MATRIXSIZE  @"8x8"
#elif defined(SUDOKU7)
#define STR_MATRIXSIZE  @"7x7"
#elif defined(SUDOKU6)
#define STR_MATRIXSIZE  @"6x6"
#elif defined(SUDOKU5)
#define STR_MATRIXSIZE  @"5x5"
#else
#define STR_MATRIXSIZE  @"?x?"
#endif











#define MY_BANNER_UNIT_ID       ((cDeviceType == DEVICETYPE_IPAD) ? MY_BANNER_UNIT_ID_IPAD : (isIphone5 ? MY_BANNER_UNIT_ID_IPHONE5 : MY_BANNER_UNIT_ID_IPHONE))

#define IPHONE_GAD_H            GAD_SIZE_320x50.height
#define IPHONE_GAD_W            GAD_SIZE_320x50.width
#define IPAD_GAD_H              GAD_SIZE_728x90.height
#define IPAD_GAD_W              GAD_SIZE_728x90.width

#define BACKTRACKING_START      3
#define BACKTRACKING_INTERVAL    3
#define BACKTRACKING_MAX        15
#define MAX_HANDYTRAYFAIL       10

#define GAMECOUNTFORREVIEW        20
#define SECONDSFORFREEHINT		1200



enum SUDOKUTYPE {
    SUDOKUTYPE_SUDOKU = 0,
    SUDOKUTYPE_GT = 1,
    SUDOKUTYPE_KILLER = 2,
    SUDOKUTYPE_CALCU = 3,
    SUDOKUTYPE_MAX = 4      // SOMETIMES Auto
};

typedef enum SUDOKUTYPE SUDOKUTYPE;



enum GAMELEVEL {
	GAMELEVEL_VERYHARD = 0,		// handy 0
	GAMELEVEL_HARD,
	GAMELEVEL_NORMAL,
	GAMELEVEL_EASY,
	GAMELEVEL_VERYEASY
};

typedef enum GAMELEVEL GAMELEVEL;

enum DEVICETYPE {
	DEVICETYPE_UNKNOWN = 0,
	DEVICETYPE_ANDROID,
	DEVICETYPE_IPHONE,
	DEVICETYPE_IPAD,
	DEVICETYPE_BLACKBERRY,
	DEVICETYPE_WINDOWPHONE7
};

typedef enum DEVICETYPE DEVICETYPE;

typedef struct SUDOKUSCORE
{
    NSInteger	scoreGames[SUDOKUTYPE_MAX][10];					// original:5 automemo:5
	NSInteger	scoreClears[SUDOKUTYPE_MAX][10];
	NSInteger	scoreBestTime[SUDOKUTYPE_MAX][10];
	NSInteger	scoreClearTimeSum[SUDOKUTYPE_MAX][10];
	NSInteger	scoreRankLevel[SUDOKUTYPE_MAX][10];            // normal sudoku는 auto ranking도 저장 
    NSInteger   scoreTotal;
    NSInteger   scoreRankTotal;
} SUDOKUSCORE;

#define cTableXMargine              60
#define cTableYMargine              33
#define cDeviceType					((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? DEVICETYPE_IPAD : DEVICETYPE_IPHONE)
#define cOSType						@"iOS"
#define cOSVersion					[[[UIDevice currentDevice] systemVersion] floatValue]
#define isIpad                      (cDeviceType == DEVICETYPE_IPAD)
#define isIphone5                    ([UIScreen mainScreen].bounds.size.height * [[UIScreen mainScreen] scale] == 1136)
//#define isPortrait                  (lastOrientation == UIInterfaceOrientationPortrait || lastOrientation == UIInterfaceOrientationPortraitUpsideDown)
#define isPortrait                  ([self interfaceOrientation] == UIInterfaceOrientationPortrait || [self interfaceOrientation] == UIInterfaceOrientationPortraitUpsideDown)


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define TIME_HOLDANDCHOICE	0.2
#define TIME_UNDOREPEATE	0.5
#define TIME_UNDOINTERVAL	0.05	// undo가 느리게 진행될 수 있으므로... 짧게 설정


#ifdef DEBUG
#define DLog(format, ...)				NSLog(format, ## __VA_ARGS__)
#define DAssert(condition, desc, ...)	NSAssert(condition, desc, ## __VA_ARGS__)
#else
#define DLog(format, ...)
#define DAssert(condition, desc, ...)
#endif

#ifdef SUDOKU9
#define REPLAY_FRAME_INTERVAL   0.05f
#else
#define REPLAY_FRAME_INTERVAL   0.2f
#endif

#define DRAWONIMAGE_W           1000
#define DRAWONIMAGE_H           1000
#define DRAWONIMAGE_TABLE_X     10
#define DRAWONIMAGE_TABLE_Y     10
#define DRAWONIMAGE_TABLE_W     (DRAWONIMAGE_W-DRAWONIMAGE_TABLE_X*2)
#define DRAWONIMAGE_TABLE_H     (DRAWONIMAGE_H - DRAWONIMAGE_TABLE_Y*3 - DRAWONIMAGE_ICONSIZE)
#define DRAWONIMAGE_ICONSIZE    50

#define NUM_RANK_BESTTIME	5
#define MAX_SKIN_COUNT 12


#ifdef ADMOB_FREEVERSION
#define SUPPORT_ROTATION    ((cDeviceType == DEVICETYPE_IPHONE)?NO:YES)
#else
#define SUPPORT_ROTATION    YES
#endif

#define STR_LICENSE     @"Ⓒ 2014 Smartone, All rights reserved."
#define NUM_HINTBONUS   2
#define NUM_DEFHINT9    3
#define NUM_DEFHINT6    2


// for daily puzzle
#define cProtocolVersion        1
#define cDefaultUserID          0
//#define cServerHostName         @"gracegyu.comlu.com"
//#define cServerHostName         @"www.smartoneinc.com"
#define cServerHostName         @"dailysudoku.cafe24.com"
//#define cServerScript           @"dailysudoku_test.php"
#define cServerScript           @"dailysudoku.php"
#define cDefaultHTTPTimeOut     5.f
#define kResultStatus				@"Result"
#define kCount						@"Count"
#define kSuccess					@"Success"

#ifdef SUDOKU9
#ifdef ADMOB_FREEVERSION
#define kHint50Item             @"com.raymond.sudoku9free.hint50"
#else
#define kHint50Item             @"com.raymond.sudoku9.hint50"
#endif
#else
#ifdef ADMOB_FREEVERSION
#define kHint50Item             @"com.raymond.sudoku6free.hint50"
#else
#define kHint50Item             @"com.raymond.sudoku6.hint50"
#endif
#endif


#define countHint50             50

