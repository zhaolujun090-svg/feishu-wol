const express = require('express');
const dgram = require('dgram');

const app = express();
app.use(express.json());

// ====== 配置区（改这里就行）======
const CONFIG = {
  MAC: 'ec:d6:8a:cd:1e:6d',           // 你的电脑网卡MAC
  ROUTER_IP: '36.34.1.94',            // 你家路由器公网IP
  ROUTER_PORT: 30009,                  // 路由器端口转发端口
  VERIFY_TOKEN: 'wol_wakeup_2024',     // 验证token（和之前一致）
  PORT: process.env.PORT || 3000       // 云服务监听端口
};

// ====== 发送WOL魔法包 ======
function sendWOL(macStr, ip, port) {
  return new Promise((resolve, reject) => {
    // 转MAC为字节
    const mac = macStr.replace(/[:\-]/g, '');
    const macBytes = Buffer.from(mac, 'hex');
    
    // 构建魔法包: 6个FF + 16遍MAC地址
    const magic = Buffer.alloc(6 + 16 * 6, 0xFF);
    for (let i = 0; i < 16; i++) {
      macBytes.copy(magic, 6 + i * 6);
    }
    
    const sock = dgram.createSocket('udp4');
    sock.send(magic, 0, magic.length, port, ip, (err) => {
      sock.close();
      if (err) reject(err);
      else resolve();
    });
  });
}

// ====== 飞书事件订阅入口 ======
app.post('/webhook/feishu', async (req, res) => {
  const body = req.body;
  console.log(`[${new Date().toISOString()}] 收到请求 type=${body.type || 'unknown'}`);
  
  // 1️⃣ 飞书URL验证（配置事件订阅时必须）
  if (body.type === 'url_verification') {
    console.log('→ URL验证');
    return res.json({ challenge: body.challenge });
  }
  
  // 2️⃣ 解析飞书事件
  const event = body.event || {};
  const header = body.header || {};
  const token = header.token || body.token || '';
  
  // token验证（防止乱调）
  if (token !== CONFIG.VERIFY_TOKEN) {
    console.log(`→ token不匹配: ${token}`);
    return res.status(403).json({ error: 'token验证失败' });
  }
  
  // 3️⃣ 发送WOL唤醒包
  console.log(`→ 发送WOL到 ${CONFIG.MAC} @ ${CONFIG.ROUTER_IP}:${CONFIG.ROUTER_PORT}`);
  
  try {
    await sendWOL(CONFIG.MAC, CONFIG.ROUTER_IP, CONFIG.ROUTER_PORT);
    console.log('✅ WOL发送成功');
    res.json({ code: 0, message: '电脑即将唤醒' });
  } catch (err) {
    console.error('❌ WOL发送失败:', err.message);
    res.status(500).json({ error: 'WOL发送失败' });
  }
});

// ====== 健康检查 ======
app.get('/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

// ====== 启动 ======
app.listen(CONFIG.PORT, () => {
  console.log(`🦞 Feishu WOL 唤醒来服务已启动 :${CONFIG.PORT}`);
  console.log(`   目标: ${CONFIG.MAC} @ ${CONFIG.ROUTER_IP}:${CONFIG.ROUTER_PORT}`);
});
