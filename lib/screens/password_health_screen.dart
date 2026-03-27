import 'package:flutter/material.dart';

class PasswordHealthScreen extends StatelessWidget {
  const PasswordHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Password Health')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Score Hero
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Text('92', style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
                Text('Overall Score', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildHealthRow(context, '3 Weak Passwords', Icons.warning_amber_rounded, Colors.orange),
          const SizedBox(height: 12),
          _buildHealthRow(context, '2 Reused Passwords', Icons.repeat, Colors.redAccent),
          const SizedBox(height: 12),
          _buildHealthRow(context, '248 Strong Passwords', Icons.verified_user, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildHealthRow(BuildContext context, String label, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
