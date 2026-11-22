#!/bin/bash
# labs.sh: analyze, test and build every lab app of the handbook
set -u
R="$GITHUB_WORKSPACE/results/labs"; A="$GITHUB_WORKSPACE/apks"
mkdir -p "$R" "$A"
cd app
flutter --version > "$R/flutter-version.txt" 2>&1
flutter create --platforms=android,web --org pk.student . > "$R/create.log" 2>&1
rm -f test/widget_test.dart
python3 ../ci/patch_android.py >> "$R/create.log" 2>&1
flutter pub get > "$R/pubget.log" 2>&1; echo "pub get exit $?" >> "$R/summary.txt"
flutter pub deps --style=compact > "$R/deps.txt" 2>&1
flutter analyze > "$R/analyze.log" 2>&1; echo "analyze exit $?" >> "$R/summary.txt"
flutter test --reporter expanded > "$R/test.log" 2>&1
echo "test exit $?" >> "$R/summary.txt"
for a in hello bmi navigation notes async api firebase login; do
  rm -rf build/web
  flutter build web -t lib/${a}_app.dart > "$R/web-$a.log" 2>&1
  echo "web $a exit $? $(du -sh build/web/main.dart.js 2>/dev/null)" >> "$R/summary.txt"
done
for a in phone async notes; do
  flutter build apk --debug -t lib/${a}_app.dart > "$R/apk-$a.log" 2>&1
  echo "apk $a exit $?" >> "$R/summary.txt"
  cp build/app/outputs/flutter-apk/app-debug.apk "$A/$a.apk"
done
cat "$R/summary.txt"
