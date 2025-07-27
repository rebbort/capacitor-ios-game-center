import { PlaywrightTestConfig } from '@playwright/test';

const config: PlaywrightTestConfig = {
  webServer: {
    command: 'npm run demo:dev',
    port: 5173,
    reuseExistingServer: !process.env.CI,
    cwd: new URL('.', import.meta.url).pathname,
  },
  testDir: './e2e',
};
export default config;
