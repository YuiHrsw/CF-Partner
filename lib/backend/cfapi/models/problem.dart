class Problem {
  Problem({
    required this.contestId,
    required this.index,
    required this.name,
    required this.type,
    required this.points,
    required this.rating,
    required this.tags,
  });

  final int? contestId;
  final String? index;
  final String? name;
  final String? type;
  final double? points;
  final int? rating;
  final List<String> tags;

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      contestId: json["contestId"],
      index: json["index"],
      name: json["name"],
      type: json["type"],
      points: json["points"],
      rating: json["rating"],
      tags: json["tags"] == null
          ? []
          : List<String>.from(
              json["tags"]!.map((x) => x),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        "contestId": contestId,
        "index": index,
        "name": name,
        "type": type,
        "tags": tags.map((x) => x).toList(),
        "points": points,
        "rating": rating,
      };
}
