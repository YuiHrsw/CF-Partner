class ProblemResult {
  ProblemResult({
    required this.points,
    required this.rejectedAttemptCount,
    required this.type,
    required this.bestSubmissionTimeSeconds,
  });

  final double? points;
  final int? rejectedAttemptCount;
  final String? type;
  final int? bestSubmissionTimeSeconds;

  factory ProblemResult.fromJson(Map<String, dynamic> json) {
    return ProblemResult(
      points: json["points"],
      rejectedAttemptCount: json["rejectedAttemptCount"],
      type: json["type"],
      bestSubmissionTimeSeconds: json["bestSubmissionTimeSeconds"],
    );
  }

  Map<String, dynamic> toJson() => {
        "points": points,
        "rejectedAttemptCount": rejectedAttemptCount,
        "type": type,
        "bestSubmissionTimeSeconds": bestSubmissionTimeSeconds,
      };
}
