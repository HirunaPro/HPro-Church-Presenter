# Church Presentation App - Build Windows Executable
# This script creates a standalone .exe file that doesn't require Python installation

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Church Presentation App - Executable Builder" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

# Check if Python is installed
Write-Host "Checking for Python installation..." -ForegroundColor Yellow
$pythonCheck = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Python from python.org and add it to PATH" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Found: $pythonCheck`n" -ForegroundColor Green

# Install PyInstaller
Write-Host "Installing PyInstaller (this may take a minute)..." -ForegroundColor Yellow
pip install pyinstaller --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install PyInstaller" -ForegroundColor Red
    exit 1
}
Write-Host "✓ PyInstaller installed`n" -ForegroundColor Green

# Create build directory
Write-Host "Creating build directory..." -ForegroundColor Yellow
$buildDir = ".\build-dist"
if (Test-Path $buildDir) {
    Remove-Item $buildDir -Recurse -Force
}
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
Write-Host "✓ Build directory created`n" -ForegroundColor Green

# Build the executable
Write-Host "Building executable (this may take 2-3 minutes)..." -ForegroundColor Yellow
Write-Host "This will create a standalone .exe that runs without Python`n" -ForegroundColor Cyan

# Simple build command - PyInstaller needs to be in PATH
Write-Host "Running PyInstaller..." -ForegroundColor Cyan

# Get parent directory (where app files are)
$parentDir = (Get-Item $PSScriptRoot).Parent.FullName

# Resolve all paths to absolute paths (from parent directory)
$songPath = Join-Path $parentDir "songs"
$cssPath = Join-Path $parentDir "css"
$jsPath = Join-Path $parentDir "js"
$imagesPath = Join-Path $parentDir "images"
$indexPath = Join-Path $parentDir "index.html"
$operatorPath = Join-Path $parentDir "operator.html"
$projectorPath = Join-Path $parentDir "projector.html"
$welcomePath = Join-Path $parentDir "welcome.html"
$serverPath = Join-Path $parentDir "server.py"

# Verify files exist
$files = @(
    @{name="songs"; path=$songPath},
    @{name="css"; path=$cssPath},
    @{name="js"; path=$jsPath},
    @{name="images"; path=$imagesPath},
    @{name="index.html"; path=$indexPath},
    @{name="operator.html"; path=$operatorPath},
    @{name="projector.html"; path=$projectorPath},
    @{name="welcome.html"; path=$welcomePath},
    @{name="server.py"; path=$serverPath}
)

