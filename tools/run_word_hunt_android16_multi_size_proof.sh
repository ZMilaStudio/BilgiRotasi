#!/usr/bin/env bash
set -euo pipefail

PACKAGE='com.leventua.bilgirotasi'
MAIN_ACTIVITY='com.leventua.bilgirotasi/.MainActivity'
APK='reports/WORD_HUNT_ORMAN_MULTI_SIZE_PROOF.apk'

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

  for _ in $(seq 1 45); do
    a 15 shell dumpsys activity activities > "$activity_file" 2>/dev/null || true
    a 15 logcat -d -v threadtime > "$log_file" 2>/dev/null || true
    if grep -Fq "$MAIN_ACTIVITY" "$activity_file" \
        && grep -Fq '[WORD_HUNT_REUSABLE_MAP_PROOF_FRAME_READY]' "$log_file"; then
      ready=1
      break
    fi
    sleep 1
  done

  if [ "$ready" -ne 1 ]; then
    echo 'Orman multi-size proof never reached frame-ready marker.' >&2
    tail -n 160 "$log_file" >&2 || true
    return 1
  fi

  # Opening transition is 650 ms. Give the approved raster artwork and the
  # live node layer enough time to settle before taking evidence.
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

validate_forest_richness() {
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
previous = bytearray(stride)
offset = 0

x0 = int(width * 0.05)
x1 = int(width * 0.95)
y0 = int(height * 0.18)
y1 = int(height * 0.88)

count = 0
luma_total = 0.0
bright = 0
sat_total = 0.0


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


for y in range(height):
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

    if y0 <= y < y1:
        for x in range(x0, x1):
            base = x * channels
            if color_type in (0, 4):
                r = g = b = row[base]
            else:
                r, g, b = row[base:base + 3]
            luma = 0.2126 * r + 0.7152 * g + 0.0722 * b
            luma_total += luma
            sat_total += max(r, g, b) - min(r, g, b)
            bright += 1 if luma > 80 else 0
            count += 1

    previous = row

avg_luma = luma_total / count if count else 0.0
bright_ratio = bright / count if count else 0.0
avg_saturation = sat_total / count if count else 0.0

print(f'width={width}')
print(f'height={height}')
print(f'central_avg_luma={avg_luma:.3f}')
print(f'central_bright_ratio_gt80={bright_ratio:.6f}')
print(f'central_avg_saturation={avg_saturation:.3f}')

# The dark green fallback can pass a generic non-black test. These thresholds
# intentionally require the approved forest artwork's real scene richness.
if avg_luma < 55 or bright_ratio < 0.20 or avg_saturation < 28:
    raise SystemExit(
        'approved forest artwork is not visibly rendered: '
        f'avg_luma={avg_luma:.3f} bright_ratio={bright_ratio:.6f} '
        f'avg_saturation={avg_saturation:.3f}'
    )
PY
  cat "$metrics"
}

capture_profile() {
  local label="$1"
  local size_override="$2"
  local density_override="$3"

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
    > "reports/WORD_HUNT_ORMAN_${label}_LAUNCH.txt" 2>&1

  wait_for_ready \
    "reports/WORD_HUNT_ORMAN_${label}_LOGCAT.txt" \
    "reports/WORD_HUNT_ORMAN_${label}_ACTIVITY.txt"

  capture_png "reports/WORD_HUNT_ORMAN_ANDROID16_${label}.png"
  validate_forest_richness \
    "reports/WORD_HUNT_ORMAN_ANDROID16_${label}.png" \
    "reports/WORD_HUNT_ORMAN_ANDROID16_${label}_METRICS.txt"
}

test -s "$APK"
a 20 wait-for-device
a 20 shell getprop sys.boot_completed | tr -d '\r' | grep -Fxq '1'
a 120 install -r "$APK" | tee reports/WORD_HUNT_ORMAN_MULTI_SIZE_INSTALL.txt
grep -Fq 'Success' reports/WORD_HUNT_ORMAN_MULTI_SIZE_INSTALL.txt

capture_profile 'STANDARD_1080x1920' '' ''
capture_profile 'COMPACT_720x1280' '720x1280' '320'
capture_profile 'TALL_1080x2400' '1080x2400' '440'

printf '%s\n' \
  'RESULT=SUCCESS' \
  'STANDARD=WORD_HUNT_ORMAN_ANDROID16_STANDARD_1080x1920.png' \
  'COMPACT=WORD_HUNT_ORMAN_ANDROID16_COMPACT_720x1280.png' \
  'TALL=WORD_HUNT_ORMAN_ANDROID16_TALL_1080x2400.png' \
  > reports/WORD_HUNT_ORMAN_MULTI_SIZE_RESULT.txt
