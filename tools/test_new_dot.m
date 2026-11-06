//
//  test_new_dot.m — More Games 「새 게임」 점 판정(Classes/MGNewDot.h) 시험.
//
//    clang -fobjc-arc -framework Foundation -iquote Classes tools/test_new_dot.m -o /tmp/test_new_dot && /tmp/test_new_dot
//
//  규칙 정본: factory _docs/specs/MORE_GAMES.md §13 (공장 · Flutter 6 · Native 같은 규칙).
//  시계는 인자로 넣는다 — 벽시계를 안 본다. 종료 코드: 통과 0 · 실패 1.
//

#import <Foundation/Foundation.h>
#import "MGNewDot.h"

static int gBad = 0, gRan = 0;

static void check(NSString *what, BOOL got, BOOL want)
{
    gRan++;
    if (got == want) return;
    gBad++;
    fprintf(stderr, "  실패: %s (got %d, want %d)\n", what.UTF8String, got, want);
}

/// 오늘(2026-11-06 15:00, 기기 시간대) — 시험의 시계.
static NSDate *Today(void)
{
    NSDateComponents *c = [NSDateComponents new];
    c.year = 2026; c.month = 11; c.day = 6; c.hour = 15;
    return [[NSCalendar currentCalendar] dateFromComponents:c];
}

/// 2026-11-06 에서 n 일 전의 "YYYY-MM-DD" 를 읽은 날짜.
static NSDate *DaysAgo(NSInteger n)
{
    NSDate *base = MGParseReleased(@"2026-11-06");
    return [MGUTCCalendar() dateByAddingUnit:NSCalendarUnitDay value:-n toDate:base options:0];
}

int main(void)
{
    @autoreleasepool {
        NSDate *now = Today();
        check(@"30일은 상수 하나", kMGNewDays == 30, YES);
        check(@"29일 → 점", MGHasNewApps(@{@"a": DaysAgo(29)}, [NSSet set], now), YES);
        check(@"31일 → 점 없음", MGHasNewApps(@{@"a": DaysAgo(31)}, [NSSet set], now), NO);
        check(@"30일째(경계) → 점", MGHasNewApps(@{@"a": DaysAgo(30)}, [NSSet set], now), YES);
        check(@"출시일이 없으면 점 없음", MGHasNewApps(@{@"a": [NSNull null], @"b": DaysAgo(400)}, [NSSet set], now), NO);
        check(@"첫 설치(본 것 nil) + 최근 출시 → 점", MGHasNewApps(@{@"a": DaysAgo(3), @"b": DaysAgo(900)}, nil, now), YES);
        NSDictionary *live = @{@"a": DaysAgo(900), @"c": DaysAgo(2)};
        check(@"열기 전 → 점", MGHasNewApps(live, [NSSet set], now), YES);
        check(@"열면(본 것에 더함) 꺼짐", MGHasNewApps(live, [NSSet setWithArray:live.allKeys], now), NO);
        // 시계를 31일째로 넘기면 저절로 꺼진다.
        NSDate *later = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:31 toDate:now options:0];
        check(@"31일째 시계 → 꺼짐", MGHasNewApps(@{@"a": DaysAgo(0)}, nil, later), NO);
        // 날짜 모양
        check(@"모양 — YYYY-MM-DD", MGParseReleased(@"2026-11-03") != nil, YES);
        check(@"모양 — 슬래시는 버린다", MGParseReleased(@"2026/11/03") != nil, NO);
        check(@"모양 — 없는 날(02-30)은 버린다", MGParseReleased(@"2026-02-30") != nil, NO);
        check(@"모양 — 숫자는 버린다", MGParseReleased(@20261103) != nil, NO);
    }
    if (gBad) {
        fprintf(stderr, "test_new_dot: %d/%d 실패\n", gBad, gRan);
        return 1;
    }
    printf("test_new_dot: %d/%d OK\n", gRan, gRan);
    return 0;
}
