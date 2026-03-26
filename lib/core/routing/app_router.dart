import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/unlock_screen.dart';
import 'main_shell.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/tools/presentation/tools_screen.dart';
import '../../features/tools/presentation/password_generator_screen.dart';
import '../../features/tools/presentation/password_health_screen.dart';
import '../../features/vault/presentation/item_detail_screen.dart';
import '../../features/vault/presentation/add_password_screen.dart';
import '../../features/vault/presentation/browse_screen.dart';
import '../../features/autofill/presentation/autofill_prompt_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/unlock',
        builder: (context, state) => const UnlockScreen(),
      ),
      GoRoute(
        path: '/add_password',
        builder: (context, state) => const AddPasswordScreen(),
      ),
      GoRoute(
        path: '/item_detail',
        builder: (context, state) => const ItemDetailScreen(),
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
      )
    ],
  );
}
