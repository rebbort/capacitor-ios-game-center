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
  photo?: string;
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
