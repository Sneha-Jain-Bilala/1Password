import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthException;
import 'auth_controller.dart';
import 'vault_item.dart';
import 'vault_repository.dart';
import 'activity_item.dart';
import 'activity_notifier.dart';
import 'supabase_vault_repository.dart';

part 'vault_notifier.g.dart';

// ─── Repository provider (injectable / swappable) ───────────────────
@riverpod
VaultRepository vaultRepository(Ref ref) {
  return SupabaseVaultRepository(ref.read(supabaseClientProvider));
}

// ─── Notifier — the single source of truth for vault items ──────────
@riverpod
class VaultNotifier extends _$VaultNotifier {
  late VaultRepository _repository;

  @override
  List<VaultItem> build() {
    // Pin the repository instance for the lifetime of this notifier.
    _repository = ref.watch(vaultRepositoryProvider);

    // Reload when auth state changes (sign-in / sign-out).
    ref.listen(authStateChangesProvider, (_, next) {
      next.whenData((authState) {
        if (authState.event == AuthChangeEvent.signedOut) {
          state = [];
          return;
        }
        Future.microtask(_loadFromDb);
      });
    });

    Future.microtask(_loadFromDb);
    return [];
  }

  /// Fetches all vault items directly from the database and updates state.
  Future<void> _loadFromDb() async {
    try {
      await _repository.refresh();
      final items = [..._repository.getAll()];
      state = items;

      // Prune activity log entries that refer to items no longer in the vault.
      final liveNames = items
          .map((i) => i.serviceName.toLowerCase())
          .toSet();
      await ref
          .read(activityNotifierProvider.notifier)
          .pruneForDeletedItems(liveNames);
    } on AuthException {
      state = [];
    } catch (e, st) {
      // Print so it's visible in the Flutter console during development.
      // Do NOT wipe state — keep the last known good list visible.
      // ignore: avoid_print
      print('[VaultNotifier] _loadFromDb error: $e\n$st');
    }
  }

  /// Public method so screens can manually trigger a reload (e.g. pull-to-refresh).
  Future<void> reload() => _loadFromDb();

  VaultRepository get _repo => _repository;

  /// Save a new entry, reload from DB, and update state.
  Future<VaultItem> addItem(VaultItem item) async {
    final saved = await _repo.save(item);
    await _loadFromDb(); // Guaranteed DB fetch — no Realtime dependency

    // Log activity
    final activityType = _getActivityTypeForAdd(item.type);
    await ref
        .read(activityNotifierProvider.notifier)
        .logActivity(
          type: activityType,
          itemName: item.serviceName,
          itemType: item.type.browseLabel,
          isHighlighted: true,
        );

    return saved;
  }

  /// Update an existing entry, reload from DB, and update state.
  Future<void> updateItem(VaultItem item) async {
    await _repo.update(item);
    await _loadFromDb();

    // Log activity
    final activityType = _getActivityTypeForUpdate(item.type);
    await ref
        .read(activityNotifierProvider.notifier)
        .logActivity(
          type: activityType,
          itemName: item.serviceName,
          itemType: item.type.browseLabel,
          isHighlighted: true,
        );
  }

  /// Move to trash, reload from DB, and update state.
  Future<void> trashItem(String id) async {
    final item = state.firstWhere((i) => i.id == id);

    await _repo.trash(id);
    await _loadFromDb();

    // Log activity
    final activityType = _getActivityTypeForDelete(item.type);
    await ref
        .read(activityNotifierProvider.notifier)
        .logActivity(
          type: activityType,
          itemName: item.serviceName,
          itemType: item.type.browseLabel,
          isHighlighted: true,
        );
  }

  // ── Derived counts (Browse screen reads these) ──────────────────
  int countByType(VaultItemType type) =>
      state.where((i) => i.type == type).length;

  List<VaultItem> byType(VaultItemType type) =>
      state.where((i) => i.type == type).toList();

  /// The 5 most recently added/updated items for the Dashboard.
  List<VaultItem> get recent =>
      [...state]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  /// All favourite items sorted by most recently updated.
  List<VaultItem> get favourites =>
      state.where((i) => i.isFavourite).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  /// Update favourite status for a single item.
  Future<void> setFavourite(String id, bool isFavourite) async {
    final index = state.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final current = state[index];
    if (current.isFavourite == isFavourite) return;

    final updated = current.copyWith(isFavourite: isFavourite);
    await _repo.update(updated);
    await _repo.refresh();
    state = [..._repo.getAll()];

    await ref
        .read(activityNotifierProvider.notifier)
        .logActivity(
          type: isFavourite
              ? ActivityType.itemFavourited
              : ActivityType.itemUnfavourited,
          itemName: updated.serviceName,
          itemType: updated.type.browseLabel,
          isHighlighted: true,
        );
  }

  /// Toggle favourite status for a single item.
  Future<void> toggleFavourite(String id) async {
    final index = state.indexWhere((i) => i.id == id);
    if (index == -1) return;
    await setFavourite(id, !state[index].isFavourite);
  }

  // ── Activity type mapping helpers ────────────────────────────────
  ActivityType _getActivityTypeForAdd(VaultItemType type) {
    switch (type) {
      case VaultItemType.login:
        return ActivityType.passwordAdded;
      case VaultItemType.secureNote:
        return ActivityType.noteAdded;
      case VaultItemType.card:
        return ActivityType.cardAdded;
      case VaultItemType.contact:
        return ActivityType.contactAdded;
      case VaultItemType.document:
        return ActivityType.documentAdded;
      case VaultItemType.address:
        return ActivityType.addressAdded;
    }
  }

  ActivityType _getActivityTypeForUpdate(VaultItemType type) {
    switch (type) {
      case VaultItemType.login:
        return ActivityType.passwordUpdated;
      case VaultItemType.secureNote:
        return ActivityType.noteUpdated;
      case VaultItemType.card:
        return ActivityType.cardUpdated;
      case VaultItemType.contact:
        return ActivityType.contactUpdated;
      case VaultItemType.document:
        return ActivityType.documentUpdated;
      case VaultItemType.address:
        return ActivityType.addressUpdated;
    }
  }

  ActivityType _getActivityTypeForDelete(VaultItemType type) {
    switch (type) {
      case VaultItemType.login:
        return ActivityType.passwordDeleted;
      case VaultItemType.secureNote:
        return ActivityType.noteDeleted;
      case VaultItemType.card:
        return ActivityType.cardDeleted;
      case VaultItemType.contact:
        return ActivityType.contactDeleted;
      case VaultItemType.document:
        return ActivityType.documentDeleted;
      case VaultItemType.address:
        return ActivityType.addressDeleted;
    }
  }
}
