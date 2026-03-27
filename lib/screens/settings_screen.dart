import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildGroup(context, 'Security', [
            ListTile(leading: const Icon(Icons.fingerprint), title: const Text('Biometrics'), trailing: const Icon(Icons.chevron_right)),
            ListTile(leading: const Icon(Icons.lock), title: const Text('Change Master Password'), trailing: const Icon(Icons.chevron_right)),
          ]),
          _buildGroup(context, 'Appearance', [
            SwitchListTile(value: theme.brightness == Brightness.dark, onChanged: (_) {}, title: const Text('Dark Mode')),
          ]),
          _buildGroup(context, 'Account', [
            ListTile(leading: const Icon(Icons.person), title: const Text('Profile'), trailing: const Icon(Icons.chevron_right)),
            ListTile(leading: const Icon(Icons.cloud_sync), title: const Text('Sync'), trailing: const Icon(Icons.chevron_right)),
          ]),
          _buildGroup(context, 'About', [
            ListTile(leading: const Icon(Icons.info), title: const Text('Version 1.0.0')),
            ListTile(leading: const Icon(Icons.privacy_tip), title: const Text('Privacy Policy'), trailing: const Icon(Icons.chevron_right)),
          ]),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, String title, List<Widget> tiles) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
          child: Text(title.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.5, color: theme.colorScheme.onSurfaceVariant)),
        ),
        ...tiles,
        const Divider(),
      ],
    );
  }
}
