import {
  authenticateSilent,
  getProfile,
  GameCenter,
  PluginError,
  type GameCenterPlugin,
} from '../src';

const gcOverride = (window as any).__gcPlugin as Partial<GameCenterPlugin> | undefined;
console.log('gcOverride', gcOverride);
const auth = gcOverride?.authenticateSilent ?? authenticateSilent;
const profile = gcOverride?.getProfile ?? getProfile;
const addListener = gcOverride?.addListener ?? GameCenter.addListener;

const avatar = document.getElementById('avatar') as HTMLImageElement;
const nameEl = document.getElementById('name') as HTMLElement;
const statusEl = document.getElementById('status') as HTMLElement;
const guestUrl = new URL('./assets/guest.png', import.meta.url).href;

async function showGuest() {
  avatar.src = guestUrl;
  nameEl.textContent = 'Guest';
  statusEl.textContent = 'Progress will be saved locally';
}

async function loadProfile() {
  try {
    const state = await auth();
    if (!state.authenticated) {
      throw { code: PluginError.NOT_AUTHENTICATED };
    }
    const p = await profile('small');
    avatar.src = p.avatarUrl;
    await avatar.decode();
    nameEl.textContent = p.displayName;
    statusEl.textContent = '';
  } catch (e: unknown) {
    const err = e as { code?: string; message?: string };
    if (
      err?.code === PluginError.NOT_AUTHENTICATED ||
      err?.code === PluginError.GC_UNAVAILABLE
    ) {
      await showGuest();
    } else {
      statusEl.textContent = 'Error: ' + (err?.message || 'unknown');
      await showGuest();
    }
  }
}

addListener('authStateChanged', (ev: { authenticated: boolean }) => {
  if (ev.authenticated) {
    loadProfile();
  } else {
    showGuest();
  }
});

loadProfile();
