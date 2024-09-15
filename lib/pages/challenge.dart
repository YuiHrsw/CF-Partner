import 'package:cf_partner/backend/library_helper.dart';
import 'package:cf_partner/backend/problem_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Challenge extends StatefulWidget {
  const Challenge({super.key});

  @override
  ChallengeState createState() => ChallengeState();
}

class ChallengeState extends State<Challenge> {
  List<ChallengeProblem> _dailyProblems = [];
  final List<OnlineContest> _contests = [];
  int clistCnt = 100;
  String _errMsg = '';
  String _clistErrMsg = '';
  // final bool _listening = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    try {
      var res = await WebHelper().get(
          "https://raw.githubusercontent.com/Yawn-Sean/Daily_CF_Problems/main/README.md");
      setState(() {
        _dailyProblems = parse(res.data);
        _errMsg = '';
      });
    } catch (e) {
      setState(() {
        _errMsg = e.toString();
      });
    }
    try {
      _contests.clear();

      String now = DateTime.now()
          .subtract(
            const Duration(days: 1),
          )
          .toString();
      now = now.substring(0, 19).replaceAll(' ', 'T');
      var data = await WebHelper().get(
        'https://clist.by/api/v4/contest/',
        queryParameters: {
          'order_by': 'start',
          'upcoming': true,
          'limit': clistCnt,
          'start__gt': now,
          'filtered': true,
          'format_time': true,
        },
      );
      var clist = data.data['objects'];
      for (var c in clist) {
        _contests.add(
          OnlineContest(
            title: c['event'],
            url: c['href'],
            host: c['host'],
            duration: c['duration'],
            start: c['start'],
            end: c['end'],
          ),
        );
      }
      setState(() {});
    } catch (e) {
      setState(() {
        _clistErrMsg = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'Dashboard',
      //     style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
      //   ),
      //   actions: [
      //     IconButton(
      //       tooltip: 'Edit title',
      //       onPressed: () {},
      //       icon: const Icon(Icons.edit_outlined),
      //     ),
      //     const SizedBox(
      //       width: 6,
      //     )
      //   ],
      // ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 160,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    // '📅 ${DateTime.now().year} - ${DateTime.now().month} - ${DateTime.now().day}',
                    'Welcome back, ${AppStorage().settings.handle}! 🥰',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(
              indent: 16,
              endIndent: 16,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Daily Problems',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () async {
                      try {
                        var res = await WebHelper().get(
                            "https://raw.githubusercontent.com/Yawn-Sean/Daily_CF_Problems/main/README.md");
                        setState(() {
                          _dailyProblems = parse(res.data);
                          _errMsg = '';
                        });
                      } catch (e) {
                        setState(() {
                          _errMsg = e.toString();
                        });
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  IconButton(
                    tooltip: 'Open repo',
                    onPressed: () {
                      launchUrl(
                        Uri.parse(
                          'https://github.com/Yawn-Sean/Daily_CF_Problems',
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_browser),
                  ),
                ],
              ),
            ),
          ),
          _errMsg != ''
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(_errMsg),
                  ),
                )
              : SliverList.builder(
                  itemBuilder: (context, index) {
                    return buildProblemListTile(_dailyProblems[index]);
                  },
                  itemCount: _dailyProblems.length,
                ),
          const SliverToBoxAdapter(
            child: Divider(
              indent: 16,
              endIndent: 16,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Upcoming Contests',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () async {
                      try {
                        _contests.clear();

                        String now = DateTime.now()
                            .subtract(
                              const Duration(days: 1),
                            )
                            .toString();
                        now = now.substring(0, 19).replaceAll(' ', 'T');
                        var data = await WebHelper().get(
                          'https://clist.by/api/v4/contest/',
                          queryParameters: {
                            'order_by': 'start',
                            'upcoming': true,
                            'limit': clistCnt,
                            'start__gt': now,
                            'filtered': true,
                            'format_time': true,
                          },
                        );
                        var clist = data.data['objects'];
                        for (var c in clist) {
                          _contests.add(
                            OnlineContest(
                              title: c['event'],
                              url: c['href'],
                              host: c['host'],
                              duration: c['duration'],
                              start: c['start'],
                              end: c['end'],
                            ),
                          );
                        }
                        setState(() {
                          _clistErrMsg = '';
                        });
                      } catch (e) {
                        setState(() {
                          _clistErrMsg = e.toString();
                        });
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  IconButton(
                    tooltip: 'Open clist.by',
                    onPressed: () {
                      launchUrl(
                        Uri.parse('https://clist.by/?view=list'),
                      );
                    },
                    icon: const Icon(Icons.open_in_browser),
                  ),
                ],
              ),
            ),
          ),
          _clistErrMsg != ''
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(_clistErrMsg),
                  ),
                )
              : SliverList.builder(
                  itemBuilder: (context, index) {
                    return buildContestListTile(_contests[index]);
                  },
                  itemCount: _contests.length,
                ),
        ],
      ),
    );
  }

  Widget buildProblemListTile(ChallengeProblem p) {
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 46,
      child: InkWell(
        onTap: () {
          launchUrl(Uri.parse(p.url));
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 4,
              ),
              Ink(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  child: Text(
                    ' ${p.difficulty} ',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              Text(
                p.title,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Submit',
                    onPressed: () {
                      RegExp regExp = RegExp(r'/(\d{4})/(\d{2})/(\d{4})/');
                      Match? match = regExp.firstMatch(p.tutorial);

                      if (match != null) {
                        String year = match.group(1)!;
                        String month = match.group(2)!;
                        String day = match.group(3)!;
                        launchUrl(Uri.parse(
                          'https://github.com/Yawn-Sean/Daily_CF_Problems/new/main/daily_problems/$year/$month/$day/personal_submission',
                        ));
                      }
                    },
                    icon: const Icon(Icons.send_outlined),
                  ),
                  IconButton(
                    tooltip: 'Hint',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text(
                            'Hint',
                          ),
                          content: Text(p.hint),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                launchUrl(Uri.parse(p.tutorial));
                              },
                              child: const Text('Tutorial'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.tips_and_updates_outlined),
                  ),
                  IconButton(
                    tooltip: 'Save',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Add to list'),
                          content: SizedBox(
                            width: 400,
                            height: 300,
                            child: ListView.builder(
                              itemBuilder: (context, indexList) {
                                return SizedBox(
                                  height: 60,
                                  child: InkWell(
                                    onTap: () {
                                      LibraryHelper.addProblemToList(
                                          AppStorage().problemlists[indexList],
                                          p);
                                      Navigator.pop(context);
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          height: 50,
                                          width: 50,
                                          child: Icon(
                                            Icons.star_rounded,
                                            color:
                                                colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Text(
                                          AppStorage()
                                              .problemlists[indexList]
                                              .title,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: AppStorage().problemlists.length,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                    ),
                  ),
                ],
              )),
              const SizedBox(
                width: 6,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContestListTile(OnlineContest p) {
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 46,
      child: InkWell(
        onTap: () {
          launchUrl(Uri.parse(p.url));
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 4,
              ),
              Ink(
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  child: Text(
                    ' ${p.host} ',
                    style: TextStyle(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                child: Text(
                  p.title,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                p.start,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                width: 6,
              )
            ],
          ),
        ),
      ),
    );
  }
}

List<ChallengeProblem> parse(String markdownContent) {
  List<ChallengeProblem> res = [];

  final tableStartPattern =
      RegExp(r'\| Difficulty \| Problems \| Hints \| Solution \|');
  final tableEndPattern =
      RegExp(r'\| -------- \| -------- \| -------- \| -------- \|');

  final lines = markdownContent.split('\n');

  bool isTableSection = false;
  final tableContent = <String>[];

  for (final line in lines) {
    if (tableStartPattern.hasMatch(line)) {
      isTableSection = true;
      continue;
    } else if (isTableSection && tableEndPattern.hasMatch(line)) {
      continue;
    } else if (isTableSection && line.trim().isEmpty) {
      isTableSection = false;
    } else if (isTableSection) {
      tableContent.add(line);
    }
  }

  for (final row in tableContent) {
    final columns = row
        .split('|')
        .map((col) => col.trim())
        .where((col) => col.isNotEmpty)
        .toList();
    if (columns.length == 4) {
      final difficulty = columns[0];
      final problemName =
          RegExp(r'\[(.*?)\]').firstMatch(columns[1])?.group(1) ?? 'N/A';
      final problemLink =
          RegExp(r'\((.*?)\)').firstMatch(columns[1])?.group(1) ?? 'N/A';
      final hint = columns[2];
      final solutionLink =
          RegExp(r'\((.*?)\)').firstMatch(columns[3])?.group(1) ?? 'N/A';

      res.add(
        ChallengeProblem(
          title: problemName,
          source: 'Codeforces',
          url: problemLink,
          status: 'unknown',
          note: '',
          tags: [],
          hint: hint,
          tutorial: solutionLink,
          difficulty: difficulty,
        ),
      );
    }
  }

  return res;
}

class ChallengeProblem extends ProblemItem {
  ChallengeProblem({
    required super.title,
    required super.source,
    required super.url,
    required super.status,
    required super.note,
    required super.tags,
    required this.hint,
    required this.tutorial,
    required this.difficulty,
  });
  String difficulty;
  String hint;
  String tutorial;
}

class OnlineContest {
  OnlineContest({
    required this.title,
    required this.url,
    required this.host,
    required this.duration,
    required this.start,
    required this.end,
  });
  String title;
  String url;
  String host;
  String duration;
  String start;
  String end;
}
