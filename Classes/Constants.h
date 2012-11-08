
#define ADDTHIS_MYPUBID     @"ra-5064495f594cc950"
#define ADDTHIS_MYAPPID     @"50988413246ba277"



#ifdef GTSUDOKU	// Greater than sudoku

#ifdef SUDOKU9
#ifdef ADMOB_FREEVERSION
#define APP_ID      @"569760774"  // Greater than sudoku9 Free
#define FACEBOOK_ID @"483561938330570"
#define SHORTENURL  @"http://goo.gl/hTPaX"
#define JMC_PRJKEY  @"SDGTSNINEF"
#define JMC_APIKEY  @"7e35de83-0ce1-4f69-b30b-ca4c08269299"
#else
#define APP_ID      @"574380693"  // Greater than sudoku9 Paid
#define FACEBOOK_ID @"550584541622317"
#define SHORTENURL  @"http://goo.gl/lKD69"
#define JMC_PRJKEY  @"SDGTSNINEP"
#define JMC_APIKEY  @"9176b134-1289-4782-adba-5f6be380f7b9"
#endif
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a150765b79bf648")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a150765af719cb3")
#define MY_BANNER_UNIT_ID_IPAD      (@"a150765bbea49a7")
#else  // SUDOKU6
#ifdef ADMOB_FREEVERSION
#define APP_ID      @"569751989"  // Greater than sudoku6 Free
#define FACEBOOK_ID @"453421778026824"
#define SHORTENURL  @"http://goo.gl/jzQnD"
#define JMC_PRJKEY  @"SDGTSSIXF"
#define JMC_APIKEY  @"f40f6440-259a-4c81-a878-569453fe7fe4"
#else
#define APP_ID      @"574377045"  // Greater than sudoku Paid
#define FACEBOOK_ID @"382498565165793"
#define SHORTENURL  @"http://goo.gl/cH2gi"
#define JMC_PRJKEY  @"SDGTSSIXP"
#define JMC_APIKEY  @"d69a926b-d57e-4f6a-9904-464877c17ec2"
#endif
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a1507644eca74b4")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a15076456849bb3")
#define MY_BANNER_UNIT_ID_IPAD      (@"a1507645bce8c4c")
#endif

#elif (defined KILLERSUDOKU) && (!defined CALCUDOKU) 	// killersudoku9

#ifdef SUDOKU9
#ifdef ADMOB_FREEVERSION
#define APP_ID      @"574234872"  // killersudoku9 Free
#define FACEBOOK_ID @"469019206474062"
#define SHORTENURL  @"http://goo.gl/3dkRW"
#define JMC_PRJKEY  @"SDKSNINEF"
#define JMC_APIKEY  @"b7adf06f-0474-4e44-a4e2-455022b6f73b"
#else
#define APP_ID      @"574345418"  // killersudoku9 Paid
#define FACEBOOK_ID @"478373285535985"
#define SHORTENURL  @"http://goo.gl/jwHCX"
#define JMC_PRJKEY  @"SDKSNINEP"
#define JMC_APIKEY  @"5f92294a-2d26-4dec-b342-b9710a2f1e99"
#endif
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a15088f9e25e0fa")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a15088f9935ab96")
#define MY_BANNER_UNIT_ID_IPAD      (@"a15088fa20ad7d8")
#else  // SUDOKU6
#ifdef ADMOB_FREEVERSION
#define APP_ID      @"574235264"  // killersudoku6 Free
#define FACEBOOK_ID @"290298984415040"
#define SHORTENURL  @"http://goo.gl/k13Q7"
#define JMC_PRJKEY  @"SDKSSIXF"
#define JMC_APIKEY  @"73c6ac34-1f53-4fc3-b6b5-c39f9e2e088c"
#else
#define APP_ID      @"574347141"  // killersudoku6 Paid
#define FACEBOOK_ID @"160306354116246"
#define SHORTENURL  @"http://goo.gl/51rxy"
#define JMC_PRJKEY  @"SDKSSIXP"
#define JMC_APIKEY  @"87dab42e-13c6-4cc7-b16d-5d107b8b4fbb"
#endif
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a1508bd6c300c4e")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a1508bd679e3282")
#define MY_BANNER_UNIT_ID_IPAD      (@"a1508bd70d7fe12")
#endif

#elif (defined CALCUDOKU) 	// calcudoku

