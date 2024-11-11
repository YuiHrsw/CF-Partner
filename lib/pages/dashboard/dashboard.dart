import 'package:cf_partner/backend/library_helper.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';
import 'package:cf_partner/pages/dashboard/models/challenge_problem.dart';
import 'package:cf_partner/pages/dashboard/models/online_contest.dart';
import 'package:cf_partner/pages/dashboard/problem_parser.dart';
import 'package:cf_partner/pages/toolbox/bingo.dart';
import 'package:cf_partner/pages/toolbox/online_categories.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Challenge extends StatefulWidget {
  const Challenge({super.key});

  @override
  ChallengeState createState() => ChallengeState();
}

class ChallengeState extends State<Challenge> {
  // final _emoji = [
  //   '🤔',
  //   '😘',
  //   '🤩',
  //   '😌',
  //   '🤪',
  //   '🥳',
  //   '🤓',
  //   '🥰',
  //   '😍',
  //   '😀',
  //   '😚',
  // ];
  List<ChallengeProblem> _dailyProblems = [];
  final List<OnlineContest> _contests = [];
  int clistCnt = 100;
  String _errMsg = '';
  String _clistErrMsg = '';

  @override
  void initState() {
    super.initState();
    _loadLatestDailyProblems();
    _loadClistData();
  }

  void _loadLatestDailyProblems() async {
    try {
      var res = await WebHelper().get(
        "https://raw.githubusercontent.com/Yawn-Sean/Daily_CF_Problems/main/README.md",
      );
      setState(() {
        _dailyProblems = parse(res.data);
        _errMsg = '';
      });
    } catch (e) {
      setState(() {
        _errMsg = e.toString();
      });
    }
  }

  void _loadClistData() async {
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
      body: CustomScrollView(
        slivers: [
          // SliverToBoxAdapter(
          //   child: Container(
          //     height: 120,
          //     alignment: Alignment.center,
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Text(
          //           // '📅 ${DateTime.now().year} - ${DateTime.now().month} - ${DateTime.now().day}',
          //           'Welcome back, ${AppStorage().settings.handle}! ${_emoji[Random().nextInt(_emoji.length)]}',
          //           style: const TextStyle(
          //             fontSize: 30,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          const SliverToBoxAdapter(
            child: Divider(
              indent: 16,
              endIndent: 16,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: Bingo(),
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
                    'Daily CF Problems',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _loadLatestDailyProblems,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  IconButton(
                    tooltip: 'Categories',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const OnlineCategories(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.stream),
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
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     child: ContributionTileGrid(
          //       contributionColors: [
          //         Colors.grey.withOpacity(0.2),
          //         Colors.green.withOpacity(0.2),
          //         Colors.green.withOpacity(0.4),
          //         Colors.green.withOpacity(0.6),
          //         Colors.green,
          //       ],
          //       startDate: DateTime.now().subtract(const Duration(days: 363)),
          //     ),
          //   ),
          // ),
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
                    'Clist',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _loadClistData,
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
                  color: colorScheme.secondaryContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  child: Text(
                    ' Diff: ${p.difficulty} ',
                    style: TextStyle(
                      color: colorScheme.onSecondaryContainer.withOpacity(0.8),
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
                  color: colorScheme.secondaryContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  child: Text(
                    ' ${p.host} ',
                    style: TextStyle(
                      color: colorScheme.onSecondaryContainer.withOpacity(0.8),
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
