# 백로그 — sudoku2 (Sudoku9 · Sudoku9Pro · Sudoku6 · Sudoku6Pro)

네 앱이 코드베이스 하나를 공유한다. 여기 적은 것은 대개 **네 앱 전부**에
해당한다.

> **Sudoku9 는 전체 앱 수입의 절반을 낸다.** 이 저장소의 변경은 다른
> 저장소보다 한 단계 더 조심한다 — 한 번에 하나씩 바꾸고, 바꾼 것마다
> 따로 확인한다.

## 쓰는 법

- 번호는 `B-1` 부터 붙이고 **다시 쓰지 않는다.** 항목을 빼도 번호는 비워 둔다.
- 다른 항목을 가리킬 때는 **번호가 아니라 이름**으로 쓴다.
- 상태는 넷이다 — **Open** · In Progress · Done · Cancelled.
  **굵게 쓰는 것은 `Open` 뿐이다.**
- **`Done` 으로 옮기기 전에 그것을 확인한 방법을 남긴다.**
- **`Cancelled` 는 지우는 것과 다르다** — `Open` 은 조건이 오면 한다,
  `Cancelled` 는 조건이 와도 안 한다.
- **`[사람]`** 은 저장소 밖이라 에이전트가 못 하는 것이다 (콘솔·계정·결정).

---

| # | 상태 | 우선 | 받은 날 | 항목 |
|:---:|:---:|:---:|---|---|
| B-1 | In Progress | **P1** | 2026-09-19 | **AdMob 정책 위반 해소 — GDPR 동의(UMP) 도입.** SDK 7.69 → 13.9 · 실기 확인 통과 · **4.940 심사 제출 완료.** 심사 결과와 정책 센터 대기 |
| B-2 | **Open** | P3 | 2026-09-19 | **후보 계산(CALCCANDI)에 보상형 광고를 붙인다** — 유닛은 만들어져 있는데 **기능이 없다.** 어떻게 열어줄지 결정이 필요하다 `[사람]` |
| B-3 | **Open** | P2 | 2026-09-19 | **나머지 세 앱(Sudoku9Pro · Sudoku6 · Sudoku6Pro)을 올린다** — 코드는 이미 고쳐져 있다. Sudoku9 심사 결과를 보고 움직인다 |

---

## B-1 · AdMob 정책 위반 해소 (UMP 도입)

**상태: In Progress** · 우선 P1 · 2026-09-19

AdMob 정책 센터가 Sudoku 9(iOS)에 「동의 요건: CMP 없음」을 띄웠다
(2026-09-12 신고 · 최근 7일 광고 요청 8.01천 · **제한된 광고 개인 최적화**).

EEA·영국·스위스 사용자에게 개인 맞춤 광고를 내보내려면 IAB TCF 에 등록된
인증 CMP 를 써야 한다. 콘솔에 GDPR 메시지는 만들어 두었지만 **앱이 UMP SDK 를
부르지 않아** 광고 요청에 TC 문자열이 붙지 않았다.

정본 계획: `../../GitFlutter/_docs/UMP_PLAN.md` §7 (트랙 B)

### 왜 SDK 업그레이드가 먼저였나

`canRequestAds` 같은 현행 UMP API 는 **2.1.0**(2023-07) 부터다. 이 저장소는
UMP **1.4.0** 이 딸려 있었는데, GMA 7.69 가 `GoogleUserMessagingPlatform
(~> 1.1)` 로 **상한을 걸어** UMP 만 올릴 수도 없었다.

최신 GMA 13.9.0 은 의존성이 `>= 1.1` 이라 상한이 없다.

podspec 의 배포 타겟은 `ios 12.0` 이라 **SDK 쪽에서는 타겟을 안 올려도 된다.**
다만 그것과 별개로 **App Store 가 12.0 업로드를 거부**해서 결국 15.0 으로
올렸다 (아래 「네 번 막혔다」 ④).

### 진행

