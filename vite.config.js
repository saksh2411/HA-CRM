import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
export default defineConfig({ plugins: [react()], base: './', publicDir: false, build: { outDir: 'public/assets/build', emptyOutDir: true }, server: { proxy: { '/api': 'http://localhost/HA-CRM/public', '/index.php': 'http://localhost/HA-CRM/public' } } });
