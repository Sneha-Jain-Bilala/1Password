// lib/screens/unlock_screen.dart
//
// Feature 1: Fingerprint icon now triggers real local_auth biometric prompt.
// Navigates to /dashboard on success; shows SnackBar on failure/cancel.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../backend/app_theme.dart';
import '../backend/auth_controller.dart';
import '../backend/biometric_pref_provider.dart';
import '../services/biometric_auth_service.dart';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  bool _isAuthenticating = false;

  // ── Feature 1: Trigger biometric auth ──────────────────────────────────────
  Future<void> _authenticate() async {
    // Respect the user's biometric toggle from Settings
    final biometricEnabled = ref.read(biometricPrefProvider);
    if (!biometricEnabled) {
      _showSnackBar('Biometric login is disabled. Use your master password.');
      return;
    }

    setState(() => _isAuthenticating = true);

    final result = await BiometricAuthService.authenticate(
      reason: 'Authenticate to access your VaultKey',
    );

    if (!mounted) return;
    setState(() => _isAuthenticating = false);

    switch (result) {
      case BiometricResult.success:
        context.go('/dashboard');
        break;
      case BiometricResult.cancelled:
        // User dismissed — no message needed
        break;
      case BiometricResult.notAvailable:
        _showSnackBar('No biometric hardware found on this device.');
        break;
      case BiometricResult.notEnrolled:
        _showSnackBar(
          'No fingerprints enrolled. Go to device Settings to add one.',
        );
        break;
      case BiometricResult.lockout:
        _showSnackBar('Too many attempts. Please use your master password.');
        break;
      default:
        _showSnackBar('Authentication failed. Please try again.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.darkTheme.colorScheme.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const SizedBox.shrink(),
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.darkTheme.colorScheme.primary,
                          AppTheme.darkTheme.colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 16,
                      color: Color(0xFF100069),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'VaultKey',
                    style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkTheme.colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // Ambient glow
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.darkTheme.colorScheme.primary.withValues(
                    alpha: 0.05,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                  child: const SizedBox(),
                ),
              ),
            ),

            Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome back',
                          style: AppTheme.darkTheme.textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.email ?? 'Signed in user',
                          style: AppTheme.darkTheme.textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme
                                    .darkTheme
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 64),

                        // ── Fingerprint button ─────────────────────────────
                        GestureDetector(
                          onTap: _isAuthenticating ? null : _authenticate,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme
                                  .darkTheme
                                  .colorScheme
                                  .surfaceContainerHigh,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.darkTheme.colorScheme.primary
                                      .withValues(
                                        alpha: _isAuthenticating ? 0.4 : 0.15,
                                      ),
                                  blurRadius: _isAuthenticating ? 40 : 20,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme
                                        .darkTheme
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: _isAuthenticating
                                    ? Padding(
                                        padding: const EdgeInsets.all(32),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppTheme
                                              .darkTheme
                                              .colorScheme
                                              .primary,
                                        ),
                                      )
                                    : Icon(
                                        Icons.fingerprint,
                                        size: 48,
                                        color: AppTheme
                                            .darkTheme
                                            .colorScheme
                                            .primary,
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        Text(
                          _isAuthenticating
                              ? 'VERIFYING...'
                              : 'TOUCH THE FINGERPRINT SENSOR',
                          style: AppTheme.darkTheme.textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme
                                    .darkTheme
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.8),
                                letterSpacing: 2.0,
                              ),
                        ),

                        const SizedBox(height: 80),

                        // Divider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 1,
                              color: AppTheme
                                  .darkTheme
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: AppTheme
                                      .darkTheme
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 1,
                              color: AppTheme
                                  .darkTheme
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => context.go('/master_password'),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                AppTheme.darkTheme.colorScheme.primary,
                            backgroundColor: AppTheme
                                .darkTheme
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.05),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Use Master Password',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .signOut();
                              if (context.mounted) context.go('/sign_in');
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AuthController.messageFromError(error),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.darkTheme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppTheme.darkTheme.colorScheme.outlineVariant
                            .withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 14,
                          color: AppTheme.darkTheme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'END-TO-END ENCRYPTED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: AppTheme
                                .darkTheme
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
