@echo off
chcp 65001 >nul
title Hermes Wake Monitor

echo [%date% %time%] PC woke up, checking Hermes...

REM Check if Hermes gateway is running
wsl -d Ubuntu -- bash -c "ps aux | grep -v grep | grep -q 'hermes.*gateway' && echo running || echo stopped" 2>nul > %TEMP%\hstat.txt
set /p HSTAT=<%TEMP%\hstat.txt

if "%HSTAT%"=="stopped" (
    echo [%date% %time%] Starting Hermes gateway...
    wsl -d Ubuntu -- bash -ic "cd ~/.hermes/hermes-agent && source .venv/bin/activate && hermes gateway 2>&1 &" >nul 2>&1
    timeout /t 15 /nobreak >nul
) else (
    timeout /t 10 /nobreak >nul
)

REM Check if there's recent activity
wsl -d Ubuntu -- bash -ic "tail -3 ~/.hermes/logs/gateway.log 2>/dev/null | grep -q 'inbound message\|response ready' && echo active || echo idle" 2>nul > %TEMP%\hactive.txt
set /p HACTIVE=<%TEMP%\hactive.txt

if "%HACTIVE%"=="active" (
    echo [%date% %time%] Activity detected - keeping PC awake
    powercfg /change standby-timeout-ac 15
) else (
    echo [%date% %time%] No activity - going back to sleep
    powercfg /change standby-timeout-ac 1
)

exit /b 0
