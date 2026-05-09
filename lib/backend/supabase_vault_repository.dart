import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'encryption_service.dart';
import 'vault_item.dart';
import 'vault_repository.dart';

/// Maps [VaultItem] ↔ the live `vault_items` Supabase table.
///
/// All sensitive fields are **always** encrypted with AES-256-GCM before being
/// written to Supabase, and decrypted when read back.
///
/// Encrypted columns: `password_enc`, `totp_secret_enc`, `notes`,
///   `custom_fields` (JSON-serialised then encrypted), `card_cvv_enc`.
///
/// Plaintext columns (needed for search/browse): `username`, `service_name`,
///   `domain`, `card_expiry`.
class SupabaseVaultRepository implements VaultRepository {
  SupabaseVaultRepository(this._client);

  final SupabaseClient _client;

  // ── In-memory cache (kept in sync after every mutating call) ──────────────
  List<VaultItem> _cache = [];

  // ── Auth helper ───────────────────────────────────────────────────────────
  String _uid() {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Not signed in.');
    return user.id;
  }

  // ── Colour helpers ────────────────────────────────────────────────────────

  static String? _colorToHex(Color? color) {
    if (color == null) return null;
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static Color? _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    return null;
  }

  // ── Type helpers ──────────────────────────────────────────────────────────

  static String _typeToDb(VaultItemType t) => t.name;

  static VaultItemType _typeFromDb(String s) {
    return VaultItemType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => VaultItemType.login,
    );
  }

  // ── Encryption helpers ────────────────────────────────────────────────────

  /// Encrypts [value]; returns null if value is null or empty.
  static String? _enc(String? value) {
    if (value == null || value.isEmpty) return null;
    return EncryptionService.encrypt(value);
  }

  /// Decrypts [value] if it is in encrypted format; returns plaintext otherwise
  /// (graceful handling of legacy unencrypted rows).
  static String? _dec(String? value) {
    if (value == null || value.isEmpty) return value;
    if (EncryptionService.isEncrypted(value)) {
      return EncryptionService.decrypt(value); // null on corrupted data
    }
    return value; // legacy plaintext row — pass through as-is
  }

  /// Encrypts a Map<String,String> as an encrypted JSON string.
  static String? _encMap(Map<String, String> map) {
    if (map.isEmpty) return null;
    return EncryptionService.encrypt(jsonEncode(map));
  }

  /// Decrypts a raw DB value back to Map<String,String>.
  /// Handles three cases: encrypted string, legacy JSONB object, null.
  static Map<String, String> _decMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      // Check for our encrypted-envelope format: {"_enc": "<iv:ct>"}
      if (raw.containsKey('_enc')) {
        final decrypted = _dec(raw['_enc'] as String?);
        if (decrypted == null) return {};
        try {
          final decoded = jsonDecode(decrypted) as Map<String, dynamic>;
          return decoded.map((k, v) => MapEntry(k, v.toString()));
        } catch (_) {
          return {};
        }
      }
      // Legacy unencrypted JSONB object
      return Map<String, String>.from(
        raw.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }
    if (raw is String) {
      // Encrypted string (older format without the _enc envelope)
      final decrypted = _dec(raw);
      if (decrypted == null) return {};
      try {
        final decoded = jsonDecode(decrypted) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  // ── Row serialisation ─────────────────────────────────────────────────────

  Map<String, dynamic> _toRow(VaultItem item) {
    // Card-specific structured fields
    final isCard = item.type == VaultItemType.card;
    final cardExpiry = isCard ? item.customFields['expiry'] : null;
    final cardCvvRaw = isCard ? item.customFields['cvv'] : null;

    // Encrypt custom_fields as a JSON blob wrapped in an _enc envelope
    final encCustomFields = item.customFields.isNotEmpty
        ? {'_enc': _encMap(item.customFields)}
        : <String, dynamic>{};

    return {
      'user_id': _uid(),
      'item_type': _typeToDb(item.type),
      'service_name': item.serviceName,
      'domain': item.domain,
      'service_color': _colorToHex(item.serviceColor),
      'username': item.username, // intentionally plaintext for search/display
      // ── always-encrypted fields ─────────────────────────────────────────
      'password_enc': _enc(item.password),
      'totp_secret_enc': _enc(item.totpSecret),
      'notes': _enc(item.notes),
      'custom_fields': encCustomFields,
      // ── card-specific columns ──────────────────────────────────────────
      if (cardExpiry != null) 'card_expiry': cardExpiry, // not sensitive
      if (cardCvvRaw != null) 'card_cvv_enc': _enc(cardCvvRaw),
      // ──────────────────────────────────────────────────────────────────
      'folder_name': item.folderName,
      'is_website': item.isWebsite,
      'is_favourite': item.isFavourite,
      'is_trashed': false,
      'is_encrypted': true, // always encrypted now
    };
  }

  VaultItem _fromRow(Map<String, dynamic> row) {
    return VaultItem(
      id: row['id'] as String,
      type: _typeFromDb(row['item_type'] as String),
      serviceName: row['service_name'] as String,
      domain: row['domain'] as String?,
      serviceColor: _hexToColor(row['service_color'] as String?),
      username: row['username'] as String?,
      password: _dec(row['password_enc'] as String?),
      totpSecret: _dec(row['totp_secret_enc'] as String?),
      notes: _dec(row['notes'] as String?),
      folderName: row['folder_name'] as String?,
      customFields: _decMap(row['custom_fields']),
      isWebsite: row['is_website'] as bool?,
      isFavourite: row['is_favourite'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── Cache refresh ─────────────────────────────────────────────────────────

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
