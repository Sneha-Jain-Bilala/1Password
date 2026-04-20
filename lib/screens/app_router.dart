import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/auth_controller.dart';

import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'unlock_screen.dart';
import 'master_password_screen.dart';
import 'biometric_setup_screen.dart';

import 'main_shell.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'tools_screen.dart';

import 'password_generator_screen.dart';
import 'password_health_screen.dart';
import 'item_detail_screen.dart';
import 'view_all_activities_screen.dart';

import 'add_password_screen.dart';
import 'browse_screen.dart';
import 'autofill_prompt_screen.dart';
import 'add_note_screen.dart';
import 'add_card_screen.dart';
import 'add_address_screen.dart';

import 'profile_screen.dart';
import 'change_password_screen.dart';
import 'privacy_policy_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  final refresh = _GoRouterRefreshStream(client.auth.onAuthStateChange);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,

    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoggedIn = client.auth.currentSession != null;

      final isPublicRoute = const {
        '/',
        '/onboarding',
        '/sign_in',
        '/sign_up',
      }.contains(location);

      final isOnboardingRoute = const {
        '/biometric_setup',
        '/master_password',
      }.contains(location);

      // Not logged in → go to sign_in
      if (!isLoggedIn && !isPublicRoute) {
        return '/sign_in';
      }

      // Logged in → prevent going back to auth screens
      if (isLoggedIn && isPublicRoute) {
        return '/unlock';
      }

      // Allow onboarding flow
      if (isLoggedIn && isOnboardingRoute) {
        return null;
      }

      return null;
    },

    routes: [
      // ── AUTH FLOW ─────────────────────────────
      GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/sign_in', builder: (c, s) => const SignInScreen()),
      GoRoute(path: '/sign_up', builder: (c, s) => const SignUpScreen()),
      GoRoute(path: '/unlock', builder: (c, s) => const UnlockScreen()),

      // ── SECURITY SETUP FLOW ───────────────────
      GoRoute(
        path: '/biometric_setup',
        builder: (c, s) => const BiometricSetupScreen(),
      ),
      GoRoute(
        path: '/master_password',
        builder: (c, s) => const MasterPasswordScreen(),
      ),

      // ── ADD SCREENS ───────────────────────────
      GoRoute(
        path: '/add_password',
        builder: (c, s) => const AddPasswordScreen(),
      ),
      GoRoute(path: '/add_note', builder: (c, s) => const AddNoteScreen()),
      GoRoute(path: '/add_card', builder: (c, s) => const AddCardScreen()),
      GoRoute(
        path: '/add_address',
        builder: (c, s) => const AddAddressScreen(),
      ),

      // ── ITEM DETAIL ───────────────────────────
      GoRoute(
        path: '/item_detail',
        builder: (context, state) {
          final platformName = state.extra as String?;
          return ItemDetailScreen(platformName: platformName ?? '');
        },
      ),

      // ── TOOLS ────────────────────────────────
      GoRoute(
        path: '/password_health',
        builder: (c, s) => const PasswordHealthScreen(),
      ),
      GoRoute(
        path: '/password_generator',
        builder: (c, s) => const PasswordGeneratorScreen(),
      ),
      GoRoute(
        path: '/autofill',
        builder: (c, s) => const AutofillPromptScreen(),
      ),
      GoRoute(
        path: '/activities',
        builder: (c, s) => const ViewAllActivitiesScreen(),
      ),

      // ── SETTINGS EXTRA ───────────────────────
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(
        path: '/change_password',
        builder: (c, s) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/privacy_policy',
        builder: (c, s) => const PrivacyPolicyScreen(),
      ),

      // ── BOTTOM NAVIGATION ────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (c, s) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/browse', builder: (c, s) => const BrowseScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/tools', builder: (c, s) => const ToolsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (c, s) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// ── FIXED CLASS ───────────────────────────────
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
