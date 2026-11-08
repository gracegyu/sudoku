//
//  NewGameDialog.h
//
//  「새 게임」 창 (A478). 메뉴의 New game · 완료 창의 New game 이 이 창을 띄운다.
//  AllSudoku(Flutter) 의 새 게임 창이 본보기다 — 종류 5가지를 그림 + 이름 + 한 줄 설명으로,
//  난이도를 따로 고르고, [시작] 으로 판을 만든다. 예전에는 그림만 있는 세그먼트 5칸과
//  난이도 단추(누르면 곧바로 시작)였다.
//
//  고르기만 하고 판은 만들지 않는다 — 판 만들기 · 분석(game_start) 은 MainViewController 의
//  예전 길(makeNewGame: · newgameUserInput)을 그대로 탄다.
//
//  네 타깃(sudoku9free · sudoku9paid · sudoku6free · sudoku6paid) 공용. 종류 5가지는 6 · 9 가 같다.
//  이 파일은 ARC 로 컴파일한다(-fobjc-arc). 프로젝트 기본은 MRC 다.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface NewGameDialog : UIViewController

/// type · level · autoMemo 를 미리 고른 채로 연다. canCancel=NO 면 [취소] 를 숨긴다(진행 중인 판이 없을 때).
- (instancetype)initWithType:(SUDOKUTYPE)type
                       level:(GAMELEVEL)level
                    autoMemo:(BOOL)autoMemo
                   canCancel:(BOOL)canCancel;

/// [시작]. 창이 닫힌 뒤 부른다. level 은 GAMELEVEL_USERINPUT(직접 입력, 일반 스도쿠만) 일 수 있다.
@property (nonatomic, copy) void (^onStart)(SUDOKUTYPE type, GAMELEVEL level, BOOL autoMemo);
/// [취소] · 바깥 누르기. 창이 닫힌 뒤 부른다.
@property (nonatomic, copy) void (^onCancel)(void);

/// 한 줄 설명 (5개 언어). 도움말 등 다른 곳에서도 쓸 수 있게 밖에 둔다.
+ (NSString *)descriptionForType:(SUDOKUTYPE)type;

@end