- [x] `Google-Mobile-Ads-SDK` 7.69.0 → **13.9.0**
- [x] `GoogleUserMessagingPlatform` 1.4.0 → **3.1.0**
- [x] Podfile source 를 CDN 으로 (git Specs repo 가 낡아 13.x 를 못 찾았다)
- [x] 광고 API 마이그레이션 — 아래 표
- [x] 빌드 통과 (`sudoku9free` · 시뮬레이터)
- [x] UMP 도입 (`requestConsentThenStartAds` → ATT → `startMobileAdsIfAllowed`)
- [x] fastlane 구축 — 네 앱 선택 배포 (`./deploy.sh testflight sudoku9free`)
- [x] **TestFlight 4.940 업로드** (2026-09-19 19:40)
- [x] **실기 확인** (2026-09-19) — 앱 실행 · 배너 · 전면 · **보상형 힌트 5개 지급** ·
      중간 종료 시 미지급 · ATT 프롬프트, 전부 정상
- [x] 릴리스 노트 5개 언어 (`fastlane/metadata/`)
- [x] 연령 등급 설문 `[사람]` (2026-09-19)
- [x] **4.940 심사 제출** (2026-09-19 21:43) — `./deploy.sh submit sudoku9free`
- [ ] 심사 결과 `[사람]`
- [ ] 정책 센터에서 경고가 사라지는지 `[사람]` — 최대 48시간 + 신버전 확산

SDK 업그레이드와 UMP 를 한 빌드에 담았다. 원래는 나눠서 검증하려 했으나
**SDK 를 올리지 않으면 UMP 를 쓸 수 없어서** 나눌 수가 없었다 (UMP 1.4.0 에는
`canRequestAds` 가 없다). 그래서 확인 목록을 두 덩어리로 갈라 둔다.

### 바꾼 API

| 옛 API (7.x) | 새 API (13.x) |
|---|---|
| `configureWithApplicationID:` | `startWithCompletionHandler:` + Info.plist `GADApplicationIdentifier` |
| `GADInterstitial` + delegate | `GADInterstitialAd` + completionHandler |
| `GADRewardBasedVideoAd` (싱글턴) | `GADRewardedAd` (인스턴스) |
| `GADInterstitialDelegate` · `GADRewardBasedVideoAdDelegate` | `GADFullScreenContentDelegate` 하나로 |
| `adView*` 배너 delegate 6종 | `bannerView*` |
| `GADRequestError` | `NSError` |
| `request.testDevices` | `requestConfiguration.testDeviceIdentifiers` |

`Info.plist` 는 네 타겟 모두 `GADApplicationIdentifier` 가 이미 들어 있었고
`Constants.h` 값과 일치했다 — 손댈 것이 없었다.

### 확인한 것 (2026-09-19 · 전부 통과)

1. **앱이 뜨는가** — `GADApplicationIdentifier` 가 없으면 SDK 8.0+ 는 실행
   즉시 죽는다
2. 배너가 뜨는가 — delegate 이름이 전부 바뀌었다
3. 전면광고가 뜨는가 — 로드가 delegate 에서 콜백으로 바뀌었다
4. **보상형: 비디오를 끝까지 본 뒤 힌트가 5개 느는가** — 보상 지급 경로가
   `didRewardUserWithReward:` 에서 `userDidEarnRewardHandler:` 로 옮겼다.
   **비디오는 뜨는데 힌트가 안 늘면 여기다**
5. 중간에 닫으면 보상이 **안 주어지는가**
6. 광고를 본 뒤 다시 누르면 또 뜨는가 (재로드)
7. ATT 프롬프트 (첫 실행 · 1초 뒤)
8. iPad 배너 (크기가 다르다)

### 배포가 여섯 번 막혔다 — 전부 설정 문제였다

코드는 처음부터 빌드되고 있었다. 다음에 같은 자리에서 헤매지 않게 적어 둔다.

