# Build a native bundle on Windows.
# Output: dist\windows-<arch>\church-presenter\ and dist\church-presenter-windows-<arch>.zip
$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $Root

$Arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'x64' }
$Target = "windows-$Arch"

$Venv = if ($env:VENV_DIR) { $env:VENV_DIR } else { Join-Path $Root '.venv-build' }
$Py = if ($env:PYTHON) { $env:PYTHON } else { 'python' }
& $Py -m venv $Venv
$VPy = Join-Path $Venv 'Scripts\python.exe'
& $VPy -m pip install --upgrade pip
& $VPy -m pip install -r requirements-build.txt
if ($LASTEXITCODE -ne 0) { throw 'pip install failed' }

Remove-Item -Recurse -Force "dist\$Target", "build\native\$Target" -ErrorAction SilentlyContinue
& $VPy -m PyInstaller --noconfirm --clean --distpath "dist\$Target" --workpath "build\native\$Target" deployment\native\church-presenter.spec
if ($LASTEXITCODE -ne 0) { throw 'PyInstaller failed' }

$Zip = "dist\church-presenter-$Target.zip"
Remove-Item -Force $Zip -ErrorAction SilentlyContinue
Compress-Archive -Path "dist\$Target\church-presenter" -DestinationPath $Zip
Write-Host "Built dist\$Target\church-presenter and $Zip"
