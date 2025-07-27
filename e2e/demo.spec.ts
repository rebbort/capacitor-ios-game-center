import { test, expect } from '@playwright/test';

const demoUrl = 'http://localhost:5173';

test.describe('Demo app', () => {
  test('Game Center ON', async ({ page }) => {
    await page.addInitScript(() => {
      const plugin = {
        authenticateSilent: async () => ({ authenticated: true }),
        getProfile: async () => ({
          displayName: 'Player',
          playerId: '1',
          avatarUrl: 'data:image/png;base64,' + 'a'.repeat(150),
        }),
        addListener: () => ({ remove: () => {} }),
      } as any;
      window.Capacitor = { registerPlugin: () => plugin } as any;
    });
    await page.goto(demoUrl);
    await expect(page.locator('#name')).toHaveText('Player');
    const src = await page.locator('#avatar').getAttribute('src');
    expect(src).toMatch(/^data:image\/png;base64,/);
  });

  test('Game Center OFF', async ({ page }) => {
    await page.addInitScript(() => {
      const plugin = {
        authenticateSilent: async () => {
          throw { code: 'NOT_AUTHENTICATED' };
        },
        addListener: () => ({ remove: () => {} }),
      } as any;
      window.Capacitor = { registerPlugin: () => plugin } as any;
    });
    await page.goto(demoUrl);
    await expect(page.locator('#name')).toHaveText('Guest');
    const src = await page.locator('#avatar').getAttribute('src');
    expect(src).toContain('guest');
  });
});