| # | 막힌 것 | 푼 방법 |
|---|---|---|
| ① | `No Accounts` · `No profiles for ...` | Xcode 에 Apple 계정이 없다. **ASC API 키로 프로필을 받아 수동 서명**으로 고정 |
| ② | `Could not find option 'app_store'` | `get_provisioning_profile` 에 그런 옵션이 없다. App Store 용이 기본값 |
| ③ | `Invalid Pre-Release Train. '4.930' is closed` | 이미 출시된 버전에는 새 빌드를 못 올린다 → **4.940** |
| ④ | `MinimumOSVersion '12.0' is not acceptable` | **SDK 가 지원하는 것과 Apple 이 받는 것은 다르다** → 배포 타겟 **15.0** |
| ⑤ | `You must provide a value for 'whatsNew'` | 새 버전에는 릴리스 노트가 필수 → `fastlane/metadata/<locale>/release_notes.txt` |
| ⑥ | `gunsOrOtherWeapons` 등 8개 누락 | **연령 등급 설문.** 게임 내용 판단이라 사람이 콘솔에서 한 번 답한다 — 그 뒤로는 자동 제출이 계속 동작한다 |

④ 가 특히 헷갈린다. GMA 13.9.0 의 podspec 은 `ios 12.0` 이라 타겟을 안 올려도
되는 줄 알았는데, App Store 업로드 쪽에서 막는다. **iOS 15 미만 기기는 앞으로
업데이트를 받지 못한다** — 되돌리려면 12.0 으로 낮출 수 있지만 그러면 업로드
자체가 안 된다.

### 곁가지

보상형을 읽는 코드가 이랬다:

```objc
[[GADRewardBasedVideoAd sharedInstance] loadRequest:... withAdUnitID:MY_HINT_REWARD_UNIT_ID];
[[GADRewardBasedVideoAd sharedInstance] loadRequest:... withAdUnitID:MY_CALCCANDI_REWARD_UNIT_ID];
```

**싱글턴이라 뒤엣것이 앞엣것을 덮어쓴다.** 실제로는 CALCCANDI 만 살아 있다가
광고를 닫고 재로드할 때 HINT 로 바뀌는 상태였다. 화면에서 쓰는 곳은 힌트뿐이라
**힌트 유닛 하나만** 읽도록 정리했다. CALCCANDI 는 `B-2` 로 넘긴다.

---

## B-2 · 후보 계산(CALCCANDI)에 보상형 광고를 붙인다

**상태: Open** · 우선 P3 · 2026-09-19 · **방향은 B안으로 정함**

### 지금 상태 — 「빠진」 것이 아니라 처음부터 없었다

```
Constants.h   MY_CALCCANDI_REWARD_UNIT_ID   네 타겟 × iPhone/iPad = 8개 유닛
코드           기능 구현 0줄
```

AdMob 콘솔에는 유닛이 만들어져 있는데 **앱에서 그것을 소비하는 코드가 없다.**
로드만 하고 아무 데서도 쓰지 않았다 (`B-1` 곁가지 참조).

### 후보 계산에 해당하는 기존 기능

`AutoMemo` 다.

```objc
mainView.bSettingAutoMemo                                  // 설정 체크박스
[[SudokuGame alloc] init... automemo:bSettingAutoMemo]     // 새 게임 시작 시 결정
```

**지금은 무료·무제한**이고, **게임을 시작하는 시점에만** 정해진다. 게임 도중
변경은 버그가 있어 막아 둔 흔적이 있다 (`MainViewController.m:3491` 주석).

### 정한 방향 — B안

> **게임 중에 쓰는 「후보 채우기」 액션을 새로 만들고, 광고를 보면 쓸 수 있게
> 한다.** 힌트와 같은 결의 소모성 기능이다.

유닛 이름(CALCCANDI = 후보 계산)이 가리키는 원래 의도로 보인다. AutoMemo 를
끄고 시작한 사람이 막히는 순간 한 번 쓰는 그림이다.

**고르지 않은 것과 그 이유:**

- **A안 — 지금 무료인 AutoMemo 를 광고로 제한한다.**
  쓰던 것을 막는 것이라 반발이 크다. 수입의 절반을 내는 앱에서 할 일이 아니다.
