@echo off
setlocal EnableDelayedExpansion
title XERO - Windows Driver ^& App Toolkit
color 0B
cd /d "%~dp0"

:: ============================================================
::  CONFIG  (change these if you like)
:: ============================================================
set "BOSS=Boss"
set "BACKUP_ROOT=%~dp0XERO_Backup"
set "DRV_DIR=%BACKUP_ROOT%\Drivers"
set "APP_DIR=%BACKUP_ROOT%\Apps"
set "APP_JSON=%APP_DIR%\installed-apps.json"
set "APP_TXT=%APP_DIR%\installed-apps.txt"

:: ============================================================
::  ADMIN CHECK (self-elevate)
:: ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo   [XERO] Administrator access required. Requesting elevation...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ============================================================
::  ESSENTIAL APP LIST  (id = winget package id)
::  To add an app: add a :defapp line and raise APP_COUNT
:: ============================================================
set "APP_COUNT=14"
call :defapp 1  "Notepad++.Notepad++"            "Notepad++"
call :defapp 2  "Microsoft.WindowsTerminal"      "Windows Terminal"
call :defapp 3  "OpenJS.NodeJS"                  "Node.js"
call :defapp 4  "Zen-Team.Zen-Browser.Twilight"  "Zen Browser (Twilight)"
call :defapp 5  "Opera.Opera"                    "Opera"
call :defapp 6  "Brave.Brave"                    "Brave"
call :defapp 7  "Shift.Shift"                    "Shift"
call :defapp 8  "Devolutions.UniGetUI"           "UniGetUI"
call :defapp 9  "7zip.7zip"                      "7-Zip"
call :defapp 10 "Daum.PotPlayer"                 "PotPlayer"
call :defapp 11 "XiaoYouChR.GhostDownloader"     "Ghost Downloader"
call :defapp 12 "Telegram.TelegramDesktop"       "Telegram Desktop"
call :defapp 13 "VideoLAN.VLC"                   "VLC Media Player"
call :defapp 14 "SumatraPDF.SumatraPDF"          "SumatraPDF"

:: ============================================================
::  BOOT SEQUENCE + GREETING
:: ============================================================
set /a H=1%time:~0,2%-100
set "GREET=Good evening"
if %H% LSS 18 set "GREET=Good afternoon"
if %H% LSS 12 set "GREET=Good morning"
if %H% LSS 5  set "GREET=Burning the midnight oil"

cls
call :banner
echo.
echo   [ boot ] Loading core modules ........ OK
timeout /t 1 /nobreak >nul
echo   [ boot ] Scanning system ............. OK
timeout /t 1 /nobreak >nul
echo   [ boot ] Privileges: ADMIN ........... OK
timeout /t 1 /nobreak >nul
echo.
call :say "%GREET%, %BOSS%. XERO is online and awaiting orders."

:: ============================================================
::  MAIN MENU
:: ============================================================
:menu
echo.
call :say "What's the mission, %BOSS%?"
echo.
echo        [1]  Backup my drivers
echo        [2]  Restore my drivers
echo        [3]  Install essential apps
echo        [4]  Export my installed apps list
echo        [5]  Restore apps from an exported list
echo        [0]  Exit
echo.
set "CHOICE="
set /p "CHOICE=   %BOSS% > "
if "%CHOICE%"=="1" goto backup
if "%CHOICE%"=="2" goto restore
if "%CHOICE%"=="3" goto apps
if "%CHOICE%"=="4" goto exportapps
if "%CHOICE%"=="5" goto importapps
if "%CHOICE%"=="0" goto bye
call :say "Command not recognized. Choose 1-5, or 0 to exit."
goto menu

:: ============================================================
::  1. BACKUP DRIVERS
:: ============================================================
:backup
echo.
call :say "Initiating driver backup..."
call :say "Destination: %DRV_DIR%"
if not exist "%DRV_DIR%" mkdir "%DRV_DIR%"
echo.
dism /online /export-driver /destination:"%DRV_DIR%"
set "RC=%errorlevel%"
echo.
if "%RC%"=="0" (
    call :say "Backup complete. Your drivers are secured, %BOSS%."
) else (
    call :say "Something went wrong during the backup. Check the output above."
)
call :back
goto menu

:: ============================================================
::  2. RESTORE DRIVERS
:: ============================================================
:restore
echo.
call :say "Preparing driver restore."
call :say "Default folder: %DRV_DIR%"
set "SRC="
set /p "SRC=   Press Enter for default, or type/drag another folder > "
if not defined SRC set "SRC=%DRV_DIR%"
set "SRC=%SRC:"=%"
if not exist "%SRC%" (
    call :say "I can't find that folder: %SRC%"
    call :back
    goto menu
)
echo.
call :say "Installing drivers from: %SRC%"
echo.
pnputil /add-driver "%SRC%\*.inf" /subdirs /install
set "RC=%errorlevel%"
echo.
if "%RC%"=="0" (
    call :say "Restore complete. A reboot is recommended."
) else (
    call :say "Finished with warnings (some drivers may already be installed). Review the output above."
)
call :back
goto menu

