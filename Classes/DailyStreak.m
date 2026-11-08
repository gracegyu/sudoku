//
//  DailyStreak.m
//
//  설명은 DailyStreak.h. ARC (-fobjc-arc).
//

#import "DailyStreak.h"
#import "Locale.h"

const NSInteger kDailyStreakMilestones[DS_MILESTONE_COUNT] = { 3, 7, 14, 30 };
static const NSInteger kDailyStreakRewards[DS_MILESTONE_COUNT] = { 3, 5, 10, 20 };

// NSUserDefaults 열쇠 — 예전 kDailyStat(오늘 받은 판)과 따로 둔다. 그쪽은 날이 바뀌면 지워진다.
static NSString *const kDSLastDay = @"dailyStreak.lastDay";   // 마지막으로 연속에 들어간 날 yyyyMMdd
static NSString *const kDSCount   = @"dailyStreak.count";     // 그날까지의 연속 일수
static NSString *const kDSBest    = @"dailyStreak.best";      // 최고 연속 일수
static NSString *const kDSEarned  = @"dailyStreak.earned";    // 받은 마일스톤 비트

#define DS_ORANGE      [UIColor colorWithRed:0.90 green:0.42 blue:0.08 alpha:1]
#define DS_ORANGE_BG   [UIColor colorWithRed:1.00 green:0.95 blue:0.88 alpha:1]
#define DS_INK         [UIColor colorWithRed:0.055 green:0.198 blue:0.458 alpha:1]
#define DS_SUB         [UIColor colorWithRed:0.32 green:0.36 blue:0.44 alpha:1]
#define DS_LINE        [UIColor colorWithRed:0.86 green:0.80 blue:0.72 alpha:1]

@implementation DailyStreak

+ (NSDateFormatter *)dayFormatter
{
    static NSDateFormatter *f;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        f = [NSDateFormatter new];
        f.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        f.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        f.timeZone = [NSTimeZone localTimeZone];
        f.dateFormat = @"yyyyMMdd";
    });
    return f;
}

+ (NSString *)dayBefore:(NSString *)day
{
    if (day.length != 8) return @"";
    NSDateFormatter *f = [self dayFormatter];
    // 정오로 잡아 서머타임 경계에서 날이 밀리지 않게 한다
    NSDate *d = [f dateFromString:day];
    if (!d) return @"";
    NSCalendar *cal = f.calendar;
    NSDate *noon = [cal dateBySettingHour:12 minute:0 second:0 ofDate:d options:0] ?: d;
    NSDate *prev = [cal dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:noon options:0];
    return prev ? [f stringFromDate:prev] : @"";
}

+ (NSString *)lastDay { return [[NSUserDefaults standardUserDefaults] stringForKey:kDSLastDay] ?: @""; }
+ (NSInteger)count    { return [[NSUserDefaults standardUserDefaults] integerForKey:kDSCount]; }
+ (NSInteger)best     { return [[NSUserDefaults standardUserDefaults] integerForKey:kDSBest]; }
+ (NSInteger)earnedMask { return [[NSUserDefaults standardUserDefaults] integerForKey:kDSEarned]; }

+ (NSInteger)rewardHintsForDays:(NSInteger)days
{
    for (int i = 0; i < DS_MILESTONE_COUNT; i++)
        if (kDailyStreakMilestones[i] == days) return kDailyStreakRewards[i];
    return 0;
}

+ (BOOL)clearedOn:(NSString *)today
{
    return today.length && [[self lastDay] isEqualToString:today];
}

+ (BOOL)atRiskOn:(NSString *)today
{
    return [self count] > 0 && [[self lastDay] isEqualToString:[self dayBefore:today]];
}

+ (NSInteger)aliveStreakOn:(NSString *)today
{
    if ([self clearedOn:today] || [self atRiskOn:today]) return [self count];
    return 0;
}

+ (NSInteger)nextMilestoneAfter:(NSInteger)streak
{
    NSInteger mask = [self earnedMask];
    for (int i = 0; i < DS_MILESTONE_COUNT; i++)
        if (kDailyStreakMilestones[i] > streak && !(mask & (1 << i))) return kDailyStreakMilestones[i];
    return 0;
}

