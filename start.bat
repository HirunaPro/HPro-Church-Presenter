@echo off

REM Change to the directory where this batch file is located
cd /d "%~dp0"

echo ============================================================
echo   Church Presentation App - Starting Server
echo ============================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.7 or later from https://www.python.org
    echo.
    pause
    exit /b 1
)

echo Checking Python dependencies...
echo.

REM Check if websockets module is installed
python -c "import websockets" >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing websockets module...
    pip install websockets
    echo.
)

echo Starting server...
echo.
echo The application will be accessible in your web browser.
echo Look for the URL in the output below.
echo.
echo Press Ctrl+C to stop the server.
echo.
echo ============================================================
echo.

REM Start the server
python server.py

pause
