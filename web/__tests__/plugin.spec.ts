import {
  PluginError,
  authenticateSilent,
  getProfile,
  isAuthState,
  isUserProfile,
  isVerificationPayload,
} from '../../src';

var pluginMock: any;
jest.mock('@capacitor/core', () => {
  pluginMock = {
    authenticateSilent: jest.fn(),
    getVerificationData: jest.fn(),
    getProfile: jest.fn(),
    refreshAuthState: jest.fn(),
    addListener: jest.fn(),
  };
  return { registerPlugin: () => pluginMock };
});

describe('Type guards', () => {
  test('isAuthState', () => {
    expect(isAuthState({ authenticated: true })).toBe(true);
    expect(isAuthState({})).toBe(false);
  });

  test('isUserProfile', () => {
    expect(
      isUserProfile({ displayName: 'n', playerId: 'p', avatarUrl: 'a' }),
    ).toBe(true);
    expect(isUserProfile({ displayName: 'n' })).toBe(false);
    expect(isUserProfile(null)).toBe(false);
  });

  test('isVerificationPayload', () => {
    const payload = {
      playerId: '1',
      publicKeyUrl: 'https://static.gc.apple.com',
      signature: 's',
      salt: 's',
      timestamp: 1,
      bundleId: 'b',
    };
    expect(isVerificationPayload(payload)).toBe(true);
    expect(isVerificationPayload({})).toBe(false);
    expect(isVerificationPayload(null)).toBe(false);
  });
});

describe('Enums', () => {
  test('values are stable', () => {
    expect(PluginError.NOT_AUTHENTICATED).toBe('NOT_AUTHENTICATED');
    expect(PluginError.GC_UNAVAILABLE).toBe('GC_UNAVAILABLE');
  });
});

describe('API wrappers', () => {
  test('authenticateSilent forwards call', async () => {
    pluginMock.authenticateSilent.mockResolvedValue({ authenticated: true });
    await expect(authenticateSilent()).resolves.toEqual({ authenticated: true });
    expect(pluginMock.authenticateSilent).toHaveBeenCalled();
  });
});

describe('guest fallback', () => {
  test('renders Guest when auth fails', async () => {
    document.body.innerHTML = `
      <img id="avatar" />
      <div id="name"></div>
      <div id="status"></div>
    `;

    (HTMLImageElement.prototype as any).decode = jest
      .fn()
      .mockResolvedValue(undefined);

    pluginMock.authenticateSilent = jest
      .fn()
      .mockResolvedValue({ authenticated: false });
    pluginMock.getProfile = jest.fn();

    const avatar = document.getElementById('avatar') as HTMLImageElement;
    const nameEl = document.getElementById('name') as HTMLElement;
    const statusEl = document.getElementById('status') as HTMLElement;

    try {
      const state = await authenticateSilent();
      if (!state.authenticated) {
        throw { code: PluginError.NOT_AUTHENTICATED };
      }
      const profile = await getProfile('small');
      avatar.src = profile.avatarUrl;
      await avatar.decode();
      nameEl.textContent = profile.displayName;
      statusEl.textContent = '';
    } catch (_) {
      nameEl.textContent = 'Guest';
    }

    expect(nameEl.textContent).toBe('Guest');
  });
});
