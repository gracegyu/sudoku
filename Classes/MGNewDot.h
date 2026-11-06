//
//  MGNewDot.h
//
//  More Games 「새 게임」 빨간 점의 판정 — 공장(factory) ga_ui more_games_new_dot.dart ·
//  Flutter 6앱 lib/more_games/more_games_new_dot.dart 와 같은 규칙이다
//  (정본 factory _docs/specs/MORE_GAMES.md §13, 사람 결정 2026-11-06).
//
//    점 = 「iOS 출시일(games.json 줄의 ios.released, "YYYY-MM-DD")이 오늘로부터
//         kMGNewDays 일 이내(같은 날 포함, 날짜만 비교)」인 줄 중
//         「사용자가 More Games 에서 본 적 없는 id」가 하나라도 있다.
//
//  - 출시일이 없거나 모양이 틀리면 새 게임이 아니다.
//  - 첫 설치도 같은 규칙이다(본 것이 비어 있다). 예전에는 첫 목록을 「본 것」으로 두었다.
//  - 시계는 인자(now)로 받는다 — tools/test_new_dot.m 이 벽시계를 안 보고 잰다.
//
//  Foundation 만 쓴다. sudoku2 · tetrasquare 두 저장소에 같은 파일이 있다.
//

#import <Foundation/Foundation.h>

/// 「새 게임」으로 치는 날 수 — 출시일로부터 이 날 수 이내(같은 날 포함)면 새것이다.
static const NSInteger kMGNewDays = 30;

static inline NSCalendar *MGUTCCalendar(void)
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    cal.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    return cal;
}

/// "YYYY-MM-DD" → 그날 UTC 자정. 모양이 틀리거나 없는 날(2026-02-30)이면 nil.
static inline NSDate *MGParseReleased(id value)
{
    if (![value isKindOfClass:[NSString class]]) return nil;
    NSString *s = value;
    if (s.length != 10 || [s characterAtIndex:4] != '-' || [s characterAtIndex:7] != '-') return nil;
    NSCharacterSet *notDigit = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *y = [s substringWithRange:NSMakeRange(0, 4)];
    NSString *m = [s substringWithRange:NSMakeRange(5, 2)];
    NSString *d = [s substringWithRange:NSMakeRange(8, 2)];
    for (NSString *part in @[y, m, d])
        if ([part rangeOfCharacterFromSet:notDigit].location != NSNotFound) return nil;
    NSDateComponents *c = [NSDateComponents new];
    c.year = y.integerValue;
    c.month = m.integerValue;
    c.day = d.integerValue;
    NSCalendar *utc = MGUTCCalendar();
    NSDate *date = [utc dateFromComponents:c];
    if (!date) return nil;
    NSDateComponents *back = [utc components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    if (back.year != c.year || back.month != c.month || back.day != c.day) return nil;
    return date;
}

/// released 가 now(기기 시간대의 오늘) 기준 kMGNewDays 일 이내인가.
static inline BOOL MGIsFresh(NSDate *released, NSDate *now)
{
    if (!released || !now) return NO;
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                              fromDate:now];
    NSCalendar *utc = MGUTCCalendar();
    NSDate *todayUTC = [utc dateFromComponents:today];
    NSInteger days = [utc components:NSCalendarUnitDay fromDate:released toDate:todayUTC options:0].day;
    return days <= kMGNewDays;
}

/// releasedById(id → NSDate, 모르면 NSNull) 중 새 게임인 id.
static inline NSSet<NSString *> *MGFreshIds(NSDictionary<NSString *, id> *releasedById, NSDate *now)
{
    NSMutableSet *out = [NSMutableSet set];
    [releasedById enumerateKeysAndObjectsUsingBlock:^(NSString *gid, id released, BOOL *stop) {
        if ([released isKindOfClass:[NSDate class]] && MGIsFresh(released, now)) [out addObject:gid];
    }];
    return out;
}

/// 점을 켤까 — 새 게임 중 seen(nil = 아직 한 번도 안 열었다 = 빈 집합)에 없는 id 가 있나.
static inline BOOL MGHasNewApps(NSDictionary<NSString *, id> *releasedById, NSSet<NSString *> *seen, NSDate *now)
{
    NSMutableSet *fresh = [MGFreshIds(releasedById, now) mutableCopy];
    if (seen) [fresh minusSet:seen];
    return fresh.count > 0;
}