- **C안 — AutoMemo 를 켠 채로 새 게임을 시작할 때 광고를 보여준다.**
  시작마다 마찰이 생겨 이탈 위험이 있다.

`Cancelled` 로 따로 적지 않고 여기 남긴다 — 반년 뒤에 같은 제안이 올라오면
이 문단이 답이다.

### 할 일

- [ ] **게임 중 후보 채우기 로직** — `SudokuGame` 의 automemo 초기화 경로에
      이미 비슷한 계산이 있다. 그것을 게임 도중에도 부를 수 있게 꺼낸다
- [ ] 되돌리기(Undo)와 어떻게 맞물릴지 정한다 — 후보를 한꺼번에 채우면
      `SudokuUndo` 에 한 덩어리로 들어가야 한다
- [ ] 버튼 UI — 힌트 버튼 옆이 자연스럽다
- [ ] `GADRewardedAd` 인스턴스를 **하나 더** 들고 `MY_CALCCANDI_REWARD_UNIT_ID`
      로 읽는다. `GADFullScreenContentDelegate` 에서 힌트용과 구분해야 한다
      (지금은 `isKindOfClass:` 로 전면/보상형만 가른다 — 보상형이 둘이 되면
      인스턴스 비교가 필요하다)
- [ ] 난이도 영향 확인 `[사람]` — 후보를 언제든 채울 수 있으면 게임이 쉬워진다.
      횟수·쿨다운을 둘지 정한다

### 언제 하나

**`B-1` 이 끝난 뒤.** SDK 업그레이드·UMP 검증과 섞으면 광고가 이상할 때 원인을
못 가린다. 빌드를 나눠서 올린다.

---

## B-3 · 나머지 세 앱을 올린다

**상태: Open** · 우선 P2 · 2026-09-19

### 코드는 이미 다 되어 있다

네 앱이 **코드베이스 하나**를 공유한다. `B-1` 에서 고친 것이 이미 넷 모두에
들어가 있다 — UMP, SDK 13.9, 광고 API 마이그레이션, 배포 타겟 15.0, 버전
4.940. 빌드해서 올리기만 하면 된다.

```sh
./deploy.sh testflight sudoku9paid sudoku6free sudoku6paid   # 먼저 확인
./deploy.sh submit     sudoku9paid sudoku6free sudoku6paid   # 그 빌드를 제출
```

### 왜 Sudoku9 결과를 기다리나

**심사에서 걸리면 세 앱까지 같이 걸린다.** 이번 변경은 SDK 메이저 업그레이드
(7.69 → 13.9)와 UMP 도입이 함께 들어갔고, 둘 다 심사에서 새로 보는 항목이다:

- ATT 프롬프트 순서 (Guideline 2.1)
- 광고 SDK 동작
- 개인정보 처리 (UMP)

Sudoku9 하나가 통과하면 나머지는 **같은 코드**라 통과할 것으로 본다. 반대로
걸리면 그 사유를 고친 뒤에 넷을 한꺼번에 올리는 편이 빠르다.

### 앱마다 다른 것

**Paid 판에는 배너·전면 광고가 없다** (`ADMOB_FREEVERSION` 매크로로 갈린다).
보상형은 있을 수 있으니 확인이 필요하다. 광고가 없으면 UMP 동의를 받을 이유도
줄지만, 보상형이 남아 있으면 그대로 필요하다.

- [ ] Sudoku9 심사 결과 확인 `[사람]`
- [ ] 통과하면 세 앱 TestFlight → 실기 확인 → 심사 제출
- [ ] Paid 판에서 광고가 실제로 어디까지 쓰이는지 확인 (보상형만인지)
- [ ] 걸렸으면 사유를 고치고 **넷을 함께** 올린다

### 버전

네 타겟이 같은 `MARKETING_VERSION`(4.940)을 쓴다. Sudoku9 가 4.940 으로
심사에 들어갔으니, 나머지 셋도 그대로 올릴 수 있다 — 앱이 다르면 버전이
겹쳐도 무방하다. 다만 **한 앱 안에서는** 같은 (버전, 빌드) 조합을 두 번 쓸 수
없다.
