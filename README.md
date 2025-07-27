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
