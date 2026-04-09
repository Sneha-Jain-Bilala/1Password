import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(supabaseClientProvider).auth.currentUser;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref);
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  SupabaseClient get _client => _ref.read(supabaseClientProvider);

  Future<bool> hasMasterPassword() async {
    try {
      final row = await _getMasterPasswordRow();
      return row != null;
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException(error.toString());
    }
  }

  Future<void> createMasterPassword(String password) async {
    final sanitizedPassword = password.trim();
    if (sanitizedPassword.isEmpty) {
      throw const AuthException('Master password cannot be empty.');
    }

    try {
      final user = _requireCurrentUser();
      final existing = await _getMasterPasswordRow();
      if (existing != null) {
        throw const AuthException('Master password already exists.');
      }

      final hash = _hashPassword(sanitizedPassword);
      await _insertMasterPassword(userId: user.id, hash: hash);
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException(error.toString());
    }
  }

  Future<bool> verifyMasterPassword(String password) async {
    final sanitizedPassword = password.trim();
    if (sanitizedPassword.isEmpty) {
      return false;
    }

    try {
      final row = await _getMasterPasswordRow();
      if (row == null) {
        throw const AuthException(
          'No master password found. Please create one first.',
        );
      }

      final storedHash = _extractStoredMasterPassword(row);
      if (storedHash == null || storedHash.isEmpty) {
        throw const AuthException('Master password record is invalid.');
      }

      final inputHash = _hashPassword(sanitizedPassword);
      return storedHash == inputHash || storedHash == sanitizedPassword;
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException(error.toString());
    }
  }

  Future<Map<String, dynamic>?> _getMasterPasswordRow() async {
    final user = _requireCurrentUser();
    final userColumnCandidates = ['userId', 'user_id'];

    for (final column in userColumnCandidates) {
      try {
        final response = await _client
            .from('MasterPassword')
            .select('*')
            .eq(column, user.id)
            .maybeSingle();

        if (response == null) {
          continue;
        }

        return Map<String, dynamic>.from(response as Map);
      } on PostgrestException {
        // Try the next user id column naming variant.
      }
    }

    return null;
  }

  Future<void> _insertMasterPassword({
    required String userId,
    required String hash,
  }) async {
    final payloads = <Map<String, dynamic>>[
      {'userId': userId, 'masterpass': hash},
      {'userId': userId, 'password_hash': hash},
      {'user_id': userId, 'masterpass': hash},
      {'user_id': userId, 'password_hash': hash},
    ];

    PostgrestException? lastError;
    for (final payload in payloads) {
      try {
        await _client.from('MasterPassword').insert(payload);
        return;
      } on PostgrestException catch (error) {
        lastError = error;
      }
    }

    if (lastError != null) {
      throw lastError;
    }

    throw const AuthException('Unable to create master password.');
  }

  String? _extractStoredMasterPassword(Map<String, dynamic> row) {
    const keys = [
      'masterpass',
      'password_hash',
      'master_password_hash',
      'master_password',
      'password',
    ];

    for (final key in keys) {
      final value = row[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  User _requireCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Please sign in again.');
    }
    return user;
  }

  String _hashPassword(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }

  Future<bool> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      state = const AsyncData(null);
      return response.session != null;
    } on AuthException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      state = const AsyncData(null);
    } on AuthException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    await _signInWithOAuth(OAuthProvider.google);
  }

  Future<void> signInWithApple() async {
    await _signInWithOAuth(OAuthProvider.apple);
  }

  Future<void> _signInWithOAuth(OAuthProvider provider) async {
    state = const AsyncLoading();
    try {
      final launched = await _client.auth.signInWithOAuth(provider);
      if (!launched) {
        throw const AuthException('Could not start OAuth sign in.');
      }
      state = const AsyncData(null);
    } on AuthException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _client.auth.signOut();
      state = const AsyncData(null);
    } on AuthException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  static String messageFromError(Object error) {
    if (error is AuthException) {
      return error.message;
    }
    if (error is PostgrestException) {
      return error.message;
    }
    return 'Authentication failed. Please try again.';
  }

  bool get supportsAppleSignIn {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }
}
