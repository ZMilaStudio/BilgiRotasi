#!/usr/bin/env bash
set -euo pipefail

mkdir -p reports

PACKAGE='com.leventua.bilgirotasi'
MAIN_ACTIVITY='com.leventua.bilgirotasi/.MainActivity'
REUSABLE_APK='reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_PROOF.apk'
MASTER_ART_APK='reports/WORD_HUNT_VISUAL_PROOF_ANDROID16_PROOF.apk'

adb_call() {
  local timeout_seconds="$1"
  shift
  timeout "$timeout_seconds" adb "$@"
}

refresh_logcat_snapshot() {
  local log_file="$1"
  local temp_file="${log_file}.tmp"

  if adb_call 20 logcat -d -v threadtime > "$temp_file" 2>&1; then
    mv "$temp_file" "$log_file"
    return 0
  fi

  if [ -s "$temp_file" ]; then
    cat "$temp_file" >> "$log_file" 2>/dev/null || true
  fi
  rm -f "$temp_file"
  return 1
}

recover_adb_transport() {
  for recovery_attempt in 1 2 3; do
    if adb_call 8 wait-for-device >/dev/null 2>&1 \
        && adb_call 8 shell getprop sys.boot_completed 2>/dev/null \
          | tr -d '\r' | grep -Fxq '1'; then
      return 0
    fi
    sleep 2
  done
  return 1
}

wait_for_flutter_frame() {
  local snapshot="$1"
  local log_file="$2"
  local ready_marker="$3"
  local label="$4"
  local ready=0
  local consecutive_adb_failures=0

  for attempt in $(seq 1 60); do
    local snapshot_temp="${snapshot}.tmp"
    if ! adb_call 15 shell dumpsys activity activities > "$snapshot_temp" 2>&1; then
      mv "$snapshot_temp" "$snapshot"
      refresh_logcat_snapshot "$log_file" || true
      consecutive_adb_failures=$((consecutive_adb_failures + 1))
      echo "$label adb probe failed on attempt $attempt ($consecutive_adb_failures/3)" >&2
      if [ "$consecutive_adb_failures" -ge 3 ]; then
        echo "$label lost adb after bounded recovery attempts" >&2
        return 1
      fi
      recover_adb_transport || true
      sleep 2
      continue
    fi
    mv "$snapshot_temp" "$snapshot"
    consecutive_adb_failures=0

    refresh_logcat_snapshot "$log_file" || true
    if grep -Fq "$MAIN_ACTIVITY" "$snapshot" \
      && grep -Eq 'topResumedActivity=.*com\.leventua\.bilgirotasi|ResumedActivity:.*com\.leventua\.bilgirotasi' "$snapshot" \
      && grep -Fq "$ready_marker" "$log_file"; then
      ready=1
      echo "$label Flutter frame confirmed on attempt $attempt"
      break
    fi
    sleep 1
  done

  refresh_logcat_snapshot "$log_file" || true
  if [ "$ready" -ne 1 ]; then
    echo "$label never emitted its Flutter frame-ready marker" >&2
    cat "$snapshot" >&2 || true
    tail -n 200 "$log_file" >&2 || true
    return 1
  fi

  grep -Fq "$MAIN_ACTIVITY" "$snapshot"
  grep -Eq 'topResumedActivity=.*com\.leventua\.bilgirotasi|ResumedActivity:.*com\.leventua\.bilgirotasi' "$snapshot"
  grep -Fq "$ready_marker" "$log_file"

  local app_pid=''
  for pid_attempt in 1 2 3; do
    app_pid="$(adb_call 10 shell pidof "$PACKAGE" 2>/dev/null | tr -d '\r\n' || true)"
    if [ -n "$app_pid" ]; then
      break
    fi
    recover_adb_transport || true
    sleep 1
  done
  test -n "$app_pid"
  sleep 1
}

launch_main_activity() {
  local launch_report="$1"
  local label="$2"
  local launched=0

  for attempt in 1 2 3; do
    adb_call 15 shell am force-stop "$PACKAGE" >/dev/null 2>&1 || true
    if adb_call 30 shell am start -W -n "$MAIN_ACTIVITY" \
        > "$launch_report" 2>&1; then
      launched=1
      break
    fi
    echo "$label explicit activity launch failed on attempt $attempt" >&2
    cat "$launch_report" >&2 || true
    recover_adb_transport || true
    sleep 2
  done

  if [ "$launched" -ne 1 ]; then
    return 1
  fi
  cat "$launch_report"
  grep -Eq 'Starting: Intent|Status: ok|Activity:' "$launch_report"
}

