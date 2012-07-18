//
//  MainView.h
//  SudokuHelper
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SudokuNum.h"
#import "SudokuGame.h"

@interface MainView : UIView {
    UIColor	*tableBgColor;
    UIColor	*selectedTableBgColor;
	UIColor *selectedTableBorderColor;
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
	
	
	UIFont *cellOneSmallFont;
	UIFont *cellOneBigFont;
	UIFont *cellFailFont;
	UIFont *cellTwoFont;
	UIFont *cellFourFont;
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
	BOOL bSoundOn;						// 소리를 켤까요?
	
	CGRect	rectLandscape;
	CGRect	rectPortrait;
	CGRect	rectCurrent;
	UIInterfaceOrientation	lastOrientation;
	CGFloat	fTableWidth;	
	CGFloat	fButtonStart;	
	
	CGFloat	fPress;
}


@property (nonatomic, retain) UIColor *tableBgColor;
@property (nonatomic, retain) UIColor *selectedTableBgColor;
@property (nonatomic, retain) UIColor *selectedTableBorderColor;
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
@property BOOL bSoundOn;


@property (nonatomic, retain) UIFont *cellOneSmallFont;
@property (nonatomic, retain) UIFont *cellOneBigFont;
@property (nonatomic, retain) UIFont *cellTwoFont;
@property (nonatomic, retain) UIFont *cellFailFont;
@property (nonatomic, retain) UIFont *cellFourFont;
@property (nonatomic, retain) UIFont *cellNineFont;
@property (nonatomic, retain) UIFont *buttonSmallFont;
@property (nonatomic, retain) UIFont *buttonBigFont;
@property (nonatomic, retain) UIFont *buttonTextFont;
@property (nonatomic, retain) UIFont *buttonMemoSmallFont;
@property (nonatomic, retain) UIFont *buttonMemoBigFont;
@property (nonatomic, retain) UIFont *buttonMemoTextFont;

@property CGRect	rectLandscape;
@property CGRect	rectPortrait;
@property CGRect	rectCurrent;
@property UIInterfaceOrientation	lastOrientation;
@property CGFloat	fTableWidth;
@property CGFloat	fButtonStart;
@property CGFloat	fPress;

- (void) runUndo;
- (BOOL) memoOnOff;
- (void) delNumber;
- (void) clearNumbers;
- (void) doHint;


- (void) newGame:(NSInteger)level;
- (BOOL) loadGame;
- (void) checkClearGame;
- (BOOL) selectedCellisFixed;
- (BOOL) selectedCellisableHint;
- (void) setFont;
@end
