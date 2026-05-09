// lib/screens/profile_screen.dart
// Repaired Profile screen — compact, valid, and styled.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../backend/user_display_provider.dart';
import '../backend/vault_notifier.dart';
import '../backend/vault_item.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = ref.watch(userDisplayNameProvider).value ?? 'User';
    final vaultItems = ref.watch(vaultProvider);

    final email = user?.email ?? '';
    final createdAt = user?.createdAt;
    final memberSince = createdAt != null
      ? _formatDate(DateTime.parse(createdAt))
        : '—';
    final lastLogin = _formatNullableDate(user?.lastSignInAt);
    final isVerified = user?.emailConfirmedAt != null;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    final totalPasswords = vaultItems
        .where((item) => item.type == VaultItemType.login)
        .length;
    final weakCount = _countWeakPasswords(vaultItems);
    final reusedCount = _countReusedPasswords(vaultItems);
    const breachAlerts = 0; // Placeholder until breach monitoring is wired.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // decorative circles
          Positioned(
            top: -80,
            right: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -90,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.06),
              ),
            ),
          ),

          // content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.34),
                          theme.colorScheme.primary.withValues(alpha: 0.12),
                        ],
                      ),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.36,
                        ),
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isVerified
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.error)
                              .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVerified ? Icons.verified : Icons.error_outline,
                          size: 14,
                          color: isVerified
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isVerified
                              ? 'Verified account'
                              : 'Verification pending',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isVerified
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // stats
                Row(
                  children: [
                    Expanded(
                      child: _statPill(
                        context,
                        icon: Icons.calendar_month,
                        label: 'Member since',
                        value: memberSince,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statPill(
                        context,
                        icon: Icons.shield_outlined,
                        label: 'Status',
                        value: isVerified ? 'Secured' : 'Unverified',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),
                Text(
                  'Account details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),

                _infoTile(
                  context,
                  label: 'User ID',
                  value: user?.id ?? '—',
                  icon: Icons.badge_outlined,
                  trailing: IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    color: theme.colorScheme.onSurfaceVariant,
                    tooltip: 'Copy User ID',
                    onPressed: user?.id == null
                        ? null
                        : () async {
                            await Clipboard.setData(
                              ClipboardData(text: user!.id),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User ID copied'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                  ),
                ),

                _infoTile(
                  context,
                  label: 'Email verified',
                  value: isVerified ? 'Yes' : 'No',
                  icon: isVerified
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                ),

                const SizedBox(height: 22),
                Text(
                  'Vault stats',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _statPill(
                        context,
                        icon: Icons.lock_outline,
                        label: 'Total passwords',
                        value: totalPasswords.toString(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statPill(
                        context,
                        icon: Icons.warning_amber_rounded,
                        label: 'Weak / reused',
                        value: '$weakCount / $reusedCount',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _infoTile(
                  context,
                  label: 'Breach alerts',
                  value: breachAlerts == 0
                      ? 'No alerts'
                      : breachAlerts.toString(),
                  icon: breachAlerts == 0
                      ? Icons.shield_outlined
                      : Icons.report_gmailerrorred_outlined,
                ),

                const SizedBox(height: 22),
                Text(
                  'Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),

                _infoTile(
                  context,
                  label: 'Last login',
                  value: lastLogin,
                  icon: Icons.login_rounded,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  // Simple localized-ish formatting: Apr 21, 2026
  return '${_monthShort(dt.month)} ${dt.day}, ${dt.year}';
}

String _formatNullableDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return '—';
  return _formatDate(parsed);
}

int _countWeakPasswords(List<VaultItem> items) {
  int count = 0;
  for (final item in items) {
    if (item.type != VaultItemType.login) continue;
    final pass = item.password ?? '';
    if (pass.isEmpty) continue;

    final hasLower = RegExp(r'[a-z]').hasMatch(pass);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pass);
    final hasDigit = RegExp(r'\d').hasMatch(pass);
    final hasSpecial = RegExp(r'[^a-zA-Z0-9]').hasMatch(pass);
    final typeCount =
        (hasLower ? 1 : 0) +
        (hasUpper ? 1 : 0) +
        (hasDigit ? 1 : 0) +
        (hasSpecial ? 1 : 0);

    if (pass.length < 8 || typeCount < 3) {
      count += 1;
    }
  }
  return count;
}

int _countReusedPasswords(List<VaultItem> items) {
  final seen = <String, int>{};
  for (final item in items) {
    if (item.type != VaultItemType.login) continue;
    final pass = item.password ?? '';
    if (pass.isEmpty) continue;
    seen[pass] = (seen[pass] ?? 0) + 1;
  }

  int reused = 0;
  for (final entry in seen.entries) {
    if (entry.value > 1) {
      reused += entry.value;
    }
  }
  return reused;
}

String _monthShort(int m) {
  const names = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final monthIndex = m.clamp(1, 12).toInt();
  return names[monthIndex];
}

Widget _statPill(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
}) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

Widget _infoTile(
  BuildContext context, {
  required String label,
  required String value,
  required IconData icon,
  Widget? trailing,
}) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    ),
  );
}
