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
import 'main_shell.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'tools_screen.dart';
import 'password_generator_screen.dart';
import 'password_health_screen.dart';
import 'item_detail_screen.dart';
import 'add_password_screen.dart';
import 'browse_screen.dart';
import 'autofill_prompt_screen.dart';
import 'add_note_screen.dart';
import 'add_card_screen.dart';
import 'add_address_screen.dart';

// ✅ NEW SCREENS
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

    // ✅ AUTH REDIRECT (IMPORTANT)
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoggedIn = client.auth.currentSession != null;

      final isPublicRoute =
          location == '/' ||
          location == '/onboarding' ||
          location == '/sign_in' ||
          location == '/sign_up';

      if (!isLoggedIn && !isPublicRoute) {
        return '/sign_in';
      }

      if (isLoggedIn && isPublicRoute) {
        return '/unlock';
      }

      return null;
    },

    routes: [
      // ✅ BASIC ROUTES
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/sign_in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign_up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/unlock',
        builder: (context, state) => const UnlockScreen(),
      ),
      GoRoute(
        path: '/master_password',
        builder: (context, state) => const MasterPasswordScreen(),
      ),

      // ✅ ADD SCREENS
      GoRoute(
        path: '/add_password',
        builder: (context, state) => const AddPasswordScreen(),
      ),
      GoRoute(
        path: '/add_note',
        builder: (context, state) => const AddNoteScreen(),
      ),
      GoRoute(
        path: '/add_card',
        builder: (context, state) => const AddCardScreen(),
      ),
      GoRoute(
        path: '/add_address',
        builder: (context, state) => const AddAddressScreen(),
      ),

      // ✅ FIXED ITEM DETAIL (IMPORTANT)
      GoRoute(
        path: '/item_detail',
        builder: (context, state) {
          final platformName = state.extra as String?;
          return ItemDetailScreen(platformName: platformName ?? '');
        },
      ),

      GoRoute(
        path: '/password_health',
        builder: (context, state) => const PasswordHealthScreen(),
      ),
      GoRoute(
        path: '/password_generator',
        builder: (context, state) => const PasswordGeneratorScreen(),
      ),
      GoRoute(
        path: '/autofill',
        builder: (context, state) => const AutofillPromptScreen(),
      ),

      // ✅ NEW FEATURES (FROM CLAUDE)
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/change_password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/privacy_policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // ✅ BOTTOM NAV
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/browse',
                builder: (context, state) => const BrowseScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tools',
                builder: (context, state) => const ToolsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// ✅ REQUIRED FOR AUTH REFRESH
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
