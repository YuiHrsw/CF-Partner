import 'package:cf_partner/backend/cfapi/models/contest.dart';
import 'package:cf_partner/backend/cfapi/models/contests_request.dart';
import 'package:cf_partner/backend/cfapi/models/problem.dart';
import 'package:cf_partner/backend/cfapi/models/standing_request.dart';
import 'package:cf_partner/backend/cfapi/models/submission.dart';
import 'package:cf_partner/backend/cfapi/models/submission_request.dart';
import 'package:cf_partner/backend/problem_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';
import 'package:flutter/foundation.dart';

class CFHelper {
  static ProblemItem toLocalProblem(Problem p) {
    return ProblemItem(
      title: p.name!,
      source: p.gym ? 'Gym' : 'CF',
      url:
          'https://codeforces.com/${p.gym ? 'gym' : 'contest'}/${p.contestId!}/problem/${p.index!}',
      status: p.status,
      note: '',
      tags: p.tags,
    );
  }

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

  static Future<List<ProblemItem>> getContestProblemsWithStatus(int id) async {
    try {
      var request = await WebHelper().get(
          'https://codeforces.com/api/contest.standings',
          queryParameters: {
            'contestId': id,
            'count': 1,
          });
      StandingRequest requestInfo = StandingRequest.fromJson(request.data);
      // return requestInfo.result!.problems;
      var problems = requestInfo.result!.problems;
      var submissions = await getContestSubmissions(id);
      Map<String, Problem> map = {};
      for (var p in problems) {
        map.addAll({p.index!: p});
      }
      for (var s in submissions) {
        String sid = s.problem!.index!;
        if (map[sid]!.status == 'unknown') {
          map[sid]!.status = s.verdict! == 'OK' ? 'Accepted' : 'Attempted';
        } else if (s.verdict! == 'OK' && map[sid]!.status != 'Accepted') {
          map[sid]!.status = 'Accepted';
        }
      }
      var res = map.values.toList();
      return List.generate(res.length, (index) => toLocalProblem(res[index]));
    } catch (e) {
      return <ProblemItem>[];
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
