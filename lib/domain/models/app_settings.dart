class AppSettings {
  static const AppSettings defaults = AppSettings(
    currency: 'BDT',
    theme: 'system',
    startOfWeek: 'sat',
    biometricEnabled: false,
  );

  final String currency;
  final String theme;
  final String startOfWeek;
  final bool biometricEnabled;

  const AppSettings({
    required this.currency,
    required this.theme,
    required this.startOfWeek,
    required this.biometricEnabled,
  });

  AppSettings copyWith({
    String? currency,
    String? theme,
    String? startOfWeek,
    bool? biometricEnabled,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
      startOfWeek: startOfWeek ?? this.startOfWeek,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'theme': theme,
      'startOfWeek': startOfWeek,
      'biometricEnabled': biometricEnabled,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      currency: map['currency'] as String? ?? 'BDT',
      theme: map['theme'] as String? ?? 'system',
      startOfWeek: map['startOfWeek'] as String? ?? 'sat',
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
    );
  }
}
