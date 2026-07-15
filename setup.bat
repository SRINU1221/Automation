@echo off
title Royalty Automation — Setup
color 0A
echo.
echo  ============================================================
echo    Royalty Automation - First Time Setup
echo  ============================================================
echo.

:: --- Find Python (skip Microsoft Store fake stub) ---
set PYTHON_EXE=

:: 1. Try 'where python' but SKIP WindowsApps stub
for /f "delims=" %%P in ('where python 2^>nul') do (
    echo %%P | findstr /i "WindowsApps" >nul 2>&1
    if errorlevel 1 (
        set PYTHON_EXE=%%P
        goto :found_python
    )
)

:: 2. Try the Python Launcher (py.exe) and resolve its path — avoids Store stub entirely
where py >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%P in ('py -c "import sys; print(sys.executable)" 2^>nul') do (
        set PYTHON_EXE=%%P
        goto :found_python
    )
)

:: 3. Search common real Python install locations on current drive, C drive, and localappdata
for %%D in ("%~d0" "C:") do (
    for %%V in (313 312 311 310 39 38) do (
        if exist "%%~D\Python%%V\python.exe" (
            set PYTHON_EXE=%%~D\Python%%V\python.exe
            goto :found_python
        )
        if exist "%%~D\Programs\Python\Python%%V\python.exe" (
            set PYTHON_EXE=%%~D\Programs\Python\Python%%V\python.exe
            goto :found_python
        )
        if exist "%LOCALAPPDATA%\Programs\Python\Python%%V\python.exe" (
            set PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python%%V\python.exe
            goto :found_python
        )
    )
)

echo  ERROR: Python not found!
echo.
echo  Please install Python 3.10 or newer from:
echo  https://www.python.org/downloads/
echo.
echo  IMPORTANT: During installation, CHECK the box:
echo  "Add Python to PATH"
echo.
pause
exit /b 1

:found_python
echo  [OK] Python found at: %PYTHON_EXE%
echo.

:: Install packages
echo  Installing required packages...
if exist "%~dp0requirements.txt" (
    %PYTHON_EXE% -m pip install -r "%~dp0requirements.txt" --upgrade -q
) else (
    %PYTHON_EXE% -m pip install streamlit pandas openpyxl playwright xlsxwriter Pillow psycopg2-binary python-dotenv --upgrade -q
)
if errorlevel 1 (
    echo  ERROR: Package install failed. Check internet connection.
    pause
    exit /b 1
)
echo  [OK] Packages installed.
echo.

:: Install Playwright Chromium browser
echo  Installing Playwright Chromium browser...
%PYTHON_EXE% -m playwright install chromium
if errorlevel 1 (
    echo  ERROR: Playwright browser install failed.
    pause
    exit /b 1
)
echo  [OK] Browser installed.
echo.

:: Save python path for run.bat
echo %PYTHON_EXE% > python_path.txt

echo  ============================================================
echo    Setup Complete!
echo    Now double-click  run.bat  to start the dashboard.
echo  ============================================================
echo.
pause
