import { registerPlugin } from '@capacitor/core';
import type {
  AuthState,
  VerificationPayload,
  UserProfile,
} from './definitions';

export type PhotoSize = 'small' | 'normal' | 'large';

export interface GameCenterPlugin {
  authenticateSilent(): Promise<AuthState>;
  getVerificationData(): Promise<VerificationPayload>;
  getProfile(size?: PhotoSize): Promise<UserProfile>;
  refreshAuthState(): Promise<AuthState>;
}

const GameCenter = registerPlugin<GameCenterPlugin>('GameCenter');

export const authenticateSilent = () => GameCenter.authenticateSilent();
export const getVerificationData = () => GameCenter.getVerificationData();
export const getProfile = (size?: PhotoSize) => GameCenter.getProfile(size);
export const refreshAuthState = () => GameCenter.refreshAuthState();

export * from './definitions';
export { GameCenter };
