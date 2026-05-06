# 🦞 Feishu WOL Wakeup Service

飞书消息 → 自动唤醒电脑 的中转服务。

## 一句话原理

你手机发飞书给小蜜 → 飞书通知这个云服务 → 云服务发WOL魔法包 → 你家路由器 → 电脑唤醒 → Hermes启动 → 回复你

## 部署（Railway免费版）

1. 把代码推到GitHub仓库
2. 打开 https://railway.app 用GitHub登录
3. 点 **New Project → Deploy from GitHub repo**
4. 选择这个仓库，Railway自动部署
5. 部署成功后，把生成URL记下来（格式如 `https://xxx.up.railway.app`）

## 配置飞书事件订阅

1. 打开飞书开发者后台 → 你的机器人应用 → **事件与回调**
2. 订阅方式选 **推送至开发者服务器**
3. 回调URL填：`https://你的域名.up.railway.app/webhook/feishu`

## 电脑端配置

1. 确保WOL已开启（BIOS + 网卡驱动 → 魔术包唤醒）
2. 路由器配好端口转发：外网30009 → 内网广播
3. 电脑设好15分钟无人休眠
4. 把 `电脑自动休眠.bat` 添加到开机启动项
