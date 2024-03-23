import 'package:cf_partner/backend/cfapi/models/contest.dart';
import 'package:cf_partner/backend/cfapi/models/problem.dart';

class StandingResult {
  StandingResult({
    required this.contest,
    required this.problems,
    // required this.rows,
  });

  final Contest? contest;
  final List<Problem> problems;
  // final List<Row> rows;

  factory StandingResult.fromJson(Map<String, dynamic> json) {
    return StandingResult(
      contest:
          json["contest"] == null ? null : Contest.fromJson(json["contest"]),
      problems: json["problems"] == null
          ? []
          : List<Problem>.from(
              json["problems"]!.map((x) => Problem.fromJson(x))),
      // rows: json["rows"] == null ? [] : List<Row>.from(json["rows"]!.map((x) => Row.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "contest": contest?.toJson(),
        "problems": problems.map((x) => x.toJson()).toList(),
        // "rows": rows.map((x) => x?.toJson()).toList(),
      };
}
