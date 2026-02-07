import 'package:flutter/widgets.dart';

class Category {
  final String id;
  final String name;
  final String type;
  final int icon;
  final String? iconFamily;
  final String? iconPackage;
  final int color;
  final bool isDefault;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.iconFamily,
    this.iconPackage,
    required this.color,
    required this.isDefault,
    required this.createdAt,
  });

  IconData get iconData => IconData(
        icon,
        fontFamily: iconFamily ?? 'MaterialIcons',
        fontPackage: iconPackage,
      );

  Category copyWith({
    String? id,
    String? name,
    String? type,
    int? icon,
    String? iconFamily,
    String? iconPackage,
    int? color,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      iconFamily: iconFamily ?? this.iconFamily,
      iconPackage: iconPackage ?? this.iconPackage,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'iconFamily': iconFamily,
      'iconPackage': iconPackage,
      'color': color,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<dynamic, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as int,
      iconFamily: map['iconFamily'] as String? ?? 'MaterialIcons',
      iconPackage: map['iconPackage'] as String?,
      color: map['color'] as int,
      isDefault: map['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
