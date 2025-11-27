import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [react()],
    server: {
        port: 3000,
        cors: true,
        proxy: {
            '/api': {
                target: 'https://unoffensive-mana-eustatically.ngrok-free.dev',
                changeOrigin: true,
                rewrite: (path) => path.replace(/^\/api/, ''),
                timeout: 300000,
                configure: (proxy, options) => {
                    proxy.on('proxyReq', (proxyReq, req, res) => {
                        proxyReq.setHeader('ngrok-skip-browser-warning', 'true');
                        proxyReq.setTimeout(300000);
                    });
                    proxy.on('error', (err, req, res) => {
                        console.log('Proxy error:', err.message);
                    });
                }
            }
        }
    }
})
