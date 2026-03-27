import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  double _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  String _generated = '';

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    String chars = '';
    if (_includeUppercase) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_includeLowercase) chars += 'abcdefghijklmnopqrstuvwxyz';
    if (_includeNumbers) chars += '0123456789';
    if (_includeSymbols) chars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    if (chars.isEmpty) chars = 'abcdefghijklmnopqrstuvwxyz';
    final rng = Random.secure();
    setState(() {
      _generated = List.generate(_length.toInt(), (i) => chars[rng.nextInt(chars.length)]).join();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Password Generator')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _generated,
                    style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'monospace', letterSpacing: 2),
                  ),
                ),
                IconButton(
                  onPressed: _generate,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _generated));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                  },
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Length: ${_length.toInt()}', style: theme.textTheme.titleMedium),
          Slider(value: _length, min: 8, max: 64, divisions: 56, onChanged: (v) { setState(() => _length = v); _generate(); }),
          const SizedBox(height: 12),
          SwitchListTile(title: const Text('Uppercase'), value: _includeUppercase, onChanged: (v) { setState(() => _includeUppercase = v); _generate(); }),
          SwitchListTile(title: const Text('Lowercase'), value: _includeLowercase, onChanged: (v) { setState(() => _includeLowercase = v); _generate(); }),
          SwitchListTile(title: const Text('Numbers'), value: _includeNumbers, onChanged: (v) { setState(() => _includeNumbers = v); _generate(); }),
          SwitchListTile(title: const Text('Symbols'), value: _includeSymbols, onChanged: (v) { setState(() => _includeSymbols = v); _generate(); }),
        ],
      ),
    );
  }
}
