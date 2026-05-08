import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'encryption_service.dart';
import 'vault_item.dart';
import 'vault_repository.dart';

/// Maps [VaultItem] ↔ the live `vault_items` table.
///
/// Sensitive fields are encrypted with AES-256-GCM before writing to Supabase
/// and decrypted after reading, using the in-memory [_key] derived from the
/// user's master password.
///
/// Encrypted columns: `password_enc`, `totp_secret_enc`, `notes`,
///   `custom_fields` (JSON-serialised then encrypted), `card_cvv_enc`.
///
/// If [_key] is null (vault is locked), data is written/read as plaintext
/// for backward compatibility — this should only happen during onboarding
/// before the master password is set.
class SupabaseVaultRepository implements VaultRepository {
  SupabaseVaultRepository(this._client, this._key);

  final SupabaseClient _client;

  /// AES-256-GCM key (32 bytes), null when the vault is locked.
  final Uint8List? _key;

  // ── In-memory cache (kept in sync after every mutating call) ──────────────
  List<VaultItem> _cache = [];

  // ── Auth helper ──────────────────────────────────────────────────────────
  String _uid() {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Not signed in.');
    return user.id;
  }

  // ── Colour helpers ───────────────────────────────────────────────────────

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

  // ── Type helpers ─────────────────────────────────────────────────────────

  static String _typeToDb(VaultItemType t) => t.name;

  static VaultItemType _typeFromDb(String s) {
    return VaultItemType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => VaultItemType.login,
    );
  }

  // ── Encryption helpers ───────────────────────────────────────────────────

  /// Encrypts [value] if a key is available; otherwise returns [value] as-is.
  String? _enc(String? value) {
    if (value == null || value.isEmpty || _key == null) return value;
    return EncryptionService.encrypt(value, _key!);
  }

  /// Decrypts [value] if it looks encrypted; falls back to plaintext gracefully.
  String? _dec(String? value) {
    if (value == null || value.isEmpty) return value;
    if (_key == null) return value; // locked — return as-is
    if (EncryptionService.isEncrypted(value)) {
      try {
        return EncryptionService.decrypt(value, _key!);
      } catch (_) {
        // Wrong key or corrupted data — return null rather than crash
        return null;
      }
    }
    return value; // legacy plaintext row
  }

  /// Encrypts a Map<String,String> as a JSON string.
  String? _encMap(Map<String, String> map) {
    if (map.isEmpty) return null;
    final json = jsonEncode(map);
    return _enc(json);
  }

  /// Decrypts an encrypted JSON string back to Map<String,String>.
  Map<String, String> _decMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      // Legacy un-encrypted jsonb object
      return Map<String, String>.from(
        raw.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }
    if (raw is String) {
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

  // ── Row serialisation ────────────────────────────────────────────────────

  Map<String, dynamic> _toRow(VaultItem item) {
    // Serialise custom_fields: encrypt the JSON string so it is stored as TEXT
    // when encryption is active, or as a JSON object when locked (no key).
    final customFieldsEncrypted = _key != null && item.customFields.isNotEmpty
        ? _encMap(item.customFields)
        : null;

    // For card items, extract expiry and CVV to their dedicated columns too.
    final isCard = item.type == VaultItemType.card;
    final cardExpiry = isCard ? item.customFields['expiry'] : null;
    final cardCvvRaw = isCard ? item.customFields['cvv'] : null;

    return {
      'user_id': _uid(),
      'item_type': _typeToDb(item.type),
      'service_name': item.serviceName,
      'domain': item.domain,
      'service_color': _colorToHex(item.serviceColor),
      'username': item.username, // intentionally plaintext for search
      // ── encrypted fields ──────────────────────────────────────────
      'password_enc': _enc(item.password),
      'totp_secret_enc': _enc(item.totpSecret),
      'notes': _enc(item.notes),
      // Store encrypted custom_fields as a JSON string in the text-compatible
      // "encrypted" format, or fall back to the JSONB object when no key.
      'custom_fields': customFieldsEncrypted != null
          ? {'_enc': customFieldsEncrypted}
          : item.customFields,
      // ── card-specific columns (card_expiry is not sensitive, CVV is) ──
      if (cardExpiry != null) 'card_expiry': cardExpiry,
      if (cardCvvRaw != null) 'card_cvv_enc': _enc(cardCvvRaw),
      // ─────────────────────────────────────────────────────────────
      'folder_name': item.folderName,
      'is_website': item.isWebsite,
      'is_favourite': item.isFavourite,
      'is_trashed': false,
      'is_encrypted': _key != null,
    };
  }

  VaultItem _fromRow(Map<String, dynamic> row) {
    // Decrypt custom_fields: detect whether it was stored encrypted.
    Map<String, String> customFields;
    final rawCustomFields = row['custom_fields'];
    if (rawCustomFields is Map && rawCustomFields.containsKey('_enc')) {
      // Encrypted format: {"_enc": "<iv:ciphertext>"}
      customFields = _decMap(rawCustomFields['_enc'] as String?);
    } else {
      // Legacy JSONB object (unencrypted)
      customFields = _decMap(rawCustomFields);
    }

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
      customFields: customFields,
      isWebsite: row['is_website'] as bool?,
      isFavourite: row['is_favourite'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── Cache refresh ────────────────────────────────────────────────────────

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
