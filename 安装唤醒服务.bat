@echo off
chcp 65001 >nul
title 安装Hermes唤醒服务

echo ============================================
echo   安装Hermes自动唤醒监控
echo ============================================
echo.

REM 1. 设置15分钟自动休眠
echo [1/3] 设置15分钟无操作自动休眠...
powercfg /change standby-timeout-ac 15
powercfg /change hibernate-timeout-ac 0
powercfg /change wake-timer-ac 1
echo    ✅

REM 2. 创建定时任务（用PowerShell支持唤醒）
echo [2/3] 创建每2分钟唤醒定时任务...

powershell -Command ^
"$action = New-ScheduledTaskAction -Execute '%~dp0hermes_wake_check.bat';" ^
"$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 2) -RepetitionDuration ([TimeSpan]::MaxValue);" ^
"$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -WakeToRun -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 1);" ^
"$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings;" ^
"Register-ScheduledTask 'HermesWakeCheck' -InputObject $task -Force;" ^
"Write-Output '✅ 定时任务已创建'"

echo.

REM 3. 放行防火墙
echo [3/3] 放行防火墙...
netsh advfirewall firewall add rule name="WOL-UDP-9" protocol=udp localport=9 dir=in action=allow >nul 2>&1
echo    ✅

echo.
echo ============================================
echo   ✅ 全部完成！
echo.
echo   原理很简单：
echo   ┌─ 电脑15分钟不用 → 自动休眠
echo   ├─ 休眠后每2分钟自动醒一次
echo   ├─ 醒时检查飞书有没有新消息
echo   ├─ 有消息 → 保持唤醒，Hermes回复你
echo   └─ 没消息 → 继续睡
echo.
echo   你双击这个脚本就行，后面不用管了
echo ============================================
pause
