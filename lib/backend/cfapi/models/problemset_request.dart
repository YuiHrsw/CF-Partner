import 'package:cf_partner/backend/cfapi/models/problem.dart';
import 'package:cf_partner/backend/cfapi/models/problem_statistic.dart';

class ProblemSetRequest {
  ProblemSetRequest({
    required this.status,
    required this.result,
  });

  final String? status;
  final ProblemSetResult? result;

  factory ProblemSetRequest.fromJson(Map<String, dynamic> json) {
    return ProblemSetRequest(
      status: json["status"],
      result: json["result"] == null
          ? null
          : ProblemSetResult.fromJson(json["result"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "result": result?.toJson(),
      };
}

class ProblemSetResult {
  ProblemSetResult({
    required this.problems,
    required this.problemStatistics,
  });

  final List<Problem> problems;
  final List<ProblemStatistic> problemStatistics;

  factory ProblemSetResult.fromJson(Map<String, dynamic> json) {
    return ProblemSetResult(
      problems: json["problems"] == null
          ? []
          : List<Problem>.from(
              json["problems"]!.map((x) => Problem.fromJson(x))),
      problemStatistics: json["problemStatistics"] == null
          ? []
          : List<ProblemStatistic>.from(json["problemStatistics"]!
              .map((x) => ProblemStatistic.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "problems": problems.map((x) => x.toJson()).toList(),
        "problemStatistics": problemStatistics.map((x) => x.toJson()).toList(),
      };
}
