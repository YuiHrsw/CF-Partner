import 'package:cf_partner/backend/cfapi/models/contest.dart';
import 'package:cf_partner/backend/cfapi/models/problem.dart';
import 'package:cf_partner/backend/cfapi/models/standing_row.dart';

class StandingResult {
  StandingResult({
    required this.contest,
    required this.problems,
    required this.rows,
  });

  final Contest? contest;
  final List<Problem> problems;
  final List<StandingRow> rows;

  factory StandingResult.fromJson(Map<String, dynamic> json) {
    return StandingResult(
      contest:
          json["contest"] == null ? null : Contest.fromJson(json["contest"]),
      problems: json["problems"] == null
          ? []
          : List<Problem>.from(
              json["problems"]!.map((x) => Problem.fromJson(x))),
      rows: json["rows"] == null
          ? []
          : List<StandingRow>.from(
              json["rows"]!.map((x) => StandingRow.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "contest": contest?.toJson(),
        "problems": problems.map((x) => x.toJson()).toList(),
        "rows": rows.map((x) => x.toJson()).toList(),
      };
}
