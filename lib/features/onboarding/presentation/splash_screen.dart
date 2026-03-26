import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..forward().then((_) {
            if (mounted) {
              context.go('/onboarding');
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Force dark theme for splash screen as requested
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        body: Stack(
          children: [
            // Ambient Texture Layers
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.darkTheme.colorScheme.primary.withOpacity(
                    0.2,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.darkTheme.colorScheme.secondary.withOpacity(
                    0.1,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Container
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        color:
                            AppTheme.darkTheme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.darkTheme.colorScheme.primary
                                .withOpacity(0.15),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.security,
                          size: 64,
                          color: AppTheme.darkTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'VaultKey',
                      style: AppTheme.darkTheme.textTheme.displayMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your secrets, sealed.',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.darkTheme.colorScheme.onSurfaceVariant
                            .withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 96),
                    // Progress Bar
                    Container(
                      width: 192,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme
                            .darkTheme
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              widthFactor: _controller.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.darkTheme.colorScheme.primary,
                                      AppTheme.darkTheme.colorScheme.secondary,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Security Metadata
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: AppTheme.darkTheme.colorScheme.onSurfaceVariant
                            .withOpacity(0.4),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MILITARY GRADE ENCRYPTION',
                        style: AppTheme.darkTheme.textTheme.labelSmall
                            ?.copyWith(
                              color: AppTheme
                                  .darkTheme
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.4),
                              letterSpacing: 2.0,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v1.0.0-STABLE',
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.onSurfaceVariant
                          .withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
