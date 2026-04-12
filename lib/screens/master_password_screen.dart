import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../backend/app_theme.dart';
import '../backend/auth_controller.dart';

class MasterPasswordScreen extends ConsumerStatefulWidget {
  const MasterPasswordScreen({super.key});

  @override
  ConsumerState<MasterPasswordScreen> createState() =>
      _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends ConsumerState<MasterPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isChecking = true;
  bool _hasMasterPassword = false;
  bool _isSubmitting = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _loadMasterPasswordState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
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
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _inlineError = AuthController.messageFromError(error);
        _isChecking = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Master Password'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _isChecking
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _hasMasterPassword
                              ? 'Enter Master Password'
                              : 'Create Master Password',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _hasMasterPassword
                              ? 'Master password is already configured. Enter it to unlock your vault.'
                              : 'No master password found. Create one to continue.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          enabled: !_isSubmitting,
                          decoration: const InputDecoration(
                            labelText: 'Master Password',
                          ),
                        ),
                        if (!_hasMasterPassword) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _confirmController,
                            obscureText: true,
                            enabled: !_isSubmitting,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Master Password',
                            ),
                          ),
                        ],
                        if (_inlineError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _inlineError!,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_hasMasterPassword ? 'Unlock' : 'Create'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => context.go('/unlock'),
                          child: const Text('Back'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
