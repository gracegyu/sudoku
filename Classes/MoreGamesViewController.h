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

@end

#ifdef DEBUG
/// 디버그 빌드에서 실행 인자 -MoreGamesOnLaunch 가 있으면 YES (시뮬레이터 촬영용, ATT 를 묻지 않는다).
FOUNDATION_EXPORT BOOL MGDebugMoreGamesOnLaunch(void);
#endif
