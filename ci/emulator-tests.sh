#!/usr/bin/env bash
# Runs inside android-emulator-runner: every lab's tests on the emulator, plus Lab 13's install checks.
set -u
API="$1"
R="$GITHUB_WORKSPACE/results/emulator-$API"
mkdir -p "$R"
cd "$GITHUB_WORKSPACE/ci/labs"

adb shell settings put global window_animation_scale 0
adb shell getprop ro.build.version.release > "$R/android-version.txt"
adb shell rm -rf /sdcard/Download/ci
adb logcat -c
adb logcat -v time > "$R/logcat-full.txt" 2>&1 &
LOGCAT=$!
# Lab 10: a GPS position at GCUF, Faisalabad, sent every 3 seconds
( while true; do adb emu geo fix 73.0700 31.4161 >/dev/null 2>&1; sleep 3; done ) &
GEO=$!

./gradlew --no-daemon --continue connectedDebugAndroidTest > "$R/connected.log" 2>&1
echo "connectedDebugAndroidTest exit: $?" >> "$R/connected.log"

kill $GEO $LOGCAT 2>/dev/null
adb pull /sdcard/Download/ci "$R/screens" > /dev/null 2>&1 || true
grep "LABCI" "$R/logcat-full.txt" > "$R/labci.txt" || true
grep -E "FATAL EXCEPTION|AndroidRuntime" -A 12 "$R/logcat-full.txt" > "$R/crashes.txt" || true
mkdir -p "$R/reports"
for m in */; do
  d="${m%/}/build/outputs/androidTest-results/connected"
  [ -d "$d" ] && cp -r "$d" "$R/reports/${m%/}" 2>/dev/null
done

# ---- Lab 13: signed release, signature mismatch, version shown ----
{
  echo "== keytool"
  keytool -genkeypair -v -keystore "$RUNNER_TEMP/my-release-key.jks" -alias mad_key -keyalg RSA -keysize 2048 -validity 10000 \
     -storepass lab13pass -dname "CN=Student, OU=IT, O=GCUF, L=Faisalabad, ST=Punjab, C=PK" 2>&1 | tail -2
  export LAB13_KEYSTORE="$RUNNER_TEMP/my-release-key.jks"
  ./gradlew --no-daemon -q :lab13:assembleDebug :lab13:assembleRelease :lab13:bundleRelease 2>&1 | tail -5
  ls -la lab13/build/outputs/apk/release/ lab13/build/outputs/bundle/release/ 2>&1
  adb uninstall com.university.lab13 >/dev/null 2>&1
  echo "== install debug, then release over it (expect INSTALL_FAILED_UPDATE_INCOMPATIBLE)"
  adb install lab13/build/outputs/apk/debug/lab13-debug.apk 2>&1 | tail -1
  adb install lab13/build/outputs/apk/release/lab13-release.apk 2>&1 | tail -1
  echo "== uninstall, install release"
  adb uninstall com.university.lab13
  adb install lab13/build/outputs/apk/release/lab13-release.apk 2>&1 | tail -1
  adb shell dumpsys package com.university.lab13 | grep -E "versionName|versionCode" | head -2
  echo "== debug over release (Task 2)"
  adb install lab13/build/outputs/apk/debug/lab13-debug.apk 2>&1 | tail -1
} > "$R/lab13.txt" 2>&1
exit 0
