// lib/services/biometric_auth_service.dart
//
// Wraps the local_auth package into a clean, reusable service.
// Returns typed results so callers never deal with raw exceptions.

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricResult {
  success,
  failure,
  cancelled,
  notAvailable,
  notEnrolled,
  lockout,
  error,
}

class BiometricAuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Returns true if the device has any biometric hardware AND enrolled data.
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isDeviceSupported) return false;
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Prompts biometric authentication and returns a [BiometricResult].
  ///
  /// [reason] is the string shown in the system prompt.
  static Future<BiometricResult> authenticate({
    String reason = 'Verify your identity to view this password',
  }) async {
    try {
      final available = await isAvailable();
      if (!available) {
        // Check if device auth (PIN/pattern) is at least supported as fallback
        final deviceSupported = await _auth.isDeviceSupported();
        if (!deviceSupported) return BiometricResult.notAvailable;
        // enrolled check
        final biometrics = await _auth.getAvailableBiometrics();
        if (biometrics.isEmpty) return BiometricResult.notEnrolled;
      }

      final success = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false, // Allow PIN/pattern as fallback
        persistAcrossBackgrounding: true,
        sensitiveTransaction: true,
      );

      return success ? BiometricResult.success : BiometricResult.failure;
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
          return BiometricResult.notAvailable;
        case LocalAuthExceptionCode.noBiometricsEnrolled:
        case LocalAuthExceptionCode.noCredentialsSet:
          return BiometricResult.notEnrolled;
        case LocalAuthExceptionCode.temporaryLockout:
        case LocalAuthExceptionCode.biometricLockout:
          return BiometricResult.lockout;
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.userRequestedFallback:
          return BiometricResult.cancelled;
        case LocalAuthExceptionCode.deviceError:
        case LocalAuthExceptionCode.authInProgress:
        case LocalAuthExceptionCode.uiUnavailable:
        case LocalAuthExceptionCode.timeout:
        case LocalAuthExceptionCode.systemCanceled:
        case LocalAuthExceptionCode.unknownError:
          return BiometricResult.error;
      }
    } on PlatformException catch (e) {
      if (e.code == 'UserCancel' || e.message?.contains('cancel') == true) {
        return BiometricResult.cancelled;
      }
      return BiometricResult.error;
    } catch (_) {
      return BiometricResult.error;
    }
  }

  /// Convenience: returns a human-readable error message for a failed result.
  static String errorMessage(BiometricResult result) {
    switch (result) {
      case BiometricResult.notAvailable:
        return 'Biometric authentication is not available on this device.';
      case BiometricResult.notEnrolled:
        return 'No biometrics enrolled. Please set up fingerprint or Face ID in Settings.';
      case BiometricResult.lockout:
        return 'Too many failed attempts. Please try again later.';
      case BiometricResult.cancelled:
        return 'Authentication was cancelled.';
      case BiometricResult.failure:
        return 'Authentication failed. Please try again.';
      default:
        return 'An unexpected error occurred during authentication.';
    }
  }
}
