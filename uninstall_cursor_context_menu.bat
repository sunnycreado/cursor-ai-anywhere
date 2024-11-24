@echo off
setlocal EnableDelayedExpansion

:: Script Information
set "SCRIPT_NAME=Cursor AI Context Menu Uninstaller"
set "SCRIPT_VERSION=1.0.0"
set "LOG_FILE=%TEMP%\cursor_menu_uninstall.log"

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
echo [%DATE% %TIME%] Uninstallation started >> "%LOG_FILE%"

echo [*] Removing Cursor AI context menu entries...

:: Create backup before removal
echo [*] Creating final backup before removal...
reg export "HKEY_CLASSES_ROOT\Directory\shell\CursorAI" "%TEMP%\cursor_menu_final_backup.reg" /y >nul 2>&1

:: Remove registry entries
reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\CursorAI" /f >nul 2>&1
if !errorlevel! equ 0 (
    echo [+] Removed background context menu entry
) else (
    echo [!] Background context menu entry not found
)

reg delete "HKEY_CLASSES_ROOT\Directory\shell\CursorAI" /f >nul 2>&1
if !errorlevel! equ 0 (
    echo [+] Removed directory context menu entry
) else (
    echo [!] Directory context menu entry not found
)

echo.
echo [SUCCESS] Uninstallation completed successfully!
echo [%DATE% %TIME%] Uninstallation completed successfully >> "%LOG_FILE%"
echo The "Open with Cursor AI" option has been removed from right-click menus
pause
exit /b 0