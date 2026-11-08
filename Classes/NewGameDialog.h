//
//  NewGameDialog.h
//
//  「새 게임」 창 (A478) 과 「데일리 퍼즐」 창. 메뉴의 New game · 완료 창의 New game 이 새 게임 창을,
//  메뉴의 Daily puzzle 이 데일리 창을 띄운다.
//  AllSudoku(Flutter) 의 새 게임 창이 본보기다 — 종류 5가지를 그림 + 이름 + 한 줄 설명으로,
//  난이도를 따로 고르고, [시작] 으로 판을 만든다. 예전에는 그림만 있는 세그먼트 5칸과
//  난이도 단추(누르면 곧바로 시작)였다.
//
//  두 창은 **한 클래스**다 — 카드 · 종류 줄 · 난이도 단추 · [취소] [시작] 모양이 갈라지지 않게
//  (사람 2026-11-08 「UI 일관성」). 데일리 창이 다른 점:
//    - 난이도는 2개 (보통 · 매우 어려움). 서버의 데일리 퍼즐이 이 두 난이도로만 있다.
//      예전 단추 글자는 Easy · Hard 였지만 실제로 받는 판은 Normal · Very Hard 였다 —
//      글자를 실제 난이도에 맞췄다 (AllSudoku 데일리 창도 Normal · Very hard 라고 쓴다).
//    - 오늘 이미 받은 판은 「오늘 했음」 으로 표시하고, Release 에서는 [시작] 을 막는다(예전과 같은 규칙).
//    - 서버 상태(연결 중 · 연결 안 됨)와 이름 · [이름 변경] · [랭킹] 줄이 있다 — 예전 데일리 화면에 있던 것.
//    - 자동 메모 스위치가 없다 (데일리는 자동 메모를 끈 채로만 한다).
//
//  고르기만 하고 판은 만들지 않는다 — 판 만들기 · 분석(game_start) 은 MainViewController 의
//  예전 길(makeNewGame: · newgameUserInput · makeNewGameDailyPuzzle)을 그대로 탄다.
//
//  네 타깃(sudoku9free · sudoku9paid · sudoku6free · sudoku6paid) 공용. 종류 5가지는 6 · 9 가 같다.
//  이 파일은 ARC 로 컴파일한다(-fobjc-arc). 프로젝트 기본은 MRC 다.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

typedef NS_ENUM(NSInteger, NGDailyServerState) {
    NGDailyServerConnecting = 0,
    NGDailyServerReady,
    NGDailyServerOffline,
};

@interface NewGameDialog : UIViewController

/// 새 게임 창. type · level · autoMemo 를 미리 고른 채로 연다. canCancel=NO 면 [취소] 를 숨긴다(진행 중인 판이 없을 때).
- (instancetype)initWithType:(SUDOKUTYPE)type
                       level:(GAMELEVEL)level
                    autoMemo:(BOOL)autoMemo
                   canCancel:(BOOL)canCancel;

/// 데일리 퍼즐 창. level 은 GAMELEVEL_NORMAL · GAMELEVEL_VERYHARD 중 하나(아니면 보통).
/// 처음에는 「서버 연결 중」 이다 — 상태를 받으면 setDailyServerState: 로 알려 준다. [취소] 는 늘 있다.
- (instancetype)initDailyWithType:(SUDOKUTYPE)type
                            level:(GAMELEVEL)level
                         userName:(NSString *)userName;

@property (nonatomic, readonly) BOOL isDaily;

/// [시작]. 창이 닫힌 뒤 부른다. level 은 GAMELEVEL_USERINPUT(직접 입력, 일반 스도쿠만) 일 수 있다. 데일리 창은 autoMemo=NO.
@property (nonatomic, copy) void (^onStart)(SUDOKUTYPE type, GAMELEVEL level, BOOL autoMemo);
/// [취소] · 바깥 누르기. 창이 닫힌 뒤 부른다.
@property (nonatomic, copy) void (^onCancel)(void);

// ---- 데일리 창 전용 ----
/// 오늘 그 판을 이미 받았는지 (kDailyStat — 판을 받은 순간 기록된다. 다 풀었는지는 따로 남지 않는다).
@property (nonatomic, copy) BOOL (^dailyPlayed)(SUDOKUTYPE type, GAMELEVEL level);
/// YES 면 오늘 한 판도 다시 시작할 수 있다 (DEBUG · 데일리 발송 타깃). 표시는 그대로 한다.
@property (nonatomic) BOOL dailyAllowReplay;
/// [이름 변경] · [랭킹]. 창이 닫힌 뒤 부른다.
@property (nonatomic, copy) void (^onNickname)(void);
@property (nonatomic, copy) void (^onRanking)(void);
- (void)setDailyServerState:(NGDailyServerState)state;

/// DEBUG 촬영: 값이 있으면 뜨고 debugSnapshotDelay 초 뒤 앱 창을 Documents/<이름> 으로 남긴다. Release 에서는 쓰지 않는다.
@property (nonatomic, copy) NSString *debugSnapshotName;
@property (nonatomic) NSTimeInterval debugSnapshotDelay;

/// 한 줄 설명 (5개 언어). 도움말 등 다른 곳에서도 쓸 수 있게 밖에 둔다.
+ (NSString *)descriptionForType:(SUDOKUTYPE)type;

@end
