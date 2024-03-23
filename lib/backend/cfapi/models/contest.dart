class Contest {
  Contest({
    required this.id,
    required this.name,
    required this.type,
    required this.phase,
    required this.frozen,
    required this.durationSeconds,
    required this.startTimeSeconds,
    required this.relativeTimeSeconds,
  });

  final int? id;
  final String? name;
  final String? type;
  final String? phase;
  final bool? frozen;
  final int? durationSeconds;
  final int? startTimeSeconds;
  final int? relativeTimeSeconds;

  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      id: json["id"],
      name: json["name"],
      type: json["type"],
      phase: json["phase"],
      frozen: json["frozen"],
      durationSeconds: json["durationSeconds"],
      startTimeSeconds: json["startTimeSeconds"],
      relativeTimeSeconds: json["relativeTimeSeconds"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "phase": phase,
        "frozen": frozen,
        "durationSeconds": durationSeconds,
        "startTimeSeconds": startTimeSeconds,
        "relativeTimeSeconds": relativeTimeSeconds,
      };
}
