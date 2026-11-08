//
//  NewGameDialog.m
//
//  「새 게임」 창 (A478) · 「데일리 퍼즐」 창 — 설명은 NewGameDialog.h.
//  ARC (-fobjc-arc).
//
//  배치: 어두운 덮개 위 가운데 카드. 카드는 안전 영역(safeAreaLayoutGuide) 안에만 놓인다 —
//  노치 · Dynamic Island · 홈 표시줄을 피한다. 화면이 작으면(iPhone SE · 가로) 가운데 부분만
//  스크롤되고 [취소] [시작] 줄은 늘 보인다.
//

#import "NewGameDialog.h"
#import "Locale.h"
#import "SudokuGame.h"
#import "DailyStreak.h"

// 앱의 글자 색(xib 의 남색)과 맞춘다. 다크 모드와 상관없이 같은 색을 쓴다 — 앱 화면이 밝은 꼴 하나다.
#define NG_INK        [UIColor colorWithRed:0.055 green:0.198 blue:0.458 alpha:1]
#define NG_SUB        [UIColor colorWithRed:0.32 green:0.36 blue:0.44 alpha:1]
#define NG_SEL_BG     [UIColor colorWithRed:0.87 green:0.92 blue:1.00 alpha:1]
#define NG_ROW_BG     [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1]
#define NG_LINE       [UIColor colorWithRed:0.80 green:0.83 blue:0.88 alpha:1]
#define NG_DONE       [UIColor colorWithRed:0.10 green:0.52 blue:0.26 alpha:1]   // 「오늘 했음」 초록
#define NG_DONE_BG    [UIColor colorWithRed:0.93 green:0.97 blue:0.94 alpha:1]

static const SUDOKUTYPE kTypes[SUDOKUTYPE_MAX] = {
    SUDOKUTYPE_SUDOKU, SUDOKUTYPE_GT, SUDOKUTYPE_KILLER, SUDOKUTYPE_CALCU, SUDOKUTYPE_SYMBOL };
// 새 게임 난이도 칸 6개 (3 × 2). 마지막 「직접 입력」 은 일반 스도쿠에서만 보인다.
#define NG_LEVEL_COUNT 6
static const GAMELEVEL kLevels[NG_LEVEL_COUNT] = {
    GAMELEVEL_VERYEASY, GAMELEVEL_EASY, GAMELEVEL_NORMAL, GAMELEVEL_HARD, GAMELEVEL_VERYHARD, GAMELEVEL_USERINPUT };
// 데일리 난이도 칸 2개 (1 × 2). 서버에 있는 데일리 퍼즐의 실제 난이도다
// (예전 단추 Easy = GAMELEVEL_NORMAL · Hard = GAMELEVEL_VERYHARD).
#define NG_DAILY_LEVEL_COUNT 2
static const GAMELEVEL kDailyLevels[NG_DAILY_LEVEL_COUNT] = { GAMELEVEL_NORMAL, GAMELEVEL_VERYHARD };

@interface NewGameDialog ()
@end

@implementation NewGameDialog {
    BOOL _daily;
    SUDOKUTYPE _type;
    GAMELEVEL _level;
    BOOL _autoMemo;
    BOOL _canCancel;
    NSString *_userName;
    NGDailyServerState _serverState;
    NSMutableArray<UIControl *> *_typeRows;
    NSMutableArray<UILabel *> *_typeBadges;
    NSMutableArray<UIButton *> *_levelButtons;
    UISwitch *_autoMemoSwitch;
    UILabel *_note;
    UIButton *_rankingButton;
    UIButton *_startButton;
    UIView *_card;
}

+ (NSString *)descriptionForType:(SUDOKUTYPE)type
{
    switch (type) {
        case SUDOKUTYPE_SUDOKU: return gettext(@"newgame.desc.sudoku", nil);
        case SUDOKUTYPE_GT:     return gettext(@"newgame.desc.gt", nil);
        case SUDOKUTYPE_KILLER: return gettext(@"newgame.desc.killer", nil);
        case SUDOKUTYPE_CALCU:  return gettext(@"newgame.desc.calcu", nil);
        case SUDOKUTYPE_SYMBOL: return gettext(@"newgame.desc.symbol", nil);
        default: return @"";
    }
}

