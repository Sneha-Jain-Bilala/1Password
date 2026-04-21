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
  @override
  List<VaultItem> build() {
    // Load once initially.
    Future.microtask(_reloadFromSupabase);

    // Reload when auth/session changes (for app restarts/session restore).
    ref.listen(authStateChangesProvider, (_, next) {
      next.whenData((authState) {
        if (authState.event == AuthChangeEvent.signedOut) {
          state = [];
          return;
        }

        Future.microtask(_reloadFromSupabase);
      });
    });

    return [];
  }

  Future<void> _reloadFromSupabase() async {
    final repo = ref.read(vaultRepositoryProvider);
    if (repo is! SupabaseVaultRepository) {
      state = repo.getAll();
      return;
    }

    try {
      await repo.loadAll();
      state = repo.getAll();
    } on AuthException {
      // Session can be briefly unavailable during startup/signout transitions.
      state = [];
    }
  }

  VaultRepository get _repo => ref.read(vaultRepositoryProvider);

  /// Save a new entry and refresh state.
  Future<VaultItem> addItem(VaultItem item) async {
    final saved = await _repo.save(item);
    state = _repo.getAll();

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

  /// Update an existing entry and refresh state.
  Future<void> updateItem(VaultItem item) async {
    await _repo.update(item);
    state = _repo.getAll();

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

  /// Move to trash and refresh state.
  Future<void> trashItem(String id) async {
    // Get the item before trashing to access its serviceName
    final item = state.firstWhere((i) => i.id == id);

    await _repo.trash(id);
    state = _repo.getAll();

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
    state = _repo.getAll();

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
