// lib/screens/settings_screen.dart
//
// Feature 3: Sign Out button added at bottom of settings list.
// Calls Supabase signOut() → clears session → redirects to /sign_in via GoRouter.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../backend/theme_provider.dart';
import '../backend/biometric_pref_provider.dart';
import '../backend/auth_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSyncing = false;
  bool _isSigningOut = false;

  Future<void> _triggerSync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isSyncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cloud_done, color: Colors.white),
            SizedBox(width: 12),
            Text('Vault synced successfully'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Feature 3: Sign Out ───────────────────────────────────────────────────
  Future<void> _signOut() async {
    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? Your vault data will remain encrypted on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSigningOut = true);

    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (!mounted) return;
      // GoRouter's auth redirect will handle navigation to /sign_in
      // but we go explicitly to be safe
      context.go('/sign_in');
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSigningOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthController.messageFromError(error)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final biometricEnabled = ref.watch(biometricPrefProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Security ──────────────────────────────────────────────────
          _buildGroup(context, 'Security', [
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometric Login'),
              subtitle: Text(
                biometricEnabled ? 'Fingerprint / Face ID enabled' : 'Disabled',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: biometricEnabled,
              onChanged: (val) =>
                  ref.read(biometricPrefProvider.notifier).setEnabled(val),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Master Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/change_password'),
            ),
          ]),

          // ── Appearance ─────────────────────────────────────────────────
          _buildGroup(context, 'Appearance', [
            SwitchListTile(
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Dark Mode'),
              value: isDark,
              onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
            ),
          ]),

          // ── Account ────────────────────────────────────────────────────
          _buildGroup(context, 'Account', [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/profile'),
            ),
            ListTile(
              leading: _isSyncing
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : const Icon(Icons.cloud_sync),
              title: const Text('Sync Vault'),
              subtitle: const Text('Last synced: Just now'),
              trailing: _isSyncing ? null : const Icon(Icons.chevron_right),
              onTap: _isSyncing ? null : _triggerSync,
            ),
          ]),

          // ── About ──────────────────────────────────────────────────────
          _buildGroup(context, 'About', [
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('Version 1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/privacy_policy'),
            ),
          ]),

          // ── Feature 3: Sign Out ─────────────────────────────────────────
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _isSigningOut
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, String title, List<Widget> tiles) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...tiles,
        const Divider(),
      ],
    );
  }
}
