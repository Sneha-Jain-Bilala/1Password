import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../backend/auth_controller.dart';
import '../backend/app_theme.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final hasSession = await ref
          .read(authControllerProvider.notifier)
          .signUpWithEmail(
            fullName: fullName,
            email: email,
            password: password,
          );

      if (!mounted) return;
      if (hasSession) {
        context.go('/unlock');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created. Verify your email, then sign in.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/sign_in');
      }
    } catch (error) {
      if (!mounted) return;
      _showError(AuthController.messageFromError(error));
    }
  }

  Future<void> _socialSignIn(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      _showError(AuthController.messageFromError(error));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final isBusy = authState.isLoading;

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B1A4F), Color(0xFF181128)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -90,
                left: -100,
                child: _GlowBlob(color: const Color(0xFFFF6BB4).withValues(alpha: 0.2)),
              ),
              Positioned(
                bottom: -120,
                right: -80,
                child: _GlowBlob(color: const Color(0xFF8A75FF).withValues(alpha: 0.18)),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: Container(
                          width: 520,
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Create Account',
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'New user? Sign up to secure your vault across devices.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.78),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _AuthTextField(
                                  controller: _fullNameController,
                                  enabled: !isBusy,
                                  hintText: 'Full name',
                                  keyboardType: TextInputType.name,
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) {
                                    final input = value?.trim() ?? '';
                                    if (input.isEmpty) return 'Full name is required';
                                    if (input.length < 2) {
                                      return 'Please enter your full name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                _AuthTextField(
                                  controller: _emailController,
                                  enabled: !isBusy,
                                  hintText: 'Email address',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.mail_outline,
                                  validator: (value) {
                                    final input = value?.trim() ?? '';
                                    if (input.isEmpty) return 'Email is required';
                                    if (!input.contains('@')) return 'Enter a valid email';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                _AuthTextField(
                                  controller: _passwordController,
                                  enabled: !isBusy,
                                  hintText: 'Password',
                                  obscureText: _obscurePassword,
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    onPressed: isBusy
                                        ? null
                                        : () => setState(
                                              () => _obscurePassword = !_obscurePassword,
                                            ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.white.withValues(alpha: 0.72),
                                    ),
                                  ),
                                  validator: (value) {
                                    if ((value ?? '').isEmpty) {
                                      return 'Password is required';
                                    }
                                    if ((value ?? '').length < 8) {
                                      return 'Use at least 8 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                _AuthTextField(
                                  controller: _confirmPasswordController,
                                  enabled: !isBusy,
                                  hintText: 'Confirm password',
                                  obscureText: _obscureConfirmPassword,
                                  prefixIcon: Icons.verified_outlined,
                                  suffixIcon: IconButton(
                                    onPressed: isBusy
                                        ? null
                                        : () => setState(
                                              () => _obscureConfirmPassword =
                                                  !_obscureConfirmPassword,
                                            ),
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.white.withValues(alpha: 0.72),
                                    ),
                                  ),
                                  validator: (value) {
                                    if ((value ?? '').isEmpty) {
                                      return 'Confirm your password';
                                    }
                                    if ((value ?? '') != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                ElevatedButton(
                                  onPressed: isBusy ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6BB4),
                                    foregroundColor: const Color(0xFF2D1321),
                                    minimumSize: const Size.fromHeight(54),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: isBusy
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 18),
                                _SeparatorLabel(label: 'or sign up with'),
                                const SizedBox(height: 14),
                                _SocialButton(
                                  icon: Icons.g_mobiledata,
                                  label: 'Continue with Google',
                                  onPressed: isBusy
                                      ? null
                                      : () => _socialSignIn(authController.signInWithGoogle),
                                ),
                                if (authController.supportsAppleSignIn)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: _SocialButton(
                                      icon: Icons.apple,
                                      label: 'Continue with Apple',
                                      onPressed: isBusy
                                          ? null
                                          : () => _socialSignIn(authController.signInWithApple),
                                    ),
                                  ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already registered? ',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.72),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: isBusy ? null : () => context.go('/sign_in'),
                                      child: const Text('Sign in instead'),
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String?) validator;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.12),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.56)),
        prefixIcon: Icon(prefixIcon, color: Colors.white.withValues(alpha: 0.74)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6BB4), width: 1.4),
        ),
      ),
    );
  }
}

class _SeparatorLabel extends StatelessWidget {
  const _SeparatorLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: const SizedBox(),
      ),
    );
  }
}
