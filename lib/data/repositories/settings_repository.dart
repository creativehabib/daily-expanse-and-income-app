import 'package:hive_flutter/hive_flutter.dart';

import '../../data/local/hive_service.dart';
import '../../domain/models/app_settings.dart';

class SettingsRepository {
  final Box<Map> _box = Hive.box<Map>(HiveService.settingsBox);
  static const String _balancePrivacyKey = 'balance_privacy_mode';

  AppSettings getSettings() {
    final data = _box.get('app_settings');
    if (data == null) {
      return AppSettings.defaults;
    }
    return AppSettings.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put('app_settings', settings.toMap());
  }

  bool getBalancePrivacyMode() {
    final data = _box.get(_balancePrivacyKey);
    if (data == null) {
      return false;
    }
    final map = Map<String, dynamic>.from(data);
    return map['value'] as bool? ?? false;
  }

  Future<void> saveBalancePrivacyMode(bool value) async {
    await _box.put(_balancePrivacyKey, {'value': value});
  }
}
