# Capacitor iOS Game Center Plugin
[![CI](https://github.com/yourorg/capacitor-ios-game-center/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/yourorg/capacitor-ios-game-center/actions/workflows/ci.yml)

This package provides a minimal interface to authenticate with Game Center on iOS devices.

## Usage

```ts
import { authenticateSilent, PluginError } from '@yourorg/capacitor-gc';

try {
  const state = await authenticateSilent();
  console.log('Authenticated:', state.authenticated);
} catch (e) {
  if ((e as { code?: PluginError }).code === PluginError.NOT_AUTHENTICATED) {
    console.log('User not authenticated');
  }
}
```

```ts
import { getProfile } from '@yourorg/capacitor-gc';

const profile = await getProfile('normal');
console.log(profile.displayName, profile.avatarUrl);
```

```tsx
<img src={profile.avatarUrl} alt="avatar" />
```

## Local build

Run the example project sync command before building the iOS plugin:

```bash
npm run sync:ios
```

iOS native tests run automatically in CI on a macOS runner. Locally you can run
them only on macOS using:

```bash
npm run test:native
```

On Linux hosts this command safely exits with a skip message.

## Testing

Run the test suites with:

```bash
npm run test:native   # iOS XCTest
npm run test:web      # Jest unit tests
npm run test:e2e      # Playwright end-to-end
```

## Try it

A small web demo is located in the `demo/` directory.

```bash
cd demo
npm install
npm run dev
```

This starts a Vite dev server with hot reload so you can test Game Center authentication in the browser.
