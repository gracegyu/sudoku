//
//  MoreGamesViewController.m
//
//  공장 More games 화면과 같은 꼴: 제목 줄(뒤로 + 닫기) · 머리 한 줄 · 게임 줄
//  (48pt 둥근 아이콘 · 이름 · 한 줄 설명 · 두세 줄 소개 · 바깥 열기 표시) · 줄 사이 선.
//  본문 폭은 460pt 를 넘지 않는다(GaPage maxContentWidth).
//
//  보이는 것: group 이 factory 또는 legacy_flutter 이고 App Store 에 공개(live + id)된 게임.
//  legacy_native(이 저장소들의 앱)는 빼고, 자기 앱도 뺀다. 순서는 popularity.json.
//  누르면 앱 안 스토어 시트(SKStoreProductViewController), 실패하면 https://apps.apple.com/app/id<ID>.
//  itunes.apple.com/artist/... 는 Music 앱이 받으므로 쓰지 않는다.
//

#if !__has_feature(objc_arc)
#error "MoreGamesViewController.m 은 -fobjc-arc 로 컴파일해야 한다"
#endif

#import "MoreGamesViewController.h"
#import <StoreKit/StoreKit.h>
#import "Locale.h"

static NSString *const kMGBaseURL = @"https://raymond-game-factory3.web.app/catalog/v1/";
static const CGFloat kMGMaxContentWidth = 460.0;
static const CGFloat kMGIconSide = 48.0;

#pragma mark - Entry

@interface MGEntry : NSObject
@property (nonatomic, copy) NSString *gameId;
@property (nonatomic, copy) NSString *appStoreId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *tagline;
@property (nonatomic, copy) NSString *blurb;
@property (nonatomic, copy) NSString *fallbackLetter;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSURL *iconURL;
@end

@implementation MGEntry
@end

#pragma mark - Catalog

