#!/usr/bin/env node
/**
 * Serves the built site (build/web) over the local network, so this computer
 * acts as the web server for any device on the same Wi-Fi.
 *
 *   flutter build web --release      # once, after any code change
 *   node tools/serve.js              # then this
 *
 * Options:
 *   node tools/serve.js --port 8080 --dir build/web
 */

const http = require('http');
const fs = require('fs');
const os = require('os');
const path = require('path');

// ---- arguments -------------------------------------------------------------
const args = process.argv.slice(2);
const argOf = (name, fallback) => {
  const i = args.indexOf(`--${name}`);
  return i !== -1 && args[i + 1] ? args[i + 1] : fallback;
};

const port = Number(argOf('port', 8080));
const root = path.resolve(argOf('dir', path.join(__dirname, '..', 'build', 'web')));

if (!fs.existsSync(path.join(root, 'index.html'))) {
  console.error(`\n  No index.html in ${root}`);
  console.error('  Build it first:  flutter build web --release\n');
  process.exit(1);
}

// ---- mime types ------------------------------------------------------------
const types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.symbols': 'text/plain; charset=utf-8',
};

const server = http.createServer((req, res) => {
  let urlPath = decodeURIComponent(req.url.split('?')[0]);
  if (urlPath === '/') urlPath = '/index.html';

  let file = path.join(root, path.normalize(urlPath));
  // Never serve anything outside the build directory.
  if (!file.startsWith(root)) {
    res.writeHead(403).end('Forbidden');
    return;
  }

  fs.stat(file, (err, stat) => {
    // Single-page app: unknown paths fall back to index.html.
    if (err || !stat.isFile()) file = path.join(root, 'index.html');

    fs.readFile(file, (readErr, data) => {
      if (readErr) {
        res.writeHead(404).end('Not found');
        return;
      }
      const ext = path.extname(file).toLowerCase();
      const immutable = file.includes(`${path.sep}canvaskit${path.sep}`) ||
        file.includes(`${path.sep}assets${path.sep}`);
      res.writeHead(200, {
        'Content-Type': types[ext] || 'application/octet-stream',
        'Content-Length': data.length,
        'Cache-Control': ext === '.html'
          ? 'no-cache'
          : immutable
            ? 'public, max-age=604800'
            : 'public, max-age=3600',
      });
      res.end(data);
    });
  });
});

// 0.0.0.0 — reachable from other devices, not just this machine.
server.listen(port, '0.0.0.0', () => {
  const addresses = [];
  for (const list of Object.values(os.networkInterfaces())) {
    for (const net of list || []) {
      if (net.family === 'IPv4' && !net.internal) addresses.push(net.address);
    }
  }

  console.log(`\n  Ze Space Interior — serving ${root}\n`);
  console.log(`  On this computer:  http://localhost:${port}`);
  for (const address of addresses) {
    console.log(`  On the network:    http://${address}:${port}`);
  }
  console.log('\n  Press Ctrl+C to stop.\n');
});

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`\n  Port ${port} is already in use. Try:  node tools/serve.js --port 8081\n`);
  } else {
    console.error(error);
  }
  process.exit(1);
});
