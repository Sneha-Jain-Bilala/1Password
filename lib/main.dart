// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/app_router.dart';
import 'backend/app_theme.dart';
import 'backend/theme_provider.dart';
import 'backend/biometric_pref_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = 'https://sazvtloxxatqgeurmuys.supabase.co';
  const supabaseAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNhenZ0bG94eGF0cWdldXJtdXlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyNDUzNjksImV4cCI6MjA5MDgyMTM2OX0.34DJDyGBMj-1z4b0AwMXDpqfuthtLF0ehVeYkl5wn18";

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(const _MissingSupabaseConfigApp());
    return;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // ── Load persisted preferences once on startup ─────────────────────────
    // Using ref.read inside build is fine here because we only want to
    // trigger this once (Notifier.init() is idempotent).
    ref.read(themeProvider.notifier).init();
    ref.read(biometricPrefProvider.notifier).init();

    final themeMode = ref.watch(themeProvider);  // ← drives dark/light mode

    return MaterialApp.router(
      title: 'VaultKey',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,             // ← was ThemeMode.system (hardcoded)
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _MissingSupabaseConfigApp extends StatelessWidget {
  const _MissingSupabaseConfigApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaultKey',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.settings_suggest_outlined, size: 44),
                SizedBox(height: 12),
                Text(
                  'Supabase is not configured',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Add your Supabase URL and anon key to main.dart.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
