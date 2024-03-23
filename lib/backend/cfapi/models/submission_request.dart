import 'package:cf_partner/backend/cfapi/models/submission.dart';

class SubmissionRequestResult {
  SubmissionRequestResult({
    required this.status,
    required this.result,
  });

  final String? status;
  final List<Submission> result;

  factory SubmissionRequestResult.fromJson(Map<String, dynamic> json) {
    return SubmissionRequestResult(
      status: json["status"],
      result: json["result"] == null
          ? []
          : List<Submission>.from(
              json["result"]!.map((x) => Submission.fromJson(x))),
    );
  }
}
