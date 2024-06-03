import 'package:cf_partner/backend/cfapi/models/member.dart';

class Party {
  Party({
    required this.contestId,
    required this.members,
    required this.participantType,
    required this.ghost,
    required this.room,
    required this.startTimeSeconds,
  });

  final int? contestId;
  final List<Member> members;
  final String? participantType;
  final bool? ghost;
  final int? room;
  final int? startTimeSeconds;

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      contestId: json["contestId"],
      members: json["members"] == null
          ? []
          : List<Member>.from(json["members"]!.map((x) => Member.fromJson(x))),
      participantType: json["participantType"],
      ghost: json["ghost"],
      room: json["room"],
      startTimeSeconds: json["startTimeSeconds"],
    );
  }

  Map<String, dynamic> toJson() => {
        "contestId": contestId,
        "members": members.map((x) => x.toJson()).toList(),
        "participantType": participantType,
        "ghost": ghost,
        "room": room,
        "startTimeSeconds": startTimeSeconds,
      };
}
