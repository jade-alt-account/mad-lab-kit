MAD LITE KIT - Mobile Application Development labs on an ordinary laptop
=========================================================================

This folder lets you build Android apps for the labs without Android Studio.
The full instructions are in the Lab Manual, Lab 0, Part D. Short version:

WHAT IS IN THIS FOLDER
  starter\          The Java starter project. Copy it for every lab.
  kotlin-starter\   The same in Kotlin (with Jetpack Compose), for bonus work.
  README.txt        This file.

  If your instructor gave you a USB pack, it also has:
  jdk\              Java Development Kit 17 installer (Eclipse Temurin)
  vscode\           Visual Studio Code installer
  nodejs\           Node.js installer (Lab 12)
  gradle-home\      Build libraries already downloaded (saves about 1 GB)

  Without the USB pack, download these yourself (all free):
  JDK 17 ............ adoptium.net  (Temurin 17, Windows x64, .msi)
  VS Code ........... code.visualstudio.com
  Node.js (LTS) ..... nodejs.org
  gradle-home.zip ... github.com/jade-alt-account/mad-lab-kit/releases/latest

STEPS (Windows)
  1. Install the JDK. Tick "Set JAVA_HOME variable". Check: java -version
  2. Install VS Code and its "Extension Pack for Java" (by Microsoft).
  3. Download "Command line tools only" for Windows from
     developer.android.com/studio and copy the CONTENTS of its
     cmdline-tools folder into C:\Android\Sdk\cmdline-tools\latest
  4. Set the user variable ANDROID_HOME = C:\Android\Sdk and add to Path:
       %ANDROID_HOME%\cmdline-tools\latest\bin
       %ANDROID_HOME%\platform-tools
  5. In a NEW PowerShell window:
       android sdk install platform-tools platforms/android-37.0 build-tools/36.0.0
  6. Copy gradle-home to C:\Users\<you>\.gradle (if you have it).
  7. Copy starter to C:\MAD\lab0, open it in VS Code, and in
     app\build.gradle.kts change applicationId to com.university.lab0
  8. Connect your phone (USB debugging on), then in the terminal:
       adb devices
       .\gradlew.bat installDebug

The starter projects were built and tested automatically on Windows and on
Android emulators (Android 11 and Android 15). The test results are published
at github.com/jade-alt-account/mad-lab-kit
