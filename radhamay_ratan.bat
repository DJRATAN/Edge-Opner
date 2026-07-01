@echo off
setlocal enabledelayedexpansion
title Edge Profile Automation

:: ==========================================
:: TELEGRAM NOTIFICATION CONFIGURATION
:: ==========================================
:: Set your Telegram Bot Token and Chat ID here:
set "TELEGRAM_BOT_TOKEN=8698364241:AAFJd7wEl0IfbvsjUMRUz6ahkfFf8f1heAk"
set "TELEGRAM_CHAT_ID=5194021518"
:: ==========================================

:: ==========================================
:: AUTOMATION WORKFLOW CONFIGURATION
:: ==========================================
:: Define the last user in the sequence (e.g., radhamay_ratanF, radhamay_ratanI, or radhamay_ratanO)
:: When this user completes all profiles, the PC will shut down.
set "LAST_USER=radhamay_ratanO"
:: ==========================================

:: Check for Admin rights and self-elevate if needed
net session >nul 2>&1
if "!errorlevel!" NEQ "0" (
    echo Elevating privileges to Administrator...
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "ELEVATED", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /b
)
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )

echo [%TIME%] Script started as Admin > C:\debug_log.txt
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )

:: Note: On Windows 10 Lite, automatic shortcut creation often fails.
:: If you want the script to run on startup, manually place a shortcut 
:: of this batch file into: %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup

:: Get the actual logged-in Windows username (even if running elevated)
set "CURRENT_USER=%USERNAME%"
echo [%TIME%] USERNAME env var is: %USERNAME% >> C:\debug_log.txt
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-WmiObject -Class Win32_ComputerSystem).UserName.Split('\')[1]" 2^>nul') do (
    set "temp_user=%%A"
    set "temp_user=!temp_user: =!"
    set "CURRENT_USER=!temp_user!"
)
echo [%TIME%] Detected CURRENT_USER: !CURRENT_USER! >> C:\debug_log.txt

:: Retrieve local and public IP addresses
set "LOCAL_IP=Unknown"
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "ipv4"') do (
    if "!LOCAL_IP!"=="Unknown" (
        set "temp_ip=%%A"
        set "temp_ip=!temp_ip: =!"
        set "LOCAL_IP=!temp_ip!"
    )
)
set "PUBLIC_IP=Unknown"
for /f "delims=" %%A in ('curl -s --max-time 3 https://api.ipify.org 2^>nul') do set "PUBLIC_IP=%%A"

:: Retrieve MAC (Physical) Address
set "MAC_ADDRESS=Unknown"
for /f "tokens=1,2 delims=," %%A in ('getmac /fo csv /nh 2^>nul') do (
    set "transport=%%~B"
    if not "!transport!"=="Media disconnected" (
        if "!MAC_ADDRESS!"=="Unknown" set "MAC_ADDRESS=%%~A"
    )
)
if "!MAC_ADDRESS!"=="Unknown" (
    for /f "tokens=1 delims=," %%A in ('getmac /fo csv /nh 2^>nul') do (
        if "!MAC_ADDRESS!"=="Unknown" set "MAC_ADDRESS=%%~A"
    )
)
:: Retrieve AnyDesk ID
set "ANYDESK_ID=Unknown"
if exist "%ProgramData%\AnyDesk\system.conf" (
    for /f "tokens=2 delims==" %%A in ('findstr /i "ad.anydesk.id" "%ProgramData%\AnyDesk\system.conf"') do (
        set "ANYDESK_ID=%%A"
        set "ANYDESK_ID=!ANYDESK_ID: =!"
    )
)
if "!ANYDESK_ID!"=="Unknown" if exist "C:\Users\!CURRENT_USER!\AppData\Roaming\AnyDesk\system.conf" (
    for /f "tokens=2 delims==" %%A in ('findstr /i "ad.anydesk.id" "C:\Users\!CURRENT_USER!\AppData\Roaming\AnyDesk\system.conf"') do (
        set "ANYDESK_ID=%%A"
        set "ANYDESK_ID=!ANYDESK_ID: =!"
    )
)



:: Define the users array (radhamay_ratanA to radhamay_ratanO)
set ucount=0
for %%U in (radhamay_ratanA radhamay_ratanB radhamay_ratanC radhamay_ratanD radhamay_ratanE radhamay_ratanF radhamay_ratanG radhamay_ratanH radhamay_ratanI radhamay_ratanJ radhamay_ratanK radhamay_ratanL radhamay_ratanM radhamay_ratanN radhamay_ratanO) do (
    set /a ucount+=1
    set "user_list[!ucount!]=%%U"
)
set TOTAL_USERS=%ucount%

:: Build the profiles array
set pcount=0
for %%P in ("Default" "Profile 1" "Profile 2" "Profile 3" "Profile 4" "Profile 5" "Profile 6" "Profile 7" "Profile 8" "Profile 9" "Profile 10" "Profile 11" "Profile 12" "Profile 13" "Profile 14" "Profile 15" "Profile 16" "Profile 17" "Profile 18" "Profile 19") do (
    set /a pcount+=1
    set "prof[!pcount!]=%%~P"
)
set TOTAL_PROFILES=%pcount%

