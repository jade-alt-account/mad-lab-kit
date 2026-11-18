# Follows Lab 0, Part D of the MAD handbook on a fresh Windows machine and records every result.
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force results | Out-Null
$log = Join-Path (Resolve-Path results) 'lab0-windows.log'
Start-Transcript -Path $log
$repo = (Get-Location).Path

function Step($t) { Write-Host "`n===== $t =====" }
function Check($cond, $msg) { if ($cond) { Write-Host "PASS: $msg" } else { Write-Host "FAIL: $msg"; $script:failed = $true } }
$failed = $false

# The runner comes with its own Android SDK; a student's laptop does not. Hide it.
Remove-Item Env:ANDROID_SDK_ROOT -ErrorAction SilentlyContinue
Remove-Item Env:ANDROID_HOME -ErrorAction SilentlyContinue
Remove-Item Env:ANDROID_NDK_HOME -ErrorAction SilentlyContinue

Step 'D1. java -version'
$jv = (cmd /c "java -version 2>&1") -join "`n"
Write-Host $jv
Check ($jv -match 'openjdk version "17') 'java -version shows openjdk version "17'

Step 'D3.1 Download the command-line tools'
$xml = (Invoke-WebRequest -UseBasicParsing 'https://dl.google.com/android/repository/repository2-3.xml').Content
$nums = [regex]::Matches($xml, 'commandlinetools-win-(\d+)_latest\.zip') | ForEach-Object { [int64]$_.Groups[1].Value } | Sort-Object -Unique
$zipName = "commandlinetools-win-$($nums[-1])_latest.zip"
Write-Host "Latest package: $zipName"
Invoke-WebRequest -UseBasicParsing "https://dl.google.com/android/repository/$zipName" -OutFile "$env:TEMP\$zipName"

Step 'D3.2-3 Create C:\Android\Sdk\cmdline-tools\latest and copy the contents'
New-Item -ItemType Directory -Force 'C:\Android\Sdk\cmdline-tools\latest' | Out-Null
Expand-Archive "$env:TEMP\$zipName" -DestinationPath "$env:TEMP\clt" -Force
Write-Host "Zip top-level folder(s): $((Get-ChildItem "$env:TEMP\clt").Name -join ', ')"
Copy-Item "$env:TEMP\clt\cmdline-tools\*" 'C:\Android\Sdk\cmdline-tools\latest' -Recurse -Force
Check (Test-Path 'C:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat') 'sdkmanager.bat is at C:\Android\Sdk\cmdline-tools\latest\bin'

