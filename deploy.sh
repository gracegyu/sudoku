#!/bin/bash
# sudoku2 배포 — 네 앱을 고르거나 전부.
#
#   ./deploy.sh testflight                      네 앱 전부 TestFlight
#   ./deploy.sh testflight sudoku9free          하나만
#   ./deploy.sh appstore sudoku9free sudoku9paid  고른 것만 심사 제출
#   ./deploy.sh build sudoku9free               빌드만 (올리지 않는다)
#
# GitFlutter/deploy_all.sh 와 같은 결로 만들었다. 다만 **타입 하나가 한 가지
# 일만 한다** — 거기서는 `all` 이 네 단계를 다 돌아서 같은 버전 코드를 두 번
# 올리다 막혔다 (GitFlutter/_docs/BACKLOG.md B-8).

set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ALL_APPS=(sudoku9free sudoku9paid sudoku6free sudoku6paid)

usage() {
    echo -e "${YELLOW}사용법: ./deploy.sh <타입> [앱 ...]${NC}"
    echo "  타입: testflight | appstore | build"
    echo "  앱을 생략하면 넷 전부. 이름을 주면 그것만."
    echo
    echo "  testflight  - TestFlight (내부 테스터 · 베타 심사 없음)"
    echo "  appstore    - App Store 업로드 + 심사 제출 + 승인 시 자동 공개"
    echo "  build       - 빌드만. 올리지 않는다"
    echo
    echo "  앱: ${ALL_APPS[*]}"
}

case "$1" in
    testflight) LANE=beta ;;
    appstore)   LANE=release ;;
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
