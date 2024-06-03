import 'package:cf_partner/backend/cfapi/models/contest.dart';
import 'package:cf_partner/backend/cfapi/models/contests_request.dart';
import 'package:cf_partner/backend/cfapi/models/problem.dart';
import 'package:cf_partner/backend/cfapi/models/standing_request.dart';
import 'package:cf_partner/backend/problem_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';

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

  static Future<List<ProblemItem>> getContestProblems(int id) async {
    try {
      var request = await WebHelper().get(
          'https://codeforces.com/api/contest.standings',
          queryParameters: {
            'contestId': id,
            'showUnofficial': true,
            // TODO: display multi rows
            // 'count': 1,
            'handles': AppStorage().settings.handle,
          });
      StandingRequest requestInfo = StandingRequest.fromJson(request.data);
      var problems = requestInfo.result!.problems;
      if (requestInfo.result!.rows.isEmpty) {
        return List.generate(
            problems.length, (index) => toLocalProblem(problems[index]));
      } else {
        var results = requestInfo.result!.rows.first.problemResults;
        return List.generate(problems.length, (index) {
          var res = toLocalProblem(problems[index]);
          if (results[index].points != 0) {
            res.status = 'Accepted';
          } else if (results[index].rejectedAttemptCount != 0) {
            res.status = 'Attempted';
          }
          return res;
        });
      }
    } catch (e) {
      return <ProblemItem>[];
    }
  }

  // static Future<ProblemItem> getProblem(int id, String index) async {}
  // static Future<String> getPloblemStatus(Problem p) async {}
}
