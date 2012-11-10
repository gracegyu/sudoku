//
//  MainView.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "JMCCustomDataSource.h"
#import "SudokuNum.h"
#import "SudokuGame.h"

enum ALERT_MODE {
    ALELRT_INIT = 0,
    ALELRT_BOOKMARK
};

typedef enum ALERT_MODE ALERT_MODE;

enum SKINCOLOR
{
	SC_BACKGROUND_VIEW = 0,
	SC_BACKGROUND_NORMAL_CELL,
	SC_BACKGROUND_SELECTED_CELL,
	SC_BACKGROUND_GUIDELINE_NORMAL,
	SC_BACKGROUND_GUIDELINE_MEMO,
	
	SC_LINE_CELL_NORMAL,
	SC_LINE_CELL_WRONG,
	SC_LINE_CELL_KILLER,
	SC_LINE_SECLECTED_CELL_NORMAL,
	SC_LINE_SECLECTED_CELL_MEMO,
	
	SC_TEXT_CELL_PUZZLE,
	SC_TEXT_CELL_INPUT,
	SC_TEXT_CELL_CHOOSING_OK,
	SC_TEXT_CELL_MEMO_OK,
	SC_TEXT_CELL_MEMO_WARN,
	SC_TEXT_CELL_MEMO_CONFLICT,
	SC_TEXT_CELL_KILLER_SUM,
	
	SC_BACKGROUND_BUTTON_NORMAL,
	SC_BACKGROUND_BUTTON_PRESSED,
	SC_BACKGROUND_BUTTON_MEMO_NORMAL,
	SC_BACKGROUND_BUTTON_MEMO_PRESSED,
	SC_TEXT_BUTTON_NUMBER,
	SC_TEXT_BUTTON_MEMO,
	
	COUNT_SKINCOLOR,
};


typedef enum SKINCOLOR SKINCOLOR;

@interface MainView : UIView  {
	NSInteger skin;
	UIColor *skincolor[COUNT_SKINCOLOR];
	UIColor *rainbowcolor[7];
	
	SudokuGame* sudokuGame;
	
	NSInteger selectedXPos;
	NSInteger selectedYPos;
	NSInteger pushedButton;
	BOOL bTouch;
	BOOL bPressedInButton;
	BOOL bPressedInCell;
    NSInteger pressedButtonNum;
	
	
	UIFont *cellOneSmallFont;
	UIFont *cellOneBigFont;
	UIFont *cellFailFont;
	UIFont *cellTwoFont;
	UIFont *cellFourFont;
	UIFont *cellSixFont;
	UIFont *cellNineFont;
	UIFont *cellBookmarkFont;
	UIFont *cellSumFont;
	UIFont *cellWrongSumFont;
	UIFont *buttonSmallFont;
	UIFont *buttonBigFont;
	//UIFont *buttonTextFont;
	UIFont *buttonMemoSmallFont;
	UIFont *buttonMemoBigFont;
	//UIFont *buttonMemoTextFont;
	
    SystemSoundID   soundClickID;	
    SystemSoundID   soundClearID;	
    SystemSoundID   soundFailID;	
	
	BOOL bFailCell;
	BOOL bSetThisTime;
	BOOL bMemoMode;
	BOOL bMenuMode;
	BOOL bDupWarn;						// 중복된 번호를 경고 할까요?
    BOOL bHoldAndChoice;

	BOOL bSettingSoundOff;						// 소리를 켤까요?
    BOOL bSettingGuideline;
    BOOL bSettingDuplicationWarning;
    BOOL bSettingMarkingEqual;
    BOOL bSettingDefMap;
    BOOL bSettingAutoMemo;
    SUDOKUTYPE nSettingSudokuType;            // 0~3
    BOOL bDrawOnImage;
    CGRect      frameDrawOnImage;

    
    NSTimer		*timerTouch;

    enum ALERT_MODE alertMode;
	BOOL bBlur;
    
}


@property (nonatomic, retain) SudokuGame* sudokuGame;
@property NSInteger selectedXPos;
@property NSInteger selectedYPos;
@property NSInteger pushedButton;
@property BOOL bTouch;
@property BOOL bPressedInButton;
@property BOOL bPressedInCell;
@property BOOL bMemoMode;
@property BOOL bMenuMode;
@property BOOL bDupWarn;	
@property BOOL bSettingSoundOff;
@property BOOL bSettingGuideline;
@property BOOL bSettingDuplicationWarning;
@property BOOL bSettingMarkingEqual;
@property BOOL bSettingDefMap;
@property BOOL bSettingAutoMemo;
@property SUDOKUTYPE nSettingSudokuType;

@property (nonatomic, retain) UIFont *cellOneSmallFont;
@property (nonatomic, retain) UIFont *cellOneBigFont;
@property (nonatomic, retain) UIFont *cellTwoFont;
@property (nonatomic, retain) UIFont *cellFailFont;
@property (nonatomic, retain) UIFont *cellFourFont;
@property (nonatomic, retain) UIFont *cellSixFont;
@property (nonatomic, retain) UIFont *cellNineFont;
@property (nonatomic, retain) UIFont *cellBookmarkFont;
@property (nonatomic, retain) UIFont *cellSumFont;
@property (nonatomic, retain) UIFont *cellWrongSumFont;
@property (nonatomic, retain) UIFont *buttonSmallFont;
@property (nonatomic, retain) UIFont *buttonBigFont;
//@property (nonatomic, retain) UIFont *buttonTextFont;
@property (nonatomic, retain) UIFont *buttonMemoSmallFont;
@property (nonatomic, retain) UIFont *buttonMemoBigFont;
//@property (nonatomic, retain) UIFont *buttonMemoTextFont;

//@property UIInterfaceOrientation	lastOrientation;

- (void) runUndo;
- (void) runRedo;
- (void) runBookmark;
- (BOOL) memoOnOff;
- (void) delNumber;
- (void) clearNumbers;
- (void) doHint;



- (void) newGame:(NSInteger)level size:(NSInteger)sizePuzzle;

- (BOOL) loadGame;
- (void) checkClearGame;
- (BOOL) isSelectedCellisFixed;
- (BOOL) isSelectedCellisableHint;
- (void) setFont;
- (void) playSound:(SystemSoundID) inSystemSoundID;
- (void) playSoundClick;
- (void) setBlur:(BOOL)blur;
- (BOOL) runRedo4Replay;
- (void) drawOnImage:(CGContextRef) context strTime:(NSString*) strTime;
@end
