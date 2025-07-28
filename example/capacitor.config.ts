import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.example.gcdemo',
  appName: 'gc-demo',
  webDir: 'www',
  bundledWebRuntime: false,
  ios: { minVersion: '13.0' },
};

export default config;