// 단추 글자는 첫 글자를 대문자로 — en 문자열이 "normal" · "very hard" 처럼 소문자다(게임 화면 등 다른 곳은 그대로 둔다).
static NSString *CapFirst(NSString *s)
{
    if (s.length == 0) return s;
    return [[[s substringToIndex:1] uppercaseString] stringByAppendingString:[s substringFromIndex:1]];
}

static NSString *LevelTitleRaw(GAMELEVEL level);
static NSString *LevelTitle(GAMELEVEL level) { return CapFirst(LevelTitleRaw(level)); }
static NSString *LevelTitleRaw(GAMELEVEL level)
{
    switch (level) {
        case GAMELEVEL_VERYEASY:  return gettext(@"very easy", nil);
        case GAMELEVEL_EASY:      return gettext(@"easy", nil);
        case GAMELEVEL_NORMAL:    return gettext(@"normal", nil);
        case GAMELEVEL_HARD:      return gettext(@"hard", nil);
        case GAMELEVEL_VERYHARD:  return gettext(@"very hard", nil);
        case GAMELEVEL_USERINPUT: return gettext(@"user input", nil);
        default: return @"";
    }
}

static UIFont *NGFont(CGFloat size, BOOL bold)
{
    UIFont *f = [UIFont fontWithName:(bold ? @"TrebuchetMS-Bold" : @"TrebuchetMS") size:size];
    return f ?: (bold ? [UIFont boldSystemFontOfSize:size] : [UIFont systemFontOfSize:size]);
}

- (instancetype)initWithType:(SUDOKUTYPE)type level:(GAMELEVEL)level autoMemo:(BOOL)autoMemo canCancel:(BOOL)canCancel
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _type = (type >= 0 && type < SUDOKUTYPE_MAX) ? type : SUDOKUTYPE_SUDOKU;
        BOOL known = NO;
        for (int i = 0; i < NG_LEVEL_COUNT; i++) if (kLevels[i] == level) known = YES;
        _level = known ? level : GAMELEVEL_NORMAL;
        if (_level == GAMELEVEL_USERINPUT && _type != SUDOKUTYPE_SUDOKU) _level = GAMELEVEL_NORMAL;
        _autoMemo = autoMemo;
        _canCancel = canCancel;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (instancetype)initDailyWithType:(SUDOKUTYPE)type level:(GAMELEVEL)level userName:(NSString *)userName
{
    if ((self = [self initWithType:type level:GAMELEVEL_NORMAL autoMemo:NO canCancel:YES])) {
        _daily = YES;
        _level = (level == GAMELEVEL_VERYHARD) ? GAMELEVEL_VERYHARD : GAMELEVEL_NORMAL;
        _userName = [userName copy] ?: @"";
        _serverState = NGDailyServerConnecting;
    }
    return self;
}

- (BOOL)isDaily { return _daily; }

- (BOOL)isUserInputAllowed { return !_daily && _type == SUDOKUTYPE_SUDOKU; }

- (BOOL)playedType:(SUDOKUTYPE)t level:(GAMELEVEL)l
{
    return _daily && self.dailyPlayed && self.dailyPlayed(t, l);
}

#pragma mark - 화면

- (UILabel *)headerLabel:(NSString *)text
{
    UILabel *l = [UILabel new];
    l.text = text;
    l.font = NGFont(15, YES);
    l.textColor = NG_SUB;
    return l;
}

