import 'package:cf_partner/backend/cfapi/models/contest.dart';
import 'package:cf_partner/backend/cfapi/models/contests_request.dart';
import 'package:cf_partner/backend/cfapi/models/problem.dart';
import 'package:cf_partner/backend/cfapi/models/problemset_request.dart';
import 'package:cf_partner/backend/cfapi/models/standing_request.dart';
import 'package:cf_partner/backend/cfapi/models/submission.dart';
import 'package:cf_partner/backend/cfapi/models/submission_request.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/problem_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';

class CFHelper {
  static List<Contest> contests = [];
  static List<Problem> problems = [];
  static ProblemItem toLocalProblem(Problem p) {
    return ProblemItem(
      title: '${p.index!}. ${p.name!}',
      source: 'Codeforces',
      url: 'https://codeforces.com/contest/${p.contestId!}/problem/${p.index!}',
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
      requestInfo.result.removeWhere((element) => element.phase != 'FINISHED');
      return requestInfo.result;
    } catch (e) {
      return <Contest>[];
    }
  }

  static Future<List<Problem>> getProblemSet() async {
    try {
      var request = await WebHelper()
          .get('https://codeforces.com/api/problemset.problems');
      ProblemSetRequest requestInfo = ProblemSetRequest.fromJson(request.data);
      return requestInfo.result!.problems;
    } catch (e) {
      return <Problem>[];
    }
  }

  static Future<List<Submission>> getSubmissions() async {
    try {
      var request = await WebHelper()
          .get('https://codeforces.com/api/user.status', queryParameters: {
        'handle': AppStorage().settings.handle,
      });
      SubmissionRequestResult requestInfo =
          SubmissionRequestResult.fromJson(request.data);
      return requestInfo.result;
    } catch (e) {
      return <Submission>[];
    }
  }

  static Future<List<ListItem>> getContestsWithProblems() async {
    try {
      contests = await getContestList();
      problems = await getProblemSet();
      var submissions = await getSubmissions();
      Map<int, ListItem> res = {};
      Map<String, String> status = {};

      for (var s in submissions) {
        if (s.contestId == null || s.verdict == null) {
          continue;
        }
        var id = '${s.contestId!}${s.problem!.index!}';
        var result = s.verdict! == 'OK' ? 'Accepted' : 'Attempted';
        if (!status.containsKey(id)) {
          status.addAll({id: result});
        } else if ((status[id] == 'Attempted') && (result == 'Accepted')) {
          status[id] = 'Accepted';
        }
      }

      for (var c in contests) {
        res.addAll({c.id!: ListItem(title: c.name!, items: [])});
      }

      for (var p in problems.reversed) {
        if (!res.containsKey(p.contestId!)) {
          res.addAll({
            p.contestId!: ListItem(title: 'Contest ${p.contestId!}', items: [])
          });
        }
        var id = '${p.contestId!}${p.index!}';
        var tmp = toLocalProblem(p);
        if (status.containsKey(id)) {
          tmp.status = status[id]!;
        }
        res[p.contestId!]!.items.add(tmp);
      }

      return res.values.toList()
        ..removeWhere((element) => element.items.isEmpty);
    } catch (e) {
      return <ListItem>[];
    }
  }

  static Future<List<ListItem>> getContestsWithProblemsCached() async {
    try {
      var submissions = await getSubmissions();
      Map<int, ListItem> res = {};
      Map<String, String> status = {};

      for (var s in submissions) {
        if (s.contestId == null || s.verdict == null) {
          continue;
        }
        var id = '${s.contestId!}${s.problem!.index!}';
        var result = s.verdict! == 'OK' ? 'Accepted' : 'Attempted';
        if (!status.containsKey(id)) {
          status.addAll({id: result});
        } else if ((status[id] == 'Attempted') && (result == 'Accepted')) {
          status[id] = 'Accepted';
        }
      }

      for (var c in contests) {
        res.addAll({c.id!: ListItem(title: c.name!, items: [])});
      }

      for (var p in problems.reversed) {
        if (!res.containsKey(p.contestId!)) {
          res.addAll({
            p.contestId!: ListItem(title: 'Contest ${p.contestId!}', items: [])
          });
        }
        var id = '${p.contestId!}${p.index!}';
        var tmp = toLocalProblem(p);
        if (status.containsKey(id)) {
          tmp.status = status[id]!;
        }
        res[p.contestId!]!.items.add(tmp);
      }

      return res.values.toList()
        ..removeWhere((element) => element.items.isEmpty);
    } catch (e) {
      return <ListItem>[];
    }
  }

  static Future<List<ProblemItem>> getContestDetails(int id) async {
    try {
      var request = await WebHelper().get(
          'https://codeforces.com/api/contest.standings',
          queryParameters: {
            'contestId': id,
            'showUnofficial': true,
            // TODO: display multi rows
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
