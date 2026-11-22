const http = require('http');
const os = require('os');
const { spawn } = require('child_process');
const path = require('path');

const IIS_PORT = 50379;
const PROXY_PORT = process.env.PORT || 3000;
const PROJECT_DIR = __dirname;
const CONFIG_PATH = path.join(PROJECT_DIR, '.vs', 'FoundrLink', 'config', 'applicationhost.config');
const IIS_EXPRESS_PATH = 'C:\\Program Files\\IIS Express\\iisexpress.exe';

// Discover local Wi-Fi / LAN IP
function getLocalIp() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                return iface.address;
            }
        }
    }
    return '127.0.0.1';
}

const localIp = getLocalIp();

// Start IIS Express
console.log('----------------------------------------------------');
console.log(' Starting IIS Express for FoundrLink...');
console.log('----------------------------------------------------');

const iisProcess = spawn(IIS_EXPRESS_PATH, [
    `/config:${CONFIG_PATH}`,
    '/site:FoundrLink'
], {
    windowsHide: false,
    stdio: 'inherit'
});

iisProcess.on('error', (err) => {
    console.error('Failed to start IIS Express:', err.message);
});

iisProcess.on('exit', (code, signal) => {
    console.log(`IIS Express stopped (code: ${code}, signal: ${signal})`);
    process.exit(code || 0);
});

// Create Reverse Proxy for Mobile & External LAN devices
const server = http.createServer((req, res) => {
    const clientHost = req.headers.host || `${localIp}:${PROXY_PORT}`;
    
    const headers = { ...req.headers };
    headers['host'] = `localhost:${IIS_PORT}`;
    headers['x-forwarded-host'] = clientHost;
    headers['x-forwarded-for'] = req.socket.remoteAddress;
    headers['x-forwarded-proto'] = 'http';

    const options = {
        hostname: '127.0.0.1',
        port: IIS_PORT,
        path: req.url,
        method: req.method,
        headers: headers
    };

    const proxyReq = http.request(options, (proxyRes) => {
        const resHeaders = { ...proxyRes.headers };

        // Rewrite redirects from localhost:50379 to mobile client host
        if (resHeaders['location']) {
            resHeaders['location'] = resHeaders['location']
                .replace(`localhost:${IIS_PORT}`, clientHost)
                .replace(`127.0.0.1:${IIS_PORT}`, clientHost);
        }

        // Strip "; Secure" flag from cookies for HTTP local testing
        if (resHeaders['set-cookie']) {
            resHeaders['set-cookie'] = (Array.isArray(resHeaders['set-cookie']) 
                ? resHeaders['set-cookie'] 
                : [resHeaders['set-cookie']]
            ).map(cookie => cookie.replace(/;\s*secure/gi, ''));
        }

        res.writeHead(proxyRes.statusCode, resHeaders);
        proxyRes.pipe(res, { end: true });
    });

    proxyReq.on('error', (err) => {
        console.error(`Proxy error forwarding ${req.method} ${req.url}:`, err.message);
        if (!res.headersSent) {
            res.writeHead(502, { 'Content-Type': 'text/html; charset=utf-8' });
            res.end(`<h3>502 Bad Gateway</h3><p>Could not connect to IIS Express on port ${IIS_PORT}. Please ensure the server is ready.</p>`);
        }
    });

    req.pipe(proxyReq, { end: true });
});

server.listen(PROXY_PORT, '0.0.0.0', () => {
    console.log('\n====================================================');
    console.log(' FoundrLink is RUNNING!');
    console.log('====================================================');
    console.log(` Local (PC):     http://localhost:${PROXY_PORT}/`);
    console.log(` Mobile (Phone): http://${localIp}:${PROXY_PORT}/`);
    console.log('====================================================');
    console.log(' Make sure your phone is connected to the same Wi-Fi.');
    console.log(' Test Credentials:');
    console.log('   Admin:      admin@ripaldesign.studio    | Password123');
    console.log('   Founder:    founder@ripaldesign.studio  | Password123');
    console.log('   Co-Founder: cofounder@ripaldesign.studio| Password123');
    console.log('   Investor:   investor@ripaldesign.studio | Password123');
    console.log('====================================================\n');
});

// Clean termination
function cleanup() {
    console.log('\nShutting down Mobile Proxy and IIS Express...');
    if (iisProcess && !iisProcess.killed) {
        try {
            process.kill(iisProcess.pid);
        } catch (e) {}
    }
    process.exit(0);
}

process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);
process.on('exit', cleanup);
