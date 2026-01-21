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
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
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
    _nameController = TextEditingController(text: settings.profileName);
    _emailController = TextEditingController(text: settings.profileEmail);
    _currency = settings.currency;
    _theme = settings.theme;
    _startOfWeek = settings.startOfWeek;
    _biometricEnabled = settings.biometricEnabled;
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
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
    if (!available) {
      final settings = ref.read(settingsProvider);
      if (settings.biometricEnabled) {
        await ref
            .read(settingsProvider.notifier)
            .updateSettings(settings.copyWith(biometricEnabled: false));
      }
    }
  }

  Future<void> _updateBiometricSetting(bool value) async {
    setState(() {
      _biometricEnabled = value;
    });
    final settings = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).updateSettings(
          settings.copyWith(
            biometricEnabled: value && _biometricAvailable,
          ),
        );
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
        _nameController.text = AppSettings.defaults.profileName;
        _emailController.text = AppSettings.defaults.profileEmail;
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

  AppSettings _buildSettings() {
    return AppSettings(
      profileName: _nameController.text.trim(),
      profileEmail: _emailController.text.trim(),
      currency: _currency,
      theme: _theme,
      startOfWeek: _startOfWeek,
      biometricEnabled: _biometricEnabled && _biometricAvailable,
    );
  }

  bool _settingsMatch(AppSettings current, AppSettings next) {
    return current.profileName == next.profileName &&
        current.profileEmail == next.profileEmail &&
        current.currency == next.currency &&
        current.theme == next.theme &&
        current.startOfWeek == next.startOfWeek &&
        current.biometricEnabled == next.biometricEnabled;
  }

  Future<void> _saveSettings({bool showSnackBar = false}) async {
    final nextSettings = _buildSettings();
    final currentSettings = ref.read(settingsProvider);
    if (_settingsMatch(currentSettings, nextSettings)) {
      return;
    }
    await ref.read(settingsProvider.notifier).updateSettings(nextSettings);
    if (showSnackBar && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
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
    return WillPopScope(
      onWillPop: () async {
        await _saveSettings();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
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
              onChanged: (value) =>
                  setState(() => _startOfWeek = value ?? 'sat'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _biometricEnabled,
              onChanged: _checkingBiometric || !_biometricAvailable
                  ? null
                  : (value) async {
                      await _updateBiometricSetting(value);
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
                await _saveSettings(showSnackBar: true);
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
            const SizedBox(height: 24),
            Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Expanse & Income',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track daily income, expenses, and budgets with quick '
                      'insights into your spending patterns.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Contact',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.email_outlined),
                    title: Text('support@dailyexpanse.app'),
                    subtitle: Text('Email support'),
                  ),
                  Divider(height: 0),
                  ListTile(
                    leading: Icon(Icons.public),
                    title: Text('www.dailyexpanse.app'),
                    subtitle: Text('Visit our website'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
