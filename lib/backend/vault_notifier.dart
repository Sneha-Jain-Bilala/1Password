import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_controller.dart';
import 'vault_item.dart';
import 'vault_repository.dart';
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
    // Load from Supabase on first build (fire-and-forget; UI rebuilds when done)
    Future.microtask(() async {
      final repo = ref.read(vaultRepositoryProvider) as SupabaseVaultRepository;
      await repo.loadAll();
      state = repo.getAll();
    });
    return [];
  }

  VaultRepository get _repo => ref.read(vaultRepositoryProvider);

  /// Save a new entry and refresh state.
  Future<VaultItem> addItem(VaultItem item) async {
    final saved = await _repo.save(item);
    state = _repo.getAll();
    return saved;
  }

  /// Update an existing entry and refresh state.
  Future<void> updateItem(VaultItem item) async {
    await _repo.update(item);
    state = _repo.getAll();
  }

  /// Move to trash and refresh state.
  Future<void> trashItem(String id) async {
    await _repo.trash(id);
    state = _repo.getAll();
  }

  // ── Derived counts (Browse screen reads these) ──────────────────
  int countByType(VaultItemType type) =>
      state.where((i) => i.type == type).length;

  List<VaultItem> byType(VaultItemType type) =>
      state.where((i) => i.type == type).toList();

  /// The 5 most recently added/updated items for the Dashboard.
  List<VaultItem> get recent =>
      [...state]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
}
