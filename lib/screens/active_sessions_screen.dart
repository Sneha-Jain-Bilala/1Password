import 'package:flutter/material.dart';

class ActiveSessionsScreen extends StatelessWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessions = [
      _SessionItem(
        deviceName: 'This device',
        platform: 'Android • M2006C3LII',
        location: 'Now',
        status: 'Current session',
        isCurrent: true,
      ),
      _SessionItem(
        deviceName: 'Chrome on Windows',
        platform: 'Windows 10',
        location: 'Last active 2h ago',
        status: 'Signed in',
      ),
      _SessionItem(
        deviceName: 'Edge on Desktop',
        platform: 'Windows 11',
        location: 'Last active 1d ago',
        status: 'Signed in',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Active Sessions'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            'Manage where your account is signed in',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: 'Current device',
            subtitle: 'You are signed in on this phone right now.',
            icon: Icons.smartphone_rounded,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Sign out all devices',
            subtitle: 'End every other session except this one.',
            icon: Icons.logout_rounded,
            destructive: true,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Text(
            'Recent sessions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...sessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SessionTile(session: session),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionItem {
  final String deviceName;
  final String platform;
  final String location;
  final String status;
  final bool isCurrent;

  const _SessionItem({
    required this.deviceName,
    required this.platform,
    required this.location,
    required this.status,
    this.isCurrent = false,
  });
}

class _SessionTile extends StatelessWidget {
  final _SessionItem session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: session.isCurrent
              ? theme.colorScheme.primary.withValues(alpha: 0.25)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: session.isCurrent
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : theme.colorScheme.surface.withValues(alpha: 0.8),
            ),
            child: Icon(
              session.isCurrent
                  ? Icons.my_location_rounded
                  : Icons.devices_rounded,
              color: session.isCurrent
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.deviceName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (session.isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Current',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  session.platform,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  session.location,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.status,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: session.isCurrent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: destructive
                  ? theme.colorScheme.error.withValues(alpha: 0.2)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
