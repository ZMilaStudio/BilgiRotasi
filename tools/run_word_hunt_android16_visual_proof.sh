#!/usr/bin/env bash
set -eu

mkdir -p reports

PACKAGE='com.leventua.bilgirotasi'
MAIN_ACTIVITY='com.leventua.bilgirotasi/.MainActivity'

wait_for_flutter_frame() {
  local snapshot="$1"
  local log_file="$2"
  local ready_marker="$3"
  local label="$4"
  local ready=0

  for attempt in $(seq 1 45); do
    if ! adb shell dumpsys activity activities > "$snapshot"; then
      echo "$label lost adb while waiting for Flutter frame" >&2
      return 1
    fi
    if grep -Fq "$MAIN_ACTIVITY" "$snapshot" \
      && grep -Eq 'topResumedActivity=.*com\.leventua\.bilgirotasi|ResumedActivity:.*com\.leventua\.bilgirotasi' "$snapshot" \
      && grep -Fq "$ready_marker" "$log_file"; then
      ready=1
      echo "$label Flutter frame confirmed on attempt $attempt"
      break
    fi
    sleep 1
  done

  if [ "$ready" -ne 1 ]; then
    echo "$label never emitted its Flutter frame-ready marker" >&2
    cat "$snapshot" >&2
    tail -n 200 "$log_file" >&2 || true
    return 1
  fi

  grep -Fq "$MAIN_ACTIVITY" "$snapshot"
  grep -Eq 'topResumedActivity=.*com\.leventua\.bilgirotasi|ResumedActivity:.*com\.leventua\.bilgirotasi' "$snapshot"
  grep -Fq "$ready_marker" "$log_file"
  test -n "$(adb shell pidof "$PACKAGE" | tr -d '\r\n')"
  sleep 1
}

launch_main_activity() {
  local launch_report="$1"
  local label="$2"

  adb shell am force-stop "$PACKAGE"
  if ! adb shell am start -S -n "$MAIN_ACTIVITY" > "$launch_report" 2>&1; then
    echo "$label explicit activity launch failed" >&2
    cat "$launch_report" >&2
    return 1
  fi
  cat "$launch_report"
  grep -Eq 'Starting: Intent|Status: ok|Activity:' "$launch_report"
}

start_runtime_logcat() {
  local log_file="$1"
  adb logcat -c
  adb logcat -v threadtime > "$log_file" 2>&1 &
  RUNTIME_LOGCAT_PID=$!
}

stop_runtime_logcat() {
  if [ -n "${RUNTIME_LOGCAT_PID:-}" ]; then
    kill "$RUNTIME_LOGCAT_PID" 2>/dev/null || true
    wait "$RUNTIME_LOGCAT_PID" 2>/dev/null || true
    unset RUNTIME_LOGCAT_PID
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

if adb shell pm path "$PACKAGE" 2>/dev/null | grep -q '^package:'; then
  adb uninstall "$PACKAGE"
fi

adb install reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_PROOF.apk
start_runtime_logcat reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LOGCAT.txt
launch_main_activity \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LAUNCH.txt \
  'Reusable map proof'
wait_for_flutter_frame \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_ACTIVITY.txt \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LOGCAT.txt \
  '[WORD_HUNT_REUSABLE_MAP_PROOF_FRAME_READY]' \
  'Reusable map proof'
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
adb exec-out screencap -p > reports/WORD_HUNT_REUSABLE_MAP_ANDROID16.png
stop_runtime_logcat
test -s reports/WORD_HUNT_REUSABLE_MAP_ANDROID16.png
validate_nonblack_png \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16.png \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_PIXEL_CHECK.txt
if grep -E 'FATAL EXCEPTION|ANR in com\.leventua\.bilgirotasi|am_crash.*com\.leventua\.bilgirotasi|am_proc_died.*com\.leventua\.bilgirotasi' \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LOGCAT.txt; then
  echo 'Reusable map Android proof process failure detected.' >&2
  exit 1
fi
adb uninstall "$PACKAGE"

adb install build/app/outputs/flutter-apk/app-debug.apk
start_runtime_logcat reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt
launch_main_activity \
  reports/WORD_HUNT_VISUAL_PROOF_LAUNCH.txt \
  'MASTER ART visual proof'
wait_for_flutter_frame \
  reports/WORD_HUNT_VISUAL_PROOF_ACTIVITY.txt \
  reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt \
  '[WORD_HUNT_VISUAL_PROOF_FRAME_READY]' \
  'MASTER ART visual proof'
adb exec-out screencap -p > reports/ANDROID16_RAW.png
stop_runtime_logcat
awk '/WORD_HUNT_VISUAL_PROOF_FRAME_READY|WORD_HUNT_PIXEL_PROOF_ASSET_(LOADED|ERROR)/' \
  reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt \
  > reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt
grep -Fq '[WORD_HUNT_VISUAL_PROOF_FRAME_READY]' \
  reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt
test -s reports/ANDROID16_RAW.png
validate_nonblack_png \
  reports/ANDROID16_RAW.png \
  reports/WORD_HUNT_VISUAL_PROOF_PIXEL_CHECK.txt
if grep -E 'FATAL EXCEPTION|ANR in com\.leventua\.bilgirotasi|am_crash.*com\.leventua\.bilgirotasi|am_proc_died.*com\.leventua\.bilgirotasi' \
  reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt; then
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