$missingFiles = @()
foreach ($file in $files) {
    if (-not (Test-Path $file.path)) {
        $missingFiles += $file.name
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "ERROR: Missing required files: $($missingFiles -join ', ')" -ForegroundColor Red
    Write-Host "Make sure you're in the project root directory" -ForegroundColor Red
    exit 1
}

# Build using simpler command line with absolute paths
& python -m PyInstaller `
  --onefile `
  --console `
  --name=Church-Presentation-Server `
  --distpath="$buildDir\dist" `
  --workpath="$buildDir\build" `
  --specpath="$buildDir" `
  --add-data="$songPath;songs" `
  --add-data="$cssPath;css" `
  --add-data="$jsPath;js" `
  --add-data="$imagesPath;images" `
  --add-data="$indexPath;." `
  --add-data="$operatorPath;." `
  --add-data="$projectorPath;." `
  --add-data="$welcomePath;." `
  "$serverPath"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to build executable" -ForegroundColor Red
    exit 1
}

Write-Host "`n✓ Build complete!`n" -ForegroundColor Green

# Create the distribution package
Write-Host "Creating distribution package..." -ForegroundColor Yellow

$distDir = ".\ChurchApp-Standalone"
if (Test-Path $distDir) {
    Remove-Item $distDir -Recurse -Force
}
New-Item -ItemType Directory -Path $distDir -Force | Out-Null

# Copy the executable
Copy-Item "$buildDir/dist/Church-Presentation-Server.exe" "$distDir/" -Force
Write-Host "✓ Copied executable" -ForegroundColor Green

# Copy data directories
Copy-Item "$parentDir\songs" "$distDir\songs" -Recurse -Force
Copy-Item "$parentDir\css" "$distDir\css" -Recurse -Force
Copy-Item "$parentDir\js" "$distDir\js" -Recurse -Force
Copy-Item "$parentDir\images" "$distDir\images" -Recurse -Force
Write-Host "✓ Copied data directories" -ForegroundColor Green

# Copy HTML files
Copy-Item "$parentDir\index.html" "$distDir\" -Force
Copy-Item "$parentDir\operator.html" "$distDir\" -Force
Copy-Item "$parentDir\projector.html" "$distDir\" -Force
Copy-Item "$parentDir\welcome.html" "$distDir\" -Force
Write-Host "✓ Copied HTML files" -ForegroundColor Green

# Create launcher batch file
$launcherContent = @"
@echo off
REM Church Presentation App - Standalone Launcher
REM This batch file starts the application

echo.
echo ========================================
echo   Church Presentation Web App
echo ========================================
echo.

REM Get the directory where this script is located
cd /d "%~dp0"

REM Start the server
echo Starting server...
echo.
start "" "Church-Presentation-Server.exe"

REM Wait a moment for server to start
timeout /t 2 /nobreak

REM Open browser
echo Opening browser...
start http://localhost:8000/index.html

echo.
echo ========================================
echo Server started successfully!
echo.
echo The app will open in your default browser.
echo If it doesn't, open http://localhost:8000
echo.
echo Control Panel: http://localhost:8000/operator.html
echo Projector: http://localhost:8000/projector.html
echo.
echo Press Ctrl+C in the server window to stop.
echo ========================================
echo.
pause
"@
Set-Content -Path "$distDir/START.bat" -Value $launcherContent -Encoding ASCII
Write-Host "✓ Created START.bat launcher" -ForegroundColor Green

# Create firewall configuration script
$firewallContent = @"
@echo off
REM Church Presentation App - Firewall Configuration
REM This script adds exceptions to Windows Defender Firewall
REM Must be run as Administrator

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Windows Firewall Configuration
echo ========================================
echo.

REM Check if running as admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo.
    echo Please:
    echo 1. Right-click this batch file
    echo 2. Select "Run as administrator"
    echo.
    pause
    exit /b 1
)

REM Get the full path of the executable
set "EXE_PATH=%~dp0Church-Presentation-Server.exe"

echo Configuring Windows Firewall...
echo Executable: !EXE_PATH!
echo.

REM Check if executable exists
if not exist "!EXE_PATH!" (
    echo ERROR: Church-Presentation-Server.exe not found!
    echo Expected location: !EXE_PATH!
    echo.
    pause
    exit /b 1
)

REM Remove any existing rules for this app (cleanup)
echo Removing existing firewall rules...
netsh advfirewall firewall delete rule name="Church Presentation App - HTTP" >nul 2>&1
netsh advfirewall firewall delete rule name="Church Presentation App - WebSocket" >nul 2>&1

REM Add HTTP rule (port 8000)
echo Adding HTTP rule (port 8000)...
netsh advfirewall firewall add rule name="Church Presentation App - HTTP" ^
  dir=in action=allow program="!EXE_PATH!" enable=yes protocol=tcp localport=8000 ^
  description="Church Presentation App - HTTP Server" >nul 2>&1

if %errorLevel% neq 0 (
    echo WARNING: Failed to add HTTP rule
) else (
    echo ✓ HTTP rule added
)

REM Add WebSocket rule (port 8765)
echo Adding WebSocket rule (port 8765)...
netsh advfirewall firewall add rule name="Church Presentation App - WebSocket" ^
  dir=in action=allow program="!EXE_PATH!" enable=yes protocol=tcp localport=8765 ^
  description="Church Presentation App - WebSocket Server" >nul 2>&1

if %errorLevel% neq 0 (
    echo WARNING: Failed to add WebSocket rule
) else (
    echo ✓ WebSocket rule added
)

echo.
echo ========================================
echo Firewall Configuration Complete!
echo ========================================
echo.
echo Your app can now be accessed from:
echo - Local computer: http://localhost:8000
echo - Network: http://[your-ip]:8000
echo.
echo To find your IP address, open Command Prompt and type:
echo   ipconfig
echo.
pause
"@
Set-Content -Path "$distDir/CONFIGURE-FIREWALL.bat" -Value $firewallContent -Encoding ASCII
Write-Host "✓ Created CONFIGURE-FIREWALL.bat" -ForegroundColor Green

# Create README for distribution
$readmeContent = @"
# Church Presentation App - Standalone Version

## Quick Start

Simply double-click **START.bat** to run the application!

No installation, no Python, no dependencies needed.

## What You Get

- **Church-Presentation-Server.exe** - The complete application
- **START.bat** - Easy launcher script
- **CONFIGURE-FIREWALL.bat** - Firewall setup (for remote access)
- **songs/** - Song database
- **css/, js/, images/** - Application resources
- **HTML files** - Web interfaces

## First Time Use

1. Double-click **START.bat**
2. Wait 2-3 seconds
3. Your browser will open automatically
4. Click "Open Operator Control" to start

## Network Setup (Important for Remote Access)

### Step 1: Allow Firewall Access (Required)

Before other computers can access your app:

1. **Right-click CONFIGURE-FIREWALL.bat**
2. **Select "Run as administrator"**
3. Wait for completion message
4. Done! Firewall is now configured

OR manually:
- Open Windows Defender Firewall
- Click "Allow an app through firewall"
- Add Church-Presentation-Server.exe to allowed apps

### Step 2: Find Your Computer's IP Address

Open Command Prompt and type:
```
ipconfig
```

Look for "IPv4 Address" (e.g., 192.168.1.100)

Share this with others: **http://[your-ip]:8000**

## For Projector Display

On the projector computer:
1. Double-click **START.bat** to start the server
2. On another device, open: http://projector-computer-ip:8000/projector.html
3. Press F11 for full-screen mode

## Adding Songs

1. Open the **songs/** folder
2. Add .json files following the format in existing songs
3. Restart the server and refresh the browser page

## Troubleshooting

**"Windows cannot find Church-Presentation-Server.exe"**
- Make sure all files are in the same folder
- Make sure the .exe file isn't corrupted
- Re-download and try again

**"Port 8000 already in use"**
- Another application is using port 8000
- Close other applications or contact your IT support
- Edit the server to use a different port

**Can't connect from other computers**
- ✓ Did you run CONFIGURE-FIREWALL.bat as admin?
- ✓ Are both computers on the same WiFi network?
- ✓ Are you using the correct IP address?
- ✓ Try pinging from the client: ping [server-ip]

**WebSocket connection fails on remote device**
- Run CONFIGURE-FIREWALL.bat again as administrator
- Verify port 8765 is allowed (WebSocket port)
- Check firewall logs for blocked connections

## Need More Help?

See the original README.md for detailed information about:
- Song format and adding songs
- Operator controls
- Customization options
- Full documentation

---

Version 1.0 - Created $(Get-Date -Format "MMMM yyyy")
"@
Set-Content -Path "$distDir/README.txt" -Value $readmeContent -Encoding ASCII
Write-Host "✓ Created README.txt" -ForegroundColor Green

# Create a config file template
$configContent = @"
{
  "churchName": "Your Church Name",
  "httpPort": 8000,
  "websocketPort": 8765,
  "logoPath": "images/church-logo.png"
}
"@
Set-Content -Path "$distDir/config.json" -Value $configContent
Write-Host "✓ Created config.json template" -ForegroundColor Green

Write-Host "`n================================================" -ForegroundColor Green
Write-Host "  Package Creation Complete! ✓" -ForegroundColor Green
Write-Host "================================================`n" -ForegroundColor Green

Write-Host "Location: .\ChurchApp-Standalone\`n" -ForegroundColor Cyan

Write-Host "NEXT STEPS:`n" -ForegroundColor Yellow
Write-Host "1. Open the 'ChurchApp-Standalone' folder" -ForegroundColor White
Write-Host "2. Double-click START.bat to test the app" -ForegroundColor White
Write-Host "3. Once verified, zip this folder for distribution" -ForegroundColor White
Write-Host "4. Share the ZIP file with other PCs on your network`n" -ForegroundColor White

Write-Host "TO DISTRIBUTE:`n" -ForegroundColor Yellow
Write-Host "1. Right-click 'ChurchApp-Standalone' folder" -ForegroundColor White
Write-Host "2. Select 'Send to' > 'Compressed (zipped) folder'" -ForegroundColor White
Write-Host "3. Share the .ZIP file via USB, email, or network drive" -ForegroundColor White
Write-Host "4. Recipients just extract and double-click START.bat`n" -ForegroundColor White

Write-Host "File sizes:" -ForegroundColor Cyan
Get-ChildItem "$distDir" -Recurse | Measure-Object -Property Length -Sum | ForEach-Object {
    $sizeMB = [math]::Round($_.Sum / 1MB, 2)
    Write-Host "Total: $sizeMB MB" -ForegroundColor Green
}

Write-Host "`n"
