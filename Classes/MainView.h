//
//  MainView.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SudokuNum.h"
#import "SudokuGame.h"

enum ALERT_MODE {
    ALELRT_INIT = 0,
    ALELRT_BOOKMARK
};


@interface MainView : UIView {
    UIColor	*normalCellBgColor;
    UIColor	*selectedCellBgColor;
	UIColor *normalModeSelectedCellLineColor;
	UIColor *memoModeSelectedCellLineColor;
    UIColor	*normalModeGuidelineBgColor;
    UIColor	*memoModeGuidelineBgColor;
	UIColor *choosingOkCellTextColor;
	UIColor *choosingNoCellTextColor;
	UIColor *normalCellLineColor;
	UIColor *wrongCellLineColor;
	UIColor *puzzleCellTextColor;
	UIColor *inputCellTextColor;
	UIColor *normalMemoCellTextColor;
	UIColor *candidateTwoColor;
	UIColor *cellFailColor;
	UIColor *warnMemoCellTextColor;
	UIColor *conflictMemoCellTextColor;
	UIColor *numberButtonTextColor;
	UIColor *memoButtonTextColor;
	UIColor *normalButtonBgColor;
	UIColor *pressedButtonBgColor;
	
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
	UIFont *buttonSmallFont;
	UIFont *buttonBigFont;
	UIFont *buttonTextFont;
	UIFont *buttonMemoSmallFont;
	UIFont *buttonMemoBigFont;
	UIFont *buttonMemoTextFont;
	
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

    
    NSTimer		*timerTouch;

    enum ALERT_MODE alertMode;
}


@property (nonatomic, retain) UIColor *normalCellBgColor;
@property (nonatomic, retain) UIColor *selectedCellBgColor;
@property (nonatomic, retain) UIColor *normalModeSelectedCellLineColor;
@property (nonatomic, retain) UIColor *memoModeSelectedCellLineColor;

@property (nonatomic, retain) UIColor *normalModeGuidelineBgColor;
@property (nonatomic, retain) UIColor *memoModeGuidelineBgColor;
@property (nonatomic, retain) UIColor *choosingOkCellTextColor;
@property (nonatomic, retain) UIColor *choosingNoCellTextColor;

@property (nonatomic, retain) UIColor *normalCellLineColor;
@property (nonatomic, retain) UIColor *wrongCellLineColor;
@property (nonatomic, retain) UIColor *puzzleCellTextColor;
@property (nonatomic, retain) UIColor *inputCellTextColor;
@property (nonatomic, retain) UIColor *normalMemoCellTextColor;
@property (nonatomic, retain) UIColor *candidateTwoColor;
@property (nonatomic, retain) UIColor *cellFailColor;
@property (nonatomic, retain) UIColor *warnMemoCellTextColor;
@property (nonatomic, retain) UIColor *conflictMemoCellTextColor;

@property (nonatomic, retain) SudokuGame* sudokuGame;
@property (nonatomic, retain) UIColor *numberButtonTextColor;
@property (nonatomic, retain) UIColor *memoButtonTextColor;
@property (nonatomic, retain) UIColor *normalButtonBgColor;
@property (nonatomic, retain) UIColor *pressedButtonBgColor;
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

@property (nonatomic, retain) UIFont *cellOneSmallFont;
@property (nonatomic, retain) UIFont *cellOneBigFont;
@property (nonatomic, retain) UIFont *cellTwoFont;
@property (nonatomic, retain) UIFont *cellFailFont;
@property (nonatomic, retain) UIFont *cellFourFont;
@property (nonatomic, retain) UIFont *cellSixFont;
@property (nonatomic, retain) UIFont *cellNineFont;
@property (nonatomic, retain) UIFont *buttonSmallFont;
@property (nonatomic, retain) UIFont *buttonBigFont;
@property (nonatomic, retain) UIFont *buttonTextFont;
@property (nonatomic, retain) UIFont *buttonMemoSmallFont;
@property (nonatomic, retain) UIFont *buttonMemoBigFont;
@property (nonatomic, retain) UIFont *buttonMemoTextFont;

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
@end
