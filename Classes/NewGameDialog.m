//
//  NewGameDialog.m
//
//  「새 게임」 창 (A478) — 설명은 NewGameDialog.h.
//  ARC (-fobjc-arc).
//
//  배치: 어두운 덮개 위 가운데 카드. 카드는 안전 영역(safeAreaLayoutGuide) 안에만 놓인다 —
//  노치 · Dynamic Island · 홈 표시줄을 피한다. 화면이 작으면(iPhone SE · 가로) 가운데 부분만
//  스크롤되고 [취소] [시작] 줄은 늘 보인다.
//

#import "NewGameDialog.h"
#import "Locale.h"
#import "SudokuGame.h"

// 앱의 글자 색(xib 의 남색)과 맞춘다. 다크 모드와 상관없이 같은 색을 쓴다 — 앱 화면이 밝은 꼴 하나다.
#define NG_INK        [UIColor colorWithRed:0.055 green:0.198 blue:0.458 alpha:1]
#define NG_SUB        [UIColor colorWithRed:0.32 green:0.36 blue:0.44 alpha:1]
#define NG_SEL_BG     [UIColor colorWithRed:0.87 green:0.92 blue:1.00 alpha:1]
#define NG_ROW_BG     [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1]
#define NG_LINE       [UIColor colorWithRed:0.80 green:0.83 blue:0.88 alpha:1]

static const SUDOKUTYPE kTypes[SUDOKUTYPE_MAX] = {
    SUDOKUTYPE_SUDOKU, SUDOKUTYPE_GT, SUDOKUTYPE_KILLER, SUDOKUTYPE_CALCU, SUDOKUTYPE_SYMBOL };
// 난이도 칸 6개 (3 × 2). 마지막 「직접 입력」 은 일반 스도쿠에서만 보인다.
#define NG_LEVEL_COUNT 6
static const GAMELEVEL kLevels[NG_LEVEL_COUNT] = {
    GAMELEVEL_VERYEASY, GAMELEVEL_EASY, GAMELEVEL_NORMAL, GAMELEVEL_HARD, GAMELEVEL_VERYHARD, GAMELEVEL_USERINPUT };

@interface NewGameDialog ()
@end

