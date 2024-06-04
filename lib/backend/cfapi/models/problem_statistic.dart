class ProblemStatistic {
  ProblemStatistic({
    required this.contestId,
    required this.index,
    required this.solvedCount,
  });

  final int? contestId;
  final String? index;
  final int? solvedCount;

  factory ProblemStatistic.fromJson(Map<String, dynamic> json) {
    return ProblemStatistic(
      contestId: json["contestId"],
      index: json["index"],
      solvedCount: json["solvedCount"],
    );
  }
  Map<String, dynamic> toJson() => {
        "contestId": contestId,
        "index": index,
        "solvedCount": solvedCount,
      };
}
