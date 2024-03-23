import 'package:cf_partner/backend/cfapi/models/problem.dart';
import 'package:cf_partner/backend/cfapi/models/standing_request.dart';
import 'package:cf_partner/backend/cfapi/models/submission.dart';
import 'package:cf_partner/backend/cfapi/models/submission_request.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';

class CFHelper {
  static Future<List<Submission>> getContestStatus(int id) async {
    var request = await WebHelper()
        .get('https://codeforces.com/api/contest.status', queryParameters: {
      'contestId': id,
      'handle': AppStorage().settings.handle
    });
    SubmissionRequestResult requestInfo =
        SubmissionRequestResult.fromJson(request.data);
    return requestInfo.result;
  }

  static Future<bool> accepted(Problem p) async {
    var res = await getContestStatus(p.contestId!);
    for (var item in res) {
      if (item.verdict == 'OK' && item.problem!.name! == p.name!) {
        return true;
      }
    }
    return false;
  }

  static Future<List<bool>> getListStatus(List<Problem> list) async {
    var res = List.filled(list.length, false, growable: true);
    int n = list.length;
    for (int i = 0; i < n; ++i) {
      res[i] = await accepted(list[i]);
    }
    return res;
  }

  static Future<List<Problem>> getContestProblems(int id) async {
    var request = await WebHelper()
        .get('https://codeforces.com/api/contest.standings', queryParameters: {
      'contestId': id,
      'count': 1,
    });
    StandingRequest requestInfo = StandingRequest.fromJson(request.data);
    return requestInfo.result!.problems;
  }

  static Future<Problem> getProblem(int id, String index) async {
    var list = await getContestProblems(id);
    for (var p in list) {
      if (p.index! == index) {
        return p;
      }
    }
    return list[0];
  }
}
