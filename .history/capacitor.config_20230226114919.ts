
/* eslint-disable @typescript-eslint/naming-convention */
/* eslint-disable no-trailing-spaces */
import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.cordova.plumb.demo',
  appName: 'plumb5-kotak-test',
  webDir: 'www',
  bundledWebRuntime: false,
  plugins:{
    Plumb5:{
      PLUMB5_ACCOUNT_ID:1011,
      PLUMB5_BASE_URL: 'https://p5mobile.kotakmf.com',
      PLUMB5_API_KEY: '6e2b8ed6b5ef28ab5e420cb5eb7a1b5ee5b5bd6eaaa6'
    }

  }

};

export default config;

