#!/usr/bin/env bash
# Installs the Android command-line tools and the SDK packages the labs need (Lab 0, Part G).
set -euo pipefail
LOG="$(pwd)/.devcontainer/setup.log"
exec > >(tee -a "$LOG") 2>&1
echo "setup started $(date) as $(whoami) in $(pwd)"
set -x
SDK=/home/vscode/android-sdk
if [ -x "$SDK/cmdline-tools/latest/bin/android" ] && [ -d "$SDK/platforms/android-37.0" ]; then
  echo "Android SDK ready"; exit 0
fi
mkdir -p "$SDK/cmdline-tools"
ZIP=$(curl -fsSL https://dl.google.com/android/repository/repository2-3.xml \
      | grep -o 'commandlinetools-linux-[0-9]*_latest\.zip' | sort -u | tail -1)
echo "Downloading $ZIP"
curl -fsSL -o /tmp/clt.zip "https://dl.google.com/android/repository/$ZIP"
command -v unzip >/dev/null || (sudo apt-get update -qq && sudo apt-get install -y -qq unzip)
rm -rf /tmp/clt && unzip -q /tmp/clt.zip -d /tmp/clt
rm -rf "$SDK/cmdline-tools/latest" && mv /tmp/clt/cmdline-tools "$SDK/cmdline-tools/latest"
export ANDROID_HOME="$SDK"
export PATH="$SDK/cmdline-tools/latest/bin:$SDK/platform-tools:$PATH"
command -v unzip >/dev/null || (sudo apt-get update -qq && sudo apt-get install -y -qq unzip)
android sdk install platform-tools platforms/android-37.0 build-tools/36.0.0
echo "Android SDK ready"
