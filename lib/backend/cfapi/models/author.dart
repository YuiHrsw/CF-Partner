import 'package:cf_partner/backend/cfapi/models/member.dart';

class Author {
  Author({
    required this.contestId,
    required this.members,
    required this.participantType,
    required this.ghost,
    required this.startTimeSeconds,
  });

  final int? contestId;
  final List<Member> members;
  final String? participantType;
  final bool? ghost;
  final int? startTimeSeconds;

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      contestId: json["contestId"],
      members: json["members"] == null
          ? []
          : List<Member>.from(json["members"]!.map((x) => Member.fromJson(x))),
      participantType: json["participantType"],
      ghost: json["ghost"],
      startTimeSeconds: json["startTimeSeconds"],
    );
  }
}
