class AppSettings {
  static const AppSettings defaults = AppSettings(
    profileName: '',
    profileEmail: '',
    currency: 'BDT',
    theme: 'system',
    startOfWeek: 'sat',
    biometricEnabled: false,
  );

  final String profileName;
  final String profileEmail;
  final String currency;
  final String theme;
  final String startOfWeek;
  final bool biometricEnabled;

  const AppSettings({
    required this.profileName,
    required this.profileEmail,
    required this.currency,
    required this.theme,
    required this.startOfWeek,
    required this.biometricEnabled,
  });

  AppSettings copyWith({
    String? profileName,
    String? profileEmail,
    String? currency,
    String? theme,
    String? startOfWeek,
    bool? biometricEnabled,
  }) {
    return AppSettings(
      profileName: profileName ?? this.profileName,
      profileEmail: profileEmail ?? this.profileEmail,
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
      startOfWeek: startOfWeek ?? this.startOfWeek,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileName': profileName,
      'profileEmail': profileEmail,
      'currency': currency,
      'theme': theme,
      'startOfWeek': startOfWeek,
      'biometricEnabled': biometricEnabled,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      profileName: map['profileName'] as String? ?? '',
      profileEmail: map['profileEmail'] as String? ?? '',
      currency: map['currency'] as String? ?? 'BDT',
      theme: map['theme'] as String? ?? 'system',
      startOfWeek: map['startOfWeek'] as String? ?? 'sat',
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
    );
  }
}
