# Capacitor iOS Game Center Plugin

[![npm](https://img.shields.io/npm/v/@yourorg/capacitor-gc)](https://www.npmjs.com/package/@yourorg/capacitor-gc)
[![CI](https://github.com/yourorg/capacitor-ios-game-center/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/yourorg/capacitor-ios-game-center/actions/workflows/ci.yml)
[![License](https://img.shields.io/npm/l/@yourorg/capacitor-gc)](LICENSE)

Minimal Game Center authentication for Capacitor apps.

## 1. Introduction
This plugin performs silent Game Center login on iOS devices and returns a verification payload for your backend.

## 2. Requirements
- iOS 13 or later
- Capacitor 6

## 3. Install
```bash
npm i @yourorg/capacitor-gc
npx cap sync
```

## 4. Quick start
Paste the following code into your Ionic/Phaser project. It compiles without TypeScript errors.

```ts
import { authenticateSilent, getVerificationData, getProfile, PluginError } from '@yourorg/capacitor-gc';

async function initGC() {
  try {
    const state = await authenticateSilent();
    if (!state.authenticated) return;

    const verify = await getVerificationData();
    await fetch('/verify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(verify),
    });

    const profile = await getProfile('small');
    console.log(profile.displayName);
  } catch (e) {
    if ((e as { code?: PluginError }).code === PluginError.GC_UNAVAILABLE) {
      console.log('Game Center unavailable');
    }
  }
}
```

## 5. Backend verification
Send the payload returned by `getVerificationData()` to your server. Example using curl:

```bash
curl -X POST https://your.app/verify \
  -H 'Content-Type: application/json' \
  -d '{"playerId":"...","signature":"..."}'
```

## 6. Guest fallback
When authentication fails you may continue in guest mode and hide any Game Center features.

![Profile](docs/profile_success.png)
![Guest](docs/guest_mode.png)

## 7. API reference
TypeScript definitions are located in [src/definitions.ts](src/definitions.ts).

## 8. Building & Testing
```bash
npm run sync:ios    # prepare example project
npm run build       # build plugin
npm run test:native # iOS XCTest (macOS only)
npm run test:web    # Jest
npm run test:e2e    # Playwright
```

## 9. License
MIT

