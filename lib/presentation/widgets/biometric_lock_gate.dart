import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/biometric_auth_service.dart';
import '../../domain/models/app_settings.dart';
import '../providers/providers.dart';

class BiometricLockGate extends ConsumerStatefulWidget {
  const BiometricLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BiometricLockGate> createState() => _BiometricLockGateState();
}

class _BiometricLockGateState extends ConsumerState<BiometricLockGate>
    with WidgetsBindingObserver {
  final BiometricAuthService _authService = BiometricAuthService();
  ProviderSubscription<AppSettings>? _settingsSubscription;
  bool _unlocked = false;
  bool _authInProgress = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleSettingsChange(ref.read(settingsProvider));
    });
    _settingsSubscription = ref.listenManual<AppSettings>(
      settingsProvider,
      (previous, next) {
        if (previous?.biometricEnabled != next.biometricEnabled) {
          _handleSettingsChange(next);
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settingsSubscription?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(settingsProvider).biometricEnabled) {
      setState(() {
        _unlocked = false;
      });
      _authenticate();
    }
  }

  void _handleSettingsChange(AppSettings settings) {
    if (!settings.biometricEnabled) {
      setState(() {
        _unlocked = true;
        _error = null;
      });
      return;
    }
    setState(() {
      _unlocked = false;
    });
    _authenticate();
  }

  Future<void> _authenticate() async {
    if (_authInProgress) {
      return;
    }
    setState(() {
      _authInProgress = true;
      _error = null;
    });

    final available = await _authService.isAvailable();
    if (!available) {
      setState(() {
        _authInProgress = false;
        _error = 'Biometric authentication is not available on this device.';
      });
      return;
    }

    final success = await _authService.authenticate(
      reason: 'Authenticate to unlock your data',
    );
    setState(() {
      _authInProgress = false;
      _unlocked = success;
      _error = success ? null : 'Authentication failed. Please try again.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    if (!settings.biometricEnabled || _unlocked) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fingerprint, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Biometric Login',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error ?? 'Authenticate to continue',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _authInProgress ? null : _authenticate,
                      child: Text(
                        _authInProgress ? 'Checking...' : 'Unlock',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
