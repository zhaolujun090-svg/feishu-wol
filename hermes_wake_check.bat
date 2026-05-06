@echo off
chcp 65001 >nul
title Hermes 唤醒监控

echo [%date% %time%] 电脑已唤醒，检查Hermes状态...

cd /d D:\Ai-ruanjian\python

REM 检查Hermes是否在运行（通过Feishu WebSocket连接判断）
wsl -d Ubuntu -- bash -c "ps aux | grep -v grep | grep -q 'hermes.*gateway' && echo 'running' || echo 'stopped'" 2>nul > %TEMP%\hermes_status.txt
set /p HERMES_STATUS=<%TEMP%\hermes_status.txt

if "%HERMES_STATUS%"=="stopped" (
    echo [%date% %time%] Hermes未运行，启动中...
    REM 启动Hermes Feishu网关
    wsl -d Ubuntu -- bash -ic "cd ~/.hermes/hermes-agent && source .venv/bin/activate && hermes gateway 2>&1 &" >nul 2>&1
    echo [%date% %time%] Hermes已启动
    REM 等一会让Hermes连上飞书
    timeout /t 10 /nobreak >nul
    
    REM 尝试从飞书拉取消息（如果Hermes收到了消息，它会保持运行）
    echo [%date% %time%] 等待消息处理...
    timeout /t 20 /nobreak >nul
) else (
    echo [%date% %time%] Hermes已在运行
    timeout /t 15 /nobreak >nul
)

REM 检查是否有活动（最近是否有飞书消息）
wsl -d Ubuntu -- bash -ic "tail -5 ~/.hermes/logs/gateway.log 2>/dev/null | grep -q 'inbound message\|response ready' && echo 'active' || echo 'idle'" 2>nul > %TEMP%\hermes_active.txt
set /p HERMES_ACTIVE=<%TEMP%\hermes_active.txt

if "%HERMES_ACTIVE%"=="active" (
    echo [%date% %time%] ✓ 有消息处理，电脑保持唤醒
    REM 重置休眠计时器（再给15分钟）
    powercfg /change standby-timeout-ac 15
) else (
    echo [%date% %time%] ✗ 无消息，准备继续休眠
    REM 设置1分钟后休眠
    powercfg /change standby-timeout-ac 1
)

echo [%date% %time%] 监控完成
exit /b 0
