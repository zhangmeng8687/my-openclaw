const net = require('net');
const crypto = require('crypto');
const fs = require('fs');

function simpleWebSocket(url) {
  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    const key = crypto.randomBytes(16).toString('base64');
    
    const socket = net.createConnection(parseInt(parsed.port), parsed.hostname, () => {
      const request = 'GET ' + parsed.pathname + ' HTTP/1.1\r\n' +
        'Host: ' + parsed.host + '\r\n' +
        'Upgrade: websocket\r\n' +
        'Connection: Upgrade\r\n' +
        'Sec-WebSocket-Key: ' + key + '\r\n' +
        'Sec-WebSocket-Version: 13\r\n' +
        '\r\n';
      socket.write(request);
    });
    
    let headers = '';
    let handshakeDone = false;
    let messageCallback = null;
    let buffer = Buffer.alloc(0);
    
    socket.on('data', (chunk) => {
      if (!handshakeDone) {
        headers += chunk.toString();
        if (headers.includes('\r\n\r\n')) {
          handshakeDone = true;
          resolve({ 
            socket, 
            send: (msg) => {
              const buf = Buffer.from(msg);
              const mask = crypto.randomBytes(4);
              let header;
              if (buf.length < 126) {
                header = Buffer.alloc(6);
                header[0] = 0x81;
                header[1] = 0x80 | buf.length;
                mask.copy(header, 2);
              } else if (buf.length < 65536) {
                header = Buffer.alloc(8);
                header[0] = 0x81;
                header[1] = 0x80 | 126;
                header.writeUInt16BE(buf.length, 2);
                mask.copy(header, 4);
              } else {
                header = Buffer.alloc(14);
                header[0] = 0x81;
                header[1] = 0x80 | 127;
                header.writeUInt32BE(0, 2);
                header.writeUInt32BE(buf.length, 6);
                mask.copy(header, 10);
              }
              const masked = Buffer.alloc(buf.length);
              for (let i = 0; i < buf.length; i++) {
                masked[i] = buf[i] ^ mask[i % 4];
              }
              socket.write(Buffer.concat([header, masked]));
            }, 
            onMessage: (cb) => {
              messageCallback = cb;
            }
          });
        }
      } else {
        buffer = Buffer.concat([buffer, chunk]);
        
        while (buffer.length > 2) {
          const firstByte = buffer[0];
          const secondByte = buffer[1];
          const opcode = firstByte & 0x0f;
          const isMasked = (secondByte & 0x80) !== 0;
          let payloadLength = secondByte & 0x7f;
          let headerSize = 2;
          
          if (payloadLength === 126) {
            if (buffer.length < 4) break;
            payloadLength = buffer.readUInt16BE(2);
            headerSize = 4;
          } else if (payloadLength === 127) {
            if (buffer.length < 10) break;
            payloadLength = buffer.readUInt32BE(6);
            headerSize = 10;
          }
          
          if (isMasked) headerSize += 4;
          
          if (buffer.length < headerSize + payloadLength) break;
          
          const payload = buffer.slice(headerSize, headerSize + payloadLength);
          buffer = buffer.slice(headerSize + payloadLength);
          
          if (opcode === 1) {
            if (messageCallback) messageCallback(payload.toString());
          } else if (opcode === 2) {
            if (messageCallback) messageCallback(payload);
          }
        }
      }
    });
    
    socket.on('error', reject);
    setTimeout(() => reject(new Error('Timeout')), 60000);
  });
}

async function getPageWs() {
  const res = await fetch('http://localhost:9222/json');
  const pages = await res.json();
  const page = pages.find(p => p.title.includes('lanhu') || p.title.includes('金石'));
  if (!page) throw new Error('Page not found');
  return simpleWebSocket(page.webSocketDebuggerUrl);
}

