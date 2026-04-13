// lib/screens/biometric_setup_screen.dart
//
// Feature 1: Shown after successful sign-up.
// Asks user to enable biometric authentication.
// Saves preference → navigates to master password setup.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../backend/app_theme.dart';
import '../backend/biometric_pref_provider.dart';
import '../services/biometric_auth_service.dart';

class BiometricSetupScreen extends ConsumerStatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  ConsumerState<BiometricSetupScreen> createState() =>
      _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends ConsumerState<BiometricSetupScreen> {
  bool _isChecking = false;
  bool? _deviceHasBiometrics; // null = not checked yet

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    setState(() => _isChecking = true);
    final available = await BiometricAuthService.isAvailable();
    if (mounted) {
      setState(() {
        _deviceHasBiometrics = available;
        _isChecking = false;
      });
    }
  }

  // User taps "Enable Biometrics" → run a real auth prompt to confirm it works
  Future<void> _enableBiometrics() async {
    setState(() => _isChecking = true);

    final result = await BiometricAuthService.authenticate(
      reason: 'Confirm your biometric to enable it for VaultKey',
    );

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (result == BiometricResult.success) {
      await ref.read(biometricPrefProvider.notifier).setEnabled(true);
      _goNext();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(BiometricAuthService.errorMessage(result)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.darkTheme.colorScheme.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // User taps "Skip" → disable biometrics, move on
  Future<void> _skip() async {
    await ref.read(biometricPrefProvider.notifier).setEnabled(false);
    _goNext();
  }

  void _goNext() => context.go('/master_password');

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              children: [
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(active: false), // step 1: account (done)
                    const SizedBox(width: 8),
                    _dot(active: true), // step 2: biometrics (current)
                    const SizedBox(width: 8),
                    _dot(active: false), // step 3: master password
                  ],
                ),

                const Spacer(),

                // Fingerprint illustration
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.darkTheme.colorScheme.surfaceContainerHigh,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.darkTheme.colorScheme.primary
                            .withValues(alpha: 0.25),
                        blurRadius: 40,
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.darkTheme.colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    size: 72,
                    color: AppTheme.darkTheme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'Enable Biometric Login',
                  style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  _isChecking
                      ? 'Checking device support...'
                      : _deviceHasBiometrics == false
                      ? 'Your device does not have biometric hardware, or no fingerprints are enrolled. You can enable this later in Settings.'
                      : 'Use your fingerprint or Face ID to quickly and securely unlock your vault — no password needed.',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Primary action
                if (_isChecking)
                  const CircularProgressIndicator()
                else if (_deviceHasBiometrics == true) ...[
                  FilledButton.icon(
                    onPressed: _enableBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Enable Biometrics'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ] else ...[
                  // Device has no biometrics — only option is to continue
                  FilledButton(
                    onPressed: _skip,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppTheme.darkTheme.colorScheme.primary : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
