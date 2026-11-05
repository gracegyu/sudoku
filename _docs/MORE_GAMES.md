# More Games 배치 (2026-11)

공장(factory) 저장소 `LEGACY_APPS_PLAN.md` §7 의 추천을 따른다.

## 위치별 검토

| 위치 | 장점 | 위험 | 이번 |
|---|---|---|---|
| 게임 화면 상시 아이콘 | 항상 보임 | 기종별 xib 가 여럿이고 판 크기가 빠듯하다. 오터치가 늘고 판이 가려질 수 있다 | 안 함 |
| 팝업 메뉴 첫 항목 | 홈이 없는 앱에서 가장 먼저 보이는 목록 | 메뉴 틀이 고정이라 줄 간격을 줄여야 한다 | **함** |
| Congratulations 창 단추 | 퍼즐을 깬 직후라 관심이 가장 높다 | 전면 광고 흐름을 건드릴 수 있다 | **함** (OK 흐름은 그대로) |
| 설정 | 이미 있던 자리 | 눈에 안 띈다 | 같은 곳으로 모음 |

## 동작

- 모두 `+[Locale openMoreGames]` 한 곳을 부른다. 이 함수는 앱 안 **More Games 화면**(`Classes/MoreGamesViewController.m`)을 전체 화면으로 띄운다. 「닫기」는 dismiss 로 원래 화면에 돌아온다.
  - 2026-11-05 이전에는 `http://itunes.apple.com/artist/abc-consulting/id353770805` 를 열었다. `itunes.apple.com/artist/…` 는 Apple Music 아티스트 주소 꼴이라 iOS 가 **Music 앱**으로 보냈다(사람 보고). id 자체는 맞는 개발자 id 였다.
  - 화면은 공장 More games(ga_ui `GaMoreGamesScreen`)와 같은 꼴을 UIKit 로 옮겼다: 머리 한 줄, 48pt 둥근 아이콘·이름·한 줄 설명·소개(4줄)·바깥 열기 표시, 줄 사이 선, 본문 폭 ≤460pt, 다크 모드는 시스템 색.
  - WKWebView 로 `more_games_<lang>.html` 을 띄우는 길은 쓰지 않았다 — 그 HTML 은 카드+「Get」 알약 꼴이라 공장 화면과 다르다.
  - 데이터: `https://raymond-game-factory3.web.app/catalog/v1/` 의 `games.json` · `games_<lang>.json`(ko·ja·zh-Hans·zh-Hant, 없으면 영어) · `popularity.json`. 받은 것은 Caches/MoreGames 에, 망이 없으면 캐시 → 번들 내장본 `resource/MoreGames/moregames_*.json` 순. 아이콘은 `icon/<id>.png` 를 받아 캐시하고, 없으면 바탕색+첫 글자.
  - 보이는 것: group 이 factory·legacy_flutter 이고 iOS 에 공개(live+id)된 줄만, 자기 앱 제외. 2026-11-05 기준 11개.
  - 누르면 `SKStoreProductViewController`(앱 안 스토어 시트), 못 띄우면 `https://apps.apple.com/app/id<ID>`.
  - 디버그 빌드에서 실행 인자 `-MoreGamesOnLaunch` 를 주면 시작하자마자 이 화면을 띄우고 ATT 를 묻지 않는다(시뮬레이터 촬영용, `#ifdef DEBUG`).
- 메뉴: 맨 위 단추를 복제해 맨 위에 끼우고 아래 줄 간격을 줄인다(xib 는 그대로). 왼쪽 그림은 줄을 따라 옮기고, 새 줄에는 SF Symbol `square.grid.2x2.fill`.
- 완료 창: OK(전면 광고 호출 그대로) 옆에 More Games. 이것을 고르면 그 판의 전면 광고는 보이지 않는다(앱 밖으로 나가므로 돌아와 띄우지 않는다). 광고 조건 카운터는 바꾸지 않았다.
- 문구 `More Games` 는 en·ko·ja·zh_CN·zh_TW `Localizable.strings` 에 넣었다.
