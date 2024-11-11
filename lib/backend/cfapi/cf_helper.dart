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
import 'package:flutter/material.dart';

class CFHelper {
  static Color getColor(int rating) {
    if (rating < 1200) return Colors.grey;
    if (rating < 1400) return Colors.teal;
    if (rating < 1600) return Colors.cyan;
    if (rating < 1900) return Colors.blueAccent;
    if (rating < 2100) return Colors.deepPurpleAccent;
    if (rating < 2400) return Colors.orange;
    if (rating < 3000) return Colors.redAccent;
    return Colors.pink.shade200;
  }

  static Color getColorDetailed(int rating) {
    if (rating < 1200) return Colors.grey;
    if (rating < 1400) return Colors.teal;
    if (rating < 1600) return Colors.cyan;
    if (rating < 1800) return Colors.blue;
    if (rating < 1900) return Colors.indigo;
    if (rating < 2000) return Colors.purple;
    if (rating < 2100) return Colors.deepPurple;
    if (rating < 2300) return Colors.amber;
    if (rating < 2400) return Colors.orange;
    if (rating < 3000) return Colors.red;
    return Colors.black;
  }

  static List<Contest> _contests = [];
  static List<Problem> _problems = [];
  static ProblemItem toLocalProblem(Problem p) {
    return ProblemItem(
      title: '${p.index!}. ${p.name!}',
      source: 'Codeforces',
      url: 'https://codeforces.com/contest/${p.contestId!}/problem/${p.index!}',
      status: 'unknown',
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
      var problems = requestInfo.result!.problems;
      for (var p in problems) {
        p.tags.add(p.rating == null ? 'N/A' : p.rating.toString());
      }
      return problems;
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
      _contests = await getContestList();
      _problems = await getProblemSet();
      var submissions = await getSubmissions();
      Map<int, ListItem> res = {};
      Map<String, String> status = {};

      for (var s in submissions) {
        if (s.contestId == null || s.verdict == null) {
          continue;
        }
        var id = '${s.contestId!}${s.problem!.index!}';
        var result = s.verdict! == 'OK' ? 'AC' : 'Tried';
        if (!status.containsKey(id)) {
          status.addAll({id: result});
        } else if ((status[id] == 'Tried') && (result == 'AC')) {
          status[id] = 'AC';
        }
      }

      for (var c in _contests) {
        res.addAll({c.id!: ListItem(title: c.name!, items: [])});
      }

      for (var p in _problems.reversed) {
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
        var result = s.verdict! == 'OK' ? 'AC' : 'Tried';
        if (!status.containsKey(id)) {
          status.addAll({id: result});
        } else if ((status[id] == 'Tried') && (result == 'AC')) {
          status[id] = 'AC';
        }
      }

      for (var c in _contests) {
        res.addAll({c.id!: ListItem(title: c.name!, items: [])});
      }

      for (var p in _problems.reversed) {
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
            res.status = 'AC';
          } else if (results[index].rejectedAttemptCount != 0) {
            res.status = 'Tried';
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

  static List<String> parseProblemCode(String str) {
    String prefix = '';
    String suffix = '';

    for (int i = 0; i < str.length; i++) {
      if (RegExp(r'\d').hasMatch(str[i])) {
        prefix += str[i];
      } else {
        suffix = str.substring(i);
        break;
      }
    }

    return [prefix, suffix];
  }

  static Future<List<ProblemItem>> refreshProblemStatus(
      List<ProblemItem> problems) async {
    try {
      var submissions = await getSubmissions();
      Map<String, String> status = {};

      for (var s in submissions) {
        if (s.contestId == null || s.verdict == null) {
          continue;
        }
        var id = 'CF${s.contestId!}${s.problem!.index!}';
        var result = s.verdict! == 'OK' ? 'AC' : 'Tried';

        if (!status.containsKey(id)) {
          status.addAll({id: result});
        } else if ((status[id] == 'Tried') && (result == 'AC')) {
          status[id] = 'AC';
        }
      }
      for (var p in problems) {
        // TODO: get code from url
        if (status.containsKey(p.title)) {
          p.status = status[p.title]!;
        }
      }

      return problems;
    } catch (e) {
      return problems;
    }
  }
}
