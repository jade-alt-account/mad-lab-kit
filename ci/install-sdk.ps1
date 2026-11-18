# Lab 0 Part D3 in one script (used by the release jobs): command-line tools + SDK packages.
$ErrorActionPreference = 'Stop'
Remove-Item Env:ANDROID_SDK_ROOT -ErrorAction SilentlyContinue
$xml = (Invoke-WebRequest -UseBasicParsing 'https://dl.google.com/android/repository/repository2-3.xml').Content
$nums = [regex]::Matches($xml, 'commandlinetools-win-(\d+)_latest\.zip') | ForEach-Object { [int64]$_.Groups[1].Value } | Sort-Object -Unique
$zip = "commandlinetools-win-$($nums[-1])_latest.zip"
Invoke-WebRequest -UseBasicParsing "https://dl.google.com/android/repository/$zip" -OutFile "$env:TEMP\clt.zip"
Expand-Archive "$env:TEMP\clt.zip" -DestinationPath "$env:TEMP\clt" -Force
New-Item -ItemType Directory -Force 'C:\Android\Sdk\cmdline-tools\latest' | Out-Null
Copy-Item "$env:TEMP\clt\cmdline-tools\*" 'C:\Android\Sdk\cmdline-tools\latest' -Recurse -Force
$env:ANDROID_HOME = 'C:\Android\Sdk'
$env:Path = "$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:ANDROID_HOME\platform-tools;$env:Path"
"ANDROID_HOME=C:\Android\Sdk" | Out-File -Append $env:GITHUB_ENV
"ANDROID_SDK_ROOT=C:\Android\Sdk" | Out-File -Append $env:GITHUB_ENV
"C:\Android\Sdk\cmdline-tools\latest\bin" | Out-File -Append $env:GITHUB_PATH
"C:\Android\Sdk\platform-tools" | Out-File -Append $env:GITHUB_PATH
("y`n" * 10) | cmd /c 'android sdk install platform-tools platforms/android-37.0 build-tools/36.0.0 2>&1' | Select-Object -Last 3
if (-not (Test-Path 'C:\Android\Sdk\platforms\android-37.0\android.jar')) { throw 'platform not installed' }
