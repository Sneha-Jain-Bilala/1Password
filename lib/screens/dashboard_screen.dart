// lib/screens/dashboard_screen.dart
//
// Changes from original:
//  • Feature 1 — PlatformIcon widget replaces the hardcoded Icons.language globe.
//  • Feature 2 — chevron_right button triggers BiometricAuthService before
//                navigating; shows a SnackBar on failure/cancellation.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/platform_icon_service.dart'; // Feature 1
import '../services/biometric_auth_service.dart'; // Feature 2
import '../widgets/app_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ── Feature 2: authenticate then navigate ─────────────────────────────────
  Future<void> _onItemTap(BuildContext context, String platformName) async {
    final result = await BiometricAuthService.authenticate(
      reason: 'Verify your identity to view "$platformName" password',
    );

    if (!context.mounted) return;

    if (result == BiometricResult.success) {
      // Replace with your real route + any extra data you need to pass
      context.push('/item_detail', extra: platformName);
    } else {
      final message = BiometricAuthService.errorMessage(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.fingerprint, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHigh,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.person, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Good morning,',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Alex 👋',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? const Color(0xFFC4C0FF)
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
       
      ),
      
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // ── Health Score Hero Card ──────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 50,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -48,
                    top: -48,
                    child: Container(
                      width: 192,
                      height: 192,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'VAULT STATUS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                      color: theme.colorScheme.onPrimary
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Password Health Score',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.onPrimary,
                                          fontWeight: FontWeight.w800,
                                          height: 1.1,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Your security is exceptional this month.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimary
                                          .withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Circular score
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: Stack(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: CircularProgressIndicator(
                                        value: 0.92,
                                        strokeWidth: 8,
                                        color: Colors.white,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '92',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'SOLID',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  size: 16,
                                  color: theme.colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '248 Passwords Encrypted',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.15,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text('Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Quick Access ────────────────────────────────────────────────
            Text(
              'QUICK ACCESS',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              primary: false,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Row(
                children: [
                  _buildQuickAccessPill(context, Icons.history, 'Recent', true),
                  const SizedBox(width: 12),
                  _buildQuickAccessPill(
                    context,
                    Icons.star,
                    'Favourites',
                    false,
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAccessPill(
                    context,
                    Icons.gpp_maybe,
                    'Weak Passwords',
                    false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Recent Activity ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT ACTIVITY',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'View All',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Activity items ──────────────────────────────────────────────
            // Feature 1 + Feature 2 are both applied inside _buildRecentActivityItem
            _buildRecentActivityItem(
              context,
              'Netflix',
              'alex.v•••••••••',
              true,
            ),
            const SizedBox(height: 12),
            _buildRecentActivityItem(
              context,
              'GitHub',
              'dev_alex••••••••',
              true,
            ),
            const SizedBox(height: 12),
            _buildRecentActivityItem(
              context,
              'Binance Vault',
              'crypto_h••••••••',
              false,
            ),
            const SizedBox(height: 12),
            _buildRecentActivityItem(
              context,
              'Dribbble Pro',
              'pixel_per••••••••',
              true,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ── Quick access pill (unchanged) ─────────────────────────────────────────

  Widget _buildQuickAccessPill(
    BuildContext context,
    IconData icon,
    String label,
    bool isPrimary,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isPrimary
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isPrimary
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPrimary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent activity item — Feature 1 + Feature 2 applied here ─────────────

  Widget _buildRecentActivityItem(
    BuildContext context,
    String title,
    String subtitle,
    bool is2FA,
  ) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // ── Feature 1: PlatformIcon replaces hardcoded Icons.language ──
          PlatformIcon(platformName: title, size: 48),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: is2FA
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.outlineVariant,
                        boxShadow: is2FA
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.secondary.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Copy button (unchanged)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.copy, size: 20),
            color: theme.colorScheme.onSurfaceVariant,
          ),

          // ── Feature 2: Biometric auth before navigation ─────────────────
          IconButton(
            onPressed: () => _onItemTap(context, title),
            icon: const Icon(Icons.chevron_right, size: 24),
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
