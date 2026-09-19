#!/usr/bin/env bash
set -euo pipefail

PACKAGE='com.leventua.bilgirotasi'
MAIN_ACTIVITY='com.leventua.bilgirotasi/.MainActivity'
APK='reports/TRILOGY_RUNTIME_VISUAL_PROOF.apk'
REPORT_TSV='reports/TRILOGY_RUNTIME_VISUAL_PROOF_RECORDS.tsv'
RESULT_TXT='reports/TRILOGY_RUNTIME_VISUAL_PROOF_RESULT.txt'
RESULT_JSON='reports/TRILOGY_RUNTIME_VISUAL_PROOF_RESULT.json'
COMBINED_LOG='reports/TRILOGY_RUNTIME_VISUAL_PROOF_LOGCAT.txt'

mkdir -p reports
: > "$REPORT_TSV"
: > "$COMBINED_LOG"

a() {
  local timeout_seconds="$1"
  shift
  timeout "$timeout_seconds" adb "$@"
}

reset_display() {
  a 15 shell wm size reset >/dev/null 2>&1 || true
  a 15 shell wm density reset >/dev/null 2>&1 || true
}

set_standard_display() {
  a 15 shell wm size 1080x1920 >/dev/null
  a 15 shell wm density 420 >/dev/null
}

cleanup() {
  reset_display
  a 30 shell am force-stop "$PACKAGE" >/dev/null 2>&1 || true
}
trap cleanup EXIT

capture_png() {
  local output="$1"
  for _ in 1 2 3; do
    if a 30 exec-out screencap -p > "$output" 2>/dev/null && test -s "$output"; then
      return 0
    fi
    sleep 1
  done
  echo "Unable to capture $output" >&2
  return 1
}

validate_png_size() {
  local png="$1"
  local expected_width="$2"
  local expected_height="$3"
  local metrics="$4"

  python3 - "$png" "$expected_width" "$expected_height" > "$metrics" <<'PY'
import struct
import sys

path = sys.argv[1]
expected_width = int(sys.argv[2])
expected_height = int(sys.argv[3])
with open(path, 'rb') as handle:
    header = handle.read(24)

if header[:8] != b'\x89PNG\r\n\x1a\n' or header[12:16] != b'IHDR':
    raise SystemExit('not a PNG with IHDR')

width, height = struct.unpack('>II', header[16:24])
print(f'width={width}')
print(f'height={height}')
if (width, height) != (expected_width, expected_height):
    raise SystemExit(
        f'unexpected screenshot size {width}x{height}; '
        f'expected {expected_width}x{expected_height}'
    )
PY
}

wait_for_menu() {
  local log='reports/TRILOGY_RUNTIME_VISUAL_PROOF_MENU_LOGCAT.txt'
  local ready=0

  for _ in $(seq 1 45); do
    a 15 logcat -d -v threadtime > "$log" 2>/dev/null || true
    if grep -Fq '[WORD_HUNT_TRILOGY_PROOF_MENU_READY]' "$log"; then
      ready=1
      break
    fi
    sleep 1
  done

  if [ "$ready" -ne 1 ]; then
    echo 'Proof menu never reached ready marker.' >&2
    tail -n 180 "$log" >&2 || true
    return 1
  fi
}

scenario_tap() {
  local route="$1"
  local state="$2"
  local x
  local y

  case "$state" in
    l5-current) x=180 ;;
    l10-current) x=540 ;;
    completed) x=900 ;;
    *) echo "Unknown proof state: $state" >&2; return 1 ;;
  esac

  case "$route" in
    kayip-sehir) y=365 ;;
    yeralti-kralligi) y=725 ;;
    gunes-imparatorlugu) y=1085 ;;
    *) echo "Unknown proof route: $route" >&2; return 1 ;;
  esac

  a 15 shell input tap "$x" "$y"
}

