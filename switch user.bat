@echo off
title Manual User Switcher (No Restart)
cls

REM ====================================================
REM  1. AUTO-ADMIN CHECK (Required for Registry)
REM ====================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
)
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"

REM ====================================================
REM  2. USER SELECTION MENU
REM ====================================================
:MENU
cls
echo.
echo ==============================================
echo    SELECT USER TO SWITCH TO (NO RESTART)
echo ==============================================
echo.
echo 1  - radhamay_ratanA       9  - radhamay_ratanI
echo 2  - radhamay_ratanB       10 - radhamay_ratanJ
echo 3  - radhamay_ratanC       11 - radhamay_ratanK
echo 4  - radhamay_ratanD       12 - radhamay_ratanL
echo 5  - radhamay_ratanE       13 - radhamay_ratanM
echo 6  - radhamay_ratanF       14 - radhamay_ratanN
echo 7  - radhamay_ratanG       15 - radhamay_ratanO
echo 8  - radhamay_ratanH
echo.

set /p id=Enter number (1-15): 

set username=
if "%id%"=="1" set username=radhamay_ratanA
if "%id%"=="2" set username=radhamay_ratanB
if "%id%"=="3" set username=radhamay_ratanC
if "%id%"=="4" set username=radhamay_ratanD
if "%id%"=="5" set username=radhamay_ratanE
if "%id%"=="6" set username=radhamay_ratanF
if "%id%"=="7" set username=radhamay_ratanG
if "%id%"=="8" set username=radhamay_ratanH
if "%id%"=="9" set username=radhamay_ratanI
if "%id%"=="10" set username=radhamay_ratanJ
if "%id%"=="11" set username=radhamay_ratanK
if "%id%"=="12" set username=radhamay_ratanL
if "%id%"=="13" set username=radhamay_ratanM
if "%id%"=="14" set username=radhamay_ratanN
if "%id%"=="15" set username=radhamay_ratanO

REM Check if input was valid
if "%username%"=="" (
    echo.
    echo Invalid selection! Please try again.
    timeout /t 2 >nul
    goto MENU
)

REM ====================================================
REM  3. CONFIGURE REGISTRY FOR AUTO LOGIN
REM ====================================================
echo.
echo Configuring AutoLogon for user: %username%...

REM Set the Username
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d "%username%" /f

REM Set the Password
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d "Radhe" /f

REM Set Computer Name as Domain (Fixes login errors)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultDomainName /t REG_SZ /d "%COMPUTERNAME%" /f

REM Enable Auto Logon
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f

REM Force Auto Logon (Crucial for Logoff vs Restart)
REM This ensures it doesn't get stuck on the Lock Screen
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v ForceAutoLogon /t REG_SZ /d 1 /f

REM ====================================================
REM  4. LOG OFF (NO RESTART)
REM ====================================================
echo.
echo Switching user in 3 seconds...
timeout /t 3 >nul

REM /l = Logoff, /f = Force close applications
shutdown /l /f