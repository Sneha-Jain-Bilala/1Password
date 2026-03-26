import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class AutofillPromptScreen extends StatelessWidget {
  const AutofillPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Requires transparent routing in go_router
      body: Stack(
        children: [
          // Simulated background (Gmail)
          Positioned.fill(
            child: Container(
              color: theme.colorScheme.surface, // Base background
              child: Opacity(
                opacity: 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Center(child: Icon(Icons.email, color: Colors.black, size: 32))),
                    const SizedBox(height: 32),
                    Text('Sign in', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    Container(width: 320, height: 56, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)))),
                    Container(width: 320, height: 56, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)))),
                  ],
                ),
              ),
            ),
          ),
          
          // Scrim
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: theme.colorScheme.surfaceContainerLowest.withOpacity(0.6)),
            ),
          ),
          
          // VaultKey Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 12, 32, 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle
                        Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
                        const SizedBox(height: 32),
                        
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer]), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.key, color: theme.colorScheme.onPrimary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text('VaultKey', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: -0.5)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                              children: [
                                const TextSpan(text: 'Sign in to '),
                                TextSpan(text: 'Gmail', style: TextStyle(color: theme.colorScheme.primaryFixedDim)),
                                const TextSpan(text: '?'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Credential Row
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Center(child: Icon(Icons.email, color: Colors.red)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Gmail', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                      Text('a@gmail.com', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.more_horiz, color: theme.colorScheme.outlineVariant),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.pop(),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Use This', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        TextButton(
                          onPressed: () {},
                          child: Text('Other accounts...', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primaryFixedDim, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
