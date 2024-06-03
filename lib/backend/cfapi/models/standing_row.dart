import 'package:cf_partner/backend/cfapi/models/member.dart';
import 'package:cf_partner/backend/cfapi/models/party.dart';
import 'package:cf_partner/backend/cfapi/models/problem_result.dart';

class StandingRow {
  StandingRow({
    required this.party,
    required this.rank,
    required this.points,
    required this.penalty,
    required this.successfulHackCount,
    required this.unsuccessfulHackCount,
    required this.problemResults,
  });

  final Party? party;
  final int? rank;
  final double? points;
  final int? penalty;
  final int? successfulHackCount;
  final int? unsuccessfulHackCount;
  final List<ProblemResult> problemResults;

  factory StandingRow.fromJson(Map<String, dynamic> json) {
    return StandingRow(
      party: json["party"] == null ? null : Party.fromJson(json["party"]),
      rank: json["rank"],
      points: json["points"],
      penalty: json["penalty"],
      successfulHackCount: json["successfulHackCount"],
      unsuccessfulHackCount: json["unsuccessfulHackCount"],
      problemResults: json["problemResults"] == null
          ? []
          : List<ProblemResult>.from(
              json["problemResults"]!.map((x) => ProblemResult.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "party": party?.toJson(),
        "rank": rank,
        "points": points,
        "penalty": penalty,
        "successfulHackCount": successfulHackCount,
        "unsuccessfulHackCount": unsuccessfulHackCount,
        "problemResults": problemResults.map((x) => x.toJson()).toList(),
      };
}
