// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListItem _$ListItemFromJson(Map<String, dynamic> json) => ListItem(
      items: (json['items'] as List<dynamic>)
          .map((e) => ProblemItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String,
    );

Map<String, dynamic> _$ListItemToJson(ListItem instance) => <String, dynamic>{
      'items': instance.items,
      'title': instance.title,
    };
