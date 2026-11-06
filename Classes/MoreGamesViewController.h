//
//  MoreGamesViewController.h
//
//  공장(factory) 앱의 More games 화면(ga_ui GaMoreGamesScreen)을 UIKit 로 옮긴 것.
//  sudoku2 · tetrasquare 두 저장소에 같은 파일이 있다 — 고치면 양쪽을 같이 고친다.
//
//  데이터: https://raymond-game-factory3.web.app/catalog/v1/ 의 games.json ·
//  games_<lang>.json · popularity.json. 받은 것은 Caches 에 두고, 망이 없으면
//  캐시 → 앱 번들 내장본(moregames_*.json) 순으로 내려간다.
//
//  이 파일은 ARC 로 컴파일한다(-fobjc-arc). 프로젝트 기본은 MRC 다.
//

#import <UIKit/UIKit.h>

@interface MoreGamesViewController : UIViewController

/// 지금 맨 위 화면 위에 More Games 를 전체 화면으로 띄운다. 닫기는 dismiss 로 원래 화면에 돌아온다.
+ (void)presentFromTopViewController;

/// 위와 같고, 닫기(dismiss) 가 끝나면 onDismiss 를 부른다. 띄우지 못했으면 곧바로 부른다.
+ (void)presentFromTopViewControllerOnDismiss:(void (^)(void))onDismiss;

/// More Games 화면이 떠 있나. 떠 있는 동안 게임 타이머를 다시 돌리지 않는 데 쓴다.
+ (BOOL)isShowing;

/// 새 앱 출시 표시(빨간 점). 보이는 live 앱 중 iOS 출시일이 30일(kMGNewDays) 이내이고 More Games 에서
/// 본 적 없는 id 가 있으면 YES. 첫 실행도 같은 규칙. More Games 를 열면 본 것으로 친다 (판정 MGNewDot.h).
+ (BOOL)hasNewApps;

/// 카탈로그(games.json)를 백그라운드로 받아 캐시에 두고 점을 갱신한다. 앱 시작 · 포그라운드 복귀 때 부른다.
+ (void)refreshNewAppsBadge;

/// host 에 빨간 점을 단다(이미 있으면 갱신만). 점은 상태가 바뀌면 스스로 켜고 끈다.
/// afterTitle=YES 면 UIButton 제목 글자 오른쪽 옆, NO 면 host 오른쪽 위 모서리.
+ (void)attachNewDotToView:(UIView *)host afterTitleOfButton:(BOOL)afterTitle;

@end

/// 새 앱 표시 상태가 바뀌었을 때(main 큐) 올라오는 알림.
FOUNDATION_EXPORT NSString *const MoreGamesNewAppsDidChangeNotification;

#ifdef DEBUG
/// 디버그 빌드에서 실행 인자 -MoreGamesOnLaunch 가 있으면 YES (시뮬레이터 촬영용, ATT 를 묻지 않는다).
FOUNDATION_EXPORT BOOL MGDebugMoreGamesOnLaunch(void);
/// 디버그 빌드에서 -MoreGamesNewDotDemo 가 있으면 YES (새 앱 점 촬영용, ATT 를 묻지 않는다).
FOUNDATION_EXPORT BOOL MGDebugNewDotDemo(void);
#endif
