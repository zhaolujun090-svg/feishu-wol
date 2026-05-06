@echo off
chcp 65001 >nul
title Install Hermes Wake Service

REM Check admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Right-click and select "Run as Administrator"
    pause
    exit /b 1
)

echo ============================================
echo   Install Hermes Auto-Wake Monitor
echo ============================================
echo.

echo [1/3] Setting sleep and power options...
REM Try both S3 and Modern Standby settings
powercfg /change standby-timeout-ac 15 >nul 2>&1
powercfg /change sleep-timeout-ac 15 >nul 2>&1
powercfg /change hibernate-timeout-ac 0 >nul 2>&1
powercfg /change monitor-timeout-ac 10 >nul 2>&1
powercfg /change wake-timer-ac 1 >nul 2>&1
powercfg /h off >nul 2>&1
echo    OK

echo [2/3] Creating wake-up task (every 2 min)...
powershell -Command ^
  "unregister-scheduledtask -taskname 'HermesWakeCheck' -confirm:$false 2>$null;" ^
  "$action = New-ScheduledTaskAction -Execute '%~dp0hermes_wake_check.bat';" ^
  "$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval ([TimeSpan]'00:02:00') -RepetitionDuration ([TimeSpan]'365.00:00:00');" ^
  "$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -WakeToRun -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]'00:01:00');" ^
  "$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings;" ^
  "Register-ScheduledTask 'HermesWakeCheck' -InputObject $task -Force | out-null;" ^
  "Write-Output 'OK'"

echo [3/3] Configuring firewall...
netsh advfirewall firewall add rule name="WOL-UDP-9" protocol=udp localport=9 dir=in action=allow >nul 2>&1
echo    OK

echo.
echo ============================================
echo   Done!
echo.
echo   - PC sleeps after 15 min idle
echo   - Wakes every 2 min to check Feishu
echo   - Message found = stays awake
echo   - No message = sleeps again
echo.
echo   Just chat normally with Feishu.
echo ============================================
pause
