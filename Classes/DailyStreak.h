//
//  DailyStreak.h
//
//  데일리 퍼즐 연속 기록 · 마일스톤 (factory A468 R3, LEGACY_APPS_PLAN §1-3).
//  「매일 올 이유 · 연속이 끊기기 싫다」 — 공장 g005 A450 의 구조(3 · 7 · 14 · 30일 마일스톤 평생 한 번 ·
//  배지 · 최고 기록)를 개념만 옮겼다. 코드는 복사하지 않았다.
//
//  이 앱에는 코인이 없다 — 마일스톤 보상은 이 앱의 재화인 **힌트**(paidHintCount, 판을 넘어 남는 힌트)다.
//  「명예의 전당」 자리는 최고 연속 일수(best)다. 서버는 바꾸지 않는다 — 연속은 기기 안에서만 센다.
//
//  하루 = 데일리 퍼즐을 받을 때 쓰는 날짜 문자열(yyyyMMdd, 기기 시간대 — MainViewController getNowYYYYMMDD)과 같은 값.
//  데일리 퍼즐을 **하나라도 깬 날**이 연속에 들어간다(종류 · 난이도 상관없이, 하루 한 번만 센다).
//  어제 깼으면 +1, 오늘 이미 셌으면 그대로, 그보다 오래 비었으면 1 부터 다시.
//
//  네 타깃(sudoku9free · sudoku9paid · sudoku6free · sudoku6paid) 공용. ARC (-fobjc-arc).
//

#import <UIKit/UIKit.h>

/// 마일스톤 날 수 (오름차순). 평생 한 번씩만 받는다.
#define DS_MILESTONE_COUNT 4
extern const NSInteger kDailyStreakMilestones[DS_MILESTONE_COUNT];   // 3, 7, 14, 30

typedef struct {
    BOOL counted;            ///< 오늘 처음 깬 판이라 연속에 들어갔다 (NO 면 오늘 이미 셌다)
    NSInteger streak;        ///< 깬 뒤 연속 일수
    NSInteger best;          ///< 깬 뒤 최고 연속 일수
    NSInteger brokenFrom;    ///< 끊겨서 1 부터 다시 셀 때 끊기기 전 일수 (아니면 0)
    NSInteger milestone;     ///< 이번에 처음 닿은 마일스톤 날 수 (없으면 0)
    NSInteger rewardHints;   ///< 그 마일스톤의 힌트 보상 (없으면 0) — 부르는 쪽이 paidHintCount 에 더한다
} DSClearResult;

@interface DailyStreak : NSObject

/// 마일스톤 날 수 → 힌트 보상 (3일 3 · 7일 5 · 14일 10 · 30일 20). 마일스톤이 아니면 0.
+ (NSInteger)rewardHintsForDays:(NSInteger)days;

/// 오늘(today=yyyyMMdd) 기준으로 살아 있는 연속 일수 — 마지막으로 깬 날이 오늘이나 어제면 그 값, 아니면 0.
+ (NSInteger)aliveStreakOn:(NSString *)today;
/// 오늘 이미 데일리를 깨서 연속에 들어갔나.
+ (BOOL)clearedOn:(NSString *)today;
/// 어제까지 이어졌고 오늘 아직 안 깸 — 오늘 안 깨면 끊긴다.
+ (BOOL)atRiskOn:(NSString *)today;
+ (NSInteger)best;
/// 받은 마일스톤 비트 (kDailyStreakMilestones 의 i 번째 = 1<<i).
+ (NSInteger)earnedMask;
/// 연속 일수 다음에 오는(아직 안 받은) 마일스톤 날 수. 없으면 0.
+ (NSInteger)nextMilestoneAfter:(NSInteger)streak;

/// 데일리 퍼즐을 깼다 — 연속을 세고 저장한다. 같은 날 두 번째부터는 counted=NO (연속 · 보상 그대로).
+ (DSClearResult)recordClearOn:(NSString *)today;

#ifdef DEBUG
/// 촬영 · 시험용: 연속 상태를 바로 써 넣는다 (lastDay 가 nil 이면 지운다). Release 에 없다.
+ (void)debugSetStreak:(NSInteger)streak best:(NSInteger)best lastDay:(NSString *)lastDay earnedMask:(NSInteger)mask;
#endif

/// yyyyMMdd 하루 전 (달력 계산, 그레고리력).
+ (NSString *)dayBefore:(NSString *)day;

@end

/// 데일리 창 위쪽의 연속 띠 — 「n일 연속 · 최고 m일」, 마일스톤 칩 4개, 다음 목표 한 줄.
@interface DailyStreakView : UIView
- (instancetype)initWithToday:(NSString *)today;
@end
