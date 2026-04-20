import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reactive provider that updates whenever auth state changes
final userDisplayNameProvider = StreamProvider<String>((ref) {
  final supabase = Supabase.instance.client;

  return supabase.auth.onAuthStateChange.map((event) {
    final user = event.session?.user;

    if (user == null) return 'User';

    // Check metadata
    final meta = user.userMetadata;
    if (meta != null) {
      final name = meta['name'] ?? meta['full_name'] ?? meta['username'];
      if (name != null && name.toString().isNotEmpty) {
        return name.toString().split(' ').first;
      }
    }

    // fallback from email
    final email = user.email ?? '';
    final prefix = email.split('@').first;
    if (prefix.isNotEmpty) {
      final cleaned = prefix.replaceAll(RegExp(r'[._\\-]'), ' ');
      return cleaned.split(' ').first.capitalize();
    }

    return 'User';
  });
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
