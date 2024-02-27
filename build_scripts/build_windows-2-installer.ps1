# $env:path should contain a path to editbin.exe and signtool.exe

$ErrorActionPreference = "Stop"

mkdir build_scripts\win_build

git status
git submodule

if (-not (Test-Path env:CORPOCHAIN_INSTALLER_VERSION)) {
  $env:CORPOCHAIN_INSTALLER_VERSION = '0.0.0'
  Write-Output "WARNING: No environment variable CORPOCHAIN_INSTALLER_VERSION set. Using 0.0.0"
}
Write-Output "Corpochain Version is: $env:CORPOCHAIN_INSTALLER_VERSION"
Write-Output "   ---"

Write-Output "   ---"
Write-Output "Use pyinstaller to create corpochain .exe's"
Write-Output "   ---"
$SPEC_FILE = (python -c 'import chia; print(chia.PYINSTALLER_SPEC_PATH)') -join "`n"
pyinstaller --log-level INFO $SPEC_FILE

Write-Output "   ---"
Write-Output "Creating a directory of licenses from pip and npm packages"
Write-Output "   ---"
bash ./build_win_license_dir.sh

Write-Output "   ---"
Write-Output "Copy corpochain executables to corpochain-gui\"
Write-Output "   ---"
Copy-Item "dist\daemon" -Destination "..\corpochain-gui\packages\gui\" -Recurse

Write-Output "   ---"
Write-Output "Setup npm packager"
Write-Output "   ---"
Set-Location -Path ".\npm_windows" -PassThru
npm ci
$Env:Path = $(npm bin) + ";" + $Env:Path

Set-Location -Path "..\..\" -PassThru

Write-Output "   ---"
Write-Output "Prepare Electron packager"
Write-Output "   ---"
$Env:NODE_OPTIONS = "--max-old-space-size=3000"

# Change to the GUI directory
Set-Location -Path "corpochain-gui\packages\gui" -PassThru

Write-Output "   ---"
Write-Output "Increase the stack for corpochain command for (corpochain plots create) chiapos limitations"
# editbin.exe needs to be in the path
editbin.exe /STACK:8000000 daemon\corpochain.exe
Write-Output "   ---"

$packageVersion = "$env:CORPOCHAIN_INSTALLER_VERSION"
$packageName = "Cryptomines-$packageVersion"

Write-Output "packageName is $packageName"

Write-Output "   ---"
Write-Output "fix version in package.json"
choco install jq
cp package.json package.json.orig
jq --arg VER "$env:CORPOCHAIN_INSTALLER_VERSION" '.version=$VER' package.json > temp.json
rm package.json
mv temp.json package.json
Write-Output "   ---"

Write-Output "   ---"
Write-Output "electron-builder create package directory"
electron-builder build --win --x64 --config.productName="Corpochain" --dir
Get-ChildItem dist\win-unpacked\resources
Write-Output "   ---"

If ($env:HAS_SIGNING_SECRET) {
   Write-Output "   ---"
   Write-Output "Sign all EXEs"
   Get-ChildItem ".\dist\win-unpacked" -Recurse | Where-Object { $_.Extension -eq ".exe" } | ForEach-Object {
      $exePath = $_.FullName
      Write-Output "Signing $exePath"
      signtool.exe sign /sha1 $env:SM_CODE_SIGNING_CERT_SHA1_HASH /tr http://timestamp.digicert.com /td SHA256 /fd SHA256 $exePath
      Write-Output "Verify signature"
      signtool.exe verify /v /pa $exePath
  }
}    Else    {
   Write-Output "Skipping verify signatures - no authorization to install certificates"
}

Write-Output "   ---"
Write-Output "electron-builder create installer"
electron-builder build --win --x64 --config.productName="Corpochain" --pd ".\dist\win-unpacked"
Write-Output "   ---"

If ($env:HAS_SIGNING_SECRET) {
   Write-Output "   ---"
   Write-Output "Sign Final Installer App"
   signtool.exe sign /sha1 $env:SM_CODE_SIGNING_CERT_SHA1_HASH /tr http://timestamp.digicert.com /td SHA256 /fd SHA256 .\dist\CryptominesSetup-$packageVersion.exe
   Write-Output "   ---"
   Write-Output "Verify signature"
   Write-Output "   ---"
   signtool.exe verify /v /pa .\dist\CryptominesSetup-$packageVersion.exe
}   Else    {
   Write-Output "Skipping verify signatures - no authorization to install certificates"
}

Write-Output "   ---"
Write-Output "Moving final installers to expected location"
Write-Output "   ---"
Copy-Item ".\dist\win-unpacked" -Destination "$env:GITHUB_WORKSPACE\corpochain-gui\Cryptomines-win32-x64" -Recurse
mkdir "$env:GITHUB_WORKSPACE\corpochain-gui\release-builds\windows-installer" -ea 0
Copy-Item ".\dist\CryptominesSetup-$packageVersion.exe" -Destination "$env:GITHUB_WORKSPACE\corpochain-gui\release-builds\windows-installer"

Write-Output "   ---"
Write-Output "Windows Installer complete"
Write-Output "   ---"