Step 'D3.4-7 Environment variables (user scope, as in the handbook)'
[Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Android\Sdk', 'User')
$env:ANDROID_HOME = 'C:\Android\Sdk'
$env:Path = "$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:ANDROID_HOME\platform-tools;$env:Path"
Write-Host "Files in cmdline-tools\latest\bin: $((Get-ChildItem 'C:\Android\Sdk\cmdline-tools\latest\bin').Name -join ', ')"
$v = (cmd /c "android --version 2>&1") -join "`n"
Write-Host "android --version: $v"
Check ($LASTEXITCODE -eq 0) 'android --version runs'
Write-Host "--- android sdk --help:`n$((cmd /c 'android sdk --help 2>&1') -join "`n")"
Write-Host "--- android sdk install --help:`n$((cmd /c 'android sdk install --help 2>&1') -join "`n")"
$avail = (cmd /c 'android sdk list --all 2>&1') -join "`n"
if ($avail.Length -lt 200) { $avail = (cmd /c 'android sdk list 2>&1') -join "`n" }
Write-Host "--- available packages (platforms, build-tools, platform-tools, usb):"
Write-Host (($avail -split "`n") | Where-Object { $_ -match 'platforms|build-tools/3[5-7]|platform-tools|usb_driver|Available|Installed' } | Select-Object -First 40 | Out-String)

Step 'D3.9 android sdk install platform-tools platforms/android-37.0 build-tools/36.0.0'
$t0 = Get-Date
$yes = ("y`n" * 10)
$out = ($yes | cmd /c 'android sdk install platform-tools platforms/android-37.0 build-tools/36.0.0 2>&1') -join "`n"
$code = $LASTEXITCODE
Write-Host (($out -split "`n") | Where-Object { $_ -notmatch '\[[#\. ]+\]' } | Select-Object -Last 25 | Out-String)
Check ($code -eq 0) 'android sdk install exited with 0'
$sz = (Get-ChildItem 'C:\Android\Sdk' -Recurse -File | Measure-Object Length -Sum).Sum / 1MB
Write-Host ("SDK size on disk after D3: {0:N0} MB; download took {1:N0} s" -f $sz, ((Get-Date) - $t0).TotalSeconds)
Check (Test-Path 'C:\Android\Sdk\platforms\android-37.0\android.jar') 'platform android-37.0 installed'
Check (Test-Path 'C:\Android\Sdk\build-tools\36.0.0') 'build-tools 36.0.0 installed'
$adbv = (cmd /c "adb version 2>&1") -join "`n"
Check ($adbv -match 'Android Debug Bridge version') 'adb version prints Android Debug Bridge version'
$before = (cmd /c "android sdk list 2>&1") -join "`n"
Write-Host "Installed packages after D3:`n$before"
$beforeDirs = (Get-ChildItem 'C:\Android\Sdk' -Directory -Recurse -Depth 1).FullName -join "`n"

Step 'Experiment: old sdkmanager line in a second, empty SDK folder'
$env:ANDROID_HOME = 'C:\Android\Sdk2'
New-Item -ItemType Directory -Force 'C:\Android\Sdk2\cmdline-tools' | Out-Null
Copy-Item 'C:\Android\Sdk\cmdline-tools\latest' 'C:\Android\Sdk2\cmdline-tools\latest' -Recurse
foreach ($cmd in @('sdkmanager "platforms;android-37"', 'sdkmanager "platforms;android-37.0"', 'C:\Android\Sdk2\cmdline-tools\latest\bin\android.bat sdk install "platforms;android-37.0"')) {
  $o = ($yes | cmd /c "$cmd 2>&1") -join "`n"
  Write-Host "> $cmd  (exit $LASTEXITCODE)"
  Write-Host (($o -split "`n") | Where-Object { $_ -notmatch '\[[#\. ]+\]' -and $_ -notmatch 'deprecated|android-cli|replacement' } | Select-Object -Last 6 | Out-String)
  Write-Host "  platforms now: $((Get-ChildItem 'C:\Android\Sdk2\platforms' -ErrorAction SilentlyContinue).Name -join ', ')"
}
$env:ANDROID_HOME = 'C:\Android\Sdk'

Step 'D4. Copy the starter project to C:\MAD\lab0 and change applicationId'
New-Item -ItemType Directory -Force 'C:\MAD' | Out-Null
Copy-Item "$repo\starter" 'C:\MAD\lab0' -Recurse
$g = 'C:\MAD\lab0\app\build.gradle.kts'
(Get-Content $g) -replace 'applicationId = "com.university.labstarter"', 'applicationId = "com.university.lab0"' | Set-Content $g
Check ((Get-Content $g -Raw) -match 'applicationId = "com.university.lab0"') 'applicationId changed to com.university.lab0'

Step 'D5. Build (assembleDebug: no phone is attached on the test machine)'
Push-Location 'C:\MAD\lab0'
$t0 = Get-Date
$b = (cmd /c '.\gradlew.bat assembleDebug --no-daemon 2>&1') -join "`n"
$code = $LASTEXITCODE
Write-Host ($b -split "`n" | Select-Object -Last 40 | Out-String)
Write-Host ("First build took {0:N0} s" -f ((Get-Date) - $t0).TotalSeconds)
Check ($code -eq 0 -and $b -match 'BUILD SUCCESSFUL') 'gradlew.bat assembleDebug: BUILD SUCCESSFUL with -Xmx1536m'
Check (Test-Path 'C:\MAD\lab0\app\build\outputs\apk\debug\app-debug.apk') 'app-debug.apk produced'
Pop-Location

Step 'Did the build download any extra SDK packages?'
$after = (cmd /c "android sdk list 2>&1") -join "`n"
Write-Host "Installed packages after build:`n$after"
$afterDirs = (Get-ChildItem 'C:\Android\Sdk' -Directory -Recurse -Depth 1).FullName -join "`n"
Check ($afterDirs -eq $beforeDirs) 'No extra SDK packages were downloaded by the build'

Step 'Kotlin starter builds the same way'
Copy-Item "$repo\kotlin-starter" 'C:\MAD\kotlin1' -Recurse
Push-Location 'C:\MAD\kotlin1'
$b = (cmd /c '.\gradlew.bat assembleDebug --no-daemon 2>&1') -join "`n"
$code = $LASTEXITCODE
Write-Host ($b -split "`n" | Select-Object -Last 30 | Out-String)
Check ($code -eq 0) 'kotlin-starter assembleDebug succeeded'
Pop-Location


Step 'Lab 12 Part A: Notes service with npm and PowerShell'
New-Item -ItemType Directory -Force 'C:\MAD\notes-api' | Out-Null
Push-Location 'C:\MAD\notes-api'
Write-Host ((cmd /c "npm init -y 2>&1") | Select-Object -Last 3 | Out-String)
Write-Host ((cmd /c "npm install express 2>&1") | Select-Object -Last 3 | Out-String)
Check (Test-Path 'node_modules') 'node_modules created'
Check (Test-Path 'package.json') 'package.json created'
Copy-Item "$repo\ci\notes-api\server.js" 'server.js'
$node = Start-Process node -ArgumentList 'server.js' -PassThru -RedirectStandardOutput 'server.log' -NoNewWindow
Start-Sleep 3
Write-Host "server.log: $(Get-Content server.log)"
Check ((Get-Content server.log -Raw) -match 'Notes API on http://localhost:3000') 'server prints Notes API on http://localhost:3000'
$get = (Invoke-WebRequest -UseBasicParsing http://localhost:3000/api/notes).Content
Write-Host "GET: $get"
Check ($get -eq '[{"id":1,"title":"First note","body":"Hello from the server"}]') 'browser page shows the first note exactly'
Invoke-RestMethod -Method Post -Uri http://localhost:3000/api/notes `
  -ContentType "application/json" `
  -Body '{"title":"Lab 12","body":"From PowerShell"}'
$get2 = (Invoke-WebRequest -UseBasicParsing http://localhost:3000/api/notes).Content
Write-Host "GET after POST: $get2"
Check ($get2 -match '"title":"Lab 12"') 'POST from PowerShell added the note'
Stop-Process $node.Id
Pop-Location

Step 'Lab 13: keytool, signingConfigs, assembleRelease, bundleRelease'
New-Item -ItemType Directory -Force 'C:\MAD\keys' | Out-Null
Push-Location 'C:\MAD\keys'
$answers = "lab13pass`nlab13pass`nAli Khan`nIT`nGCUF`nFaisalabad`nPunjab`nPK`nyes`n"
$kt = ($answers | cmd /c "keytool -genkeypair -v -keystore my-release-key.jks -alias mad_key -keyalg RSA -keysize 2048 -validity 10000 2>&1") -join "`n"
Write-Host $kt
Check (Test-Path 'C:\MAD\keys\my-release-key.jks') 'keytool created my-release-key.jks'
Pop-Location
$g = 'C:\MAD\lab0\app\build.gradle.kts'
$t = Get-Content $g -Raw
$t = $t -replace 'versionCode = 1', 'versionCode = 2' -replace 'versionName = "1.0"', 'versionName = "1.1"'
$sign = @'
    signingConfigs {
        create("release") {
            storeFile = file("C:/MAD/keys/my-release-key.jks")
            storePassword = "lab13pass"
            keyAlias = "mad_key"
            keyPassword = "lab13pass"
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }

'@
$t = $t -replace '(android \{\r?\n)', "`$1$sign"
Set-Content $g $t
Write-Host (Get-Content $g -Raw)
Push-Location 'C:\MAD\lab0'
$b = (cmd /c '.\gradlew.bat assembleRelease bundleRelease --no-daemon 2>&1') -join "`n"
Write-Host ($b -split "`n" | Select-Object -Last 15 | Out-String)
Check (Test-Path 'app\build\outputs\apk\release\app-release.apk') 'app-release.apk built'
Check (Test-Path 'app\build\outputs\bundle\release\app-release.aab') 'app-release.aab built'
if (Test-Path 'app\build\outputs\apk\release\app-release.apk') {
  Write-Host ("APK size: {0:N0} KB; AAB size: {1:N0} KB" -f ((Get-Item 'app\build\outputs\apk\release\app-release.apk').Length/1KB), ((Get-Item 'app\build\outputs\bundle\release\app-release.aab').Length/1KB))
  $apksigner = Get-ChildItem 'C:\Android\Sdk\build-tools' -Recurse -Filter apksigner.bat | Select-Object -First 1
  Write-Host ((cmd /c "`"$($apksigner.FullName)`" verify --print-certs app\build\outputs\apk\release\app-release.apk 2>&1") | Select-Object -First 3 | Out-String)
}
Pop-Location

$gh = "$env:USERPROFILE\.gradle"
$csz = (Get-ChildItem $gh -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB
Write-Host ("Gradle user home size: {0:N0} MB" -f $csz)

Stop-Transcript
if ($failed) { exit 1 }
