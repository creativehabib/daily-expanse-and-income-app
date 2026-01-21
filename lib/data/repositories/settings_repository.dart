import 'package:hive_flutter/hive_flutter.dart';

import '../../data/local/hive_service.dart';
import '../../domain/models/app_settings.dart';

class SettingsRepository {
  final Box<Map> _box = Hive.box<Map>(HiveService.settingsBox);

  AppSettings getSettings() {
    final data = _box.get('app_settings');
    if (data == null) {
      return const AppSettings(
        currency: 'BDT',
        theme: 'system',
        startOfWeek: 'sat',
        biometricEnabled: false,
      );
    }
    return AppSettings.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put('app_settings', settings.toMap());
  }
}
