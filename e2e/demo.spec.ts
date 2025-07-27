import { test, expect } from '@playwright/test';

const demoUrl = 'http://localhost:5173';

test.describe('Demo app', () => {
  test('Game Center ON', async ({ page }) => {
    page.on('console', m => console.log('PAGE:', m.text()));
    await page.addInitScript(() => {
      (window as any).__gcPlugin = {
        authenticateSilent: async () => ({ authenticated: true }),
        getProfile: async () => ({
          displayName: 'Player',
          playerId: '1',
          avatarUrl:
            'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMB/UZdBngAAAAASUVORK5CYII=',
        }),
        addListener: () => ({ remove: () => {} }),
      };
    });
    await page.goto(demoUrl);
    await expect(page.locator('#name')).toHaveText('Player');
    const src = await page.locator('#avatar').getAttribute('src');
    expect(src).toMatch(/^data:image\/png;base64,/);
  });

  test('Game Center OFF', async ({ page }) => {
    page.on('console', m => console.log('PAGE:', m.text()));
    await page.addInitScript(() => {
      (window as any).__gcPlugin = {
        authenticateSilent: async () => {
          throw { code: 'NOT_AUTHENTICATED' };
        },
        addListener: () => ({ remove: () => {} }),
      };
    });
    await page.goto(demoUrl);
    await expect(page.locator('#name')).toHaveText('Guest');
    const src = await page.locator('#avatar').getAttribute('src');
    expect(src).toContain('guest');
  });
});