/// 앱이 지금 쓰는 말 → 카탈로그 언어 키. 영어는 games.json 안에 있으므로 nil.
static NSString *MGCatalogLang(void)
{
    NSString *lang = [[NSUserDefaults standardUserDefaults] stringForKey:@"locale"];
    if (lang.length == 0)
        lang = [[NSBundle mainBundle] preferredLocalizations].firstObject ?: @"en";
    lang = [lang stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    if ([lang hasPrefix:@"ko"]) return @"ko";
    if ([lang hasPrefix:@"ja"]) return @"ja";
    if ([lang isEqualToString:@"zh_CN"] || [lang hasPrefix:@"zh_Hans"]) return @"zh-Hans";
    if ([lang hasPrefix:@"zh"]) return @"zh-Hant";
    return nil;
}

/// 이 앱의 카탈로그 id — 목록에서 자기를 뺀다.
static NSString *MGSelfId(void)
{
    NSDictionary *map = @{
        @"com.raymond.sudokuiphonefree": @"sudoku9free",
        @"com.raymond.sudoku": @"sudoku9pro",
        @"com.raymond.sudoku6free": @"sudoku6free",
        @"com.raymond.sudoku6": @"sudoku6pro",
        @"com.raymond.tetrasquarefree": @"tetrasquare",
        @"com.raymond.tetrasquare": @"tetrasquare",
    };
    return map[[NSBundle mainBundle].bundleIdentifier ?: @""];
}

static NSString *MGCacheDir(void)
{
    NSString *base = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dir = [base stringByAppendingPathComponent:@"MoreGames"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir;
}

static id MGParseJSON(NSData *data)
{
    if (data.length == 0) return nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [obj isKindOfClass:[NSDictionary class]] ? obj : nil;
}

/// 캐시 → 번들 내장본 순서로 읽는다.
static NSDictionary *MGLoadLocal(NSString *file)
{
    NSDictionary *d = MGParseJSON([NSData dataWithContentsOfFile:[MGCacheDir() stringByAppendingPathComponent:file]]);
    if (d) return d;
    NSString *bundled = [[NSBundle mainBundle] pathForResource:[@"moregames_" stringByAppendingString:[file stringByDeletingPathExtension]] ofType:@"json"];
    return bundled ? MGParseJSON([NSData dataWithContentsOfFile:bundled]) : nil;
}

static NSString *MGString(id v)
{
    return [v isKindOfClass:[NSString class]] && [v length] > 0 ? v : nil;
}

static NSArray<MGEntry *> *MGBuildEntries(NSDictionary *games, NSDictionary *langFile, NSDictionary *popularity)
{
    NSArray *list = [games[@"games"] isKindOfClass:[NSArray class]] ? games[@"games"] : @[];
    NSDictionary *langText = [langFile[@"text"] isKindOfClass:[NSDictionary class]] ? langFile[@"text"] : @{};
    NSString *selfId = MGSelfId();
    NSMutableArray<MGEntry *> *live = [NSMutableArray array];

    for (NSDictionary *g in list) {
        if (![g isKindOfClass:[NSDictionary class]]) continue;
        NSString *gid = MGString(g[@"id"]);
        if (!gid || [gid isEqualToString:selfId]) continue;
        // group 이 없으면 공장 게임이다. 모르는 값은 안 보인다.
        id group = g[@"group"];
        if (group && !([group isEqual:@"factory"] || [group isEqual:@"legacy_flutter"])) continue;
        NSDictionary *ios = [g[@"ios"] isKindOfClass:[NSDictionary class]] ? g[@"ios"] : nil;
        NSString *storeId = MGString(ios[@"id"]);
        if (![ios[@"live"] boolValue] || !storeId) continue;

        NSDictionary *allText = [g[@"text"] isKindOfClass:[NSDictionary class]] ? g[@"text"] : @{};
        NSDictionary *en = [allText[@"en"] isKindOfClass:[NSDictionary class]] ? allText[@"en"] : @{};
        NSDictionary *loc = [langText[gid] isKindOfClass:[NSDictionary class]] ? langText[gid] : nil;
        NSString *enName = MGString(en[@"name"]);
        if (!enName) continue;

        MGEntry *e = [MGEntry new];
        e.gameId = gid;
        e.appStoreId = storeId;
        // 언어 파일에 그 게임 글이 있으면 통째로 그것, 없으면 영어.
        NSDictionary *t = MGString(loc[@"name"]) ? loc : en;
        e.name = MGString(t[@"name"]);
        e.tagline = MGString(t[@"tagline"]) ?: @"";
        e.blurb = MGString(t[@"blurb"]);
        e.fallbackLetter = [[enName substringToIndex:1] uppercaseString];
        if ([g[@"color"] isKindOfClass:[NSNumber class]]) {
            uint32_t argb = (uint32_t)[g[@"color"] unsignedLongLongValue];
            e.color = [UIColor colorWithRed:((argb >> 16) & 0xFF) / 255.0
                                      green:((argb >> 8) & 0xFF) / 255.0
                                       blue:(argb & 0xFF) / 255.0
                                      alpha:1.0];
        }
        NSString *icon = MGString(g[@"icon"]);
        e.iconURL = [NSURL URLWithString:icon ?: [NSString stringWithFormat:@"%@icon/%@.png", kMGBaseURL, gid]];
        [live addObject:e];
    }

    // 순서: iOS 순위 → 비었으면 Android 순위 → games.json 순서. 순위 밖은 뒤에 원래 순서대로.
    NSArray *order = [popularity[@"ios"] isKindOfClass:[NSArray class]] ? popularity[@"ios"] : @[];
    if (order.count == 0 && [popularity[@"android"] isKindOfClass:[NSArray class]]) order = popularity[@"android"];
    if (order.count == 0) return live;
    NSMutableDictionary *rank = [NSMutableDictionary dictionary];
    [order enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) { if (!rank[obj]) rank[obj] = @(i); }];
    NSMutableDictionary *pos = [NSMutableDictionary dictionary];
    [live enumerateObjectsUsingBlock:^(MGEntry *e, NSUInteger i, BOOL *stop) { pos[e.gameId] = @(i); }];
    return [live sortedArrayUsingComparator:^NSComparisonResult(MGEntry *a, MGEntry *b) {
        NSUInteger ra = [rank[a.gameId] ?: @(order.count) unsignedIntegerValue];
        NSUInteger rb = [rank[b.gameId] ?: @(order.count) unsignedIntegerValue];
        if (ra != rb) return ra < rb ? NSOrderedAscending : NSOrderedDescending;
        return [pos[a.gameId] compare:pos[b.gameId]];
    }];
}

#pragma mark - Icon cache

@interface MGIconCache : NSObject
+ (instancetype)shared;
- (UIImage *)imageForEntry:(MGEntry *)e;
- (void)loadEntry:(MGEntry *)e completion:(void (^)(UIImage *image))completion;
@end

@implementation MGIconCache {
    NSCache *_memory;
}

+ (instancetype)shared
{
    static MGIconCache *s;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [MGIconCache new]; });
    return s;
}

