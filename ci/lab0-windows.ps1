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
$v = (cmd /c "sdkmanager --version 2>&1") -join "`n"
Write-Host "sdkmanager --version: $v"
Check ($LASTEXITCODE -eq 0) 'sdkmanager --version runs'

Step 'D3.8 sdkmanager --licenses (answering y to each)'
$yes = ("y`n" * 30)
$lic = ($yes | cmd /c "sdkmanager --licenses 2>&1") -join "`n"
Write-Host ($lic | Select-String -Pattern 'accepted|licenses' | Out-String)

Step 'D3.9 Download platform-tools, platform 36, build-tools 36.0.0'
$t0 = Get-Date
$out = (cmd /c 'sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0" 2>&1') -join "`n"
Write-Host ($out -split "`n" | Select-Object -Last 15 | Out-String)
Check ($LASTEXITCODE -eq 0) 'sdkmanager install command succeeded'
$sz = (Get-ChildItem 'C:\Android\Sdk' -Recurse -File | Measure-Object Length -Sum).Sum / 1MB
Write-Host ("SDK size on disk after D3: {0:N0} MB; download took {1:N0} s" -f $sz, ((Get-Date) - $t0).TotalSeconds)
$adbv = (cmd /c "adb version 2>&1") -join "`n"
Check ($adbv -match 'Android Debug Bridge version') 'adb version prints Android Debug Bridge version'
$before = (cmd /c "sdkmanager --list_installed 2>&1") -join "`n"
Write-Host "Installed packages after D3:`n$before"

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
$after = (cmd /c "sdkmanager --list_installed 2>&1") -join "`n"
Write-Host "Installed packages after build:`n$after"
Check ($after -eq $before) 'No extra SDK packages were downloaded by the build'

Step 'Kotlin starter builds the same way'
Copy-Item "$repo\kotlin-starter" 'C:\MAD\kotlin1' -Recurse
Push-Location 'C:\MAD\kotlin1'
$b = (cmd /c '.\gradlew.bat assembleDebug --no-daemon 2>&1') -join "`n"
$code = $LASTEXITCODE
Write-Host ($b -split "`n" | Select-Object -Last 30 | Out-String)
Check ($code -eq 0) 'kotlin-starter assembleDebug succeeded'
Pop-Location

$gh = "$env:USERPROFILE\.gradle"
$csz = (Get-ChildItem $gh -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB
Write-Host ("Gradle user home size: {0:N0} MB" -f $csz)

Stop-Transcript
if ($failed) { exit 1 }
