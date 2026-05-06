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

REM 2. Create scheduled task with wake support
echo [2/3] Creating wake-up task...

powershell -Command ^
  "unregister-scheduledtask -taskname 'HermesWakeCheck' -confirm:$false 2>$null;" ^
  "$action = New-ScheduledTaskAction -Execute '%~dp0hermes_wake_check.bat';" ^
  "$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval ([TimeSpan]'00:02:00') -RepetitionDuration ([TimeSpan]'365.00:00:00');" ^
  "$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -WakeToRun -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]'00:01:00');" ^
  "$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings;" ^
  "Register-ScheduledTask 'HermesWakeCheck' -InputObject $task -Force | out-null;" ^
  "Write-Output 'OK'"

echo.

REM 3. Firewall
echo [3/3] Configuring firewall...
netsh advfirewall firewall add rule name="WOL-UDP-9" protocol=udp localport=9 dir=in action=allow >nul 2>&1
echo    OK

echo.
echo ============================================
echo   Done! Your PC will now:
echo   - Auto-sleep after 15 min idle
echo   - Wake every 2 min to check Feishu
echo   - Stay awake if message found
echo   - Sleep again if nothing new
echo.
echo   Just use Feishu normally.
echo ============================================
pause