:: Find index of CURRENT_USER
set user_idx=0
for /L %%U in (1,1,%TOTAL_USERS%) do (
    if /I "!user_list[%%U]!"=="!CURRENT_USER!" set user_idx=%%U
)

if "!user_idx!"=="0" (
    echo [%TIME%] ERROR: Unrecognized User. Halting. >> C:\debug_log.txt
    echo ==============================================================
    echo [ERROR] Unrecognized User
    echo.
    echo Current Windows user '!CURRENT_USER!' is not in the list 
    echo of radhamay_ratanA to O. 
    echo The script cannot determine who the next user should be.
    echo ==============================================================
    pause
    exit /b
)

echo [%TIME%] Found user index: !user_idx! >> C:\debug_log.txt

:: Check if this user has already completed everything today
echo [%TIME%] Checking completion log for !CURRENT_USER!... >> C:\debug_log.txt
if exist "C:\user_completion_log.txt" (
    findstr /I /C:"!CURRENT_USER! completed all profiles at !date!" "C:\user_completion_log.txt" >nul
    if "!errorlevel!"=="0" (
        goto WAIT_SKIP
    )
)
goto START_PROFILES

:WAIT_SKIP
set "wait_time=300"
:WAIT_LOOP
cls
echo ========================================================
echo !CURRENT_USER! has already completed all profiles today - !date!
echo ========================================================
echo.
echo Will automatically switch to the next user in !wait_time! seconds...
echo.
echo Press [S] to Switch now
echo Press [C] to Cancel (close script)
choice /c SCX /n /t 1 /d X >nul
if "!errorlevel!"=="2" (
    echo.
    echo Canceling auto-switch. Exiting script...
    exit /b
)
if "!errorlevel!"=="1" (
    echo.
    echo Skipping to next user...
    goto DETERMINE_NEXT_USER
)
set /a wait_time-=1
if !wait_time! GTR 0 goto WAIT_LOOP

echo.
echo Skipping to next user...
goto DETERMINE_NEXT_USER

:START_PROFILES
echo [%TIME%] Starting profile loop for !CURRENT_USER! >> C:\debug_log.txt

:: Define this user's data file (e.g., C:\radhamay_ratanC_complete.txt)
set "DATA_FILE=C:\!CURRENT_USER!_complete.txt"
if not exist "!DATA_FILE!" type nul > "!DATA_FILE!"

set "COMPLETED_LIST=None"
for /f "usebackq delims=" %%A in ("!DATA_FILE!") do (
    if "!COMPLETED_LIST!"=="None" (
        set "COMPLETED_LIST=%%A"
    ) else (
        set "COMPLETED_LIST=!COMPLETED_LIST!, %%A"
    )
)

:: Ensure Edge is fully closed before we start the user
taskkill /F /IM msedge.exe >nul 2>&1
ping 127.0.0.1 -n 3 > nul

:: Loop through all 20 profiles
for /L %%N in (1,1,%TOTAL_PROFILES%) do (
    set "CURRENT_PROFILE=!prof[%%N]!"
    
    :: Check if this profile is already in the completed data file
    findstr /X /I /C:"!CURRENT_PROFILE!" "!DATA_FILE!" >nul
    if "!errorlevel!"=="0" (
        echo Skipping !CURRENT_PROFILE! for User !CURRENT_USER! - already completed!
        ping 127.0.0.1 -n 2 > nul
    ) else (
        :: Dynamically build the remaining list, ignoring ones already completed
        set "REMAINING_LIST="
        set /a next=%%N+1
        for /L %%M in (!next!,1,%TOTAL_PROFILES%) do (
            set "CHECK_PROF=!prof[%%M]!"
            findstr /X /I /C:"!CHECK_PROF!" "!DATA_FILE!" >nul
            if "!errorlevel!"=="1" (
                if "!REMAINING_LIST!"=="" (
                    set "REMAINING_LIST=!CHECK_PROF!"
                ) else (
                    set "REMAINING_LIST=!REMAINING_LIST!, !CHECK_PROF!"
                )
            )
        )
        if "!REMAINING_LIST!"=="" set "REMAINING_LIST=None"
        
        call :process_profile "!CURRENT_PROFILE!" "!CURRENT_USER!"
        
        :: Save to file so we skip it next time
        >>"!DATA_FILE!" echo !CURRENT_PROFILE!
        
        :: Add to completed list for the dashboard
        if "!COMPLETED_LIST!"=="None" (
            set "COMPLETED_LIST=!CURRENT_PROFILE!"
        ) else (
            set "COMPLETED_LIST=!COMPLETED_LIST!, !CURRENT_PROFILE!"
        )
    )
)

:: ALL PROFILES COMPLETED FOR THIS USER
echo !CURRENT_USER! completed all profiles at !date! !time! >> C:\user_completion_log.txt
del "!DATA_FILE!" >nul 2>&1