- (instancetype)init
{
    if ((self = [super init])) _memory = [NSCache new];
    return self;
}

- (NSString *)pathFor:(MGEntry *)e
{
    return [MGCacheDir() stringByAppendingPathComponent:[NSString stringWithFormat:@"icon_%@.png", e.gameId]];
}

- (UIImage *)imageForEntry:(MGEntry *)e
{
    UIImage *img = [_memory objectForKey:e.gameId];
    if (img) return img;
    img = [UIImage imageWithContentsOfFile:[self pathFor:e]];
    if (img) [_memory setObject:img forKey:e.gameId];
    return img;
}

- (void)loadEntry:(MGEntry *)e completion:(void (^)(UIImage *image))completion
{
    if (!e.iconURL) return;
    NSString *path = [self pathFor:e];
    NSString *key = e.gameId;
    NSCache *memory = _memory;
    [[[NSURLSession sharedSession] dataTaskWithURL:e.iconURL completionHandler:^(NSData *data, NSURLResponse *resp, NSError *err) {
        NSInteger code = [resp isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse *)resp).statusCode : 0;
        UIImage *img = (code == 200 && data) ? [UIImage imageWithData:data] : nil;
        if (!img) return;
        [data writeToFile:path atomically:YES];
        [memory setObject:img forKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{ completion(img); });
    }] resume];
}

@end

#pragma mark - Cell

@interface MGGameCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *letterLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *taglineLabel;
@property (nonatomic, strong) UILabel *blurbLabel;
@property (nonatomic, copy) NSString *gameId;
@end

