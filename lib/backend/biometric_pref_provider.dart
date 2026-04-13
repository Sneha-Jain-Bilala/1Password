// lib/backend/biometric_pref_provider.dart
//
// Persists the user's choice to enable/disable biometric login.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBiometricEnabledKey = 'pref_biometric_enabled';

class BiometricPrefNotifier extends Notifier<bool> {
  @override
  bool build() => true; // enabled by default

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kBiometricEnabledKey) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricEnabledKey, value);
  }
}

final biometricPrefProvider = NotifierProvider<BiometricPrefNotifier, bool>(
  BiometricPrefNotifier.new,
);
