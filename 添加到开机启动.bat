@echo off
title 把自动休眠.bat添加到开机启动
chcp 65001 >nul

echo 添加开机启动项...
copy "%~dp0电脑自动休眠设置.bat" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\" >nul 2>&1
echo ✅ 已添加到开机启动
echo.
echo 你也可以手动把文件拖到：
echo %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\
echo.
pause