@implementation MGGameCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.backgroundColor = [UIColor systemBackgroundColor];

    _iconView = [UIImageView new];
    _iconView.contentMode = UIViewContentModeScaleAspectFill;
    _iconView.layer.cornerRadius = 12;
    _iconView.layer.cornerCurve = kCACornerCurveContinuous;
    _iconView.clipsToBounds = YES;
    _iconView.translatesAutoresizingMaskIntoConstraints = NO;

    _letterLabel = [UILabel new];
    _letterLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    _letterLabel.textAlignment = NSTextAlignmentCenter;
    _letterLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_iconView addSubview:_letterLabel];

    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _nameLabel.font = [UIFont systemFontOfSize:_nameLabel.font.pointSize weight:UIFontWeightSemibold];
    _nameLabel.textColor = [UIColor labelColor];
    _nameLabel.numberOfLines = 2;

    _taglineLabel = [UILabel new];
    _taglineLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _taglineLabel.textColor = [UIColor secondaryLabelColor];
    _taglineLabel.numberOfLines = 2;

    // 소개는 네 줄에서 자른다 — 공장 화면과 같다(세 줄이면 문장 가운데서 잘렸다).
    _blurbLabel = [UILabel new];
    _blurbLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _blurbLabel.textColor = [UIColor secondaryLabelColor];
    _blurbLabel.numberOfLines = 4;

    UIStackView *text = [[UIStackView alloc] initWithArrangedSubviews:@[_nameLabel, _taglineLabel, _blurbLabel]];
    text.axis = UILayoutConstraintAxisVertical;
    text.spacing = 2;
    [text setCustomSpacing:4 afterView:_taglineLabel];
    text.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightRegular];
    UIImageView *open = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"arrow.up.right.square" withConfiguration:cfg]];
    open.tintColor = [UIColor secondaryLabelColor];
    open.translatesAutoresizingMaskIntoConstraints = NO;
    [open setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [open setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    UIView *c = self.contentView;
    [c addSubview:_iconView];
    [c addSubview:text];
    [c addSubview:open];
    NSLayoutConstraint *bottom = [text.bottomAnchor constraintEqualToAnchor:c.bottomAnchor constant:-12];
    bottom.priority = UILayoutPriorityRequired - 1;
    [NSLayoutConstraint activateConstraints:@[
        // 줄이 세 층이면 아이콘을 위로 붙인다(가운데 맞춤은 글 한가운데 떠 보인다).
        [_iconView.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [_iconView.topAnchor constraintEqualToAnchor:c.topAnchor constant:12],
        [_iconView.widthAnchor constraintEqualToConstant:kMGIconSide],
        [_iconView.heightAnchor constraintEqualToConstant:kMGIconSide],
        [_iconView.bottomAnchor constraintLessThanOrEqualToAnchor:c.bottomAnchor constant:-12],
        [_letterLabel.centerXAnchor constraintEqualToAnchor:_iconView.centerXAnchor],
        [_letterLabel.centerYAnchor constraintEqualToAnchor:_iconView.centerYAnchor],
        [text.leadingAnchor constraintEqualToAnchor:_iconView.trailingAnchor constant:16],
        [text.topAnchor constraintEqualToAnchor:c.topAnchor constant:12],
        bottom,
        [open.leadingAnchor constraintEqualToAnchor:text.trailingAnchor constant:12],
        [open.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [open.topAnchor constraintEqualToAnchor:c.topAnchor constant:14],
    ]];
    return self;
}

- (void)configureWithEntry:(MGEntry *)e
{
    self.gameId = e.gameId;
    self.nameLabel.text = e.name;
    self.taglineLabel.text = e.tagline;
    self.blurbLabel.text = e.blurb;
    self.blurbLabel.hidden = (e.blurb == nil);
    self.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", e.name, e.tagline];
    self.accessibilityTraits = UIAccessibilityTraitButton;

    UIImage *img = [[MGIconCache shared] imageForEntry:e];
    [self showIcon:img entry:e];
    if (!img) {
        __weak MGGameCell *weakSelf = self;
        NSString *gid = e.gameId;
        [[MGIconCache shared] loadEntry:e completion:^(UIImage *image) {
            MGGameCell *cell = weakSelf;
            if ([cell.gameId isEqualToString:gid]) [cell showIcon:image entry:e];
        }];
    }
}

/// 아이콘이 없으면 바탕색 한 장에 첫 글자 — 빈 칸은 안 둔다.
- (void)showIcon:(UIImage *)img entry:(MGEntry *)e
{
    self.iconView.image = img;
    self.letterLabel.hidden = (img != nil);
    UIColor *bg = e.color ?: [UIColor tertiarySystemFillColor];
    self.iconView.backgroundColor = img ? [UIColor clearColor] : bg;
    self.letterLabel.text = e.fallbackLetter;
    CGFloat r = 0, g = 0, b = 0, a = 0;
    [bg getRed:&r green:&g blue:&b alpha:&a];
    BOOL dark = (0.299 * r + 0.587 * g + 0.114 * b) < 0.6;
    self.letterLabel.textColor = (e.color && dark) ? [UIColor whiteColor] : [UIColor labelColor];
}

@end

#pragma mark - Controller

@interface MoreGamesViewController () <UITableViewDataSource, UITableViewDelegate, SKStoreProductViewControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *introLabel;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, copy) NSArray<MGEntry *> *entries;
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, copy) void (^onDismiss)(void);
@end

/// 지금 떠 있는 More Games 화면. 게임 타이머가 이것을 보고 다시 돌지 않는다.
static __weak MoreGamesViewController *sShowing = nil;

@implementation MoreGamesViewController

+ (UIViewController *)topViewController
{
    UIWindow *window = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        for (UIWindow *w in ((UIWindowScene *)scene).windows)
            if (w.isKeyWindow) { window = w; break; }
        if (window) break;
    }
    if (!window) window = [UIApplication sharedApplication].delegate.window;
    UIViewController *top = window.rootViewController;
    while (top.presentedViewController && !top.presentedViewController.isBeingDismissed)
        top = top.presentedViewController;
    return top;
}

+ (BOOL)isShowing
{
    return sShowing != nil;
}

+ (void)presentFromTopViewController
{
    [self presentFromTopViewControllerOnDismiss:nil];
}

