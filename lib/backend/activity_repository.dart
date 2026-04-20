import 'package:uuid/uuid.dart';
import 'activity_item.dart';

/// Abstract repository for activity management.
abstract class ActivityRepository {
  /// Get all activities.
  List<ActivityItem> getAll();

  /// Get activities sorted by most recent first.
  List<ActivityItem> getRecent({int limit = 100});

  /// Get top N most recent activities.
  List<ActivityItem> getTop(int count);

  /// Save a new activity.
  Future<ActivityItem> save(ActivityItem activity);

  /// Delete an activity by ID.
  Future<void> delete(String id);

  /// Clear all activities.
  Future<void> clearAll();

  /// Get activities for a specific item (by item name).
  List<ActivityItem> getForItem(String itemName);

  /// Get activities of a specific type.
  List<ActivityItem> getByType(ActivityType type);
}

/// In-memory implementation of ActivityRepository.
class InMemoryActivityRepository implements ActivityRepository {
  final List<ActivityItem> _activities = [];

  @override
  List<ActivityItem> getAll() => List.unmodifiable(_activities);

  @override
  List<ActivityItem> getRecent({int limit = 100}) {
    final sorted = [..._activities]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  @override
  List<ActivityItem> getTop(int count) => getRecent(limit: count);

  @override
  Future<ActivityItem> save(ActivityItem activity) async {
    // If no ID provided, generate one
    final toSave = activity.id.isEmpty
        ? activity.copyWith(id: const Uuid().v4())
        : activity;

    // Check if activity already exists
    final index = _activities.indexWhere((a) => a.id == toSave.id);
    if (index >= 0) {
      _activities[index] = toSave;
    } else {
      _activities.add(toSave);
    }

    return toSave;
  }

  @override
  Future<void> delete(String id) async {
    _activities.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> clearAll() async {
    _activities.clear();
  }

  @override
  List<ActivityItem> getForItem(String itemName) {
    return _activities
        .where((a) => a.itemName.toLowerCase() == itemName.toLowerCase())
        .toList();
  }

  @override
  List<ActivityItem> getByType(ActivityType type) {
    return _activities.where((a) => a.type == type).toList();
  }
}
