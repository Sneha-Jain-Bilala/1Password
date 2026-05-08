// lib/backend/encryption_service.dart
//
// AES-256-GCM encryption with PBKDF2-HMAC-SHA256 key derivation.
//
// Storage format for encrypted values:
//   "<base64url_iv>:<base64url_ciphertext+tag>"
//
// The GCM auth tag (16 bytes) is appended to the ciphertext by pointycastle
// and stored together in the second segment.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class EncryptionService {
  // ── Constants ───────────────────────────────────────────────────────────────
  static const int _keyBits = 256; // AES-256
  static const int _ivLength = 12; // GCM standard IV
  static const int _tagLength = 128; // GCM auth tag length in bits
  static const int _pbkdf2Iterations = 100000;
  static const String _separator = ':';

  // ── Key Derivation ──────────────────────────────────────────────────────────

  /// Derives a 256-bit AES key from [masterPassword] and [userId].
  ///
  /// [userId] acts as a deterministic per-user salt so that two users with
  /// the same master password get different encryption keys.
  static Uint8List deriveKey(String masterPassword, String userId) {
    // PBKDF2 parameters
    final passwordBytes = Uint8List.fromList(utf8.encode(masterPassword));
    // Use a padded/hashed version of userId as the salt (must be ≥ 8 bytes)
    final saltBytes = Uint8List.fromList(
      utf8.encode('vaultkey_salt_$userId'),
    );

    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(
      Pbkdf2Parameters(saltBytes, _pbkdf2Iterations, _keyBits ~/ 8),
    );
    return pbkdf2.process(passwordBytes);
  }

  // ── Encryption ──────────────────────────────────────────────────────────────

  /// Encrypts [plaintext] with AES-256-GCM using [key].
  ///
  /// Returns `"<iv_b64>:<ciphertext+tag_b64>"`.
  static String encrypt(String plaintext, Uint8List key) {
    final iv = _randomIv();
    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));

    final cipher = _buildCipher(forEncryption: true, key: key, iv: iv);
    final ciphertextWithTag = cipher.process(plaintextBytes);

    return '${base64Url.encode(iv)}$_separator${base64Url.encode(ciphertextWithTag)}';
  }

  // ── Decryption ──────────────────────────────────────────────────────────────

  /// Decrypts a value produced by [encrypt].
  ///
  /// Returns the original plaintext, or throws [ArgumentError] if [value] is
  /// not in the expected format, or [InvalidCipherTextException] if the
  /// auth tag fails (tampered/wrong key).
  static String decrypt(String value, Uint8List key) {
    final parts = value.split(_separator);
    if (parts.length != 2) {
      throw ArgumentError('Not an encrypted value (missing separator): $value');
    }

    final iv = base64Url.decode(parts[0]);
    final ciphertextWithTag = base64Url.decode(parts[1]);

    final cipher = _buildCipher(forEncryption: false, key: key, iv: iv);
    final plaintextBytes = cipher.process(ciphertextWithTag);

    return utf8.decode(plaintextBytes);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Returns true if [value] looks like an encrypted string produced by [encrypt].
  static bool isEncrypted(String? value) {
    if (value == null || value.isEmpty) return false;
    final parts = value.split(_separator);
    if (parts.length != 2) return false;
    // Basic sanity: both parts must be valid base64url and non-empty
    try {
      final iv = base64Url.decode(parts[0]);
      return iv.length == _ivLength;
    } catch (_) {
      return false;
    }
  }

  static Uint8List _randomIv() {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(_ivLength, (_) => rng.nextInt(256)),
    );
  }

  static GCMBlockCipher _buildCipher({
    required bool forEncryption,
    required Uint8List key,
    required Uint8List iv,
  }) {
    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      forEncryption,
      AEADParameters(
        KeyParameter(key),
        _tagLength,
        iv,
        Uint8List(0), // no additional authenticated data
      ),
    );
    return cipher;
  }
}