:DETERMINE_NEXT_USER
:: Determine next user
if /I "!CURRENT_USER!"=="!LAST_USER!" (
    set next_idx=1
    set is_last_user=1
) else (
    set /a next_idx=user_idx+1
    if !next_idx! GTR %TOTAL_USERS% (
        set next_idx=1
        set is_last_user=1
    ) else (
        set is_last_user=0
    )
)
set "NEXT_USER=!user_list[%next_idx%]!"

cls
echo ========================================================
echo                 Radhe Radhe
echo ========================================================
echo All profiles complete for !CURRENT_USER!.
echo Configuring Windows to auto-login to: !NEXT_USER!
echo ========================================================

:: Configure AutoAdminLogon
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v ForceAutoLogon /t REG_SZ /d 1 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d "!NEXT_USER!" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d "Radhe" /f >nul

if "!is_last_user!"=="1" (
    echo.
    echo Last user ^(!LAST_USER!^) completed!
    echo.
    
    :: Send Telegram Notification
    if not "%TELEGRAM_BOT_TOKEN%"=="YOUR_BOT_TOKEN_HERE" if not "%TELEGRAM_BOT_TOKEN%"=="" (
        if not "%TELEGRAM_CHAT_ID%"=="YOUR_CHAT_ID_HERE" if not "%TELEGRAM_CHAT_ID%"=="" (
            echo Sending Telegram notification...
            set "MSG=------ Radhe Radhe ------%%0AAll users (A to !LAST_USER:~-1!) have successfully completed today's data run. The PC is shutting down now.%%0A%%0AIP Address: Local: !LOCAL_IP! | Public: !PUBLIC_IP!%%0AAnyDesk IP: !ANYDESK_ID!%%0AMAC (Physical): !MAC_ADDRESS!%%0A%%0ADate: !date!%%0ATime: !time!"
            curl -s -X POST "https://api.telegram.org/bot%TELEGRAM_BOT_TOKEN%/sendMessage" -d "chat_id=%TELEGRAM_CHAT_ID%" -d "text=!MSG!" >nul 2>&1
            
            :: Send completion log file
            if exist "C:\user_completion_log.txt" (
                echo Sending completion log file...
                curl -s -X POST "https://api.telegram.org/bot%TELEGRAM_BOT_TOKEN%/sendDocument" -F "chat_id=%TELEGRAM_CHAT_ID%" -F "document=@C:\user_completion_log.txt" >nul 2>&1
            )
        )
    )
    
    echo PC will now SHUT DOWN.
    echo Next time you turn it on, it will automatically log into radhamay_ratanA.
    echo.
    echo Shutting down in 5 seconds...
    ping 127.0.0.1 -n 6 > nul
    shutdown /s /t 0
) else (
    echo.
    echo Logging out to switch to !NEXT_USER!...
    echo.
    echo Please wait...
    ping 127.0.0.1 -n 6 > nul
    shutdown /l
)

exit /b

:: ---------------------------------
:process_profile
set "profile=%~1"
set "user=%~2"

:: Start Edge with the profile
start "" msedge.exe --profile-directory="!profile!"

:: Wait 3 seconds to let it fully launch before we start checking
ping 127.0.0.1 -n 4 > nul

set closed_manually=0

:: Loop for up to 200 seconds (200 checks)
for /L %%I in (1,1,200) do (
    if "!closed_manually!"=="0" (
        :: Use tasklist with verbose mode to check if Edge has an active VISIBLE window.
        :: This works even on Win10 Lite where PowerShell might be removed.
        :: We exclude lines with "N/A" and "OleMainThreadWndName" which are background processes.
        tasklist /v /FI "IMAGENAME eq msedge.exe" 2>nul | find /I "msedge.exe" | findstr /V /I "N/A OleMainThreadWndName" >nul
        if "!errorlevel!"=="1" (
            set closed_manually=1
        )
        
        if "!closed_manually!"=="0" (
            :: Refresh dashboard
            cls
            echo ==============================================
            echo                 Radhe Radhe
            echo ==============================================
            echo Edge Profile Automation Dashboard
            echo ==============================================
            echo Current User:  !user!
            echo IP Address:    Local: !LOCAL_IP! ^| Public: !PUBLIC_IP!
            echo AnyDesk IP:    !ANYDESK_ID!
            echo MAC Address:   !MAC_ADDRESS!
            echo Running:       !profile!
            echo.
            echo Completed:     !COMPLETED_LIST!
            echo.
            echo Remaining:     !REMAINING_LIST!
            echo ==============================================
            echo Timer:         %%I / 200 seconds
            echo.
            echo (If you manually close Edge, the script will
            echo  detect it and move to the next profile.)
            echo ==============================================
            
            :: 1-second delay so the timer isn't too fast
            ping 127.0.0.1 -n 2 > nul
        )
    )
)

if "!closed_manually!"=="1" (
    echo.
    echo [!] Detected that Edge was manually closed!
) else (
    echo.
    echo [!] 200 seconds reached. Automatically closing Edge for !profile!...
    taskkill /F /IM msedge.exe >nul 2>&1
)

echo.
echo Waiting 5 seconds before moving to the next profile...
ping 127.0.0.1 -n 6 > nul
exit /b
