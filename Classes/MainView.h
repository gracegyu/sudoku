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

@interface MainView : UIView {
    UIColor	*tableBgColor;
    UIColor	*selectedTableBgColor;
	UIColor *selectedCellBorderColor;
	UIColor *selectedMemoModeCellBorderColor;
    UIColor	*HintBgColor;
    UIColor	*MemoModeHintBgColor;
	UIColor *choosingOkColor;
	UIColor *choosingNoColor;
	UIColor *tableLineColor;
	UIColor *fixedByUserColor;
	UIColor *fixedByAutoColor;
	UIColor *candidateColor;
	UIColor *candidateTwoColor;
	UIColor *cellFailColor;
	UIColor *cellWarnColor;
	UIColor *cellConflictColor;
	UIColor *numButtonColor;
	UIColor *memoButtonColor;
	UIColor *bgButtonColor;
	UIColor *pressedButtonColor;
	
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

    
    NSTimer		*timerTouch;

}


@property (nonatomic, retain) UIColor *tableBgColor;
@property (nonatomic, retain) UIColor *selectedTableBgColor;
@property (nonatomic, retain) UIColor *selectedCellBorderColor;
@property (nonatomic, retain) UIColor *selectedMemoModeCellBorderColor;

@property (nonatomic, retain) UIColor *HintBgColor;
@property (nonatomic, retain) UIColor *MemoModeHintBgColor;
@property (nonatomic, retain) UIColor *choosingOkColor;
@property (nonatomic, retain) UIColor *choosingNoColor;

@property (nonatomic, retain) UIColor *tableLineColor;
@property (nonatomic, retain) UIColor *fixedByUserColor;
@property (nonatomic, retain) UIColor *fixedByAutoColor;
@property (nonatomic, retain) UIColor *candidateColor;
@property (nonatomic, retain) UIColor *candidateTwoColor;
@property (nonatomic, retain) UIColor *cellFailColor;
@property (nonatomic, retain) UIColor *cellWarnColor;
@property (nonatomic, retain) UIColor *cellConflictColor;

@property (nonatomic, retain) SudokuGame* sudokuGame;
@property (nonatomic, retain) UIColor *numButtonColor;
@property (nonatomic, retain) UIColor *memoButtonColor;
@property (nonatomic, retain) UIColor *bgButtonColor;
@property (nonatomic, retain) UIColor *pressedButtonColor;
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
