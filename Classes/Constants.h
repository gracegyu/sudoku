
#ifdef GTSUDOKU

#ifdef SUDOKU9
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a150765b79bf648")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a150765af719cb3")
#define MY_BANNER_UNIT_ID_IPAD      (@"a150765bbea49a7")
#else  // SUDOKU6
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a1507644eca74b4")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a15076456849bb3")
#define MY_BANNER_UNIT_ID_IPAD      (@"a1507645bce8c4c")
#endif

#else

#ifdef SUDOKU9
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a1506f9ab471950")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a14ccfafd6895cb")
#define MY_BANNER_UNIT_ID_IPAD      (@"a14fd69f029bc6d") 
#else  // SUDOKU6
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a1506f9efd45635")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a1506f9e947e7b0")
#define MY_BANNER_UNIT_ID_IPAD      (@"a1506f9f57f0075")
#endif

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

#ifdef ADMOB_FREEVERSION
#define APP_ID      @"403191170"  // SUDOKU9 Free
#else
#define APP_ID      @"386917779"  // SUDOKU9 Paid
#endif


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


#define TIME_HOLDANDCHOICE	0.35
#define TIME_UNDOREPEATE	0.5
#define TIME_UNDOINTERVAL	0.05	// undo가 느리게 진행될 수 있으므로... 짧게 설정


#ifdef DEBUG
#define DLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define DLog(format, ...)
#endif


#ifdef GTSUDOKU
static int	HandyCount[][5] = {
    { 0, 0, 0, 0, 0 },   // 0
    { 0, 0, 0, 0, 0 },   // 1
    { 0, 0, 0, 0, 0 },   // 2
    { 0, 0, 0, 0, 0 },   // 3
    { 0, 2, 4, 7, 10 },   // 4
    { 0, 2, 4, 10, 15 }, // 5
    { 0, 2, 6, 13, 20 }, // 6
    { 0, 3, 8, 16, 22 }, // 7
    { 0, 4, 9, 18, 25 }, // 8
    { 0, 4, 15, 24, 45 }  // 9
};
#else
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
    { 0, 5, 10, 20, 30 } // 9
};
#endif