+ (void)presentFromTopViewControllerOnDismiss:(void (^)(void))onDismiss
{
    UIViewController *top = [self topViewController];
    // 띄울 곳이 없거나 이미 떠 있으면 곧바로 돌려준다 — 부른 쪽이 멈춘 것을 되살릴 수 있게.
    if (!top || sShowing) {
        if (onDismiss) onDismiss();
        return;
    }
    MoreGamesViewController *vc = [self new];
    vc.onDismiss = onDismiss;
    sShowing = vc;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [top presentViewController:nav animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = gettext(@"More Games", nil);
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    UINavigationBarAppearance *bar = [UINavigationBarAppearance new];
    [bar configureWithOpaqueBackground];
    bar.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationItem.standardAppearance = bar;
    self.navigationItem.scrollEdgeAppearance = bar;
    self.navigationItem.compactAppearance = bar;

    // 닫기: 뒤로 꺾쇠 + 「닫기」. dismiss 로 원래 화면에 돌아온다.
    UIButtonConfiguration *cfg = [UIButtonConfiguration plainButtonConfiguration];
    cfg.image = [UIImage systemImageNamed:@"chevron.backward"
                        withConfiguration:[UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightSemibold]];
    cfg.imagePadding = 4;
    cfg.title = gettext(@"Close", nil);
    cfg.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, 0, 0);
    UIButton *close = [UIButton buttonWithConfiguration:cfg primaryAction:nil];
    [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    close.accessibilityIdentifier = @"moreGamesClose";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:close];

    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tv.dataSource = self;
    tv.delegate = self;
    tv.backgroundColor = [UIColor systemBackgroundColor];
    tv.separatorInset = UIEdgeInsetsZero;
    tv.layoutMargins = UIEdgeInsetsZero;
    tv.cellLayoutMarginsFollowReadableWidth = NO;
    tv.rowHeight = UITableViewAutomaticDimension;
    tv.estimatedRowHeight = 110;
    tv.sectionHeaderTopPadding = 0;
    tv.tableFooterView = [UIView new];
    [tv registerClass:[MGGameCell class] forCellReuseIdentifier:@"game"];
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tv];
    self.tableView = tv;

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    NSLayoutConstraint *fill = [tv.widthAnchor constraintEqualToAnchor:safe.widthAnchor];
    fill.priority = UILayoutPriorityDefaultHigh;
    [NSLayoutConstraint activateConstraints:@[
        [tv.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [tv.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [tv.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor],
        [tv.widthAnchor constraintLessThanOrEqualToConstant:kMGMaxContentWidth],
        [tv.widthAnchor constraintLessThanOrEqualToAnchor:safe.widthAnchor],
        fill,
    ]];

    // 머리 한 줄 — 왜 이 목록을 보고 있나.
    self.introLabel = [UILabel new];
    self.introLabel.text = gettext(@"MoreGamesIntro", nil);
    self.introLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.introLabel.textColor = [UIColor secondaryLabelColor];
    self.introLabel.numberOfLines = 0;

    self.emptyLabel = [UILabel new];
    self.emptyLabel.text = gettext(@"MoreGamesEmpty", nil);
    self.emptyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.emptyLabel.textColor = [UIColor secondaryLabelColor];
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.hidden = YES;
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.emptyLabel];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.spinner];
    [NSLayoutConstraint activateConstraints:@[
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:safe.centerYAnchor],
        [self.emptyLabel.leadingAnchor constraintEqualToAnchor:tv.leadingAnchor constant:32],
        [self.emptyLabel.trailingAnchor constraintEqualToAnchor:tv.trailingAnchor constant:-32],
        [self.spinner.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor],
        [self.spinner.centerYAnchor constraintEqualToAnchor:safe.centerYAnchor],
    ]];

    [self loadLocal];
    [self refreshFromNetwork];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat w = self.tableView.bounds.size.width;
    if (w <= 0) return;
    CGSize fit = [self.introLabel sizeThatFits:CGSizeMake(w - 32, CGFLOAT_MAX)];
    CGFloat h = ceil(fit.height) + 16 + 12;
    UIView *header = self.tableView.tableHeaderView;
    if (!header || fabs(header.frame.size.width - w) > 0.5 || fabs(header.frame.size.height - h) > 0.5) {
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        self.introLabel.frame = CGRectMake(16, 16, w - 32, ceil(fit.height));
        [header addSubview:self.introLabel];
        self.tableView.tableHeaderView = header;
    }
}

- (void)close
{
    void (^done)(void) = self.onDismiss;
    self.onDismiss = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        sShowing = nil;
        if (done) done();
    }];
}

#pragma mark Data

- (void)applyGames:(NSDictionary *)games lang:(NSDictionary *)lang popularity:(NSDictionary *)pop
{
    if (!games) return;
    self.entries = MGBuildEntries(games, lang, pop);
    self.loaded = YES;
    [self updateState];
}

- (void)updateState
{
    BOOL empty = self.loaded && self.entries.count == 0;
    if (self.loaded) [self.spinner stopAnimating]; else [self.spinner startAnimating];
    self.emptyLabel.hidden = !empty;
    self.tableView.hidden = !self.loaded || empty;
    [self.tableView reloadData];
}

- (void)loadLocal
{
    NSString *lang = MGCatalogLang();
    [self applyGames:MGLoadLocal(@"games.json")
                lang:lang ? MGLoadLocal([NSString stringWithFormat:@"games_%@.json", lang]) : nil
          popularity:MGLoadLocal(@"popularity.json")];
    [self updateState];
}

