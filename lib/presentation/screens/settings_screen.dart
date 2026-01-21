import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_settings.dart';
import '../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _currency = 'BDT';
  String _theme = 'system';
  String _startOfWeek = 'sat';

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsRepositoryProvider).getSettings();
    _currency = settings.currency;
    _theme = settings.theme;
    _startOfWeek = settings.startOfWeek;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _currency,
            decoration: const InputDecoration(
              labelText: 'Currency',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'BDT', child: Text('BDT')),
              DropdownMenuItem(value: 'USD', child: Text('USD')),
              DropdownMenuItem(value: 'EUR', child: Text('EUR')),
            ],
            onChanged: (value) => setState(() => _currency = value ?? 'BDT'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _theme,
            decoration: const InputDecoration(
              labelText: 'Theme',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'system', child: Text('System')),
              DropdownMenuItem(value: 'light', child: Text('Light')),
              DropdownMenuItem(value: 'dark', child: Text('Dark')),
            ],
            onChanged: (value) => setState(() => _theme = value ?? 'system'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _startOfWeek,
            decoration: const InputDecoration(
              labelText: 'Start of week',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'sat', child: Text('Saturday')),
              DropdownMenuItem(value: 'mon', child: Text('Monday')),
            ],
            onChanged: (value) => setState(() => _startOfWeek = value ?? 'sat'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              final settings = AppSettings(
                currency: _currency,
                theme: _theme,
                startOfWeek: _startOfWeek,
              );
              await ref.read(settingsRepositoryProvider).saveSettings(settings);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved')),
                );
              }
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
