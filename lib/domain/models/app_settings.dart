class AppSettings {
  final String currency;
  final String theme;
  final String startOfWeek;

  const AppSettings({
    required this.currency,
    required this.theme,
    required this.startOfWeek,
  });

  AppSettings copyWith({
    String? currency,
    String? theme,
    String? startOfWeek,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
      startOfWeek: startOfWeek ?? this.startOfWeek,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'theme': theme,
      'startOfWeek': startOfWeek,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      currency: map['currency'] as String? ?? 'BDT',
      theme: map['theme'] as String? ?? 'system',
      startOfWeek: map['startOfWeek'] as String? ?? 'sat',
    );
  }
}
