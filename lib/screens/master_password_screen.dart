import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../backend/app_theme.dart';
import '../backend/app_colors.dart';
import '../backend/auth_controller.dart';

class MasterPasswordScreen extends ConsumerStatefulWidget {
  const MasterPasswordScreen({super.key});

  @override
  ConsumerState<MasterPasswordScreen> createState() =>
      _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends ConsumerState<MasterPasswordScreen>
    with TickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isChecking = true;
  bool _hasMasterPassword = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _inlineError;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _loadMasterPasswordState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterPasswordState() async {
    setState(() {
      _isChecking = true;
      _inlineError = null;
    });

    try {
      final exists = await ref
          .read(authControllerProvider.notifier)
          .hasMasterPassword();
      if (!mounted) {
        return;
      }
      setState(() {
        _hasMasterPassword = exists;
        _isChecking = false;
      });
      _fadeController.forward();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _inlineError = AuthController.messageFromError(error);
        _isChecking = false;
      });
      _fadeController.forward();
    }
  }

  Future<void> _submit() async {
    final authController = ref.read(authControllerProvider.notifier);
    final password = _passwordController.text;

    if (password.trim().isEmpty) {
      setState(() {
        _inlineError = 'Please enter master password.';
      });
      return;
    }

    if (!_hasMasterPassword && password != _confirmController.text) {
      setState(() {
        _inlineError = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _inlineError = null;
    });

    try {
      if (_hasMasterPassword) {
        final isValid = await authController.verifyMasterPassword(password);
        if (!isValid) {
          if (!mounted) {
            return;
          }
          setState(() {
            _inlineError = 'Incorrect master password.';
            _isSubmitting = false;
          });
          return;
        }
      } else {
        await authController.createMasterPassword(password);
      }

      if (!mounted) {
        return;
      }
      context.go('/dashboard');
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _inlineError = AuthController.messageFromError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required bool enabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkSurfaceContainerHigh.withValues(alpha: 0.8),
            AppColors.darkSurfaceContainerLow.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        style: const TextStyle(color: AppColors.darkOnSurface, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.darkOnSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: AppColors.darkOnSurface.withValues(alpha: 0.6),
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.darkSurface,
                AppColors.darkSurfaceContainerLowest,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _isChecking
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.darkPrimary,
                            ),
                          ),
                        )
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Header Section
                                Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.darkPrimary.withValues(
                                          alpha: 0.2,
                                        ),
                                        AppColors.darkSecondary.withValues(
                                          alpha: 0.1,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.darkPrimary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _hasMasterPassword
                                        ? Icons.lock_open_rounded
                                        : Icons.lock_rounded,
                                    size: 64,
                                    color: AppColors.darkPrimary,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Title
                                Text(
                                  _hasMasterPassword
                                      ? 'Welcome Back'
                                      : 'Secure Your Vault',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: AppColors.darkOnSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),

                                // Subtitle
                                Text(
                                  _hasMasterPassword
                                      ? 'Enter your master password to unlock your vault'
                                      : 'Create a strong master password to protect your data',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: AppColors.darkOnSurface
                                            .withValues(alpha: 0.7),
                                        height: 1.5,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 40),

                                // Password Fields
                                _buildPasswordField(
                                  controller: _passwordController,
                                  label: 'Master Password',
                                  obscureText: _obscurePassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  enabled: !_isSubmitting,
                                ),

                                if (!_hasMasterPassword) ...[
                                  const SizedBox(height: 16),
                                  _buildPasswordField(
                                    controller: _confirmController,
                                    label: 'Confirm Master Password',
                                    obscureText: _obscureConfirm,
                                    onToggleVisibility: () {
                                      setState(() {
                                        _obscureConfirm = !_obscureConfirm;
                                      });
                                    },
                                    enabled: !_isSubmitting,
                                  ),
                                ],

                                // Error Message
                                if (_inlineError != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.error.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _inlineError!,
                                            style: TextStyle(
                                              color: AppColors.error,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 32),

                                // Action Button
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.darkPrimary,
                                        AppColors.darkPrimaryContainer,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.darkPrimary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _hasMasterPassword
                                                    ? 'Unlock Vault'
                                                    : 'Create Password',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                _hasMasterPassword
                                                    ? Icons.arrow_forward
                                                    : Icons.shield,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Back Button
                                TextButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () => context.go('/unlock'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.darkOnSurface
                                        .withValues(alpha: 0.7),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_back, size: 18),
                                      SizedBox(width: 8),
                                      Text('Back'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
