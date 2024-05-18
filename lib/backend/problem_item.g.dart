// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProblemItem _$ProblemItemFromJson(Map<String, dynamic> json) => ProblemItem(
      title: json['title'] as String,
      source: json['source'] as String,
      url: json['url'] as String,
      status: json['status'] as String,
      note: json['note'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ProblemItemToJson(ProblemItem instance) =>
    <String, dynamic>{
      'title': instance.title,
      'source': instance.source,
      'url': instance.url,
      'status': instance.status,
      'note': instance.note,
      'tags': instance.tags,
    };
