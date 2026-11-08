//
//  FirstSessionCard.m
//
//  설명은 FirstSessionCard.h. 모양은 새 게임 창(NewGameDialog)과 같은 카드 · 단추 꼴이다. ARC (-fobjc-arc).
//

#import "FirstSessionCard.h"
#import "Locale.h"

#define FS_INK   [UIColor colorWithRed:0.055 green:0.198 blue:0.458 alpha:1]
#define FS_SUB   [UIColor colorWithRed:0.32 green:0.36 blue:0.44 alpha:1]
#define FS_LINE  [UIColor colorWithRed:0.80 green:0.83 blue:0.88 alpha:1]

static UIFont *FSFont(CGFloat size, BOOL bold)
{
    UIFont *f = [UIFont fontWithName:(bold ? @"TrebuchetMS-Bold" : @"TrebuchetMS") size:size];
    return f ?: (bold ? [UIFont boldSystemFontOfSize:size] : [UIFont systemFontOfSize:size]);
}

@implementation FirstSessionCard {
    NSString *_levelName;
}

- (instancetype)initWithFirstLevelName:(NSString *)firstLevelName
{
    if ((self = [super initWithFrame:CGRectZero])) {
        _levelName = [firstLevelName copy] ?: @"";
        [self build];
    }
    return self;
}

- (UILabel *)line:(NSString *)text font:(UIFont *)font color:(UIColor *)color
{
    UILabel *l = [UILabel new];
    l.text = text;
    l.font = font;
    l.textColor = color;
    l.numberOfLines = 0;
    l.textAlignment = NSTextAlignmentCenter;
    return l;
}

- (UIButton *)button:(NSString *)title primary:(BOOL)primary action:(SEL)action
{
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setTitle:title forState:UIControlStateNormal];
    b.titleLabel.font = FSFont(17, YES);
    b.titleLabel.adjustsFontSizeToFitWidth = YES;
    b.titleLabel.minimumScaleFactor = 0.6;
    b.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    b.layer.cornerRadius = 12;
    if (primary) {
        b.backgroundColor = FS_INK;
        [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    } else {
        b.backgroundColor = UIColor.whiteColor;
        b.layer.borderWidth = 2;
        b.layer.borderColor = FS_LINE.CGColor;
        [b setTitleColor:FS_INK forState:UIControlStateNormal];
    }
    [b.heightAnchor constraintEqualToConstant:48].active = YES;
    [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return b;
}

- (void)build
{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    self.accessibilityIdentifier = @"first-session-card";
    self.accessibilityViewIsModal = YES;

    UIView *card = [UIView new];
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 22;
    card.clipsToBounds = YES;
    card.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:card];

#ifdef SUDOKU9
    NSString *imgName = @"help9_1_iphone";
    NSString *rule = gettext(@"first.rule9", nil);
#else
    NSString *imgName = @"help6_1_iphone";
    NSString *rule = gettext(@"first.rule6", nil);
#endif
    UILabel *title = [self line:gettext(@"first.title", nil) font:FSFont(22, YES) color:FS_INK];

    UIImageView *pic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    pic.contentMode = UIViewContentModeScaleAspectFit;
    // 그림은 500 × 380
    [pic.heightAnchor constraintEqualToAnchor:pic.widthAnchor multiplier:380.0 / 500.0].active = YES;

    UILabel *ruleL  = [self line:rule font:FSFont(16, YES) color:FS_INK];
    UILabel *inputL = [self line:gettext(@"first.input", nil) font:[UIFont systemFontOfSize:14] color:FS_SUB];
    UILabel *firstL = [self line:[NSString stringWithFormat:gettext(@"first.easy", nil), _levelName]
                            font:[UIFont systemFontOfSize:14] color:FS_SUB];
    ruleL.accessibilityIdentifier = @"first-session-rule";

    UIStackView *content = [[UIStackView alloc] initWithArrangedSubviews:@[pic, ruleL, inputL, firstL]];
    content.axis = UILayoutConstraintAxisVertical;
    content.spacing = 8;
    [content setCustomSpacing:12 afterView:pic];
    content.translatesAutoresizingMaskIntoConstraints = NO;

    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:content];
    [card addSubview:scroll];

    title.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:title];

    UIButton *skip = [self button:gettext(@"first.skip", nil) primary:NO action:@selector(skipTapped)];
    skip.accessibilityIdentifier = @"first-session-skip";
    UIButton *start = [self button:gettext(@"first.start", nil) primary:YES action:@selector(startTapped)];
    start.accessibilityIdentifier = @"first-session-start";
    UIStackView *footer = [[UIStackView alloc] initWithArrangedSubviews:@[skip, start]];
    footer.axis = UILayoutConstraintAxisHorizontal;
    footer.distribution = UIStackViewDistributionFillEqually;
    footer.spacing = 10;
    footer.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:footer];

    UILayoutGuide *safe = self.safeAreaLayoutGuide;
    NSLayoutConstraint *wantWidth = [card.widthAnchor constraintEqualToAnchor:safe.widthAnchor constant:-32];
    wantWidth.priority = UILayoutPriorityDefaultHigh;
    NSLayoutConstraint *fitHeight = [scroll.heightAnchor constraintEqualToAnchor:content.heightAnchor];
    fitHeight.priority = UILayoutPriorityDefaultLow;
    [NSLayoutConstraint activateConstraints:@[
        [card.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor],
        [card.centerYAnchor constraintEqualToAnchor:safe.centerYAnchor],
        wantWidth,
        [card.widthAnchor constraintLessThanOrEqualToConstant:440],
        [card.widthAnchor constraintLessThanOrEqualToAnchor:safe.widthAnchor constant:-16],
        [card.topAnchor constraintGreaterThanOrEqualToAnchor:safe.topAnchor constant:12],
        [card.bottomAnchor constraintLessThanOrEqualToAnchor:safe.bottomAnchor constant:-12],

        [title.topAnchor constraintEqualToAnchor:card.topAnchor constant:16],
        [title.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [title.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],

        [scroll.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:10],
        [scroll.leadingAnchor constraintEqualToAnchor:card.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:card.trailingAnchor],
        fitHeight,

        [content.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor],
        [content.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor],
        [content.leadingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor constant:16],
        [content.trailingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor constant:-16],

        [footer.topAnchor constraintEqualToAnchor:scroll.bottomAnchor constant:14],
        [footer.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [footer.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [footer.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16],
    ]];
}

- (void)showInView:(UIView *)host
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [host addSubview:self];
    [NSLayoutConstraint activateConstraints:@[
        [self.topAnchor constraintEqualToAnchor:host.topAnchor],
        [self.bottomAnchor constraintEqualToAnchor:host.bottomAnchor],
        [self.leadingAnchor constraintEqualToAnchor:host.leadingAnchor],
        [self.trailingAnchor constraintEqualToAnchor:host.trailingAnchor],
    ]];
    self.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{ self.alpha = 1; }];
}

- (void)closeSkipped:(BOOL)skipped
{
    void (^cb)(BOOL) = self.onClose;
    self.onClose = nil;
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{ self.alpha = 0; } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (cb) cb(skipped);
    }];
}

- (void)skipTapped  { [self closeSkipped:YES]; }
- (void)startTapped { [self closeSkipped:NO]; }

@end