#ifdef SUDOKU9
#ifdef ADMOB_FREEVERSION
#define APP_ID      @"575425696"  // calcudoku9 Free
#define FACEBOOK_ID @"346983712065153"
//#define SHORTENURL  @"http://goo.gl/TIsYM"
#define SHORTENURL  @"http://goo.gl/DOfjQ"      // black list URL?
#define JMC_PRJKEY  @"SDCDNINEF"
#define JMC_APIKEY  @"43a37625-743e-448f-a42e-767bebf6b412"
#else
#define APP_ID      @"575430711"  // calcudoku9 Paid
#define FACEBOOK_ID @"543836268963556"
#define SHORTENURL  @"http://goo.gl/AebNv"
#define JMC_PRJKEY  @"SDCDNINEP"
#define JMC_APIKEY  @"2f250f70-7954-4b1d-99a1-4f6fe0cf6d49"
#endif
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a15091355560159")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a1509134f595744")
#define MY_BANNER_UNIT_ID_IPAD      (@"a1509135947e051")
#else  // SUDOKU6
#ifdef ADMOB_FREEVERSION
#define APP_ID      @"575418850"  // calcudoku6 Free
#define FACEBOOK_ID @"166646773478741"
#define SHORTENURL  @"http://goo.gl/QZdA2"
#define JMC_PRJKEY  @"SDCDSIXF"
#define JMC_APIKEY  @"22738ec4-9f37-4bfe-9932-19bc34b3d591"
#else
#define APP_ID      @"575423342"  // calcudoku6 Paid
#define FACEBOOK_ID @"383848298356291"
#define SHORTENURL  @"http://goo.gl/KiBZZ"
#define JMC_PRJKEY  @"SDCDSIXP"
#define JMC_APIKEY  @"8d7f1b27-be8b-4125-83b2-0dc8678c2acf"
#endif
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a1509135f396fee")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a1509135bbca1af")
#define MY_BANNER_UNIT_ID_IPAD      (@"a15091362131622")
#endif

#elif defined(SUDOKU9) || defined(SUDOKU6)

#ifdef SUDOKU9
#ifdef ADMOB_FREEVERSION
#define APP_ID      @"403191170"  // SUDOKU9 Free
#define FACEBOOK_ID @"388777671193719"
#define SHORTENURL  @"http://goo.gl/VQUlv"
#define JMC_PRJKEY  @"SDSDKNINEF"
#define JMC_APIKEY  @"0d51a400-def2-4d60-b866-31d16d4af924"
#else
#define APP_ID      @"386917779"  // SUDOKU9 Paid
#define FACEBOOK_ID @"302256366555317"
//#define SHORTENURL  @"http://goo.gl/chLcy"    // blacklist URL?
#define SHORTENURL  @"http://goo.gl/7tcTc"
#define JMC_PRJKEY  @"SDSDKNINEP"
#define JMC_APIKEY  @"0c18415e-2e1c-47a3-a61b-cd5cf322703b"
#endif
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a1506f9ab471950")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a14ccfafd6895cb")
#define MY_BANNER_UNIT_ID_IPAD      (@"a14fd69f029bc6d") 
#else  // SUDOKU6
#ifdef ADMOB_FREEVERSION
#define APP_ID      @"568783854"  // SUDOKU6 Free
#define FACEBOOK_ID @"126906610795923"
#define SHORTENURL  @"http://goo.gl/Mofwx"
#define JMC_PRJKEY  @"SDSDKSIXF"
#define JMC_APIKEY  @"e1a7b32b-2a9d-4cf4-818e-efdd886034b9"
#else
#define APP_ID      @"574356934"  // SUDOKU6 Paid
#define FACEBOOK_ID @"381531935263532"
#define SHORTENURL  @"http://goo.gl/DtLbw"
#define JMC_PRJKEY  @"SDSDKSIXP"
#define JMC_APIKEY  @"e914b167-d0f2-4501-be8a-fdbb9d7e30ba"
#endif
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a1506f9efd45635")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a1506f9e947e7b0")
#define MY_BANNER_UNIT_ID_IPAD      (@"a1506f9f57f0075")
#endif

#else   // etc. SUDOKU7 etc

#define APP_ID      @"386917779"  // SUDOKU9 Paid
#define FACEBOOK_ID @""
#define SHORTENURL  @"http://goo.gl/chLcy"
#define JMC_PRJKEY  @"SDALL"
#define JMC_APIKEY  @"bfa9e7a3-208c-4200-add4-55a5d8970e5e"
#define MY_BANNER_UNIT_ID_IPHONE5   (@"a1506f9ab471950")
#define MY_BANNER_UNIT_ID_IPHONE    (@"a14ccfafd6895cb")
#define MY_BANNER_UNIT_ID_IPAD      (@"a14fd69f029bc6d")

#endif // GTSUDOKU



#ifdef SUDOKU9
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


#define TIME_HOLDANDCHOICE	0.30
#define TIME_UNDOREPEATE	0.5
#define TIME_UNDOINTERVAL	0.05	// undo가 느리게 진행될 수 있으므로... 짧게 설정


#ifdef DEBUG
#define DLog(format, ...)				NSLog(format, ## __VA_ARGS__)
#define DAssert(condition, desc, ...)	NSAssert(condition, desc, ## __VA_ARGS__)
#else
#define DLog(format, ...)
#define DAssert(condition, desc, ...)
#endif


#define REPLAY_FRAME_INTERVAL   0.2f

#define DRAWONIMAGE_W           1000
#define DRAWONIMAGE_H           1000
#define DRAWONIMAGE_TABLE_X     10
#define DRAWONIMAGE_TABLE_Y     10
#define DRAWONIMAGE_TABLE_W     (DRAWONIMAGE_W-DRAWONIMAGE_TABLE_X*2)
#define DRAWONIMAGE_TABLE_H     (DRAWONIMAGE_H - DRAWONIMAGE_TABLE_Y*3 - DRAWONIMAGE_ICONSIZE)
#define DRAWONIMAGE_ICONSIZE    50