function setupCallbacks(ws) {
  let id = 1;
  const pendingCallbacks = {};
  
  ws.onMessage((data) => {
    if (Buffer.isBuffer(data)) return;
    try {
      const msg = JSON.parse(data);
      if (msg.id && pendingCallbacks[msg.id]) {
        pendingCallbacks[msg.id](msg.result);
        delete pendingCallbacks[msg.id];
      }
    } catch (e) {}
  });
  
  function send(method, params = {}) {
    return new Promise((resolve, reject) => {
      const msgId = id++;
      pendingCallbacks[msgId] = resolve;
      ws.send(JSON.stringify({ id: msgId, method, params }));
      setTimeout(() => {
        if (pendingCallbacks[msgId]) {
          delete pendingCallbacks[msgId];
          reject(new Error('Timeout for ' + method));
        }
      }, 30000);
    });
  }
  
  return send;
}

async function clickAt(x, y) {
  const ws = await getPageWs();
  const send = setupCallbacks(ws);
  
  await send('Input.dispatchMouseEvent', {
    type: 'mousePressed', x, y, button: 'left', clickCount: 1
  });
  await send('Input.dispatchMouseEvent', {
    type: 'mouseReleased', x, y, button: 'left', clickCount: 1
  });
  
  ws.socket.destroy();
}

async function captureScreenshot(filename) {
  const ws = await getPageWs();
  const send = setupCallbacks(ws);
  
  console.log('Taking screenshot...');
  const screenshot = await send('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync('C:/Users/38422/.openclaw/workspace/' + filename, Buffer.from(screenshot.data, 'base64'));
  console.log('Screenshot saved to ' + filename);
  
  ws.socket.destroy();
}

async function findDesignCanvas() {
  const ws = await getPageWs();
  const send = setupCallbacks(ws);
  
  // Find the design canvas/iframe
  const result = await send('Runtime.evaluate', {
    expression: `
      // Look for the design canvas or iframe
      const iframes = document.querySelectorAll('iframe');
      const canvases = document.querySelectorAll('canvas');
      const svgs = document.querySelectorAll('svg');
      
      const info = {
        iframes: iframes.length,
        canvases: canvases.length,
        svgs: svgs.length
      };
      
      // Look for the main design area
      const designArea = document.querySelector('[class*="design"], [class*="canvas"], [class*="stage"]');
      if (designArea) {
        const rect = designArea.getBoundingClientRect();
        info.designArea = {
          className: designArea.className?.substring(0, 50),
          x: Math.round(rect.x),
          y: Math.round(rect.y),
          width: Math.round(rect.width),
          height: Math.round(rect.height)
        };
      }
      
      JSON.stringify(info, null, 2);
    `,
    returnByValue: true
  });
  
  console.log('Design canvas info:', result.result.value);
  
  ws.socket.destroy();
}

async function zoomIn() {
  const ws = await getPageWs();
  const send = setupCallbacks(ws);
  
  // Find and click the zoom in button
  const result = await send('Runtime.evaluate', {
    expression: `
      // Look for zoom in button (+)
      const buttons = document.querySelectorAll('button, [role="button"]');
      let found = null;
      for (const btn of buttons) {
        if (btn.textContent?.trim() === '+') {
          found = btn;
          break;
        }
      }
      if (found) {
        found.click();
        'Clicked zoom in';
      } else {
        'Could not find zoom in button';
      }
    `,
    returnByValue: true
  });
  
  console.log('Zoom result:', result.result.value);
  
  ws.socket.destroy();
}

async function main() {
  // Find design canvas
  console.log('Finding design canvas...');
  await findDesignCanvas();
  
  // Zoom in to see details better
  console.log('Zooming in...');
  for (let i = 0; i < 3; i++) {
    await zoomIn();
    await new Promise(resolve => setTimeout(resolve, 500));
  }
  
  // Take screenshot after zoom
  await captureScreenshot('lanhu-zoomed.png');
  
  // Now click on specific elements
  // Based on the zoomed view, click on the navigation bar
  console.log('Clicking on design elements...');
  await clickAt(960, 400);
  await new Promise(resolve => setTimeout(resolve, 1000));
  await captureScreenshot('lanhu-element-click.png');
  
  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(1); });
