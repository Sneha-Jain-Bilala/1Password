// lib/backend/encryption_key_provider.dart
//
// Manages the AES-256 encryption key lifecycle:
//
//   1. After master password entry → derive key via PBKDF2, store in:
//        a) RAM  (StateProvider — immediate access)
//        b) flutter_secure_storage (persists across biometric sessions)
//
//   2. After biometric unlock (key already in RAM from previous session) → no-op.
//      If the app was cold-started and user chose biometric: load the key from
//      secure storage so encryption still works.
//
//   3. On sign-out → wipe both RAM and secure storage.
//
// This guarantees that ALL vault data is ALWAYS written encrypted, regardless
// of which unlock path the user chooses.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The key used in flutter_secure_storage.
const _kSecureKey = 'vaultkey_aes256_key';

/// Singleton secure storage instance.
const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

/// In-RAM encryption key. `null` means the key has not been loaded yet.
///
/// **Do not set this directly.** Use [EncryptionKeyService] instead, which
/// persists the key to secure storage as well.
final encryptionKeyProvider = StateProvider<Uint8List?>((ref) => null);

/// Service for persisting and loading the encryption key.
class EncryptionKeyService {
  EncryptionKeyService._();

  /// Saves [key] to RAM and to flutter_secure_storage.
  /// Call this after a successful master password verification or creation.
  static Future<void> persist(WidgetRef ref, Uint8List key) async {
    ref.read(encryptionKeyProvider.notifier).state = key;
    await _storage.write(
      key: _kSecureKey,
      value: base64.encode(key),
    );
  }

  /// Loads the key from secure storage into RAM.
  /// Call this during biometric unlock when the RAM key is null.
  /// Returns `true` if a key was found and loaded, `false` otherwise.
  static Future<bool> loadFromStorage(WidgetRef ref) async {
    final encoded = await _storage.read(key: _kSecureKey);
    if (encoded == null) return false;
    try {
      final key = base64.decode(encoded);
      if (key.length != 32) return false; // must be 256-bit
      ref.read(encryptionKeyProvider.notifier).state = key;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Wipes the key from both RAM and secure storage.
  /// Call this on sign-out.
  static Future<void> wipe(WidgetRef ref) async {
    ref.read(encryptionKeyProvider.notifier).state = null;
    await _storage.delete(key: _kSecureKey);
  }

  /// Whether the key is currently available in RAM.
  static bool isLoaded(WidgetRef ref) =>
      ref.read(encryptionKeyProvider) != null;
}
