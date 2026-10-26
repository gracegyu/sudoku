#!/bin/bash
# sudoku2 배포 — 네 앱을 고르거나 전부.
#
#   ./deploy.sh testflight                      네 앱 전부 TestFlight
#   ./deploy.sh testflight sudoku9free          하나만
#   ./deploy.sh submit sudoku9free              TestFlight 빌드를 그대로 심사 제출
#   ./deploy.sh appstore sudoku9free sudoku9paid  새로 빌드해서 심사 제출
#   ./deploy.sh build sudoku9free               빌드만 (올리지 않는다)
#
#   ./deploy.sh creative sudoku9free sudoku9paid    검색 결과·헤더 그림을 올려 심사 제출
#   ./deploy.sh creative-status sudoku9free         심사 상태
#   ./deploy.sh creative-place sudoku9free          승인된 그림을 판매 중 버전에 꽂는다
#
# 크리에이티브 그림은 `tools/creative/make_*.sh` 로 만든다 (fastlane/creative/).
# 올리는 도구는 GitFlutter/tools/asc_creative 다 — fastlane 은 Asset Library 를
# 지원하지 않는다 (2026-10 기준).
#
# GitFlutter/deploy_all.sh 와 같은 결로 만들었다. 다만 **타입 하나가 한 가지
# 일만 한다** — 거기서는 `all` 이 네 단계를 다 돌아서 같은 버전 코드를 두 번
# 올리다 막혔다 (GitFlutter/_docs/BACKLOG.md B-8).

set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ALL_APPS=(sudoku9free sudoku9paid sudoku6free sudoku6paid)

usage() {
    echo -e "${YELLOW}사용법: ./deploy.sh <타입> [앱 ...]${NC}"
    echo "  타입: testflight | submit | appstore | build"
    echo "  앱을 생략하면 넷 전부. 이름을 주면 그것만."
    echo
    echo "  testflight  - TestFlight (내부 테스터 · 베타 심사 없음)"
    echo "  submit      - **이미 TestFlight 에 올라간 빌드**를 심사 제출 (새로 빌드 안 함)"
    echo "  appstore    - 새로 빌드해서 업로드 + 심사 제출"
    echo "  build       - 빌드만. 올리지 않는다"
    echo "  creative    - 검색 결과·헤더 그림 업로드 + 심사 제출 (creative-status · creative-place)"
    echo
    echo "  앱: ${ALL_APPS[*]}"
}

# ── 크리에이티브 자산 (fastlane 을 거치지 않는다) ─────────────────────
# 앱 → 번들 ID · 그림 폴더. Sudoku9 free/paid 는 같은 그림을 쓴다.
bundle_of() { case $1 in
    sudoku9free) echo com.raymond.sudokuiphonefree ;; sudoku9paid) echo com.raymond.sudoku ;;
    sudoku6free) echo com.raymond.sudoku6free ;;      sudoku6paid) echo com.raymond.sudoku6 ;; esac; }
creative_dir_of() { case $1 in sudoku9*) echo fastlane/creative/sudoku9 ;; sudoku6*) echo fastlane/creative/sudoku6 ;; esac; }

case "$1" in
    creative|creative-status|creative-place)
        cmd=upload; [ "$1" == creative-status ] && cmd=status; [ "$1" == creative-place ] && cmd=place
        shift
        [ "$#" -eq 0 ] && { echo -e "${RED}앱을 적는다 (예: sudoku9free sudoku9paid)${NC}"; exit 1; }
        cd "$(dirname "$0")"
        TOOL="$(cd ../../GitFlutter/tools 2>/dev/null && pwd)/asc_creative"
        [ -x "$TOOL" ] || { echo -e "${RED}$TOOL 이 없다 (GitFlutter 저장소가 옆에 있어야 한다)${NC}"; exit 1; }
        for app in "$@"; do
            b=$(bundle_of "$app"); [ -n "$b" ] || { echo -e "${RED}알 수 없는 앱: $app${NC}"; exit 1; }
            d=$(creative_dir_of "$app")
            echo -e "${GREEN}== $app ($b)${NC}"
            if [ "$cmd" == status ]; then "$TOOL" status --bundle "$b"
            else
                [ -d "$d" ] || { echo -e "${RED}$d 가 없다 — tools/creative/make_*.sh 를 먼저${NC}"; exit 1; }
                "$TOOL" "$cmd" --bundle "$b" --dir "$PWD/$d"
            fi
        done
        exit 0 ;;
esac

case "$1" in
    testflight) LANE=beta ;;
    appstore)   LANE=release ;;
    submit)     LANE=submit ;;
    build)      LANE=build_only ;;
    ""|-h|--help) usage; exit 1 ;;
    *) echo -e "${RED}알 수 없는 타입: $1${NC}"; usage; exit 1 ;;
esac
shift

# 앱 이름을 검사한다. 오타를 조용히 넘기면 "성공했는데 아무것도 안 올라감"이 된다.
if [ "$#" -eq 0 ]; then
    APPS_ARG=""
    TARGETS="${ALL_APPS[*]}"
else
    for name in "$@"; do
        found=0
        for a in "${ALL_APPS[@]}"; do [ "$a" == "$name" ] && found=1; done
        if [ $found -eq 0 ]; then
            echo -e "${RED}알 수 없는 앱: $name${NC}"
            echo "허용: ${ALL_APPS[*]}"
            exit 1
        fi
    done
    APPS_ARG="apps:$(IFS=,; echo "$*")"
    TARGETS="$*"
fi

echo -e "${GREEN}배포 시작${NC}"
echo -e "${YELLOW}타입: $1${NC}"
echo -e "${YELLOW}앱: $TARGETS${NC}"
echo

cd "$(dirname "$0")"
if [ -n "$APPS_ARG" ]; then
    fastlane "$LANE" "$APPS_ARG"
else
    fastlane "$LANE"
fi
