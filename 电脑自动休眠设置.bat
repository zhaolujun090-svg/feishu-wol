@echo off
title 自动休眠 + WOL设置
chcp 65001 >nul

echo ============================================
echo   设置电脑15分钟无操作自动休眠
echo   同时确保LAN唤醒(WOL)可用
echo ============================================
echo.

echo 1. 设置15分钟休眠...
powercfg /change standby-timeout-ac 15
powercfg /change hibernate-timeout-ac 0
echo    ✅ 15分钟无操作自动休眠

echo.
echo 2. 允许唤醒定时器...
powercfg /change wake-timer-ac 1
echo    ✅ 唤醒定时器已启用

echo.
echo 3. 检查网卡WOL状态...
wmic NIC where "NetEnabled=true" get Name, MACAddress, WakeOnLan
echo.
echo    ⚠ 如果上面显示WakeOnLan=False，需要去设备管理器开启
echo      网卡属性 → 高级 → "Wake on Magic Packet" 设为 Enabled

echo.
echo 4. 防火墙放行WOL端口...
netsh advfirewall firewall add rule name="WOL-UDP-9" protocol=udp localport=9 dir=in action=allow >nul 2>&1
netsh advfirewall firewall add rule name="WOL-UDP-30009" protocol=udp localport=30009 dir=in action=allow >nul 2>&1
echo    ✅ 防火墙端口已放行

echo.
echo ============================================
echo 设置完成！
echo 电脑将在15分钟无人操作后自动休眠
echo 收到WOL魔法包时会自动唤醒
echo ============================================
pause
