@echo off
chcp 65001 >nul
title Install Hermes Wake Service

echo ============================================
echo   Install Hermes Auto-Wake Monitor
echo ============================================
echo.

REM 1. Set 15-min sleep
echo [1/3] Setting 15-min auto sleep...
powercfg /change standby-timeout-ac 15
powercfg /change hibernate-timeout-ac 0
powercfg /change wake-timer-ac 1
echo    OK

REM 2. Create scheduled task (wakes every 2 min)
echo [2/3] Creating wake-up task (every 2 minutes)...

powershell -Command "$action = New-ScheduledTaskAction -Execute '%~dp0hermes_wake_check.bat'; $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 2) -RepetitionDuration ([TimeSpan]::MaxValue); $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -WakeToRun -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 1); $task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings; Register-ScheduledTask 'HermesWakeCheck' -InputObject $task -Force; Write-Output 'OK'"

echo.

REM 3. Firewall
echo [3/3] Configuring firewall...
netsh advfirewall firewall add rule name="WOL-UDP-9" protocol=udp localport=9 dir=in action=allow >nul 2>&1
echo    OK

echo.
echo ============================================
echo   Done!
echo.
echo   How it works:
echo   - PC auto-sleeps after 15 min idle
echo   - Wakes up every 2 minutes to check Feishu
echo   - If message arrived - keeps PC awake, Hermes replies
echo   - If no message - goes back to sleep
echo.
echo   Just chat normally, no extra steps needed.
echo ============================================
pause