theme_for_route() {
  case "$1" in
    kayip-sehir) printf '%s' 'kayip-sehir-production' ;;
    yeralti-kralligi) printf '%s' 'yeralti-kralligi-production' ;;
    gunes-imparatorlugu) printf '%s' 'gunes-imparatorlugu-production' ;;
    *) return 1 ;;
  esac
}

expected_completed_for_state() {
  case "$1" in
    l5-current) printf '%s' '4' ;;
    l10-current) printf '%s' '9' ;;
    completed) printf '%s' '10' ;;
    *) return 1 ;;
  esac
}

wait_for_scenario_ready() {
  local route="$1"
  local state="$2"
  local log="$3"
  local activity="$4"
  local theme
  local completed
  theme="$(theme_for_route "$route")"
  completed="$(expected_completed_for_state "$state")"
  local ready=0

  for _ in $(seq 1 60); do
    a 15 shell dumpsys activity activities > "$activity" 2>/dev/null || true
    a 15 logcat -d -v threadtime > "$log" 2>/dev/null || true
    if grep -Fq "$MAIN_ACTIVITY" "$activity" \
        && grep -Fq "[WORD_HUNT_TRILOGY_PROOF_FRAME_READY] route=$route state=$state theme=$theme" "$log"; then
      ready=1
      break
    fi
    sleep 1
  done

  if [ "$ready" -ne 1 ]; then
    echo "Scenario never reached ready marker: $route/$state" >&2
    tail -n 220 "$log" >&2 || true
    return 1
  fi

  grep -Fq "[WORD_HUNT_TRILOGY_PROOF_CONFIG_READY] route=$route state=$state theme=$theme" "$log"
  grep -Fq "completedLevels=$completed" "$log"
  grep -Fq "[WORD_HUNT_TRILOGY_PROOF_ARTWORK_READY] route=$route state=$state width=941 height=1672" "$log"
  grep -Fq "head=$(cat reports/TRILOGY_RUNTIME_VISUAL_PROOF_HEAD_SHA.txt)" "$log"
  ! grep -Fq '[WORD_HUNT_TRILOGY_PROOF_ERROR]' "$log"
  ! grep -Fq '[WORD_HUNT_TRILOGY_PROOF_FLUTTER_ERROR]' "$log"
  ! grep -Fq '[WORD_HUNT_TRILOGY_PROOF_PLATFORM_ERROR]' "$log"
}

scan_runtime_health() {
  local log="$1"
  local activity="$2"
  local pid
  pid="$(a 15 shell pidof "$PACKAGE" | tr -d '\r' || true)"
  test -n "$pid"
  grep -Fq "$MAIN_ACTIVITY" "$activity"

  if grep -Eqi \
      'FATAL EXCEPTION|ANR in com\.leventua\.bilgirotasi|am_crash.*com\.leventua\.bilgirotasi|am_proc_died.*com\.leventua\.bilgirotasi|Process com\.leventua\.bilgirotasi .*has died' \
      "$log"; then
    echo 'Application crash/ANR/process death detected.' >&2
    return 1
  fi

  if grep -Eqi \
      'A RenderFlex overflowed|overflowed by [0-9.]+ pixels|Exception caught by rendering library' \
      "$log"; then
    echo 'Flutter layout overflow/rendering exception detected.' >&2
    return 1
  fi
}

record_result() {
  local filename="$1"
  local route="$2"
  local state="$3"
  local resolution="$4"
  printf '%s\t%s\t%s\t%s\tPASS\tPASS\tPASS\n' \
    "$filename" "$route" "$state" "$resolution" >> "$REPORT_TSV"
}

capture_profile() {
  local filename="$1"
  local route="$2"
  local state="$3"
  local size="$4"
  local density="$5"
  local width="$6"
  local height="$7"
  local label
  label="$(basename "$filename" .png)"
  local log="reports/${label}_LOGCAT.txt"
  local activity="reports/${label}_ACTIVITY.txt"
  local metrics="reports/${label}_METRICS.txt"

  a 15 shell wm size "$size" >/dev/null
  a 15 shell wm density "$density" >/dev/null
  sleep 2

  a 15 shell dumpsys activity activities > "$activity" 2>/dev/null || true
  a 15 logcat -d -v threadtime > "$log" 2>/dev/null || true
  scan_runtime_health "$log" "$activity"
  grep -Fq "[WORD_HUNT_TRILOGY_PROOF_FRAME_READY] route=$route state=$state" "$log"

  capture_png "reports/$filename"
  validate_png_size "reports/$filename" "$width" "$height" "$metrics"
  cat "$log" >> "$COMBINED_LOG"
  record_result "$filename" "$route" "$state" "${width}x${height}"
}

