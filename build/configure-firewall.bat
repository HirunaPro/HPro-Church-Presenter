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
