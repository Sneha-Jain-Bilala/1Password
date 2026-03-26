import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _showFabOptions = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
        flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(color: Colors.transparent))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.secondary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Icon(Icons.terminal, color: theme.colorScheme.secondary, size: 20),
            const SizedBox(width: 8),
            Text('SECURITY_VAULT // GITHUB', style: theme.textTheme.labelSmall?.copyWith(fontFamily: 'monospace', color: theme.colorScheme.secondary, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.colorScheme.secondary, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('SECURE_LINK', style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, fontFamily: 'monospace', color: theme.colorScheme.secondary.withOpacity(0.6))),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Scrollable Cards
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surfaceContainerLow,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Master_Keys_Vault', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 2, color: theme.colorScheme.outline)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: theme.colorScheme.secondary.withOpacity(0.1), border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)), borderRadius: BorderRadius.circular(4)),
                        child: Text('LEVEL_4_AUTH', style: theme.textTheme.labelSmall?.copyWith(fontFamily: 'monospace', fontSize: 9, color: theme.colorScheme.secondary)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildIdentityCard(context),
                        const SizedBox(width: 12),
                        _buildPasswordCard(context),
                        const SizedBox(width: 12),
                        _buildTotpCard(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Detail List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLowest, border: Border.all(color: Colors.white.withOpacity(0.05)), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.code, size: 24), // Placeholder for github icon
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Target_URL', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.outline, letterSpacing: 1)),
                                Text('github.com/login', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.launch, color: theme.colorScheme.primary, size: 20),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailBox(context, 'Meta_Data', 'Primary development repository access. MFA required for all push operations. Registered with work email.'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDetailBox(context, 'Last_Access', '14h ago', isValueBold: false)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDetailBox(context, 'Health', 'OPTIMAL', valueColor: theme.colorScheme.secondary, isValueBold: true)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_showFabOptions) ...[
            _buildFabOption(context, 'Autofill', Icons.bolt, theme.colorScheme.primary),
            const SizedBox(height: 12),
            _buildFabOption(context, 'Share', Icons.share, theme.colorScheme.onSurface),
            const SizedBox(height: 12),
            _buildFabOption(context, 'Edit', Icons.edit, theme.colorScheme.onSurface),
            const SizedBox(height: 12),
            _buildFabOption(context, 'Destroy', Icons.delete_forever, theme.colorScheme.error, isDestructive: true),
            const SizedBox(height: 16),
          ],
          FloatingActionButton(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            onPressed: () {
              setState(() {
                _showFabOptions = !_showFabOptions;
              });
            },
            child: Icon(_showFabOptions ? Icons.close : Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildFabOption(BuildContext context, String label, IconData icon, Color color, {bool isDestructive = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDestructive ? color.withOpacity(0.1) : theme.colorScheme.surfaceContainerHighest,
            border: Border.all(color: isDestructive ? color.withOpacity(0.2) : Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: color)),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDestructive ? theme.colorScheme.errorContainer : (color == theme.colorScheme.primary ? color : theme.colorScheme.surfaceContainerHighest),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: isDestructive ? theme.colorScheme.onErrorContainer : (color == theme.colorScheme.primary ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface)),
        ),
      ],
    );
  }

  Widget _buildDetailBox(BuildContext context, String label, String value, {Color? valueColor, bool isValueBold = false}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLowest, border: Border.all(color: Colors.white.withOpacity(0.05)), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.outline, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: valueColor ?? theme.colorScheme.onSurfaceVariant, fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHigh, border: Border.all(color: Colors.white.withOpacity(0.05)), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Identity_Primary', style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, fontFamily: 'monospace', color: theme.colorScheme.outline, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text('alex.v@nexus-design.io', style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: theme.colorScheme.onSurface), overflow: TextOverflow.ellipsis),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.content_copy, size: 14, color: theme.colorScheme.onSurface),
                const SizedBox(width: 8),
                Text('Copy_Identity', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPasswordCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHigh, border: Border.all(color: Colors.white.withOpacity(0.05)), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Access_Token', style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, fontFamily: 'monospace', color: theme.colorScheme.outline, letterSpacing: 1)),
                  Text('SECURE_98%', style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
                ],
              ),
              const SizedBox(height: 4),
              Text('••••••••••••••', style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', color: theme.colorScheme.secondary, letterSpacing: 2)),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: theme.colorScheme.secondary.withOpacity(0.1), border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.key, size: 14, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text('Copy_Password', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: theme.colorScheme.secondary)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTotpCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.secondary, border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time_Token', style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, fontFamily: 'monospace', color: theme.colorScheme.onSecondary.withOpacity(0.6), letterSpacing: 1)),
              const SizedBox(height: 4),
              Text('482 910', style: theme.textTheme.headlineSmall?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondary, letterSpacing: 4)),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: theme.colorScheme.onSecondary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.content_copy, size: 14, color: theme.colorScheme.onSecondary),
                const SizedBox(width: 8),
                Text('Sync_Copy', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: theme.colorScheme.onSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
