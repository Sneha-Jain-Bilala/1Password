import 'package:flutter/material.dart';

class AutofillPromptScreen extends StatelessWidget {
  const AutofillPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Autofill to…', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Select a credential to autofill into the current app.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              // Placeholder entry
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: theme.colorScheme.surfaceContainerHigh,
                leading: CircleAvatar(backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15), child: Text('GH', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
                title: const Text('GitHub', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('dev_alex@example.com'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
