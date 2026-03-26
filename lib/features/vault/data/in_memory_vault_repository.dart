import 'dart:math';
import 'vault_item.dart';
import 'vault_repository.dart';

/// Fully in-memory implementation. Survives the session, resets on restart.
/// Replace with SupabaseVaultRepository when backend is ready — zero UI changes.
class InMemoryVaultRepository implements VaultRepository {
  final List<VaultItem> _items = [];
  final _random = Random();

  String _newId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(99999)}';

  @override
  List<VaultItem> getAll() => List.unmodifiable(_items);

  @override
  List<VaultItem> getByType(VaultItemType type) =>
      _items.where((i) => i.type == type).toList();

  @override
  Future<VaultItem> save(VaultItem item) async {
    // Assign a new ID if none set (id == '')
    final saved = item.id.isEmpty
        ? VaultItem(
            id: _newId(),
            type: item.type,
            serviceName: item.serviceName,
            domain: item.domain,
            serviceColor: item.serviceColor,
            username: item.username,
            password: item.password,
            totpSecret: item.totpSecret,
            notes: item.notes,
            folderName: item.folderName,
            customFields: item.customFields,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        : item;
    _items.add(saved);
    return saved;
  }

  @override
  Future<VaultItem> update(VaultItem item) async {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx == -1) throw StateError('Item ${item.id} not found');
    _items[idx] = item.copyWith();
    return _items[idx];
  }

  @override
  Future<void> trash(String id) async {
    // In a real impl, add a `trashedAt` timestamp. For now: remove from list.
    _items.removeWhere((i) => i.id == id);
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((i) => i.id == id);
  }
}