restart_menu() {
  set_standard_display
  sleep 1
  a 15 logcat -c >/dev/null 2>&1 || true
  a 15 shell am force-stop "$PACKAGE" >/dev/null 2>&1 || true
  a 15 shell am start -n "$MAIN_ACTIVITY" >/dev/null
  wait_for_menu
}

open_scenario() {
  local route="$1"
  local state="$2"

  set_standard_display
  sleep 1
  a 15 logcat -c >/dev/null 2>&1 || true
  scenario_tap "$route" "$state"
  wait_for_scenario_ready \
    "$route" "$state" \
    "reports/TRILOGY_${route}_${state}_READY_LOGCAT.txt" \
    "reports/TRILOGY_${route}_${state}_READY_ACTIVITY.txt"
  sleep 2
}

capture_route() {
  local route="$1"
  local prefix="$2"

  open_scenario "$route" 'l5-current'
  capture_profile "${prefix}_L5_CURRENT_1080x1920.png" "$route" 'l5-current' \
    '1080x1920' '420' '1080' '1920'
  restart_menu

  open_scenario "$route" 'l10-current'
  capture_profile "${prefix}_L10_CURRENT_1080x1920.png" "$route" 'l10-current' \
    '1080x1920' '420' '1080' '1920'
  capture_profile "${prefix}_L10_CURRENT_720x1280.png" "$route" 'l10-current' \
    '720x1280' '320' '720' '1280'
  capture_profile "${prefix}_L10_CURRENT_1080x2400.png" "$route" 'l10-current' \
    '1080x2400' '440' '1080' '2400'
  restart_menu

  open_scenario "$route" 'completed'
  capture_profile "${prefix}_COMPLETED_1080x1920.png" "$route" 'completed' \
    '1080x1920' '420' '1080' '1920'
  restart_menu
}

