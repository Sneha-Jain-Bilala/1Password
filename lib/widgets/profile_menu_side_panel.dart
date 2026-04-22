import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backend/auth_controller.dart';

/// Shows a compact left-side profile popover near the app bar avatar.
void showProfileMenu(BuildContext context) {
  final topInset = MediaQuery.of(context).padding.top;

  showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.12),
    builder: (dialogContext) {
      return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: 12,
              top: topInset + kToolbarHeight + 6,
              child: const _ProfileMenuCard(),
            ),
          ],
        ),
      );
    },
  );
}

class _ProfileMenuCard extends ConsumerWidget {
  const _ProfileMenuCard();

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;

    final userName =
        user?.userMetadata?['name'] ??
        user?.userMetadata?['full_name'] ??
        user?.email?.split('@').first ??
        'User';
    final userEmail = user?.email ?? 'No email';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 230),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Center(
                      child: Text(
                        userName.toString().isNotEmpty
                            ? userName.toString()[0].toUpperCase()
                            : 'U',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userEmail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ABOUT USER',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _CompactMenuItem(
                icon: Icons.person_outline,
                label: 'Profile Details',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/profile');
                },
              ),
              _CompactMenuItem(
                icon: Icons.devices_rounded,
                label: 'Active Sessions',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/active_sessions');
                },
              ),
              const SizedBox(height: 4),
              _CompactMenuItem(
                icon: Icons.logout_rounded,
                label: 'Logout',
                onTap: () => _signOut(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactMenuItem extends StatelessWidget {
  const _CompactMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        hoverColor: theme.colorScheme.surfaceContainerHighest,
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.onSurface),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
