@echo off
REM Church Presentation App - Setup and Configuration
REM Run this once to prepare your system

setlocal enabledelayedexpansion

cls
echo.
echo ========================================
echo   Church Presentation App - Setup
echo ========================================
echo.

REM Check if running as admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: This script should be run as Administrator
    echo for firewall configuration.
    echo.
    echo Press any key to continue anyway, or close this window.
    pause >nul
)

REM Get local IP
echo Detecting your network IP address...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4 Address"') do (
    set "IP=%%a"
    set "IP=!IP:~1!"
)

cls
echo.
echo ========================================
echo   Church Presentation App - Setup
echo ========================================
echo.
echo Your IP Address: !IP!
echo.
echo This address is needed for other computers
echo to access your presentation app.
echo.
echo Share this with others on your network:
echo   http://!IP!:8000
echo.
echo ========================================
echo.

REM Create a desktop shortcut
echo Creating desktop shortcut...
set "SHORTCUT=%USERPROFILE%\Desktop\Church Presentation App.lnk"
set "TARGET=%CD%\START.bat"

if exist "!SHORTCUT!" (
    echo Shortcut already exists.
) else (
    REM Use VBS to create shortcut
    (
        echo Set oWS = WScript.CreateObject("WScript.Shell"^)
        echo sLinkFile = "!SHORTCUT!"
        echo Set oLink = oWS.CreateShortcut(sLinkFile^)
        echo oLink.TargetPath = "!TARGET!"
        echo oLink.WorkingDirectory = "%CD%"
        echo oLink.Description = "Church Presentation App"
        echo oLink.Save
    ) > "!TEMP!\create-shortcut.vbs"
    
    cscript "!TEMP!\create-shortcut.vbs"
    del "!TEMP!\create-shortcut.vbs"
    echo ✓ Desktop shortcut created
)

echo.
echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo Next steps:
echo.
echo 1. Double-click START.bat to run the app
echo 2. Share your IP (above) with other computers
echo 3. They can access: http://!IP!:8000
echo.
echo 4. To allow firewall access:
echo    - Open Windows Defender Firewall
echo    - Click "Allow an app through firewall"
echo    - Add Church-Presentation-Server.exe
echo.
echo ========================================
echo.
pause
