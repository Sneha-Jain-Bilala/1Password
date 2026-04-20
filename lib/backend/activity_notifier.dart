import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'activity_item.dart';
import 'activity_repository.dart';

part 'activity_notifier.g.dart';

// ─── Repository provider (injectable / swappable) ───────────────────
@riverpod
ActivityRepository activityRepository(Ref ref) {
  return InMemoryActivityRepository();
  // Future: return HiveActivityRepository() or SupabaseActivityRepository()
}

// ─── Notifier — the single source of truth for activities ──────────
@riverpod
class ActivityNotifier extends _$ActivityNotifier {
  late ActivityRepository _repo;

  @override
  List<ActivityItem> build() {
    // Initialize the repository and load initial activities
    _repo = ref.watch(activityRepositoryProvider);
    return _repo.getRecent();
  }

  /// Log a new activity.
  Future<ActivityItem> logActivity({
    required ActivityType type,
    required String itemName,
    String? itemType,
    String? description,
    bool isHighlighted = false,
  }) async {
    final activity = ActivityItem(
      id: const Uuid().v4(),
      type: type,
      itemName: itemName,
      itemType: itemType,
      description: description,
      timestamp: DateTime.now(),
      isHighlighted: isHighlighted,
    );

    await _repo.save(activity);
    state = _repo.getRecent();
    return activity;
  }

  /// Delete an activity by ID.
  Future<void> deleteActivity(String id) async {
    await _repo.delete(id);
    state = _repo.getRecent();
  }

  /// Clear all activities.
  Future<void> clearAllActivities() async {
    await _repo.clearAll();
    state = [];
  }

  /// Get top N activities (most recent first).
  List<ActivityItem> getTop(int count) => state.take(count).toList();

  /// Get the 5 most recent activities for dashboard display.
  List<ActivityItem> get recentTop5 => getTop(5);

  /// Get activities for a specific item.
  List<ActivityItem> getForItem(String itemName) => state
      .where((a) => a.itemName.toLowerCase() == itemName.toLowerCase())
      .toList();

  /// Get activities of a specific type.
  List<ActivityItem> getByType(ActivityType type) =>
      state.where((a) => a.type == type).toList();

  /// Get all activities sorted by timestamp.
  List<ActivityItem> getAllSorted() =>
      [...state]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
}
