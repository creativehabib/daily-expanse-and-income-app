import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/biometric_auth_service.dart';
import '../../data/local/data_reset_service.dart';
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
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _checkingBiometric = true;
  bool _resettingData = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _currency = settings.currency;
    _theme = settings.theme;
    _startOfWeek = settings.startOfWeek;
    _biometricEnabled = settings.biometricEnabled;
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricAuthService().isAvailable();
    if (!mounted) {
      return;
    }
    setState(() {
      _biometricAvailable = available;
      _checkingBiometric = false;
      if (!available) {
        _biometricEnabled = false;
      }
    });
  }

  Future<void> _resetData() async {
    setState(() {
      _resettingData = true;
    });

    try {
      await DataResetService().resetToDefaults();
      if (!mounted) {
        return;
      }
      ref.read(categoriesProvider.notifier).load();
      ref.read(transactionsProvider.notifier).load();
      ref.invalidate(budgetProvider);
      await ref
          .read(settingsProvider.notifier)
          .updateSettings(AppSettings.defaults);
      setState(() {
        _currency = AppSettings.defaults.currency;
        _theme = AppSettings.defaults.theme;
        _startOfWeek = AppSettings.defaults.startOfWeek;
        _biometricEnabled = AppSettings.defaults.biometricEnabled;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data reset to defaults')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _resettingData = false;
        });
      }
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset all data?'),
          content: const Text(
            'This will remove all transactions, budgets, and settings. '
            'Default categories and sample entries will be restored.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _resetData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Back',
        ),
      ),
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
          const SizedBox(height: 12),
          SwitchListTile(
            value: _biometricEnabled,
            onChanged: _checkingBiometric || !_biometricAvailable
                ? null
                : (value) {
                    setState(() {
                      _biometricEnabled = value;
                    });
                  },
            title: const Text('Biometric Login'),
            subtitle: Text(
              _checkingBiometric
                  ? 'Checking device availability...'
                  : _biometricAvailable
                      ? 'Use fingerprint/face to unlock the app.'
                      : 'Biometric authentication is not available on this device.',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              final settings = AppSettings(
                currency: _currency,
                theme: _theme,
                startOfWeek: _startOfWeek,
                biometricEnabled: _biometricEnabled && _biometricAvailable,
              );
              await ref.read(settingsProvider.notifier).updateSettings(settings);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved')),
                );
              }
            },
            child: const Text('Save Settings'),
          ),
          const SizedBox(height: 24),
          Text(
            'Data management',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _resettingData ? null : _confirmReset,
            icon: const Icon(Icons.restart_alt),
            label: Text(_resettingData ? 'Resetting...' : 'Factory reset'),
          ),
        ],
      ),
    );
  }
}
