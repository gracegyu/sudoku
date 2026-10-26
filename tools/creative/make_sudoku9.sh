#!/bin/bash
# Sudoku9 의 App Store 크리에이티브 자산을 만든다 (Asset Library · iOS 27+).
#
#   tools/creative/make_sudoku9.sh            다섯 언어 전부
#   tools/creative/make_sudoku9.sh en-US ko   고른 언어만
#
# 결과: fastlane/creative/sudoku9/<locale>/
#   search_results_3840x2560.png   검색 결과 (3:2)
#   product_header_3840x1646.png   제품 페이지 헤더 (21:9)
#
# ## 그림 규칙 (factory `_docs/specs/STORE_ASSETS.md` 를 따른다)
#
# - **이름을 넣지 않는다.** 검색 카드에 아이콘·이름·부제가 이미 나온다.
# - **부제와 같은 말을 쓰지 않는다.** 부제가 「5가지 스도쿠 · 매일 대결」이라
#   한 줄은 다른 이야기(끝없는 퍼즐·난이도)를 한다. 「5가지」는 양옆 판이 보여 준다.
# - **판이 주인공, 가운데 세로축.** 헤더는 기기마다 양옆이 잘린다 — 양옆 판은
#   잘려도 되는 장식이다.
# - **알파 채널 없음** (있으면 반려된다).
#
# 원본은 `iTunes/sudoku9/en/12.9iPad-*.jpg` 의 판 부분만 쓴다. 판 안에는 글자가
# 없어 언어마다 다시 찍을 필요가 없다. 맨 위 줄(사용자 이름이 찍힌 막대)은
# 잘라 낸다.
set -euo pipefail
cd "$(dirname "$0")/../.."

SRC=iTunes/sudoku9/en
OUT=fastlane/creative/sudoku9
WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT

# 언어 → 글꼴 · 한 줄
font_of() {
  case $1 in
    ko)      echo "Apple-SD-Gothic-Neo-Bold" ;;
    ja)      echo "Hiragino-Sans-W6" ;;
    zh-Hans) echo "PingFang-SC-Semibold" ;;
    zh-Hant) echo "PingFang-TC-Semibold" ;;
    *)       echo "Hiragino-Sans-W6" ;;   # 라틴 글자도 고르게 나온다
  esac
}
line_of() {
  case $1 in
    en-US)   echo "Endless puzzles, beginner to expert" ;;
    ko)      echo "끝없는 퍼즐, 초급부터 고수까지" ;;
    ja)      echo "無限のパズル、初級から達人まで" ;;
    zh-Hans) echo "无限谜题，从入门到高手" ;;
    zh-Hant) echo "無限謎題，從入門到高手" ;;
  esac
}

# ── 판 셋을 잘라 둔다 (언어와 무관) ───────────────────────────────────────
magick "$SRC/12.9iPad-1.jpg" -crop 1704x1492+166+588 +repage "$WORK/classic.png"
magick "$SRC/12.9iPad-2.jpg" -crop 890x742+70+394    +repage "$WORK/jigsaw.png"
magick "$SRC/12.9iPad-2.jpg" -crop 890x790+78+1604   +repage "$WORK/killer.png"

# 판 하나를 높이 h 로 키우고 그림자를 단다.
card() {  # in h out
  local in=$1 h=$2 out=$3
  magick "$in" -resize "x$h" -bordercolor '#8aa6cc' -border $(( h / 300 )) \
    \( +clone -background '#1d3557' -shadow 35x$(( h / 45 ))+0+$(( h / 60 )) \) +swap \
    -background none -layers merge +repage "$out"
}

# 캔버스 W×H 에 한 줄(y 중심 ty, 크기 ts)과 판 셋(가운데 높이 ch, 양옆 sh)을 놓는다.
compose() {  # locale W H ts ty ch cy sh out
  local loc=$1 W=$2 H=$3 ts=$4 ty=$5 ch=$6 cy=$7 sh=$8 out=$9
  card "$WORK/classic.png" "$ch" "$WORK/c.png"
  card "$WORK/jigsaw.png"  "$sh" "$WORK/j.png"
  card "$WORK/killer.png"  "$sh" "$WORK/k.png"
  local cw; cw=$(magick identify -format %w "$WORK/c.png")
  local sw; sw=$(magick identify -format %w "$WORK/j.png")
  # 양옆 판은 가운데 판 뒤로 1/3 쯤 숨는다.
  local jx=$(( W/2 - cw/2 - sw*2/3 ))
  local kx=$(( W/2 + cw/2 - sw/3 ))
  local sy=$(( cy + (ch - sh)/2 ))
  magick -size "${W}x${H}" gradient:'#eef3fa'-'#b9cbe4' \
    "$WORK/j.png" -geometry "+${jx}+${sy}" -composite \
    "$WORK/k.png" -geometry "+${kx}+${sy}" -composite \
    "$WORK/c.png" -geometry "+$(( W/2 - cw/2 ))+${cy}" -composite \
    -font "$(font_of "$loc")" -pointsize "$ts" -fill '#1d3557' \
    -gravity north -annotate "+0+$(( ty - ts*6/10 ))" "$(line_of "$loc")" \
    -alpha off -strip "PNG24:$out"
}

LOCALES=("$@"); [ ${#LOCALES[@]} -eq 0 ] && LOCALES=(en-US ko ja zh-Hans zh-Hant)
for loc in "${LOCALES[@]}"; do
  [ -n "$(line_of "$loc")" ] || { echo "모르는 언어: $loc" >&2; exit 1; }
  mkdir -p "$OUT/$loc"
  #        loc   W    H    글자  글자y 가운데h 가운데y 양옆h
  compose "$loc" 3840 2560 170   250   1880    450     1460  "$OUT/$loc/search_results_3840x2560.png"
  compose "$loc" 3840 1646 120   150   1290    290     1000  "$OUT/$loc/product_header_3840x1646.png"
  echo "✓ $loc"
done
