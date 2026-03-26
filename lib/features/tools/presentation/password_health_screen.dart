import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PasswordHealthScreen extends StatelessWidget {
  const PasswordHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? const Color(0xFFC4C0FF) : theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.surfaceContainerHigh),
              child: const Icon(Icons.person, size: 20),
            ),
            const SizedBox(width: 12),
            Text('VaultKey', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: isDark ? const Color(0xFFC4C0FF) : theme.colorScheme.primary, letterSpacing: -1.0)),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            Text('Password Health', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1)),
            const SizedBox(height: 8),
            Text('Real-time analysis of your digital security perimeter.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7))),
            const SizedBox(height: 32),
            
            // Hero Score Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(32)),
              child: Column(
                children: [
                  SizedBox(
                    width: 180, height: 180,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CircularProgressIndicator(
                            value: 0.85,
                            strokeWidth: 12,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            color: theme.colorScheme.secondary,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('85', style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
                              Text('STRONG', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your vault health is better than 92% of users. Resolve 5 issues to reach "Impenetrable" status.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Bento Chips
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildStatChip(context, '3 Weak', 'Action Required', theme.colorScheme.error),
                _buildStatChip(context, '5 Old', 'Change Advised', theme.colorScheme.tertiaryContainer),
                _buildStatChip(context, '2 Reused', 'Security Risk', theme.colorScheme.primaryContainer),
                _buildStatChip(context, '0 Breached', 'All Clear', theme.colorScheme.secondary),
              ],
            ),
            
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Security Vulnerabilities', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('VIEW ALL', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildIssueItem(context, Icons.public, 'Netflix', 'Weak Password', theme.colorScheme.error),
            const SizedBox(height: 12),
            _buildIssueItem(context, Icons.work, 'Slack', 'Reused (2)', theme.colorScheme.primaryContainer),
            const SizedBox(height: 12),
            _buildIssueItem(context, Icons.shopping_cart, 'Amazon', 'Old Password', theme.colorScheme.tertiaryContainer),
            
            const SizedBox(height: 48),
            // Pro Tip Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(colors: [theme.colorScheme.primary.withOpacity(0.1), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VaultKey Pro Tip', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    'Users who rotate passwords every 90 days reduce breach risk by up to 65%. Turn on auto-rotation for supported sites.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Enable Auto-Rotate', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.4), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold, height: 1.0)),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9, color: Theme.of(context).colorScheme.outline, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildIssueItem(BuildContext context, IconData icon, String title, String tagLabel, Color tagColor) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: theme.colorScheme.outline),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: tagColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(tagLabel, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: tagColor, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                )
              ],
            ),
          ),
          Row(
            children: [
              Text('Fix Now', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 14, color: theme.colorScheme.secondary),
            ],
          )
        ],
      ),
    );
  }
}