+ (DSClearResult)recordClearOn:(NSString *)today
{
    DSClearResult r = { NO, 0, 0, 0, 0, 0 };
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (today.length != 8) { r.streak = [self count]; r.best = [self best]; return r; }

    if ([self clearedOn:today]) {   // 오늘 이미 셌다 — 그대로
        r.streak = [self count];
        r.best = [self best];
        return r;
    }
    NSInteger was = [self count];
    NSInteger now;
    if (was > 0 && [[self lastDay] isEqualToString:[self dayBefore:today]]) {
        now = was + 1;
    } else {
        now = 1;
        r.brokenFrom = [self lastDay].length ? was : 0;   // 처음 시작은 「끊김」 이 아니다
    }
    NSInteger best = MAX([self best], now);
    NSInteger mask = [self earnedMask];
    for (int i = 0; i < DS_MILESTONE_COUNT; i++) {
        if (kDailyStreakMilestones[i] == now && !(mask & (1 << i))) {
            mask |= (1 << i);
            r.milestone = now;
            r.rewardHints = kDailyStreakRewards[i];
        }
    }
    [d setObject:today forKey:kDSLastDay];
    [d setInteger:now forKey:kDSCount];
    [d setInteger:best forKey:kDSBest];
    [d setInteger:mask forKey:kDSEarned];
    [d synchronize];

    r.counted = YES;
    r.streak = now;
    r.best = best;
    return r;
}

#ifdef DEBUG
+ (void)debugSetStreak:(NSInteger)streak best:(NSInteger)best lastDay:(NSString *)lastDay earnedMask:(NSInteger)mask
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (lastDay.length) [d setObject:lastDay forKey:kDSLastDay]; else [d removeObjectForKey:kDSLastDay];
    [d setInteger:streak forKey:kDSCount];
    [d setInteger:best forKey:kDSBest];
    [d setInteger:mask forKey:kDSEarned];
    [d synchronize];
}
#endif

@end


@implementation DailyStreakView

static UIFont *DSFont(CGFloat size, BOOL bold)
{
    UIFont *f = [UIFont fontWithName:(bold ? @"TrebuchetMS-Bold" : @"TrebuchetMS") size:size];
    return f ?: (bold ? [UIFont boldSystemFontOfSize:size] : [UIFont systemFontOfSize:size]);
}

- (UIView *)chipForIndex:(int)i streak:(NSInteger)streak earned:(BOOL)earned
{
    UIView *chip = [UIView new];
    chip.layer.cornerRadius = 9;
    chip.layer.borderWidth = 1.5;
    chip.backgroundColor = earned ? DS_ORANGE : UIColor.whiteColor;
    chip.layer.borderColor = (earned ? DS_ORANGE : DS_LINE).CGColor;

    UILabel *days = [UILabel new];
    days.text = [NSString stringWithFormat:@"%@%@", earned ? @"✓ " : @"",
                 [NSString stringWithFormat:gettext(@"streak.chip.days", nil), (int)kDailyStreakMilestones[i]]];
    days.font = DSFont(13, YES);
    days.textColor = earned ? UIColor.whiteColor : DS_INK;
    days.textAlignment = NSTextAlignmentCenter;
    days.adjustsFontSizeToFitWidth = YES;
    days.minimumScaleFactor = 0.6;

    UILabel *reward = [UILabel new];
    reward.text = [NSString stringWithFormat:gettext(@"streak.chip.reward", nil), (int)kDailyStreakRewards[i]];
    reward.font = [UIFont systemFontOfSize:11];
    reward.textColor = earned ? [UIColor colorWithWhite:1 alpha:0.9] : DS_SUB;
    reward.textAlignment = NSTextAlignmentCenter;
    reward.adjustsFontSizeToFitWidth = YES;
    reward.minimumScaleFactor = 0.6;

    UIStackView *s = [[UIStackView alloc] initWithArrangedSubviews:@[days, reward]];
    s.axis = UILayoutConstraintAxisVertical;
    s.spacing = 0;
    s.translatesAutoresizingMaskIntoConstraints = NO;
    [chip addSubview:s];
    [NSLayoutConstraint activateConstraints:@[
        [s.topAnchor constraintEqualToAnchor:chip.topAnchor constant:4],
        [s.bottomAnchor constraintEqualToAnchor:chip.bottomAnchor constant:-4],
        [s.leadingAnchor constraintEqualToAnchor:chip.leadingAnchor constant:3],
        [s.trailingAnchor constraintEqualToAnchor:chip.trailingAnchor constant:-3],
    ]];
    chip.isAccessibilityElement = YES;
    chip.accessibilityLabel = [NSString stringWithFormat:@"%@ %@%@", days.text, reward.text,
                               earned ? [@" " stringByAppendingString:gettext(@"streak.chip.earned", nil)] : @""];
    return chip;
}

