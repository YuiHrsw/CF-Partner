// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      listview: json['listview'] as bool? ?? true,
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      themeCode: (json['themeCode'] as num?)?.toInt() ?? 0,
      handle: json['handle'] as String? ?? 'tourist',
      taskStatus: (json['taskStatus'] as num?)?.toInt() ?? 0,
      taskRatings: (json['taskRatings'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1200, 1400, 1600, 1900, 2100, 2400],
      ignoreRating: (json['ignoreRating'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'listview': instance.listview,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'themeCode': instance.themeCode,
      'handle': instance.handle,
      'taskStatus': instance.taskStatus,
      'taskRatings': instance.taskRatings,
      'ignoreRating': instance.ignoreRating,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};