make_contact_sheets() {
  python3 - <<'PY'
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path('reports')
font = ImageFont.load_default()
routes = {
    'KAYIP': [
        'KAYIP_L5_CURRENT_1080x1920.png',
        'KAYIP_L10_CURRENT_1080x1920.png',
        'KAYIP_COMPLETED_1080x1920.png',
        'KAYIP_L10_CURRENT_720x1280.png',
        'KAYIP_L10_CURRENT_1080x2400.png',
    ],
    'YERALTI': [
        'YERALTI_L5_CURRENT_1080x1920.png',
        'YERALTI_L10_CURRENT_1080x1920.png',
        'YERALTI_COMPLETED_1080x1920.png',
        'YERALTI_L10_CURRENT_720x1280.png',
        'YERALTI_L10_CURRENT_1080x2400.png',
    ],
    'GUNES': [
        'GUNES_L5_CURRENT_1080x1920.png',
        'GUNES_L10_CURRENT_1080x1920.png',
        'GUNES_COMPLETED_1080x1920.png',
        'GUNES_L10_CURRENT_720x1280.png',
        'GUNES_L10_CURRENT_1080x2400.png',
    ],
}

def route_sheet(prefix, files):
    cards = []
    for name in files:
        image = Image.open(root / name).convert('RGB')
        image.thumbnail((360, 640), Image.Resampling.LANCZOS)
        card = Image.new('RGB', (390, 700), 'white')
        card.paste(image, ((390 - image.width) // 2, 34))
        ImageDraw.Draw(card).text((12, 10), name, fill='black', font=font)
        cards.append(card)

    sheet = Image.new('RGB', (1170, 1400), '#dddddd')
    positions = [(0, 0), (390, 0), (780, 0), (195, 700), (585, 700)]
    for card, position in zip(cards, positions):
        sheet.paste(card, position)
    output = root / f'{prefix}_RUNTIME_CONTACT_SHEET.png'
    sheet.save(output, 'PNG')
    return output

route_sheets = [route_sheet(prefix, files) for prefix, files in routes.items()]
trilogy = Image.new('RGB', (1170, 4200), '#cccccc')
for index, path in enumerate(route_sheets):
    trilogy.paste(Image.open(path).convert('RGB'), (0, index * 1400))
trilogy.save(root / 'TRILOGY_RUNTIME_CONTACT_SHEET.png', 'PNG')
PY
}

finalize_reports() {
  local head
  local apk_sha
  head="$(cat reports/TRILOGY_RUNTIME_VISUAL_PROOF_HEAD_SHA.txt)"
  apk_sha="$(cut -d' ' -f1 reports/TRILOGY_RUNTIME_VISUAL_PROOF_APK_SHA256.txt)"

  {
    echo 'TECHNICAL_RUNTIME_PROOF=PASS'
    echo 'OWNER_VISUAL_GATE=PENDING'
    echo "PROOF_HEAD=$head"
    echo "APK_SHA256=$apk_sha"
    echo 'SCREENSHOT_COUNT=15'
    echo 'REQUESTED_RESOLUTIONS=PASS'
    echo 'CRASH_ANR=PASS'
    echo 'OVERFLOW=PASS'
    echo 'CATALOG_THEME_RESOLUTION=PASS'
    echo
    printf 'filename\troute\tstate\tresolution\trender\toverflow\tcrash\n'
    cat "$REPORT_TSV"
  } > "$RESULT_TXT"

  python3 - "$REPORT_TSV" "$head" "$apk_sha" > "$RESULT_JSON" <<'PY'
import csv
import json
import sys

tsv, head, apk_sha = sys.argv[1:]
records = []
with open(tsv, encoding='utf-8') as handle:
    for row in csv.reader(handle, delimiter='\t'):
        filename, route, state, resolution, render, overflow, crash = row
        records.append({
            'filename': filename,
            'route': route,
            'state': state,
            'resolution': resolution,
            'render': render,
            'overflow': overflow,
            'crash': crash,
        })

json.dump({
    'technical_runtime_proof': 'PASS',
    'owner_visual_gate': 'PENDING',
    'proof_head': head,
    'apk_sha256': apk_sha,
    'screenshots': records,
}, sys.stdout, ensure_ascii=False, indent=2)
print()
PY

  test "$(wc -l < "$REPORT_TSV")" -eq 15
  for prefix in KAYIP YERALTI GUNES; do
    test -s "reports/${prefix}_RUNTIME_CONTACT_SHEET.png"
  done
  test -s reports/TRILOGY_RUNTIME_CONTACT_SHEET.png
}

test -s "$APK"
a 20 wait-for-device
a 20 shell getprop sys.boot_completed | tr -d '\r' | grep -Fxq '1'
reset_display
set_standard_display

if a 15 shell pm path "$PACKAGE" 2>/dev/null | grep -q '^package:'; then
  a 60 uninstall "$PACKAGE" >/dev/null || true
fi
a 120 install -r "$APK" | tee reports/TRILOGY_RUNTIME_VISUAL_PROOF_INSTALL.txt
grep -Fq 'Success' reports/TRILOGY_RUNTIME_VISUAL_PROOF_INSTALL.txt

a 15 logcat -c >/dev/null 2>&1 || true
a 15 shell am start -n "$MAIN_ACTIVITY" > reports/TRILOGY_RUNTIME_VISUAL_PROOF_LAUNCH.txt 2>&1
wait_for_menu

capture_route 'kayip-sehir' 'KAYIP'
capture_route 'yeralti-kralligi' 'YERALTI'
capture_route 'gunes-imparatorlugu' 'GUNES'

make_contact_sheets
finalize_reports