- (void)refreshFromNetwork
{
    NSString *lang = MGCatalogLang();
    NSMutableArray *files = [NSMutableArray arrayWithObjects:@"games.json", @"popularity.json", nil];
    if (lang) [files addObject:[NSString stringWithFormat:@"games_%@.json", lang]];

    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    conf.timeoutIntervalForRequest = 10;
    conf.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf];
    NSMutableDictionary *got = [NSMutableDictionary dictionary];
    dispatch_group_t group = dispatch_group_create();
    for (NSString *file in files) {
        dispatch_group_enter(group);
        NSURL *url = [NSURL URLWithString:[kMGBaseURL stringByAppendingString:file]];
        [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *resp, NSError *err) {
            NSInteger code = [resp isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse *)resp).statusCode : 0;
            // 언어 파일이 아직 없으면(404) 영어로 내려간다. 읽을 수 있는 JSON 만 캐시에 둔다.
            if (code == 200 && MGParseJSON(data)) {
                [data writeToFile:[MGCacheDir() stringByAppendingPathComponent:file] atomically:YES];
                @synchronized (got) { got[file] = MGParseJSON(data); }
            }
            dispatch_group_leave(group);
        }] resume];
    }
    [session finishTasksAndInvalidate];
    __weak MoreGamesViewController *weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        MoreGamesViewController *me = weakSelf;
        if (!me) return;
        if (got[@"games.json"]) {
            NSString *langFile = lang ? [NSString stringWithFormat:@"games_%@.json", lang] : nil;
            [me applyGames:got[@"games.json"]
                      lang:langFile ? (got[langFile] ?: MGLoadLocal(langFile)) : nil
                popularity:got[@"popularity.json"] ?: MGLoadLocal(@"popularity.json")];
        } else if (!me.loaded) {
            me.loaded = YES; // 망도 캐시도 내장본도 없다 — 빈 자리를 설명한다.
            [me updateState];
        }
    });
}

#pragma mark Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGGameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"game" forIndexPath:indexPath];
    [cell configureWithEntry:self.entries[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self openStore:self.entries[indexPath.row].appStoreId];
}

#pragma mark Store

/// 앱 안 스토어 시트. 못 띄우면 App Store 앱의 앱 페이지(apps.apple.com/app/id…) — Music 으로 새지 않는다.
- (void)openStore:(NSString *)appStoreId
{
    SKStoreProductViewController *store = [SKStoreProductViewController new];
    store.delegate = self;
    __weak MoreGamesViewController *weakSelf = self;
    [store loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: @([appStoreId longLongValue])}
                     completionBlock:^(BOOL result, NSError *error) {
        if (result) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf dismissStore:store thenOpen:appStoreId];
        });
    }];
    [self presentViewController:store animated:YES completion:nil];
}

- (void)dismissStore:(SKStoreProductViewController *)store thenOpen:(NSString *)appStoreId
{
    void (^open)(void) = ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apps.apple.com/app/id%@", appStoreId]];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    };
    if (self.presentedViewController == store) [self dismissViewControllerAnimated:YES completion:open];
    else open();
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Debug

#ifdef DEBUG
/// 디버그 빌드 전용: 실행 인자 -MoreGamesOnLaunch 를 주면 앱이 뜨자마자 이 화면을 연다.
/// 시뮬레이터는 입력을 못 넣으므로 메뉴까지 못 갈 때 화면을 찍는 용도다. 이때 ATT 창은 묻지 않는다
/// (MainViewController 의 ATT 요청이 MGDebugMoreGamesOnLaunch() 를 보고 건너뛴다). Release 에는 없다.
BOOL MGDebugMoreGamesOnLaunch(void)
{
    return [[NSProcessInfo processInfo].arguments containsObject:@"-MoreGamesOnLaunch"];
}

+ (void)load
{
    if (!MGDebugMoreGamesOnLaunch()) return;
    dispatch_async(dispatch_get_main_queue(), ^{ [MoreGamesViewController debugPresentAttempt:0]; });
}

/// 시작 직후에는 다른 창이 먼저 떠 있을 수 있어 1초마다 다시 시도한다.
+ (void)debugPresentAttempt:(int)n
{
    if (n > 20) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *top = [self topViewController];
        BOOL shown = [top isKindOfClass:[UINavigationController class]] &&
            [((UINavigationController *)top).viewControllers.firstObject isKindOfClass:self];
        NSLog(@"[MoreGames] debug present attempt %d top=%@ shown=%d", n, top, shown);
        if (shown) return;
        [self presentFromTopViewController];
        [self debugPresentAttempt:n + 1];
    });
}
#endif

@end
