import 'vault_item.dart';

/// Abstract contract. Swap InMemoryVaultRepository → SupabaseVaultRepository
/// without touching any UI code.
abstract class VaultRepository {
  /// Returns all items in the vault.
  List<VaultItem> getAll();

  /// Returns a real-time stream of all items in the vault.
  Stream<List<VaultItem>> watchAll();

  /// Force-reloads all items from the source of truth into the cache.
  Future<void> refresh();

  /// Returns items filtered by type (Browse category).
  List<VaultItem> getByType(VaultItemType type);

  /// Adds a new item; returns the saved item (may have server-assigned fields).
  Future<VaultItem> save(VaultItem item);

  /// Replaces an existing item by [item.id].
  Future<VaultItem> update(VaultItem item);

  /// Moves item to trash (soft-delete).
  Future<void> trash(String id);

  /// Permanently removes an item.
  Future<void> delete(String id);
}
