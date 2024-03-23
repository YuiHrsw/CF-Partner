import 'package:cf_partner/backend/cfapi/models/problem.dart';
import 'package:json_annotation/json_annotation.dart';
part 'list_item.g.dart';

@JsonSerializable()
class ListItem {
  ListItem({
    required this.items,
    required this.title,
  });
  List<Problem> items;
  String title;

  factory ListItem.fromJson(Map<String, dynamic> json) =>
      _$ListItemFromJson(json);
  Map<String, dynamic> toJson() => _$ListItemToJson(this);
}
