@echo off
title Royalty Automation Dashboard
color 0B
echo.
echo  ============================================================
echo    Royalty Automation — Telangana Mines EPermit
echo  ============================================================
echo.

:: --- Find Python (skip Microsoft Store fake stub) ---
set PYTHON_EXE=

:: 1. Try python_path.txt written by setup.bat
if exist "%~dp0python_path.txt" (
    set /p PYTHON_EXE=<"%~dp0python_path.txt"
    for /f "tokens=* delims= " %%A in ("%PYTHON_EXE%") do set PYTHON_EXE=%%A
)

:: Skip if it points to the Microsoft Store stub (WindowsApps)
if exist "%PYTHON_EXE%" (
    echo %PYTHON_EXE% | findstr /i "WindowsApps" >nul 2>&1
    if not errorlevel 1 set PYTHON_EXE=
)

:: 2. Try 'where python' but SKIP WindowsApps stub
if not exist "%PYTHON_EXE%" (
    for /f "delims=" %%P in ('where python 2^>nul') do (
        echo %%P | findstr /i "WindowsApps" >nul 2>&1
        if errorlevel 1 (
            set PYTHON_EXE=%%P
            goto :found
        )
    )
)

:: 3. Try the Python Launcher (py.exe) and resolve its path
if not exist "%PYTHON_EXE%" (
    where py >nul 2>&1
    if not errorlevel 1 (
        for /f "delims=" %%P in ('py -c "import sys; print(sys.executable)" 2^>nul') do (
            set PYTHON_EXE=%%P
            goto :found
        )
    )
)

:: 4. Search common real Python install locations on current drive, C drive, and localappdata
if not exist "%PYTHON_EXE%" (
    for %%D in ("%~d0" "C:") do (
        for %%V in (313 312 311 310 39 38) do (
            if exist "%%~D\Python%%V\python.exe" (
                set PYTHON_EXE=%%~D\Python%%V\python.exe
                goto :found
            )
            if exist "%%~D\Programs\Python\Python%%V\python.exe" (
                set PYTHON_EXE=%%~D\Programs\Python\Python%%V\python.exe
                goto :found
            )
            if exist "%LOCALAPPDATA%\Programs\Python\Python%%V\python.exe" (
                set PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python%%V\python.exe
                goto :found
            )
        )
    )
)

:found
:: Final check — nothing found at all
if "%PYTHON_EXE%"=="" (
    echo  ERROR: Python not found on this computer.
    echo.
    echo  Please install Python 3.10+ from https://www.python.org/downloads/
    echo  During install: CHECK "Add Python to PATH"
    echo  Then run  setup.bat  before launching.
    echo.
    pause
    exit /b 1
)

echo  Python : %PYTHON_EXE%
echo  URL    : http://localhost:8501
echo  Press Ctrl+C in this window to stop.
echo.

"%PYTHON_EXE%" -m streamlit run "%~dp0app.py" --server.port 8501 --server.headless false --browser.gatherUsageStats false

if errorlevel 1 (
    echo.
    echo  ERROR launching dashboard. Check error above.
    pause
)
