import 'package:cf_partner/backend/cfapi/models/contest.dart';

class ContestListRequest {
  ContestListRequest({
    required this.status,
    required this.result,
  });

  final String? status;
  final List<Contest> result;

  factory ContestListRequest.fromJson(Map<String, dynamic> json) {
    return ContestListRequest(
      status: json["status"],
      result: json["result"] == null
          ? []
          : List<Contest>.from(json["result"]!.map((x) => Contest.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "result": result.map((x) => x.toJson()).toList(),
      };
}
