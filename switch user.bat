@echo off
title Manual User Switcher
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
REM  2. MAIN MENU
REM ====================================================
:MAIN_MENU
cls
echo.
echo ==============================================
echo              MAIN MENU
echo ==============================================
echo.
echo 1 - Set boot user and SHUT DOWN PC
echo 2 - Switch user immediately (LOG OFF)
echo.
set /p main_choice=Enter choice (1-2): 

if "%main_choice%"=="1" (
    call :SELECT_USER
    call :APPLY_REGISTRY
    echo.
    echo Shutting down PC in 5 seconds...
    timeout /t 5 >nul
    shutdown /s /f /t 0
    exit /B
)
if "%main_choice%"=="2" (
    call :SELECT_USER
    call :APPLY_REGISTRY
    echo.
    echo Switching user in 3 seconds...
    timeout /t 3 >nul
    shutdown /l /f
    exit /B
)

echo.
echo Invalid choice! Please select 1 or 2.
timeout /t 2 >nul
goto MAIN_MENU

REM ====================================================
REM  3. SELECT USER ROUTINE
REM ====================================================
:SELECT_USER
cls
echo.
echo ==============================================
echo    SELECT USER TO CONFIGURE
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

if "%username%"=="" (
    echo.
    echo Invalid selection! Please try again.
    timeout /t 2 >nul
    goto SELECT_USER
)
goto :EOF

REM ====================================================
REM  4. APPLY REGISTRY ROUTINE
REM ====================================================
:APPLY_REGISTRY
echo.
echo Configuring AutoLogon for user: %username%...

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d "%username%" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d "Radhe" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultDomainName /t REG_SZ /d "%COMPUTERNAME%" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v ForceAutoLogon /t REG_SZ /d 1 /f
goto :EOF