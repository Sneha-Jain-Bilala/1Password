// lib/services/biometric_auth_service.dart
//
// Wraps the local_auth package into a clean, reusable service.
// Returns typed results so callers never deal with raw exceptions.

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

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
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow PIN/pattern as fallback
          stickyAuth: true, // Don't cancel when app goes to background
          sensitiveTransaction: true,
        ),
      );

      return success ? BiometricResult.success : BiometricResult.failure;
    } on PlatformException catch (e) {
      switch (e.code) {
        case auth_error.notAvailable:
          return BiometricResult.notAvailable;
        case auth_error.notEnrolled:
          return BiometricResult.notEnrolled;
        case auth_error.lockedOut:
        case auth_error.permanentlyLockedOut:
          return BiometricResult.lockout;
        case auth_error.passcodeNotSet:
          return BiometricResult.notEnrolled;
        default:
          // User cancelled returns a platform exception on some devices
          if (e.code == 'UserCancel' || e.message?.contains('cancel') == true) {
            return BiometricResult.cancelled;
          }
          return BiometricResult.error;
      }
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