- (instancetype)initWithToday:(NSString *)today
{
    if ((self = [super initWithFrame:CGRectZero])) {
        NSInteger streak = [DailyStreak aliveStreakOn:today];
        NSInteger best = [DailyStreak best];
        BOOL doneToday = [DailyStreak clearedOn:today];
        NSInteger mask = [DailyStreak earnedMask];

        self.backgroundColor = DS_ORANGE_BG;
        self.layer.cornerRadius = 12;
        self.accessibilityIdentifier = @"daily-streak";

        UIImageView *flame = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"flame.fill"]];
        flame.tintColor = streak > 0 ? DS_ORANGE : DS_LINE;
        flame.contentMode = UIViewContentModeScaleAspectFit;
        [flame.widthAnchor constraintEqualToConstant:22].active = YES;
        [flame.heightAnchor constraintEqualToConstant:22].active = YES;

        UILabel *title = [UILabel new];
        title.text = streak > 0 ? [NSString stringWithFormat:gettext(@"streak.title", nil), (int)streak]
                                : gettext(@"streak.title.none", nil);
        title.font = DSFont(17, YES);
        title.textColor = streak > 0 ? DS_ORANGE : DS_INK;
        title.adjustsFontSizeToFitWidth = YES;
        title.minimumScaleFactor = 0.7;
        title.accessibilityIdentifier = @"daily-streak-title";

        UILabel *bestL = [UILabel new];
        bestL.text = [NSString stringWithFormat:gettext(@"streak.best", nil), (int)best];
        bestL.font = DSFont(13, YES);
        bestL.textColor = DS_SUB;
        [bestL setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [bestL setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

        UIStackView *top = [[UIStackView alloc] initWithArrangedSubviews:@[flame, title, bestL]];
        top.axis = UILayoutConstraintAxisHorizontal;
        top.alignment = UIStackViewAlignmentCenter;
        top.spacing = 6;

        UIStackView *chips = [UIStackView new];
        chips.axis = UILayoutConstraintAxisHorizontal;
        chips.distribution = UIStackViewDistributionFillEqually;
        chips.spacing = 6;
        for (int i = 0; i < DS_MILESTONE_COUNT; i++)
            [chips addArrangedSubview:[self chipForIndex:i streak:streak earned:(mask & (1 << i)) != 0]];

        // 다음 목표 한 줄
        NSString *note;
        if (doneToday) {
            note = gettext(@"streak.note.done", nil);
        } else if (streak == 0) {
            note = gettext(@"streak.note.start", nil);
        } else {
            NSInteger target = streak + 1;
            NSInteger reward = 0;
            for (int i = 0; i < DS_MILESTONE_COUNT; i++)
                if (kDailyStreakMilestones[i] == target && !(mask & (1 << i))) reward = kDailyStreakRewards[i];
            note = reward > 0
                ? [NSString stringWithFormat:gettext(@"streak.note.next.reward", nil), (int)target, (int)reward]
                : [NSString stringWithFormat:gettext(@"streak.note.next", nil), (int)target];
        }
        UILabel *noteL = [UILabel new];
        noteL.text = note;
        noteL.font = [UIFont systemFontOfSize:12.5];
        noteL.textColor = DS_SUB;
        noteL.numberOfLines = 0;
        noteL.textAlignment = NSTextAlignmentCenter;
        noteL.accessibilityIdentifier = @"daily-streak-note";

        UIStackView *all = [[UIStackView alloc] initWithArrangedSubviews:@[top, chips, noteL]];
        all.axis = UILayoutConstraintAxisVertical;
        all.spacing = 7;
        all.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:all];
        [NSLayoutConstraint activateConstraints:@[
            [all.topAnchor constraintEqualToAnchor:self.topAnchor constant:9],
            [all.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-9],
            [all.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
            [all.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
        ]];
    }
    return self;
}

@end
