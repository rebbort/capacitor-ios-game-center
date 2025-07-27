# Capacitor iOS Game Center Plugin

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
