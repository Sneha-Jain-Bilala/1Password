import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  double _length = 20;

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Password Generator', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1)),
              const SizedBox(height: 8),
              Text('Forge unbreakable cryptographic keys for your digital fortress.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7))),
              const SizedBox(height: 32),
              
              // Generated Password Display
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 48, offset: const Offset(0, 16)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'k9#vL2!mP8\$zR4^nT7*qW',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.primary,
                        letterSpacing: 2,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(context, Icons.content_copy, 'COPY'),
                        const SizedBox(width: 16),
                        _buildActionButton(context, Icons.refresh, 'REGENERATE'),
                      ],
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Strength Meter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SECURITY STRENGTH', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text('IMPENETRABLE', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(4, (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                    height: 6,
                    decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.circular(3)),
                  ),
                )),
              ),
              
              const SizedBox(height: 48),
              
              // Controls
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Length', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('${_length.toInt()}', style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'monospace', color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Text('CHARS', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: theme.colorScheme.primary,
                        inactiveTrackColor: theme.colorScheme.outlineVariant,
                        thumbColor: theme.colorScheme.primary,
                        overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _length,
                        min: 8,
                        max: 64,
                        onChanged: (v) => setState(() => _length = v),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Text('INCLUDE CHARACTERS', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildChip(context, 'Uppercase', true),
                  _buildChip(context, 'Lowercase', true),
                  _buildChip(context, 'Numbers', true),
                  _buildChip(context, 'Symbols', true),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Action Buttons
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('Use This Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Generate Again', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onSurfaceVariant)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, bool active) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: active ? theme.colorScheme.primary.withOpacity(0.2) : theme.colorScheme.outlineVariant.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(active ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
