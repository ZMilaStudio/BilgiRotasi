#!/usr/bin/env bash
set -euo pipefail

mkdir -p reports/wave5-gameplay

PACKAGE='com.leventua.bilgirotasi'
MAIN_ACTIVITY='com.leventua.bilgirotasi/.MainActivity'
APK='reports/WORD_HUNT_WAVE5_GAMEPLAY_PROOF.apk'
LOG='reports/WORD_HUNT_WAVE5_GAMEPLAY_ANDROID16_LOGCAT.txt'
META='reports/WORD_HUNT_WAVE5_GAMEPLAY_VISUAL_PROOF.txt'

routes=(
  baslangic-limani
  gokyuzu-adalari
  orman-yolu
  orman-2
  kristal-vadisi
  kayip-sehir
  yeralti-kralligi
  gunes-imparatorlugu
)

adb_call() {
  local timeout_seconds="$1"
  shift
  timeout "$timeout_seconds" adb "$@"
}

install_proof() {
  adb_call 180 install -r "$APK" > reports/WORD_HUNT_WAVE5_GAMEPLAY_INSTALL.txt
  grep -Fq 'Success' reports/WORD_HUNT_WAVE5_GAMEPLAY_INSTALL.txt
}

launch_proof() {
  adb_call 20 shell am force-stop "$PACKAGE" >/dev/null 2>&1 || true
  adb_call 20 logcat -c >/dev/null 2>&1 || true
  adb_call 20 shell am start -n "$MAIN_ACTIVITY"     > reports/WORD_HUNT_WAVE5_GAMEPLAY_LAUNCH.txt
  grep -Eq 'Starting: Intent|Warning: Activity not started|Activity:'     reports/WORD_HUNT_WAVE5_GAMEPLAY_LAUNCH.txt
}

refresh_log() {
  adb_call 20 logcat -d -v threadtime > "$LOG"
}

wait_route() {
  local route="$1"
  local found=0
  for _ in $(seq 1 80); do
    refresh_log || true
    if grep -Fq "[WAVE5_GAMEPLAY_PROOF_READY] route=$route " "$LOG"; then
      found=1
      break
    fi
    sleep 1
  done
  test "$found" -eq 1
  sleep 2
}

capture_png() {
  local path="$1"
  adb_call 30 exec-out screencap -p > "$path"
  test -s "$path"
  python3 - "$path" <<'PY'
import struct
import sys

path = sys.argv[1]
data = open(path, 'rb').read()
if len(data) < 10000:
    raise SystemExit(f'PNG too small: {len(data)} bytes')
if data[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit('not a PNG')
width, height = struct.unpack('>II', data[16:24])
if width < 300 or height < 500:
    raise SystemExit(f'unexpected screenshot dimensions {width}x{height}')
print(f'{path}: {width}x{height} bytes={len(data)}')
PY
}

run_viewport() {
  local label="$1"
  local size="$2"

  if [ "$size" = "reset" ]; then
    adb_call 20 shell wm size reset
  else
    adb_call 20 shell wm size "$size"
  fi

  launch_proof
  {
    echo "VIEWPORT=$label"
    adb_call 20 shell wm size
    adb_call 20 shell wm density
  } >> "$META"

  for route in "${routes[@]}"; do
    wait_route "$route"
    local png="reports/wave5-gameplay/WAVE5_${label}_${route}.png"
    capture_png "$png"
    echo "CAPTURE=$label route=$route file=$png" >> "$META"
  done
}

test -s "$APK"
: > "$META"
echo 'EVIDENCE_KIND=ANDROID16_ROUTE_AWARE_GAMEPLAY' >> "$META"
echo 'ROUTES=8' >> "$META"
echo 'VIEWPORT_CLASSES=standard,compact,tall' >> "$META"
echo 'SCREENSHOTS_EXPECTED=24' >> "$META"

install_proof
run_viewport standard reset
run_viewport compact 720x1280
run_viewport tall 720x1600

adb_call 20 shell wm size reset
refresh_log || true

test "$(find reports/wave5-gameplay -type f -name 'WAVE5_*.png' | wc -l)" -eq 24
for route in "${routes[@]}"; do
  grep -Fq "[WAVE5_GAMEPLAY_PROOF_READY] route=$route " "$LOG"
done

if grep -Eqi 'FATAL EXCEPTION|ANR in com\.leventua\.bilgirotasi|am_crash.*com\.leventua\.bilgirotasi' "$LOG"; then
  echo 'Wave 5 gameplay visual proof detected app crash/ANR.' >&2
  exit 1
fi

echo 'RESULT=PASS' >> "$META"
