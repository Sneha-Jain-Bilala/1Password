// lib/backend/encryption_service.dart
//
// AES-256-GCM encryption using a compile-time constant application key.
//
// Storage format: "<base64url_iv>:<base64url_ciphertext+tag>"
//
// The key is derived once (lazily) by SHA-256 hashing the constant passphrase,
// giving a guaranteed 32-byte AES-256 key without any runtime key management.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class EncryptionService {
  EncryptionService._(); // static-only class

  // ── Compile-time constant passphrase ────────────────────────────────────────
  // Change this string to rotate the encryption key for a new app version.
  // All existing data must be re-encrypted if this changes.
  static const String _passphrase = 'VaultKey@AES256#SecureStorage!2025';

  static const int _ivLength = 12;   // GCM standard IV (bytes)
  static const int _tagBits  = 128;  // GCM auth tag length (bits)
  static const String _sep   = ':';

  // ── Derived key (computed once, lazily) ─────────────────────────────────────
  static Uint8List? _cachedKey;

  static Uint8List get _key {
    if (_cachedKey != null) return _cachedKey!;
    // SHA-256 the passphrase → 32 bytes → AES-256 key
    final digest = SHA256Digest();
    final bytes = Uint8List.fromList(utf8.encode(_passphrase));
    _cachedKey = digest.process(bytes);
    return _cachedKey!;
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Encrypts [plaintext]. Returns `"<iv_b64>:<ciphertext+tag_b64>"`.
  static String encrypt(String plaintext) {
    final iv = _randomIv();
    final data = Uint8List.fromList(utf8.encode(plaintext));
    final cipher = _buildCipher(forEncryption: true, iv: iv);
    final encrypted = cipher.process(data);
    return '${base64Url.encode(iv)}$_sep${base64Url.encode(encrypted)}';
  }

  /// Decrypts a value produced by [encrypt].
  /// Returns `null` on any error (corrupted / tampered data).
  static String? decrypt(String value) {
    try {
      final parts = value.split(_sep);
      if (parts.length != 2) return null;
      final iv             = base64Url.decode(parts[0]);
      final ciphertextTag  = base64Url.decode(parts[1]);
      final cipher = _buildCipher(forEncryption: false, iv: iv);
      return utf8.decode(cipher.process(ciphertextTag));
    } catch (_) {
      return null;
    }
  }

  /// Returns `true` if [value] looks like an encrypted string.
  static bool isEncrypted(String? value) {
    if (value == null || value.isEmpty) return false;
    final parts = value.split(_sep);
    if (parts.length != 2) return false;
    try {
      return base64Url.decode(parts[0]).length == _ivLength;
    } catch (_) {
      return false;
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  static Uint8List _randomIv() {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(_ivLength, (_) => rng.nextInt(256)),
    );
  }

  static GCMBlockCipher _buildCipher({
    required bool forEncryption,
    required Uint8List iv,
  }) {
    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      forEncryption,
      AEADParameters(KeyParameter(_key), _tagBits, iv, Uint8List(0)),
    );
    return cipher;
  }
}
