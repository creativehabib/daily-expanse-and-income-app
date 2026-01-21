import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/biometric_auth_service.dart';
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
        ],
      ),
    );
  }
}
