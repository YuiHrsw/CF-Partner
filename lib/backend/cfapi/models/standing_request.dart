import 'package:cf_partner/backend/cfapi/models/standing_result.dart';

class StandingRequest {
  StandingRequest({
    required this.status,
    required this.result,
  });

  final String? status;
  final StandingResult? result;

  factory StandingRequest.fromJson(Map<String, dynamic> json) {
    return StandingRequest(
      status: json["status"],
      result: json["result"] == null
          ? null
          : StandingResult.fromJson(json["result"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "result": result?.toJson(),
      };
}
