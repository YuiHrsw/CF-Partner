import 'package:cf_partner/backend/cfapi/models/contest.dart';
import 'package:cf_partner/backend/cfapi/models/contests_request.dart';
import 'package:cf_partner/backend/cfapi/models/problem.dart';
import 'package:cf_partner/backend/cfapi/models/standing_request.dart';
import 'package:cf_partner/backend/cfapi/models/submission.dart';
import 'package:cf_partner/backend/cfapi/models/submission_request.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';
import 'package:flutter/foundation.dart';

class CFHelper {
  static Future<List<Submission>> getContestSubmissions(int id) async {
    try {
      var request = await WebHelper()
          .get('https://codeforces.com/api/contest.status', queryParameters: {
        'contestId': id,
        'handle': AppStorage().settings.handle
      });
      SubmissionRequestResult requestInfo =
          SubmissionRequestResult.fromJson(request.data);
      return requestInfo.result;
    } catch (e) {
      return <Submission>[];
    }
  }

  static Future<bool> getPloblemStatus(Problem p) async {
    try {
      var res = await getContestSubmissions(p.contestId!);
      for (var item in res) {
        if (item.verdict == 'OK' && item.problem!.name! == p.name!) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<bool>> getListStatus(List<Problem> list) async {
    var res = List.filled(list.length, false, growable: true);
    int n = list.length;
    for (int i = 0; i < n; ++i) {
      try {
        res[i] = await getPloblemStatus(list[i]);
      } catch (e) {
        if (kDebugMode) {
          print(
              'can not check problem status: ${list[i].contestId}${list[i].index} ${list[i].name}');
        }
      }
    }
    return res;
  }

  static Future<List<Problem>> getContestProblems(int id) async {
    try {
      var request = await WebHelper().get(
          'https://codeforces.com/api/contest.standings',
          queryParameters: {
            'contestId': id,
            'count': 1,
          });
      StandingRequest requestInfo = StandingRequest.fromJson(request.data);
      return requestInfo.result!.problems;
    } catch (e) {
      return <Problem>[];
    }
  }

  static Future<Problem?> getProblem(int id, String index) async {
    try {
      var list = await getContestProblems(id);
      for (var p in list) {
        if (p.index! == index) {
          return p;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Contest>> getContestList() async {
    try {
      var request =
          await WebHelper().get('https://codeforces.com/api/contest.list');
      ContestListRequest requestInfo =
          ContestListRequest.fromJson(request.data);
      return requestInfo.result;
    } catch (e) {
      return <Contest>[];
    }
  }
}
