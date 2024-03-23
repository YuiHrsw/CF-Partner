import 'package:cf_partner/backend/cfapi/models/author.dart';
import 'package:cf_partner/backend/cfapi/models/problem.dart';

class Submission {
  Submission({
    required this.id,
    required this.contestId,
    required this.creationTimeSeconds,
    required this.relativeTimeSeconds,
    required this.problem,
    required this.author,
    required this.programmingLanguage,
    required this.verdict,
    required this.testset,
    required this.passedTestCount,
    required this.timeConsumedMillis,
    required this.memoryConsumedBytes,
  });

  final int? id;
  final int? contestId;
  final int? creationTimeSeconds;
  final int? relativeTimeSeconds;
  final Problem? problem;
  final Author? author;
  final String? programmingLanguage;
  final String? verdict;
  final String? testset;
  final int? passedTestCount;
  final int? timeConsumedMillis;
  final int? memoryConsumedBytes;

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json["id"],
      contestId: json["contestId"],
      creationTimeSeconds: json["creationTimeSeconds"],
      relativeTimeSeconds: json["relativeTimeSeconds"],
      problem:
          json["problem"] == null ? null : Problem.fromJson(json["problem"]),
      author: json["author"] == null ? null : Author.fromJson(json["author"]),
      programmingLanguage: json["programmingLanguage"],
      verdict: json["verdict"],
      testset: json["testset"],
      passedTestCount: json["passedTestCount"],
      timeConsumedMillis: json["timeConsumedMillis"],
      memoryConsumedBytes: json["memoryConsumedBytes"],
    );
  }
}
