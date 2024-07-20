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
  TextEditingController controller = TextEditingController();
  List<ProblemItem> problems = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    var res = await WebHelper().get(
        "https://raw.githubusercontent.com/Yawn-Sean/Daily_CF_Problems/main/README.md");
    setState(() {
      problems = parse(res.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Challenge',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(
            width: 6,
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              height: 260,
              alignment: Alignment.center,
              child: Text(
                '${DateTime.now().year} - ${DateTime.now().month} - ${DateTime.now().day}',
                style: const TextStyle(fontSize: 30),
              ),
            );
          } else {
            return buildProblemListTile(problems[index - 1]);
          }
        },
        itemCount: problems.length + 1,
        // children: [
        //   Container(
        //     height: 260,
        //     alignment: Alignment.center,
        //     child: Text(
        //       '${DateTime.now().year} - ${DateTime.now().month} - ${DateTime.now().day}',
        //       style: const TextStyle(fontSize: 30),
        //     ),
        //   ),
        //   buildProblemListTile(context, problems[0]),
        //   buildProblemListTile(context, problems[1]),
        // ],
      ),
    );
  }

  Widget buildProblemListTile(ProblemItem p) {
    var colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
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
              p.status == 'unknown'
                  ? const SizedBox()
                  : Ink(
                      decoration: BoxDecoration(
                        color: p.status == 'Accepted'
                            ? colorScheme.primaryContainer
                            : colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FittedBox(
                        child: Text(
                          ' ${p.status} ',
                          style: TextStyle(
                            color: p.status == 'Accepted'
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                width: 6,
              ),
              Text(
                // AppStorage().problemlists[index].title,
                p.title,
                style: TextStyle(
                    fontSize: 18,
                    color: p.status == 'Accepted'
                        ? colorScheme.onPrimaryContainer
                        : null,
                    fontWeight:
                        p.status == 'Accepted' ? FontWeight.w500 : null),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Show hint',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text(
                            'Hint',
                          ),
                          content: Text(p.note),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.help_outline),
                  ),
                  IconButton(
                    tooltip: 'Copy problem',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Copy to'),
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
                      Icons.star_outline,
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
}

List<ProblemItem> parse(String markdownContent) {
  List<ProblemItem> res = [];

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
        ProblemItem(
            title: problemName,
            source: problemLink,
            url: problemLink,
            status: 'Unknown',
            note: '$hint\n$solutionLink',
            tags: [difficulty]),
      );
    }
  }

  return res;
}