prepare_runtime_logcat() {
  local log_file="$1"
  : > "$log_file"
  if ! adb_call 15 logcat -c > /dev/null 2>&1; then
    recover_adb_transport || true
    adb_call 15 logcat -c > /dev/null 2>&1
  fi
}

install_apk() {
  local apk="$1"
  local label="$2"
  local install_report="reports/${label}_INSTALL.txt"

  for attempt in 1 2 3; do
    if adb_call 180 install -r "$apk" > "$install_report" 2>&1 \
        && grep -Fq 'Success' "$install_report"; then
      cat "$install_report"
      return 0
    fi
    cat "$install_report" >&2 || true
    recover_adb_transport || true
    sleep 2
  done
  echo "$label APK install failed after retries" >&2
  return 1
}

uninstall_if_present() {
  if adb_call 15 shell pm path "$PACKAGE" 2>/dev/null | grep -q '^package:'; then
    adb_call 60 uninstall "$PACKAGE" >/dev/null 2>&1 || true
  fi
}

validate_nonblack_png() {
  local png="$1"
  local metrics="$2"

  python3 - "$png" > "$metrics" <<'PY'
import struct
import sys
import zlib

path = sys.argv[1]
data = open(path, 'rb').read()
if data[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit('not a PNG')

pos = 8
width = height = bit_depth = color_type = interlace = None
idat = bytearray()
while pos + 12 <= len(data):
    length = struct.unpack('>I', data[pos:pos + 4])[0]
    kind = data[pos + 4:pos + 8]
    payload = data[pos + 8:pos + 8 + length]
    pos += 12 + length
    if kind == b'IHDR':
        width, height, bit_depth, color_type, _, _, interlace = struct.unpack(
            '>IIBBBBB', payload
        )
    elif kind == b'IDAT':
        idat.extend(payload)
    elif kind == b'IEND':
        break

channels_by_type = {0: 1, 2: 3, 4: 2, 6: 4}
if bit_depth != 8 or color_type not in channels_by_type or interlace != 0:
    raise SystemExit(
        f'unsupported PNG layout bit_depth={bit_depth} '
        f'color_type={color_type} interlace={interlace}'
    )

channels = channels_by_type[color_type]
stride = width * channels
raw = zlib.decompress(bytes(idat))
expected = height * (stride + 1)
if len(raw) != expected:
    raise SystemExit(f'unexpected decompressed size {len(raw)} != {expected}')

previous = bytearray(stride)
offset = 0
visible_pixels = 0
max_channel = 0


def paeth(a, b, c):
    p = a + b - c
    pa = abs(p - a)
    pb = abs(p - b)
    pc = abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c


for _ in range(height):
    filter_type = raw[offset]
    offset += 1
    source = raw[offset:offset + stride]
    offset += stride
    row = bytearray(stride)

    for i, value in enumerate(source):
        left = row[i - channels] if i >= channels else 0
        up = previous[i]
        upper_left = previous[i - channels] if i >= channels else 0
        if filter_type == 0:
            decoded = value
        elif filter_type == 1:
            decoded = (value + left) & 255
        elif filter_type == 2:
            decoded = (value + up) & 255
        elif filter_type == 3:
            decoded = (value + ((left + up) // 2)) & 255
        elif filter_type == 4:
            decoded = (value + paeth(left, up, upper_left)) & 255
        else:
            raise SystemExit(f'unsupported PNG filter {filter_type}')
        row[i] = decoded

    for x in range(width):
        base = x * channels
        if color_type in (0, 4):
            r = g = b = row[base]
        else:
            r, g, b = row[base:base + 3]
        local_max = max(r, g, b)
        max_channel = max(max_channel, local_max)
        if local_max >= 16:
            visible_pixels += 1

    previous = row

total = width * height
ratio = visible_pixels / total if total else 0.0
print(f'width={width}')
print(f'height={height}')
print(f'max_channel={max_channel}')
print(f'visible_pixels_ge_16={visible_pixels}')
print(f'visible_ratio={ratio:.6f}')

if max_channel < 16 or ratio < 0.01:
    raise SystemExit(
        f'visual proof is blank/near-black: '
        f'max_channel={max_channel} visible_ratio={ratio:.6f}'
    )
PY

  cat "$metrics"
}

capture_screenshot() {
  local target="$1"
  for attempt in 1 2 3; do
    if adb_call 30 exec-out screencap -p > "$target" 2>/dev/null \
        && test -s "$target"; then
      return 0
    fi
    recover_adb_transport || true
    sleep 1
  done
  echo "Unable to capture Android screenshot: $target" >&2
  return 1
}

has_app_failure() {
  local log_file="$1"
  grep -Eqi \
    'FATAL EXCEPTION|ANR in com\.leventua\.bilgirotasi|am_crash.*com\.leventua\.bilgirotasi|am_proc_died.*com\.leventua\.bilgirotasi|Process com\.leventua\.bilgirotasi .*has died|Cmdline: com\.leventua\.bilgirotasi' \
    "$log_file"
}

test -s "$REUSABLE_APK"
test -s "$MASTER_ART_APK"

uninstall_if_present
install_apk "$REUSABLE_APK" 'WORD_HUNT_REUSABLE_MAP_ANDROID16'
prepare_runtime_logcat reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LOGCAT.txt
launch_main_activity \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LAUNCH.txt \
  'Reusable map proof'
wait_for_flutter_frame \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_ACTIVITY.txt \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LOGCAT.txt \
  '[WORD_HUNT_REUSABLE_MAP_PROOF_FRAME_READY]' \
  'Reusable map proof'
refresh_logcat_snapshot reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LOGCAT.txt || true
awk '/WORD_HUNT_REUSABLE_MAP_PROOF_(ARTWORK_READY|FRAME_READY|ERROR)/' \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LOGCAT.txt \
  > reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_RUNTIME.txt
grep -Fq '[WORD_HUNT_REUSABLE_MAP_PROOF_ARTWORK_READY]' \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_RUNTIME.txt
grep -Fq '[WORD_HUNT_REUSABLE_MAP_PROOF_FRAME_READY]' \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_RUNTIME.txt
if grep -Fq '[WORD_HUNT_REUSABLE_MAP_PROOF_ERROR]' \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_RUNTIME.txt; then
  echo 'Reusable map artwork/runtime probe failed.' >&2
  cat reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_RUNTIME.txt >&2
  exit 1
fi
capture_screenshot reports/WORD_HUNT_REUSABLE_MAP_ANDROID16.png
validate_nonblack_png \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16.png \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_PIXEL_CHECK.txt
if has_app_failure reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LOGCAT.txt; then
  echo 'Reusable map Android proof process failure detected.' >&2
  exit 1
fi
uninstall_if_present

install_apk "$MASTER_ART_APK" 'WORD_HUNT_VISUAL_PROOF'
prepare_runtime_logcat reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt
launch_main_activity \
  reports/WORD_HUNT_VISUAL_PROOF_LAUNCH.txt \
  'MASTER ART visual proof'
wait_for_flutter_frame \
  reports/WORD_HUNT_VISUAL_PROOF_ACTIVITY.txt \
  reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt \
  '[WORD_HUNT_VISUAL_PROOF_FRAME_READY]' \
  'MASTER ART visual proof'
capture_screenshot reports/ANDROID16_RAW.png
refresh_logcat_snapshot reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt || true
awk '/WORD_HUNT_VISUAL_PROOF_FRAME_READY|WORD_HUNT_PIXEL_PROOF_ASSET_(LOADED|ERROR)/' \
  reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt \
  > reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt
grep -Fq '[WORD_HUNT_VISUAL_PROOF_FRAME_READY]' \
  reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt
validate_nonblack_png \
  reports/ANDROID16_RAW.png \
  reports/WORD_HUNT_VISUAL_PROOF_PIXEL_CHECK.txt
if has_app_failure reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt; then
  echo 'Bilgi Rotası visual-proof process failure detected.' >&2
  exit 1
fi
if grep -Fq '[WORD_HUNT_PIXEL_PROOF_ASSET_ERROR]' \
  reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt; then
  cat reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt >&2
  exit 1
fi
grep -Fq '[WORD_HUNT_PIXEL_PROOF_ASSET_LOADED]' \
  reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt
test "$(grep -Fc '[WORD_HUNT_PIXEL_PROOF_ASSET_LOADED]' reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt)" -eq 2
