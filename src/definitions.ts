export interface VerificationPayload {
  playerId: string;
  publicKeyUrl: string;
  signature: string;
  salt: string;
  timestamp: number;
  bundleId: string;
}

export interface UserProfile {
  displayName: string;
  playerId: string;
  avatarUrl: string;
}

export interface AuthState {
  authenticated: boolean;
}

export enum PluginError {
  NOT_AUTHENTICATED = 'NOT_AUTHENTICATED',
  GC_UNAVAILABLE = 'GC_UNAVAILABLE',
  OS_UNSUPPORTED = 'OS_UNSUPPORTED',
  INTERNAL = 'INTERNAL',
}

export function isAuthState(data: unknown): data is AuthState {
  return (
    !!data &&
    typeof data === 'object' &&
    typeof (data as Record<string, unknown>).authenticated === 'boolean'
  );
}

export function isVerificationPayload(
  data: unknown,
): data is VerificationPayload {
  if (!data || typeof data !== 'object') {
    return false;
  }
  const obj = data as Record<string, unknown>;
  return (
    typeof obj.playerId === 'string' &&
    typeof obj.publicKeyUrl === 'string' &&
    typeof obj.signature === 'string' &&
    typeof obj.salt === 'string' &&
    typeof obj.timestamp === 'number' &&
    typeof obj.bundleId === 'string'
  );
}

export function isUserProfile(data: unknown): data is UserProfile {
  if (!data || typeof data !== 'object') {
    return false;
  }
  const obj = data as Record<string, unknown>;
  return (
    typeof obj.displayName === 'string' &&
    typeof obj.playerId === 'string' &&
    typeof obj.avatarUrl === 'string'
  );
}
