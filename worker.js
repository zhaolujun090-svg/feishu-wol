// Cloudflare Worker - 飞书消息唤醒来
// 部署: cd /mnt/f/Desktop/feishu-wol && npx wrangler deploy worker.js --name feishu-wol

export default {
  async fetch(request) {
    if (request.method !== 'POST') return new Response('ok');

    const body = await request.json();
    
    // 飞书URL验证
    if (body.type === 'url_verification') {
      return new Response(JSON.stringify({ challenge: body.challenge }), {
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // WOL唤醒: 调用一个免费公开的WOL API
    // depicus.com 提供免费的WOL over Internet服务
    try {
      const mac = 'ECD68ACD1E6D'; // 去掉冒号
      const wolUrl = `https://www.depicus.com/wake-on-lan/woli?mac=${mac}&ip=36.34.1.94&subnet=255.255.255.0&port=9`;
      await fetch(wolUrl);
      console.log('WOL已发送');
    } catch(e) {
      console.log('WOL发送失败:', e.message);
    }

    return new Response(JSON.stringify({ code: 0 }), {
      headers: { 'Content-Type': 'application/json' }
    });
  }
};
