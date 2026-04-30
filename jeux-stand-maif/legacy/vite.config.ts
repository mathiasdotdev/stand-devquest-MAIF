import { defineConfig } from "vite";

export default defineConfig({
  base: "./",
  publicDir: "assets",
  build: {
    outDir: "dist",
    assetsDir: "_chunks",
    rollupOptions: {
      output: {
        manualChunks: {
          phaser: ["phaser"],
        },
      },
    },
  },
  server: {
    port: 3000,
    host: "127.0.0.1",
  },
});
