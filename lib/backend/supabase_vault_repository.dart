import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'vault_item.dart';
import 'vault_repository.dart';

/// Maps [VaultItem] ↔ the live `vault_items` table.
///
/// Column mapping (schema → dart field):
///   id              → VaultItem.id
///   user_id         → set to auth.uid() on insert; never exposed to UI
///   item_type       → VaultItem.type  (enum name: 'login', 'card', …)
///   service_name    → VaultItem.serviceName
///   domain          → VaultItem.domain
///   service_color   → VaultItem.serviceColor  (stored as '#RRGGBB')
///   username        → VaultItem.username
///   password_enc    → VaultItem.password      (⚠ store encrypted in prod)
///   totp_secret_enc → VaultItem.totpSecret
///   card_expiry     → parsed from VaultItem.notes  ('Expiry: MM/YY')
///   card_cvv_enc    → unused for now (AddCardScreen stores cvv in notes)
///   card_label      → VaultItem.serviceName   (for card type)
///   card_type       → detected from password prefix
///   notes           → VaultItem.notes
///   folder_name     → VaultItem.folderName
///   is_website      → VaultItem.isWebsite
///   is_favourite    → VaultItem.isFavourite
///   is_trashed      → VaultItem soft-delete flag
///   custom_fields   → VaultItem.customFields  (jsonb)
///   created_at      → VaultItem.createdAt
///   updated_at      → VaultItem.updatedAt
class SupabaseVaultRepository implements VaultRepository {
  SupabaseVaultRepository(this._client);

  final SupabaseClient _client;

  // ── In-memory cache (kept in sync after every mutating call) ──────────────
  List<VaultItem> _cache = [];

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _uid() {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Not signed in.');
    return user.id;
  }

  /// Converts a [Color] to '#RRGGBB' hex.
  static String? _colorToHex(Color? color) {
    if (color == null) return null;
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  /// Parses '#RRGGBB' back to [Color].
  static Color? _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    return null;
  }

  /// [VaultItemType] → DB string
  static String _typeToDb(VaultItemType t) => t.name; // 'login', 'card', …

  /// DB string → [VaultItemType]
  static VaultItemType _typeFromDb(String s) {
    return VaultItemType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => VaultItemType.login,
    );
  }

  /// Builds the row map to INSERT or UPDATE.
  Map<String, dynamic> _toRow(VaultItem item) {
    return {
      'user_id': _uid(),
      'item_type': _typeToDb(item.type),
      'service_name': item.serviceName,
      'domain': item.domain,
      'service_color': _colorToHex(item.serviceColor),
      'username': item.username,
      'password_enc': item.password, // TODO: encrypt before storing
      'totp_secret_enc': item.totpSecret,
      'notes': item.notes,
      'folder_name': item.folderName,
      'is_website': item.isWebsite,
      'is_favourite': item.isFavourite,
      'is_trashed': false,
      'custom_fields': item.customFields,
    };
  }

  /// Maps a DB row back to a [VaultItem].
  static VaultItem _fromRow(Map<String, dynamic> row) {
    return VaultItem(
      id: row['id'] as String,
      type: _typeFromDb(row['item_type'] as String),
      serviceName: row['service_name'] as String,
      domain: row['domain'] as String?,
      serviceColor: _hexToColor(row['service_color'] as String?),
      username: row['username'] as String?,
      password: row['password_enc'] as String?,
      totpSecret: row['totp_secret_enc'] as String?,
      notes: row['notes'] as String?,
      folderName: row['folder_name'] as String?,
      customFields: Map<String, String>.from(
        (row['custom_fields'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      ),
      isWebsite: row['is_website'] as bool?,
      isFavourite: row['is_favourite'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── Refresh cache from DB ─────────────────────────────────────────────────

  Future<void> _refreshCache() async {
    final rows = await _client
        .from('vault_items')
        .select()
        .eq('user_id', _uid())
        .eq('is_trashed', false)
        .order('updated_at', ascending: false);

    _cache = (rows as List)
        .map((r) => _fromRow(r as Map<String, dynamic>))
        .toList();
  }

  // ── VaultRepository interface ─────────────────────────────────────────────

  @override
  List<VaultItem> getAll() => List.unmodifiable(_cache);

  @override
  List<VaultItem> getByType(VaultItemType type) =>
      _cache.where((i) => i.type == type).toList();

  @override
  Future<VaultItem> save(VaultItem item) async {
    final row = _toRow(item);
    final response = await _client
        .from('vault_items')
        .insert(row)
        .select()
        .single();

    final saved = _fromRow(response);
    await _refreshCache();
    return saved;
  }

  @override
  Future<VaultItem> update(VaultItem item) async {
    final row = _toRow(item)..remove('user_id'); // can't update user_id
    await _client
        .from('vault_items')
        .update(row)
        .eq('id', item.id)
        .eq('user_id', _uid());

    await _refreshCache();
    return _cache.firstWhere((i) => i.id == item.id);
  }

  @override
  Future<void> trash(String id) async {
    await _client
        .from('vault_items')
        .update({'is_trashed': true})
        .eq('id', id)
        .eq('user_id', _uid());

    _cache.removeWhere((i) => i.id == id);
  }

  @override
  Future<void> delete(String id) async {
    await _client
        .from('vault_items')
        .delete()
        .eq('id', id)
        .eq('user_id', _uid());

    _cache.removeWhere((i) => i.id == id);
  }

  /// Call once after sign-in to pre-populate the cache.
  Future<void> loadAll() => _refreshCache();
}
