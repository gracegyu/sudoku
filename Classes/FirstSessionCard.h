//
//  FirstSessionCard.h
//
//  첫 세션 안내 카드 (factory A468 R1, LEGACY_APPS_PLAN §1-3 「첫 세션 튜토리얼 · 첫 판 도우미」).
//  처음 설치해 저장된 판이 없을 때 한 번만 뜬다 — 규칙 그림(도움말의 help6_1 · help9_1) +
//  규칙 한 줄(6x6 은 2×3 상자, 9x9 는 3×3 상자) + 넣는 법 한 줄 + 「첫 판은 매우 쉬움」.
//  [규칙을 알아요] 로 건너뛸 수 있다 (6x6 규칙을 아는 사람 — 문서의 위험 칸).
//
//  모달 창(present)이 아니라 앱 화면 위에 얹는 뷰다 — 첫 실행에는 동의(UMP) 폼 · ATT · Game Center 가
//  같은 때 뜨는데, 모달끼리는 서로를 막는다. 얹은 뷰는 그것들 아래에 있다가 닫히면 보인다.
//
//  네 타깃 공용. 6 · 9 는 SUDOKU9 깃발로 가른다. ARC (-fobjc-arc).
//

#import <UIKit/UIKit.h>

@interface FirstSessionCard : UIView

/// firstLevelName: 첫 판 난이도 이름(이미 번역된 글자).
- (instancetype)initWithFirstLevelName:(NSString *)firstLevelName;

/// 닫힐 때 (skipped = [규칙을 알아요]). 뷰는 이미 화면에서 빠진 뒤다.
@property (nonatomic, copy) void (^onClose)(BOOL skipped);

- (void)showInView:(UIView *)host;

@end