- (UIControl *)typeRowFor:(SUDOKUTYPE)type badge:(UILabel *)badge
{
    UIControl *row = [UIControl new];
    row.tag = type;
    row.layer.cornerRadius = 12;
    row.layer.borderWidth = 2;
    row.accessibilityIdentifier = [NSString stringWithFormat:@"%@-type-%d", _daily ? @"daily" : @"newgame", (int)type];
    row.isAccessibilityElement = YES;
    row.accessibilityTraits = UIAccessibilityTraitButton;
    row.accessibilityLabel = [NSString stringWithFormat:@"%@, %@",
                              [SudokuGame getSudokuTypeName:type], [NewGameDialog descriptionForType:type]];
    [row addTarget:self action:@selector(typeTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIImage *img = [[UIImage imageNamed:[NSString stringWithFormat:@"type_%d_100b.png", (int)type]]
                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *icon = [[UIImageView alloc] initWithImage:img];
    icon.tintColor = NG_INK;
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *name = [UILabel new];
    name.text = [SudokuGame getSudokuTypeName:type];
    name.font = NGFont(17, YES);
    name.textColor = NG_INK;
    name.adjustsFontSizeToFitWidth = YES;
    name.minimumScaleFactor = 0.7;

    UILabel *desc = [UILabel new];
    desc.text = [NewGameDialog descriptionForType:type];
    desc.font = [UIFont systemFontOfSize:12.5];
    desc.textColor = NG_SUB;
    desc.numberOfLines = 2;

    UIStackView *texts = [[UIStackView alloc] initWithArrangedSubviews:@[name, desc]];
    texts.axis = UILayoutConstraintAxisVertical;
    texts.spacing = 1;
    texts.translatesAutoresizingMaskIntoConstraints = NO;
    texts.userInteractionEnabled = NO;
    icon.userInteractionEnabled = NO;

    // 오른쪽 끝 「✓ 1/2」 (데일리 창에서 오늘 한 판이 있을 때만 글자가 찬다. 비면 폭 0)
    badge.font = [UIFont boldSystemFontOfSize:13];
    badge.textColor = NG_DONE;
    badge.textAlignment = NSTextAlignmentRight;
    badge.translatesAutoresizingMaskIntoConstraints = NO;
    badge.userInteractionEnabled = NO;
    [badge setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [badge setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    [row addSubview:icon];
    [row addSubview:texts];
    [row addSubview:badge];
    [NSLayoutConstraint activateConstraints:@[
        [icon.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:10],
        [icon.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [icon.widthAnchor constraintEqualToConstant:34],
        [icon.heightAnchor constraintEqualToConstant:34],
        [texts.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:10],
        [texts.trailingAnchor constraintEqualToAnchor:badge.leadingAnchor constant:-6],
        [texts.topAnchor constraintEqualToAnchor:row.topAnchor constant:7],
        [texts.bottomAnchor constraintEqualToAnchor:row.bottomAnchor constant:-7],
        [badge.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-10],
        [badge.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [row.heightAnchor constraintGreaterThanOrEqualToConstant:50],
    ]];
    return row;
}

- (UIButton *)levelButtonFor:(GAMELEVEL)level
{
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.tag = level;
    [b setTitle:LevelTitle(level) forState:UIControlStateNormal];
    b.titleLabel.font = NGFont(15, YES);
    b.titleLabel.adjustsFontSizeToFitWidth = YES;
    b.titleLabel.minimumScaleFactor = 0.6;
    b.titleLabel.textAlignment = NSTextAlignmentCenter;
    b.titleLabel.numberOfLines = _daily ? 2 : 1;
    b.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    b.layer.cornerRadius = 10;
    b.layer.borderWidth = 2;
    b.accessibilityIdentifier = [NSString stringWithFormat:@"%@-level-%d", _daily ? @"daily" : @"newgame", (int)level];
    // 데일리는 「오늘 했음」 둘째 줄이 들어갈 수 있게 조금 높다
    [b.heightAnchor constraintEqualToConstant:(_daily ? 50 : 40)].active = YES;
    [b addTarget:self action:@selector(levelTapped:) forControlEvents:UIControlEventTouchUpInside];
    return b;
}

- (UIButton *)footerButton:(NSString *)title primary:(BOOL)primary action:(SEL)action
{
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setTitle:title forState:UIControlStateNormal];
    b.titleLabel.font = NGFont(18, YES);
    b.titleLabel.adjustsFontSizeToFitWidth = YES;
    b.titleLabel.minimumScaleFactor = 0.7;
    b.layer.cornerRadius = 12;
    if (primary) {
        b.backgroundColor = NG_INK;
        [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [b setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    } else {
        b.backgroundColor = UIColor.whiteColor;
        b.layer.borderWidth = 2;
        b.layer.borderColor = NG_LINE.CGColor;
        [b setTitleColor:NG_INK forState:UIControlStateNormal];
        [b setTitleColor:NG_SUB forState:UIControlStateHighlighted];
    }
    [b.heightAnchor constraintEqualToConstant:48].active = YES;
    [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return b;
}

// 데일리 창 아래쪽 작은 테 단추 ([이름 변경] · [랭킹])
- (UIButton *)smallButton:(NSString *)title action:(SEL)action
{
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setTitle:title forState:UIControlStateNormal];
    b.titleLabel.font = NGFont(14, YES);
    b.titleLabel.adjustsFontSizeToFitWidth = YES;
    b.titleLabel.minimumScaleFactor = 0.7;
    b.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    b.layer.cornerRadius = 8;
    b.layer.borderWidth = 1.5;
    b.layer.borderColor = NG_LINE.CGColor;
    [b setTitleColor:NG_INK forState:UIControlStateNormal];
    [b setTitleColor:NG_SUB forState:UIControlStateHighlighted];
    [b setTitleColor:NG_LINE forState:UIControlStateDisabled];
    [b.heightAnchor constraintEqualToConstant:32].active = YES;
    [b setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return b;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];

    // 바깥 누르기 = 취소 (취소가 있을 때만)
    UIButton *backdrop = [UIButton buttonWithType:UIButtonTypeCustom];
    backdrop.translatesAutoresizingMaskIntoConstraints = NO;
    backdrop.isAccessibilityElement = NO;
    [backdrop addTarget:self action:@selector(backdropTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backdrop];
    [NSLayoutConstraint activateConstraints:@[
        [backdrop.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [backdrop.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [backdrop.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [backdrop.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];

    _card = [UIView new];
    _card.backgroundColor = UIColor.whiteColor;
    _card.layer.cornerRadius = 22;
    _card.clipsToBounds = YES;
    _card.translatesAutoresizingMaskIntoConstraints = NO;
    _card.accessibilityIdentifier = _daily ? @"daily-dialog" : @"newgame-dialog";
    [self.view addSubview:_card];

    // 제목
    UILabel *title = [UILabel new];
    title.text = _daily ? gettext(@"daily puzzle", nil) : gettext(@"New game", nil);
    title.font = NGFont(22, YES);
    title.textColor = NG_INK;
    title.textAlignment = NSTextAlignmentCenter;
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [_card addSubview:title];

    // 가운데 (스크롤)
    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.alwaysBounceVertical = NO;
    [_card addSubview:scroll];

    UIStackView *content = [UIStackView new];
    content.axis = UILayoutConstraintAxisVertical;
    content.spacing = 6;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:content];

    if (_daily && self.streakToday.length) {   // 연속 띠 (A468 R3) — 종류 위
        DailyStreakView *streak = [[DailyStreakView alloc] initWithToday:self.streakToday];
        [content addArrangedSubview:streak];
        [content setCustomSpacing:10 afterView:streak];
    }
    [content addArrangedSubview:[self headerLabel:gettext(@"Sudoku type", nil)]];
    _typeRows = [NSMutableArray array];
    _typeBadges = [NSMutableArray array];
    for (int i = 0; i < SUDOKUTYPE_MAX; i++) {
        UILabel *badge = [UILabel new];
        UIControl *row = [self typeRowFor:kTypes[i] badge:badge];
        [_typeRows addObject:row];
        [_typeBadges addObject:badge];
        [content addArrangedSubview:row];
    }
    // 머리글은 대문자로 시작하는 새 열쇠 — 예전 "level" 은 en 에서 소문자 「level」 이었다.
    UILabel *levelHeader = [self headerLabel:gettext(@"newgame.header.level", nil)];
    [content addArrangedSubview:levelHeader];
    [content setCustomSpacing:14 afterView:_typeRows.lastObject];

    _levelButtons = [NSMutableArray array];
    if (_daily) {
        // 데일리 난이도 1 × 2
        UIStackView *line = [UIStackView new];
        line.axis = UILayoutConstraintAxisHorizontal;
        line.distribution = UIStackViewDistributionFillEqually;
        line.spacing = 6;
        for (int i = 0; i < NG_DAILY_LEVEL_COUNT; i++) {
            UIButton *b = [self levelButtonFor:kDailyLevels[i]];
            [_levelButtons addObject:b];
            [line addArrangedSubview:b];
        }
        [content addArrangedSubview:line];

        // 알림 한 줄: 서버 상태 · 오늘 이미 한 판 · 평소 안내
        _note = [UILabel new];
        _note.font = [UIFont systemFontOfSize:13];
        _note.textColor = NG_SUB;
        _note.numberOfLines = 0;
        _note.textAlignment = NSTextAlignmentCenter;
        _note.accessibilityIdentifier = @"daily-note";
        [content setCustomSpacing:10 afterView:line];
        [content addArrangedSubview:_note];

        // 이름 · [이름 변경] · [랭킹] — 예전 데일리 화면에 있던 것
        UILabel *name = [UILabel new];
        name.text = _userName;
        name.font = NGFont(15, YES);
        name.textColor = NG_INK;
        name.lineBreakMode = NSLineBreakByTruncatingTail;
        [name setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        UIImageView *person = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"person.crop.circle"]];
        person.tintColor = NG_SUB;
        [person setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        UIButton *nick = [self smallButton:gettext(@"Nickname", nil) action:@selector(nicknameTapped)];
        nick.accessibilityIdentifier = @"daily-nickname";
        _rankingButton = [self smallButton:gettext(@"Ranking", nil) action:@selector(rankingTapped)];
        _rankingButton.accessibilityIdentifier = @"daily-ranking";
        UIStackView *userLine = [[UIStackView alloc] initWithArrangedSubviews:@[person, name, nick, _rankingButton]];
        userLine.axis = UILayoutConstraintAxisHorizontal;
        userLine.alignment = UIStackViewAlignmentCenter;
        userLine.spacing = 6;
        [content setCustomSpacing:12 afterView:_note];
        [content addArrangedSubview:userLine];
    } else {
        // 새 게임 난이도 3 × 2
        for (int r = 0; r < 2; r++) {
            UIStackView *line = [UIStackView new];
            line.axis = UILayoutConstraintAxisHorizontal;
            line.distribution = UIStackViewDistributionFillEqually;
            line.spacing = 6;
            for (int c = 0; c < 3; c++) {
                UIButton *b = [self levelButtonFor:kLevels[r * 3 + c]];
                [_levelButtons addObject:b];
                [line addArrangedSubview:b];
            }
            [content addArrangedSubview:line];
        }

        // 자동 메모 (예전 새 게임 화면의 체크 상자를 옮겨 왔다)
        UILabel *memoLabel = [UILabel new];
        memoLabel.text = CapFirst(gettext(@"auto memo", nil));
        memoLabel.font = NGFont(16, NO);
        memoLabel.textColor = NG_INK;
        _autoMemoSwitch = [UISwitch new];
        _autoMemoSwitch.on = _autoMemo;
        _autoMemoSwitch.onTintColor = NG_INK;
        _autoMemoSwitch.accessibilityIdentifier = @"newgame-automemo";
        [_autoMemoSwitch addTarget:self action:@selector(autoMemoChanged) forControlEvents:UIControlEventValueChanged];
        UIStackView *memoLine = [[UIStackView alloc] initWithArrangedSubviews:@[memoLabel, _autoMemoSwitch]];
        memoLine.axis = UILayoutConstraintAxisHorizontal;
        memoLine.alignment = UIStackViewAlignmentCenter;
        memoLine.spacing = 8;
        [content setCustomSpacing:12 afterView:content.arrangedSubviews.lastObject];
        [content addArrangedSubview:memoLine];
    }

    // 아래 단추 줄 (늘 보인다)
    _startButton = [self footerButton:gettext(@"Start", nil) primary:YES action:@selector(startTapped)];
    _startButton.accessibilityIdentifier = _daily ? @"daily-start" : @"newgame-start";
    NSMutableArray *footerItems = [NSMutableArray array];
    if (_canCancel) {
        UIButton *cancel = [self footerButton:gettext(@"Cancel", nil) primary:NO action:@selector(cancelTapped)];
        cancel.accessibilityIdentifier = _daily ? @"daily-cancel" : @"newgame-cancel";
        [footerItems addObject:cancel];
    }
    [footerItems addObject:_startButton];
    UIStackView *footer = [[UIStackView alloc] initWithArrangedSubviews:footerItems];
    footer.axis = UILayoutConstraintAxisHorizontal;
    footer.distribution = UIStackViewDistributionFillEqually;
    footer.spacing = 10;
    footer.translatesAutoresizingMaskIntoConstraints = NO;
    [_card addSubview:footer];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    NSLayoutConstraint *wantWidth = [_card.widthAnchor constraintEqualToAnchor:safe.widthAnchor constant:-32];
    wantWidth.priority = UILayoutPriorityDefaultHigh;
    NSLayoutConstraint *fitHeight = [scroll.heightAnchor constraintEqualToAnchor:content.heightAnchor];
    fitHeight.priority = UILayoutPriorityDefaultLow;   // 자리가 모자라면 가운데만 줄고 스크롤된다

    [NSLayoutConstraint activateConstraints:@[
        [_card.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor],
        [_card.centerYAnchor constraintEqualToAnchor:safe.centerYAnchor],
        wantWidth,
        [_card.widthAnchor constraintLessThanOrEqualToConstant:440],
        [_card.widthAnchor constraintLessThanOrEqualToAnchor:safe.widthAnchor constant:-16],
        [_card.topAnchor constraintGreaterThanOrEqualToAnchor:safe.topAnchor constant:12],
        [_card.bottomAnchor constraintLessThanOrEqualToAnchor:safe.bottomAnchor constant:-12],

        [title.topAnchor constraintEqualToAnchor:_card.topAnchor constant:16],
        [title.leadingAnchor constraintEqualToAnchor:_card.leadingAnchor constant:16],
        [title.trailingAnchor constraintEqualToAnchor:_card.trailingAnchor constant:-16],

        [scroll.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:10],
        [scroll.leadingAnchor constraintEqualToAnchor:_card.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:_card.trailingAnchor],
        fitHeight,

        [content.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor],
        [content.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor],
        [content.leadingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor constant:16],
        [content.trailingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor constant:-16],

        [footer.topAnchor constraintEqualToAnchor:scroll.bottomAnchor constant:14],
        [footer.leadingAnchor constraintEqualToAnchor:_card.leadingAnchor constant:16],
        [footer.trailingAnchor constraintEqualToAnchor:_card.trailingAnchor constant:-16],
        [footer.bottomAnchor constraintEqualToAnchor:_card.bottomAnchor constant:-16],
    ]];

    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 고른 종류가 아래쪽이라 가려져 있으면 보이게 (작은 화면)
    UIControl *row = _typeRows[_type];
    UIScrollView *scroll = (UIScrollView *)row.superview.superview;
    if ([scroll isKindOfClass:[UIScrollView class]])
        [scroll scrollRectToVisible:[scroll convertRect:row.bounds fromView:row] animated:NO];
#ifdef DEBUG
    // 촬영(-DebugNewGameDialog · -DebugDailyDialog) 때 앱 창을 그대로 Documents/<이름> 으로 남긴다.
    // 시뮬레이터 화면에 다른 앱의 시스템 창(ATT 등)이 덮여 있어도 앱이 그린 것만 찍힌다. Release 에 없다.
    NSString *shot = self.debugSnapshotName;
    if (shot.length) {
        NSTimeInterval delay = self.debugSnapshotDelay > 0 ? self.debugSnapshotDelay : 0.8;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *w = self.view.window;
            if (!w) return;
            UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithBounds:w.bounds];
            UIImage *img = [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
                [w drawViewHierarchyInRect:w.bounds afterScreenUpdates:YES];
            }];
            NSString *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            [UIImagePNGRepresentation(img) writeToFile:[dir stringByAppendingPathComponent:shot] atomically:YES];
            // -DebugDialogAutoStart: 찍은 뒤 [시작] 을 눌러 판 만들기 · game_start(mode_id) 까지 몰아 본다
            if ([[NSProcessInfo processInfo].arguments containsObject:@"-DebugDialogAutoStart"])
                [self startTapped];
        });
    }
#endif
}

- (void)setDailyServerState:(NGDailyServerState)state
{
    _serverState = state;
    // 서버 상태를 받은 뒤: 고른 판을 오늘 이미 했고 다른 난이도가 남아 있으면 그쪽으로 옮겨 둔다
    if (_daily && state == NGDailyServerReady && [self playedType:_type level:_level]) {
        for (int i = 0; i < NG_DAILY_LEVEL_COUNT; i++)
            if (![self playedType:_type level:kDailyLevels[i]]) { _level = kDailyLevels[i]; break; }
    }
    if (self.isViewLoaded) [self refresh];
}

- (BOOL)canStart
{
    if (!_daily) return YES;
    if (_serverState != NGDailyServerReady) return NO;
    return self.dailyAllowReplay || ![self playedType:_type level:_level];
}

- (void)refresh
{
    for (int i = 0; i < (int)_typeRows.count; i++) {
        UIControl *row = _typeRows[i];
        BOOL sel = (row.tag == _type);
        row.backgroundColor = sel ? NG_SEL_BG : NG_ROW_BG;
        row.layer.borderColor = (sel ? NG_INK : UIColor.clearColor).CGColor;
        row.selected = sel;
        row.accessibilityTraits = UIAccessibilityTraitButton | (sel ? UIAccessibilityTraitSelected : 0);

        int done = 0;
        if (_daily)
            for (int k = 0; k < NG_DAILY_LEVEL_COUNT; k++)
                if ([self playedType:(SUDOKUTYPE)row.tag level:kDailyLevels[k]]) done++;
        _typeBadges[i].text = done ? [NSString stringWithFormat:@"✓ %d/%d", done, NG_DAILY_LEVEL_COUNT] : @"";
        _typeBadges[i].accessibilityLabel = done ? [NSString stringWithFormat:@"%@ %d/%d",
                                                     gettext(@"daily.played", nil), done, NG_DAILY_LEVEL_COUNT] : nil;
    }
    for (UIButton *b in _levelButtons) {
        BOOL sel = (b.tag == _level);
        if (b.tag == GAMELEVEL_USERINPUT) {
            // 직접 입력은 일반 스도쿠만 — 다른 종류에서는 자리만 남기고 숨긴다(칸이 흔들리지 않게)
            b.hidden = NO;
            b.alpha = [self isUserInputAllowed] ? 1 : 0;
            b.userInteractionEnabled = [self isUserInputAllowed];
            b.accessibilityElementsHidden = ![self isUserInputAllowed];
        }
        BOOL played = [self playedType:_type level:(GAMELEVEL)b.tag];
        UIColor *fg = sel ? UIColor.whiteColor : (played ? NG_DONE : NG_INK);
        b.backgroundColor = sel ? NG_INK : (played ? NG_DONE_BG : UIColor.whiteColor);
        b.layer.borderColor = (sel ? NG_INK : (played ? NG_DONE : NG_LINE)).CGColor;
        if (_daily) {
            // 둘째 줄 「✓ 오늘 했음」
            NSMutableAttributedString *t = [[NSMutableAttributedString alloc]
                initWithString:LevelTitle((GAMELEVEL)b.tag)
                    attributes:@{ NSFontAttributeName: NGFont(15, YES), NSForegroundColorAttributeName: fg }];
            if (played) {
                [t appendAttributedString:[[NSAttributedString alloc]
                    initWithString:[NSString stringWithFormat:@"\n✓ %@", gettext(@"daily.played", nil)]
                        attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:11.5],
                                      NSForegroundColorAttributeName: sel ? [UIColor colorWithWhite:1 alpha:0.85] : NG_DONE }]];
            }
            NSMutableParagraphStyle *ps = [NSMutableParagraphStyle new];
            ps.alignment = NSTextAlignmentCenter;
            [t addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, t.length)];
            [b setAttributedTitle:t forState:UIControlStateNormal];
        } else {
            [b setTitleColor:fg forState:UIControlStateNormal];
        }
        b.accessibilityTraits = UIAccessibilityTraitButton | (sel ? UIAccessibilityTraitSelected : 0);
    }

    if (_daily) {
        NSString *note;
        UIColor *noteColor = NG_SUB;
        switch (_serverState) {
            case NGDailyServerConnecting:
                note = gettext(@"daily.connecting", nil);
                break;
            case NGDailyServerOffline:
                note = gettext(@"Not connected to a server.", nil);
                noteColor = [UIColor colorWithRed:0.75 green:0.20 blue:0.15 alpha:1];
                break;
            default:
                if ([self playedType:_type level:_level]) {
                    note = gettext(@"daily.played.note", nil);
                    noteColor = NG_DONE;
                } else {
                    note = gettext(@"daily.note", nil);
                }
                break;
        }
        _note.text = note;
        _note.textColor = noteColor;
        _rankingButton.enabled = (_serverState == NGDailyServerReady);
        _rankingButton.alpha = _rankingButton.enabled ? 1 : 0.5;
    }
    BOOL can = [self canStart];
    _startButton.enabled = can;
    _startButton.alpha = can ? 1 : 0.35;
}

#pragma mark - 동작

- (void)typeTapped:(UIControl *)row
{
    _type = (SUDOKUTYPE)row.tag;
    if (_level == GAMELEVEL_USERINPUT && ![self isUserInputAllowed]) _level = GAMELEVEL_NORMAL;
    // 데일리: 이 종류에서 고른 난이도를 오늘 이미 했으면 남은 난이도로
    if (_daily && [self playedType:_type level:_level]) {
        for (int i = 0; i < NG_DAILY_LEVEL_COUNT; i++)
            if (![self playedType:_type level:kDailyLevels[i]]) { _level = kDailyLevels[i]; break; }
    }
    [self refresh];
}

- (void)levelTapped:(UIButton *)b
{
    _level = (GAMELEVEL)b.tag;
    [self refresh];
}

- (void)autoMemoChanged
{
    _autoMemo = _autoMemoSwitch.on;
}

- (void)backdropTapped
{
    if (_canCancel) [self cancelTapped];
}

- (void)clearCallbacks
{
    self.onCancel = nil;
    self.onStart = nil;
    self.onNickname = nil;
    self.onRanking = nil;
}

- (void)dismissThen:(void (^)(void))cb
{
    [self clearCallbacks];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (cb) cb();
    }];
}

- (void)cancelTapped
{
    [self dismissThen:self.onCancel];
}

- (void)nicknameTapped
{
    [self dismissThen:self.onNickname];
}

- (void)rankingTapped
{
    if (_serverState != NGDailyServerReady) return;
    [self dismissThen:self.onRanking];
}

- (void)startTapped
{
    if (![self canStart]) return;
    void (^cb)(SUDOKUTYPE, GAMELEVEL, BOOL) = self.onStart;
    SUDOKUTYPE t = _type; GAMELEVEL l = _level; BOOL m = _daily ? NO : _autoMemo;
    [self dismissThen:^{
        if (cb) cb(t, l, m);
    }];
}

@end
