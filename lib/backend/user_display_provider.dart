import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Extracts a display name from a Supabase [User], or returns 'User'.
String _nameFromUser(User? user) {
  if (user == null) return 'User';

  // Check metadata first
  final meta = user.userMetadata;
  if (meta != null) {
    final name = meta['full_name'] ?? meta['name'] ?? meta['username'];
    if (name != null && name.toString().isNotEmpty) {
      return name.toString().split(' ').first;
    }
  }

  // Fallback: derive from email prefix
  final email = user.email ?? '';
  final prefix = email.split('@').first;
  if (prefix.isNotEmpty) {
    final cleaned = prefix.replaceAll(RegExp(r'[._\-]'), ' ');
    return cleaned.split(' ').first.capitalize();
  }

  return 'User';
}

/// Reactive provider that:
/// 1. Immediately resolves to the current user's name (no loading spinner on
///    cold start / session restore).
/// 2. Updates whenever the Supabase auth state changes.
final userDisplayNameProvider = StreamProvider<String>((ref) async* {
  final supabase = Supabase.instance.client;

  // Emit the current user's name synchronously so the UI never shows '...'
  // after a session has already been restored.
  yield _nameFromUser(supabase.auth.currentUser);

  // Continue emitting on every subsequent auth event.
  await for (final event in supabase.auth.onAuthStateChange) {
    yield _nameFromUser(event.session?.user);
  }
});

/// Greeting function
String dynamicGreeting() {
  final hour = DateTime.now().hour;
  if (hour >= 4 && hour < 12) return 'Good Morning';
  if (hour >= 12 && hour < 16) return 'Good Afternoon';
  if (hour >= 16 && hour < 24) return 'Good Evening';
  return 'Welcome Back'; // 12 AM - 4 AM: warm greeting for night owls
}

/// Capitalize helper
extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
