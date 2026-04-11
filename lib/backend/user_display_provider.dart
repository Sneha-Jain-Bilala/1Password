// lib/backend/user_display_provider.dart
//
// Provides the display name for the currently signed-in user.
// Reads from Supabase user_metadata (set during sign-up).
// Falls back to the email prefix if no display name is stored.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userDisplayNameProvider = Provider<String>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return 'User';

  // Check user_metadata for a 'name' or 'full_name' field (set at sign-up)
  final meta = user.userMetadata;
  if (meta != null) {
    final name = meta['name'] ?? meta['full_name'] ?? meta['username'];
    if (name != null && name.toString().isNotEmpty) {
      return name.toString().split(' ').first; // first name only
    }
  }

  // Fallback: derive name from email (e.g. "alex.v@gmail.com" → "Alex")
  final email = user.email ?? '';
  final prefix = email.split('@').first;
  if (prefix.isNotEmpty) {
    final cleaned = prefix.replaceAll(RegExp(r'[._\-]'), ' ');
    return cleaned.split(' ').first.capitalize();
  }

  return 'User';
});

/// Time-aware greeting string ("Good Morning", "Good Afternoon", etc.)
String dynamicGreeting() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return 'Good Morning';
  if (hour >= 12 && hour < 17) return 'Good Afternoon';
  if (hour >= 17 && hour < 21) return 'Good Evening';
  return 'Good Night';
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
