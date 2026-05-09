import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../backend/activity_notifier.dart';
import '../backend/activity_item.dart';
import '../widgets/app_card.dart';

class ViewAllActivitiesScreen extends ConsumerWidget {
  const ViewAllActivitiesScreen({super.key});

  /// Get color for activity type
  Color? _getActivityColor(ActivityType activityType, ThemeData theme) {
    final typeString = activityType.toString();

    // Green for additions
    if (typeString.contains('Added') ||
        typeString.contains('Favoured') ||
        typeString.contains('Completed')) {
      return theme.colorScheme.secondary;
    }

    // Blue for updates
    if (typeString.contains('Updated')) {
      return theme.colorScheme.primary;
    }

    // Red for deletions/errors
    if (typeString.contains('Deleted') || typeString.contains('Failed')) {
      return theme.colorScheme.error;
    }

    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activities = ref.watch(activityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Activities',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: activities.isEmpty
          ? _buildEmptyState(context, theme)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildActivityCard(context, activity, theme),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No activities yet',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your vault activities will appear here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    ActivityItem activity,
    ThemeData theme,
  ) {
    final acColor = _getActivityColor(activity.type, theme);
    final timeAgo = activity.getTimeAgo();
    final subtitle = activity.itemType == null
        ? activity.type.label
        : '${activity.type.label} • ${activity.itemType}';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Activity Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  acColor?.withValues(alpha: 0.15) ??
                  theme.colorScheme.surfaceContainerHigh,
            ),
            child: Icon(
              activity.type.icon,
              size: 24,
              color: acColor ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),

          // Activity Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (activity.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    activity.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Timestamp
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeAgo,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              // Show highlighted badge for important activities
              if (activity.isHighlighted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        acColor?.withValues(alpha: 0.2) ??
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Important',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: acColor ?? theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
