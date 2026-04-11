// lib/screens/privacy_policy_screen.dart
// Simple in-app privacy policy screen. Replace content as needed.

import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Privacy Policy',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated: January 2025',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ..._sections.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s['title']!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s['body']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _sections = [
    {
      'title': '1. Data We Collect',
      'body':
          'VaultKey stores your passwords and vault items locally on your device using AES-256 encryption. Your master password never leaves your device.',
    },
    {
      'title': '2. How We Use Your Data',
      'body':
          'We use Supabase to sync your encrypted vault across devices. Only encrypted blobs are transmitted — we cannot read your passwords.',
    },
    {
      'title': '3. Biometric Data',
      'body':
          'Biometric authentication (fingerprint / Face ID) is handled entirely by your device OS. VaultKey never stores or accesses raw biometric data.',
    },
    {
      'title': '4. Third-Party Services',
      'body':
          'We use Supabase (supabase.com) for authentication and encrypted storage sync. Please refer to their privacy policy for details.',
    },
    {
      'title': '5. Contact',
      'body':
          'For privacy-related questions, contact us at privacy@vaultkey.app.',
    },
  ];
}
