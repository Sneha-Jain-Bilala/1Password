import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'activity_item.dart';
import 'activity_repository.dart';

part 'activity_notifier.g.dart';

const _kActivityStorageKey = 'vault_activity_items_v1';

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
  bool _initScheduled = false;
  Future<void>? _initFuture;

  @override
  List<ActivityItem> build() {
    // Initialize the repository and load initial activities
    _repo = ref.watch(activityRepositoryProvider);
    if (!_initScheduled) {
      _initScheduled = true;
      Future.microtask(init);
    }
    return _allSortedFromRepo();
  }

  /// Load persisted activities from local storage.
  Future<void> init() async {
    if (_initFuture != null) {
      return _initFuture;
    }

    _initFuture = _loadPersistedActivities();
    return _initFuture;
  }

  Future<void> _loadPersistedActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getStringList(_kActivityStorageKey) ?? const [];

    if (payload.isEmpty) {
      _setStateFromRepoSafely();
      return;
    }

    await _repo.clearAll();
    for (final raw in payload) {
      final parsed = _decodeActivity(raw);
      if (parsed != null) {
        await _repo.save(parsed);
      }
    }

    _setStateFromRepoSafely();
  }

  /// Log a new activity.
  Future<ActivityItem> logActivity({
    required ActivityType type,
    required String itemName,
    String? itemType,
    String? description,
    bool isHighlighted = false,
  }) async {
    await init();

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
    state = _allSortedFromRepo();
    await _persist();
    return activity;
  }

  /// Delete an activity by ID.
  Future<void> deleteActivity(String id) async {
    await init();
    await _repo.delete(id);
    state = _allSortedFromRepo();
    await _persist();
  }

  /// Clear all activities.
  Future<void> clearAllActivities() async {
    await init();
    await _repo.clearAll();
    state = [];
    await _persist();
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

  List<ActivityItem> _allSortedFromRepo() {
    final all = _repo.getAll().toList();
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all;
  }

  void _setStateFromRepoSafely() {
    try {
      state = _allSortedFromRepo();
    } catch (_) {
      // Ignore state updates after disposal.
    }
  }

  String _encodeActivity(ActivityItem activity) {
    return jsonEncode({
      'id': activity.id,
      'type': activity.type.name,
      'itemName': activity.itemName,
      'itemType': activity.itemType,
      'description': activity.description,
      'timestamp': activity.timestamp.toIso8601String(),
      'isHighlighted': activity.isHighlighted,
    });
  }

  ActivityItem? _decodeActivity(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final typeName = decoded['type'] as String?;
      final itemName = (decoded['itemName'] as String?)?.trim();
      if (typeName == null || itemName == null || itemName.isEmpty) {
        return null;
      }

      final timestampRaw = decoded['timestamp'] as String?;
      final timestamp = DateTime.tryParse(timestampRaw ?? '') ?? DateTime.now();

      return ActivityItem(
        id: (decoded['id'] as String?)?.trim().isNotEmpty == true
            ? (decoded['id'] as String)
            : const Uuid().v4(),
        type: ActivityType.values.byName(typeName),
        itemName: itemName,
        itemType: decoded['itemType'] as String?,
        description: decoded['description'] as String?,
        timestamp: timestamp,
        isHighlighted: decoded['isHighlighted'] == true,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _allSortedFromRepo().map(_encodeActivity).toList();
    await prefs.setStringList(_kActivityStorageKey, payload);
  }
}