:: ============================================================
::  3. INSTALL ESSENTIAL APPS
:: ============================================================
:apps
echo.
call :needwinget || (call :back & goto menu)
call :say "Install everything in one go, or pick one by one?"
echo.
echo        [1]  Install ALL essential apps
echo        [2]  Let me choose (numbered list)
echo        [0]  Back
echo.
set "AC="
set /p "AC=   %BOSS% > "
if "%AC%"=="1" goto apps_all
if "%AC%"=="2" goto apps_pick
if "%AC%"=="0" goto menu
call :say "Please choose 1, 2 or 0."
goto apps

:apps_all
echo.
call :say "Understood. Installing all %APP_COUNT% apps. Stand by."
set "OK=0" & set "FAIL="
for /l %%N in (1,1,%APP_COUNT%) do call :install %%N
goto apps_done

:apps_pick
echo.
call :say "Available apps:"
echo.
for /l %%N in (1,1,%APP_COUNT%) do (
    set "NAME=!APP_NAME_%%N!"
    set "NUM=  %%N"
    echo        [!NUM:~-2!]  !NAME!
)
echo.
echo        Type numbers separated by spaces or commas (e.g. 1 4 9)
echo        or type A for all, 0 to go back.
echo.
set "SEL="
set /p "SEL=   %BOSS% > "
if not defined SEL goto apps_pick
if "%SEL%"=="0" goto apps
if /i "%SEL%"=="A" goto apps_all
set "SEL=%SEL:,= %"
set "OK=0" & set "FAIL="
echo.
for %%N in (%SEL%) do call :install %%N
goto apps_done

:apps_done
echo.
call :say "Run finished. Succeeded: %OK%"
if defined FAIL call :say "Failed or skipped:%FAIL%"
call :back
goto menu

:: ------------------------------------------------------------
::  :install <number>
:: ------------------------------------------------------------
:install
set "ID="
set "NAME="
call set "ID=%%APP_ID_%~1%%"
call set "NAME=%%APP_NAME_%~1%%"
if not defined ID (
    call :say "'%~1' is not a valid selection. Skipping."
    set "FAIL=!FAIL! %~1"
    exit /b
)
call :say "Installing !NAME!..."
winget install --id=!ID! -e --silent --accept-package-agreements --accept-source-agreements
if !errorlevel! equ 0 (
    set /a OK+=1
    call :say "!NAME! installed."
) else (
    set "FAIL=!FAIL! [!NAME!]"
    call :say "!NAME! failed or was already installed."
)
echo.
exit /b

:: ============================================================
::  4. EXPORT INSTALLED APPS LIST
:: ============================================================
:exportapps
echo.
call :needwinget || (call :back & goto menu)
call :say "Scanning installed applications..."
call :say "Saving to: %APP_DIR%"
if not exist "%APP_DIR%" mkdir "%APP_DIR%"
echo.
winget export -o "%APP_JSON%" --accept-source-agreements
set "RC=%errorlevel%"
echo.
call :say "Creating a human-readable name list..."
winget list --accept-source-agreements > "%APP_TXT%" 2>&1
echo.
if exist "%APP_JSON%" (
    call :say "Export complete."
    call :say "Restore file : installed-apps.json"
    call :say "Readable list: installed-apps.txt"
    call :say "Note: only apps found in winget sources can be restored later."
) else (
    call :say "Export failed. Check the output above."
)
call :back
goto menu

:: ============================================================
::  5. RESTORE APPS FROM EXPORTED LIST
:: ============================================================
:importapps
echo.
call :needwinget || (call :back & goto menu)
call :say "Preparing app restore."
call :say "Default file: %APP_JSON%"
set "SRC="
set /p "SRC=   Press Enter for default, or type/drag a .json file > "
if not defined SRC set "SRC=%APP_JSON%"
set "SRC=%SRC:"=%"
if not exist "%SRC%" (
    call :say "I can't find that file: %SRC%"
    call :back
    goto menu
)
echo.
call :say "Restoring apps. This may take a while, %BOSS%."
echo.
winget import -i "%SRC%" --accept-package-agreements --accept-source-agreements --ignore-unavailable
set "RC=%errorlevel%"
echo.
if "%RC%"=="0" (
    call :say "All apps restored."
) else (
    call :say "Finished with warnings (some apps may be unavailable or already installed)."
)
call :back
goto menu

:: ============================================================
::  HELPERS
:: ============================================================
:defapp
set "APP_ID_%~1=%~2"
set "APP_NAME_%~1=%~3"
exit /b

:needwinget
where winget >nul 2>&1
if %errorlevel% neq 0 (
    call :say "Winget is not available. Install 'App Installer' from the Microsoft Store first."
    exit /b 1
)
exit /b 0

:say
echo   [XERO] %~1
exit /b

:back
echo.
pause
cls
call :banner
exit /b

:banner
echo.
echo.
echo       #   #  #####  ####    ###
echo        # #   #      #   #  #   #
echo         #    ####   ####   #   #
echo        # #   #      #  #   #   #
echo       #   #  #####  #   #   ###
echo.
echo       --------------------------------------
echo        Drivers . Apps . Restore . Zero fuss
echo       --------------------------------------
exit /b

:bye
echo.
call :say "Powering down. Until next time, %BOSS%."
timeout /t 2 /nobreak >nul
endlocal
exit /b
