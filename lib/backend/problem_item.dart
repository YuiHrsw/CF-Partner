import 'package:json_annotation/json_annotation.dart';
part 'problem_item.g.dart';

@JsonSerializable()
class ProblemItem {
  ProblemItem({
    required this.title,
    required this.source,
    required this.url,
    required this.status,
    required this.note,
    required this.tags,
  });
  String title;
  String source;
  String url;
  String status;
  String note;
  List<String> tags;

  factory ProblemItem.fromJson(Map<String, dynamic> json) =>
      _$ProblemItemFromJson(json);
  Map<String, dynamic> toJson() => _$ProblemItemToJson(this);
}