@implementation NewGameDialog {
    SUDOKUTYPE _type;
    GAMELEVEL _level;
    BOOL _autoMemo;
    BOOL _canCancel;
    NSMutableArray<UIControl *> *_typeRows;
    NSMutableArray<UIButton *> *_levelButtons;
    UISwitch *_autoMemoSwitch;
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

static NSString *LevelTitle(GAMELEVEL level)
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

- (BOOL)isUserInputAllowed { return _type == SUDOKUTYPE_SUDOKU; }

#pragma mark - 화면

- (UILabel *)headerLabel:(NSString *)text
{
    UILabel *l = [UILabel new];
    l.text = text;
    l.font = NGFont(15, YES);
    l.textColor = NG_SUB;
    return l;
}

- (UIControl *)typeRowFor:(SUDOKUTYPE)type
{
    UIControl *row = [UIControl new];
    row.tag = type;
    row.layer.cornerRadius = 12;
    row.layer.borderWidth = 2;
    row.accessibilityIdentifier = [NSString stringWithFormat:@"newgame-type-%d", (int)type];
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

    [row addSubview:icon];
    [row addSubview:texts];
    [NSLayoutConstraint activateConstraints:@[
        [icon.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:10],
        [icon.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [icon.widthAnchor constraintEqualToConstant:34],
        [icon.heightAnchor constraintEqualToConstant:34],
        [texts.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:10],
        [texts.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-10],
        [texts.topAnchor constraintEqualToAnchor:row.topAnchor constant:7],
        [texts.bottomAnchor constraintEqualToAnchor:row.bottomAnchor constant:-7],
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
    b.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    b.layer.cornerRadius = 10;
    b.layer.borderWidth = 2;
    b.accessibilityIdentifier = [NSString stringWithFormat:@"newgame-level-%d", (int)level];
    [b.heightAnchor constraintEqualToConstant:40].active = YES;
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
    _card.accessibilityIdentifier = @"newgame-dialog";
    [self.view addSubview:_card];

    // 제목
    UILabel *title = [UILabel new];
    title.text = gettext(@"New game", nil);
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

    [content addArrangedSubview:[self headerLabel:gettext(@"Sudoku type", nil)]];
    _typeRows = [NSMutableArray array];
    for (int i = 0; i < SUDOKUTYPE_MAX; i++) {
        UIControl *row = [self typeRowFor:kTypes[i]];
        [_typeRows addObject:row];
        [content addArrangedSubview:row];
    }
    UILabel *levelHeader = [self headerLabel:gettext(@"level", nil)];
    [content addArrangedSubview:levelHeader];
    [content setCustomSpacing:14 afterView:_typeRows.lastObject];

    // 난이도 3 × 2
    _levelButtons = [NSMutableArray array];
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
    memoLabel.text = gettext(@"auto memo", nil);
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

    // 아래 단추 줄 (늘 보인다)
    UIButton *start = [self footerButton:gettext(@"Start", nil) primary:YES action:@selector(startTapped)];
    start.accessibilityIdentifier = @"newgame-start";
    NSMutableArray *footerItems = [NSMutableArray array];
    if (_canCancel) {
        UIButton *cancel = [self footerButton:gettext(@"Cancel", nil) primary:NO action:@selector(cancelTapped)];
        cancel.accessibilityIdentifier = @"newgame-cancel";
        [footerItems addObject:cancel];
    }
    [footerItems addObject:start];
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
    // -DebugNewGameDialog 촬영 때 앱 창을 그대로 Documents/newgame_dialog.png 로 남긴다.
    // 시뮬레이터 화면에 다른 앱의 시스템 창(ATT 등)이 덮여 있어도 앱이 그린 것만 찍힌다. Release 에 없다.
    if ([[NSProcessInfo processInfo].arguments containsObject:@"-DebugNewGameDialog"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *w = self.view.window;
            if (!w) return;
            UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithBounds:w.bounds];
            UIImage *img = [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
                [w drawViewHierarchyInRect:w.bounds afterScreenUpdates:YES];
            }];
            NSString *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            [UIImagePNGRepresentation(img) writeToFile:[dir stringByAppendingPathComponent:@"newgame_dialog.png"] atomically:YES];
        });
    }
#endif
}

- (void)refresh
{
    for (UIControl *row in _typeRows) {
        BOOL sel = (row.tag == _type);
        row.backgroundColor = sel ? NG_SEL_BG : NG_ROW_BG;
        row.layer.borderColor = (sel ? NG_INK : UIColor.clearColor).CGColor;
        row.selected = sel;
        row.accessibilityTraits = UIAccessibilityTraitButton | (sel ? UIAccessibilityTraitSelected : 0);
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
        b.backgroundColor = sel ? NG_INK : UIColor.whiteColor;
        b.layer.borderColor = (sel ? NG_INK : NG_LINE).CGColor;
        [b setTitleColor:(sel ? UIColor.whiteColor : NG_INK) forState:UIControlStateNormal];
        b.accessibilityTraits = UIAccessibilityTraitButton | (sel ? UIAccessibilityTraitSelected : 0);
    }
}

#pragma mark - 동작

- (void)typeTapped:(UIControl *)row
{
    _type = (SUDOKUTYPE)row.tag;
    if (_level == GAMELEVEL_USERINPUT && ![self isUserInputAllowed]) _level = GAMELEVEL_NORMAL;
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

- (void)cancelTapped
{
    void (^cb)(void) = self.onCancel;
    self.onCancel = nil;
    self.onStart = nil;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (cb) cb();
    }];
}

- (void)startTapped
{
    void (^cb)(SUDOKUTYPE, GAMELEVEL, BOOL) = self.onStart;
    SUDOKUTYPE t = _type; GAMELEVEL l = _level; BOOL m = _autoMemo;
    self.onCancel = nil;
    self.onStart = nil;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (cb) cb(t, l, m);
    }];
}

@end
