@echo off
setlocal EnableDelayedExpansion

:: Script Information
set "SCRIPT_NAME=Cursor AI Context Menu Installer"
set "SCRIPT_VERSION=1.0.0"
set "CURSOR_PATH=%LOCALAPPDATA%\Programs\Cursor\Cursor.exe"
set "LOG_FILE=%TEMP%\cursor_menu_install.log"

:: Header
echo ================================================
echo %SCRIPT_NAME% v%SCRIPT_VERSION%
echo ================================================
echo.

:: Check for admin privileges and re-launch if needed
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [*] Requesting administrative privileges...
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
)

:: Log start time
echo [%DATE% %TIME%] Installation started >> "%LOG_FILE%"

:: Check if Cursor AI exists
if not exist "%CURSOR_PATH%" (
    echo [ERROR] Cursor AI not found at: %CURSOR_PATH%
    echo [ERROR] Please make sure Cursor AI is installed correctly
    echo [%DATE% %TIME%] Installation failed - Cursor AI not found >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo [*] Installing Cursor AI context menu entries...

:: Backup existing registry entries (if any)
echo [*] Creating registry backup...
reg export "HKEY_CLASSES_ROOT\Directory\shell\CursorAI" "%TEMP%\cursor_menu_backup.reg" /y >nul 2>&1

:: Add registry entries with error handling
echo [*] Adding registry entries...

:: Background context menu (when right-clicking in folder)
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\CursorAI" /v "Icon" /t REG_SZ /d "\"%CURSOR_PATH%\"" /f >nul 2>&1
if errorlevel 1 goto :ERROR
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\CursorAI" /ve /t REG_SZ /d "Open with Cursor AI" /f >nul 2>&1
if errorlevel 1 goto :ERROR
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\CursorAI\command" /ve /t REG_SZ /d "\"%CURSOR_PATH%\" \"%%V\"" /f >nul 2>&1
if errorlevel 1 goto :ERROR

:: Directory context menu (when right-clicking on folder)
reg add "HKEY_CLASSES_ROOT\Directory\shell\CursorAI" /v "Icon" /t REG_SZ /d "\"%CURSOR_PATH%\"" /f >nul 2>&1
if errorlevel 1 goto :ERROR
reg add "HKEY_CLASSES_ROOT\Directory\shell\CursorAI" /ve /t REG_SZ /d "Open with Cursor AI" /f >nul 2>&1
if errorlevel 1 goto :ERROR
reg add "HKEY_CLASSES_ROOT\Directory\shell\CursorAI\command" /ve /t REG_SZ /d "\"%CURSOR_PATH%\" \"%%1\"" /f >nul 2>&1
if errorlevel 1 goto :ERROR

echo [SUCCESS] Installation completed successfully!
echo [%DATE% %TIME%] Installation completed successfully >> "%LOG_FILE%"
echo.
echo You can now right-click on folders to open them with Cursor AI
pause
exit /b 0

:ERROR
echo [ERROR] Failed to add registry entries
echo [%DATE% %TIME%] Installation failed - Registry error >> "%LOG_FILE%"
pause
exit /b 1