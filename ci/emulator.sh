#!/bin/bash
# emulator.sh: run the phone, async and notes apps on an Android emulator
set -u
API="$1"; R="$GITHUB_WORKSPACE/results/emulator-$API"; mkdir -p "$R"
PKG=pk.student.gomal_mad_labs
cd "$GITHUB_WORKSPACE"
log() { echo "$*" | tee -a "$R/summary.txt"; }
shot() { adb exec-out screencap -p > "$R/$1.png"; }
dump() {
  adb shell uiautomator dump /sdcard/ui.xml > /dev/null 2>&1
  adb shell cat /sdcard/ui.xml > "$R/$1.xml"
}
tap() {   # tap the element whose label contains $2, in dump $1
  local xy; xy=$(python3 ci/ui.py "$R/$1.xml" "$2") || { log "NOT FOUND: $2"; return 1; }
  adb shell input tap $xy
}
has() { grep -q "$2" "$R/$1.xml" && log "OK: '$2' on screen" || log "FAIL: '$2' not on screen"; }
launch() { adb shell monkey -p $PKG -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1; }

adb shell getprop ro.build.version.release > "$R/android-version.txt"
adb logcat -c; adb logcat -v time > "$R/logcat.txt" 2>&1 & LC=$!

# ---- Lab 3: sensors and notifications ----
adb install -r -g apks/phone.apk > "$R/install-phone.txt" 2>&1
launch; sleep 15; dump phone-start; shot phone-start
has phone-start "Sensor Lab"; has phone-start "x: "
grep -o 'x: [^"]*' "$R/phone-start.xml" | head -1 >> "$R/summary.txt"
tap phone-start "Send notification"; sleep 4
adb shell dumpsys notification --noredact > "$R/notifications-1.txt"
grep -q "Hello from the Sensor Lab" "$R/notifications-1.txt" \
  && log "OK: button notification posted" || log "FAIL: no button notification"
for i in 1 2 3 4 5 6; do   # six shakes, 1.7 s apart
  adb emu sensor set acceleration 30:5:9.8 > /dev/null; sleep 0.5
  adb emu sensor set acceleration 0:9.8:0 > /dev/null; sleep 1.2
done
sleep 2; dump phone-shakes; shot phone-shakes
grep -o 'Shakes: [0-9]*' "$R/phone-shakes.xml" | head -1 >> "$R/summary.txt"
adb shell dumpsys notification --noredact > "$R/notifications-2.txt"
grep -q "You shook the phone 5 times" "$R/notifications-2.txt" \
  && log "OK: shake notification posted" || log "FAIL: no shake notification"
adb shell cmd statusbar expand-notifications; sleep 2; shot notification-shade
adb shell cmd statusbar collapse

# ---- Lab 2: background isolate keeps the UI responsive ----
adb install -r apks/async.apk > "$R/install-async.txt" 2>&1
launch; sleep 12; dump async-start; shot async-start
tap async-start "3. Count primes in background"; sleep 2; shot async-working
for i in $(seq 30); do sleep 2; dump async-bg; grep -q "Background: " "$R/async-bg.xml" && break; done
grep -o 'Background: [^"]*' "$R/async-bg.xml" | head -1 >> "$R/summary.txt"
has async-bg "Background: 216816 primes"
tap async-bg "2. Count primes on UI thread"
for i in $(seq 30); do sleep 2; dump async-ui; grep -q "UI thread: " "$R/async-ui.xml" && break; done
grep -o 'UI thread: [^"]*' "$R/async-ui.xml" | head -1 >> "$R/summary.txt"
has async-ui "UI thread: 216816 primes"
shot async-done

# ---- Lab 2: notes survive closing the app ----
adb install -r apks/notes.apk > "$R/install-notes.txt" 2>&1
launch; sleep 12; dump notes-start
tap notes-start "New note"; sleep 1
adb shell input text "Persistent%snote%s1"; adb shell input keyevent 66; sleep 2
dump notes-added; has notes-added "Persistent note 1"
adb shell am force-stop $PKG; sleep 2; launch; sleep 12
dump notes-reopened; shot notes-reopened
has notes-reopened "Persistent note 1"

kill $LC 2>/dev/null
grep -E "FATAL EXCEPTION|E/flutter" -A 8 "$R/logcat.txt" > "$R/errors.txt" || true
cat "$R/summary.txt"
