import { defineConfig } from 'vite';

export default defineConfig({
  root: __dirname,
  build: {
    target: 'es2021',
    outDir: 'dist',
    emptyOutDir: true,
  },
});
