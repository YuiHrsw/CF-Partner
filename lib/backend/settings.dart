//dart run build_runner build

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'settings.g.dart';

@JsonSerializable()
class AppSettings {
  bool listview;
  ThemeMode themeMode;
  int themeCode;
  String handle;

  AppSettings({
    this.listview = true,
    this.themeMode = ThemeMode.system,
    this.themeCode = 4,
    this.handle = 'tourist',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  MaterialColor getColorTheme() {
    switch (themeCode) {
      case 0:
        return Colors.pink;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.amber;
      case 3:
        return Colors.teal;
      case 4:
        return Colors.blue;
      case 5:
        return Colors.indigo;
      case 6:
        return Colors.purple;
    }
    return Colors.pink;
  }
}
