#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <path-to-aab-or-apk>

Checks an APK or AAB for 16KB page-size compatibility.
- For APK: runs `zipalign -c -P 16` (if available) and inspects bundled .so files' p_align values.
- For AAB: uses `bundletool` (if available) to build a universal APK then runs the same checks.

Examples:
  $0 build/app/outputs/bundle/release/app.aab
  $0 build/app/outputs/flutter-apk/app-release.apk
EOF
}

if [ "$#" -ne 1 ]; then
  usage
  exit 2
fi

INPUT="$1"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

find_zipalign() {
  if command -v zipalign >/dev/null 2>&1; then
    command -v zipalign
    return 0
  fi

  for sdk in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}"; do
    [ -n "$sdk" ] || continue
    for d in "$sdk"/build-tools/*; do
      if [ -x "$d/zipalign" ]; then
        printf '%s\n' "$d/zipalign"
        return 0
      fi
    done
  done

  return 1
}

find_readelf() {
  for exe in readelf greadelf llvm-readelf; do
    if command -v "$exe" >/dev/null 2>&1; then
      command -v "$exe"
      return 0
    fi
  done

  if command -v brew >/dev/null 2>&1 && [ -x "$(brew --prefix)/opt/binutils/bin/greadelf" ]; then
    printf '%s\n' "$(brew --prefix)/opt/binutils/bin/greadelf"
    return 0
  fi

  return 1
}

check_apk() {
  local apk="$1"
  echo "\n== Checking APK: $apk =="

  zipalign_path=$(find_zipalign || true)
  if [ -n "$zipalign_path" ]; then
    echo "Running: $zipalign_path -c -p -v 16 $apk"
    if "$zipalign_path" -c -p -v 16 "$apk"; then
      echo "zipalign 16 check: PASS"
    else
      echo "zipalign 16 check: FAIL"
      echo "Note: zipalign may report failures for compressed APK entries; the .so ELF p_align checks below are the stronger 16KB page-size compatibility signal."
    fi
  else
    echo "zipalign not found in PATH or Android SDK build-tools."
    echo "Install Android build-tools and ensure the build-tools path is available via ANDROID_HOME or ANDROID_SDK_ROOT."
  fi

  echo "Extracting lib/ from APK..."
  unzip -qq "$apk" -d "$TMPDIR/apk"

  shopt -s nullglob
  readelf_cmd=$(find_readelf || true)
  if [ -z "$readelf_cmd" ]; then
    echo "readelf not found; install binutils (brew install binutils) to inspect ELF headers."
    break
  fi

  for so in "$TMPDIR/apk"/lib/*/*.so; do
    [ -f "$so" ] || continue
    echo "\nInspecting: $(basename "$so") (path: $so)"
    # Print PT_LOAD p_align values
    "$readelf_cmd" -lW "$so" | awk '/Type/{t=$2} /LOAD/{print "PHDR:"$1" p_offset="$2" p_align="$(NF)}'

    pal_hex=$("$readelf_cmd" -lW "$so" | awk '/LOAD/{print $NF; exit}')
    if [ -z "$pal_hex" ]; then
      echo "  Could not find p_align; skipping numeric check."
      continue
    fi
    # Convert hex (0x1000) to decimal
    pal_dec=$((pal_hex))
    echo "  p_align (decimal): $pal_dec"
    if [ "$pal_dec" -lt 16384 ]; then
      echo "  WARNING: p_align < 16384 — this .so may be incompatible with 16KB page-size devices"
    else
      echo "  OK: p_align >= 16384"
    fi
  done
  shopt -u nullglob
}

handle_aab() {
  local aab="$1"
  if ! command -v bundletool >/dev/null 2>&1; then
    echo "bundletool not found. To check AABs you should install bundletool: https://developer.android.com/studio/command-line/bundletool"
    echo "As a fallback you can generate APKs via CI or use Android Studio → Build → Build Bundle(s) / APK(s) → Build APK(s) and then run this script on the produced APK."
    exit 3
  fi

  out_apks="$TMPDIR/out.apks"
  echo "Building universal APK from AAB via bundletool (output: $out_apks)"
  bundletool build-apks --bundle="$aab" --output="$out_apks" --mode=universal
  unzip -qq "$out_apks" -d "$TMPDIR/apks"
  if [ -f "$TMPDIR/apks/universal.apk" ]; then
    check_apk "$TMPDIR/apks/universal.apk"
  else
    # find any APK inside
    apks=("$TMPDIR/apks"/*.apk)
    if [ ${#apks[@]} -gt 0 ]; then
      for apk in "${apks[@]}"; do
        check_apk "$apk"
      done
    else
      echo "No APK found inside generated .apks — aborting."
      exit 4
    fi
  fi
}

case "$INPUT" in
  *.aab) handle_aab "$INPUT" ;;
  *.apk) check_apk "$INPUT" ;;
  *) echo "Unsupported file type. Provide an .aab or .apk"; exit 2 ;;
esac

echo "\nDone. If any .so showed p_align < 16384, identify which dependency supplies it (inspect AARs, pubspec.lock, or Gradle dependency tree)."
