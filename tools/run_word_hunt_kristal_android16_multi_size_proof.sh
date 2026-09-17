#!/usr/bin/env bash
set -euo pipefail

PACKAGE='com.leventua.bilgirotasi'
MAIN_ACTIVITY='com.leventua.bilgirotasi/.MainActivity'
APK='reports/WORD_HUNT_KRISTAL_RUNTIME_PROOF.apk'
EXPECTED_ARTWORK='assets/word_hunt/KRISTAL_VADISI_RUNTIME_PROOF_SOURCE.png'
EXPECTED_SHA='189dec3f731f66e72449625457d35d28500fe5cbd5a69ab1f2f04f303ca1bc20'

mkdir -p reports

a() {
  local timeout_seconds="$1"
  shift
  timeout "$timeout_seconds" adb "$@"
}

reset_display() {
  a 15 shell wm size reset >/dev/null 2>&1 || true
  a 15 shell wm density reset >/dev/null 2>&1 || true
}

cleanup() {
  reset_display
  a 30 shell am force-stop "$PACKAGE" >/dev/null 2>&1 || true
}
trap cleanup EXIT

wait_for_ready() {
  local log_file="$1"
  local activity_file="$2"
  local ready=0

  for _ in $(seq 1 50); do
    a 15 shell dumpsys activity activities > "$activity_file" 2>/dev/null || true
    a 15 logcat -d -v threadtime > "$log_file" 2>/dev/null || true
    if grep -Fq "$MAIN_ACTIVITY" "$activity_file" \
        && grep -Fq '[WORD_HUNT_KRISTAL_PROOF_FRAME_READY]' "$log_file"; then
      ready=1
      break
    fi
    sleep 1
  done

  if [ "$ready" -ne 1 ]; then
    echo 'Kristal runtime proof never reached frame-ready marker.' >&2
    tail -n 220 "$log_file" >&2 || true
    return 1
  fi

  grep -Fq \
    "[WORD_HUNT_KRISTAL_PROOF_CONFIG_READY] route=kristal-vadisi-runtime-proof theme=kristal-vadisi-runtime-proof asset=$EXPECTED_ARTWORK" \
    "$log_file"
  grep -Fq \
    "[WORD_HUNT_KRISTAL_PROOF_ARTWORK_READY] asset=$EXPECTED_ARTWORK width=941 height=1672 bytes=2793116" \
    "$log_file"
  grep -Fq \
    '[WORD_HUNT_KRISTAL_PROOF_STATE_READY] completed=1,2,3,4 current=5 locked=6,7,8,9,10' \
    "$log_file"
  ! grep -Fq '[WORD_HUNT_KRISTAL_PROOF_ERROR]' "$log_file"

  sleep 3
}

capture_png() {
  local output="$1"
  for _ in 1 2 3; do
    if a 30 exec-out screencap -p > "$output" 2>/dev/null \
        && test -s "$output"; then
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
  cat "$metrics"
}

capture_profile() {
  local label="$1"
  local size_override="$2"
  local density_override="$3"
  local expected_width="$4"
  local expected_height="$5"

  reset_display
  if [ -n "$size_override" ]; then
    a 15 shell wm size "$size_override"
  fi
  if [ -n "$density_override" ]; then
    a 15 shell wm density "$density_override"
  fi

  a 15 shell am force-stop "$PACKAGE" >/dev/null 2>&1 || true
  a 15 logcat -c >/dev/null 2>&1 || true
  a 15 shell am start -n "$MAIN_ACTIVITY" \
    > "reports/WORD_HUNT_KRISTAL_${label}_LAUNCH.txt" 2>&1

  wait_for_ready \
    "reports/WORD_HUNT_KRISTAL_${label}_LOGCAT.txt" \
    "reports/WORD_HUNT_KRISTAL_${label}_ACTIVITY.txt"

  capture_png "reports/WORD_HUNT_KRISTAL_ANDROID16_${label}.png"
  validate_png_size \
    "reports/WORD_HUNT_KRISTAL_ANDROID16_${label}.png" \
    "$expected_width" "$expected_height" \
    "reports/WORD_HUNT_KRISTAL_ANDROID16_${label}_METRICS.txt"
}

test -s "$APK"
test -s "$EXPECTED_ARTWORK"
echo "$EXPECTED_SHA  $EXPECTED_ARTWORK" | sha256sum -c -
a 20 wait-for-device
a 20 shell getprop sys.boot_completed | tr -d '\r' | grep -Fxq '1'
a 120 install -r "$APK" | tee reports/WORD_HUNT_KRISTAL_RUNTIME_PROOF_INSTALL.txt
grep -Fq 'Success' reports/WORD_HUNT_KRISTAL_RUNTIME_PROOF_INSTALL.txt

capture_profile 'STANDARD_1080x1920' '' '' '1080' '1920'
capture_profile 'COMPACT_720x1280' '720x1280' '320' '720' '1280'
capture_profile 'TALL_1080x2400' '1080x2400' '440' '1080' '2400'
capture_profile 'REFERENCE_411x731' '411x731' '180' '411' '731'

printf '%s\n' \
  'RESULT=SUCCESS' \
  'STANDARD=WORD_HUNT_KRISTAL_ANDROID16_STANDARD_1080x1920.png' \
  'COMPACT=WORD_HUNT_KRISTAL_ANDROID16_COMPACT_720x1280.png' \
  'TALL=WORD_HUNT_KRISTAL_ANDROID16_TALL_1080x2400.png' \
  'REFERENCE=WORD_HUNT_KRISTAL_ANDROID16_REFERENCE_411x731.png' \
  > reports/WORD_HUNT_KRISTAL_RUNTIME_PROOF_RESULT.txt
