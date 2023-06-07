
import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';

// https://vitejs.dev/config/
export default defineConfig({
  build: {
    outDir: "../native-inertia-boilerplate/www-dist",
    emptyOutDir: true,
  },
  base: "",
  plugins: [svelte()],
});
