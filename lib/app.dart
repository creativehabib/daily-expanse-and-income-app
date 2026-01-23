import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/providers.dart';
import 'presentation/widgets/biometric_lock_gate.dart';

class ExpenseApp extends ConsumerWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = _themeModeFromSetting(ref.watch(settingsProvider).theme);
    return MaterialApp.router(
      title: 'Daily Expense & Income',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return BiometricLockGate(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

ThemeMode _themeModeFromSetting(String themeSetting) {
  switch (themeSetting) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}
