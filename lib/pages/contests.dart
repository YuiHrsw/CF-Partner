import 'package:cf_partner/backend/cfapi/cf_helper.dart';
import 'package:cf_partner/backend/cfapi/models/contest.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/web_helper.dart';
import 'package:cf_partner/pages/list_detail.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  ExplorePageState createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  List<Contest> contests = [];
  bool locked = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    contests.addAll(await CFHelper.getContestList());
    setState(() {
      locked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contests',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        ),
        actions: [
          locked
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: InkWell(
                    onTap: () {
                      WebHelper().cancel(token: CancelToken());
                      setState(() {
                        locked = false;
                      });
                    },
                    child: const CircularProgressIndicator(),
                  ),
                )
              : IconButton(
                  onPressed: () async {
                    setState(() {
                      locked = true;
                    });
                    contests.clear();
                    contests.addAll(await CFHelper.getContestList());
                    setState(() {
                      locked = false;
                    });
                  },
                  icon: const Icon(Icons.refresh)),
          SizedBox(
            width: locked ? 14 : 6,
          )
        ],
        scrolledUnderElevation: 0,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return SizedBox(
            height: 50,
            child: Card.outlined(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: contests[index].phase! == 'FINISHED' && !locked
                    ? () async {
                        setState(() {
                          locked = true;
                        });
                        var problems = await CFHelper.getContestProblems(
                            contests[index].id!);
                        if (!context.mounted || locked == false) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ListDetail(
                              listItem: ListItem(
                                items: problems,
                                title: contests[index].name!,
                              ),
                              online: true,
                            ),
                          ),
                        );
                        setState(() {
                          locked = false;
                        });
                      }
                    : null,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 4,
                    ),
                    Ink(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FittedBox(
                        child: Text(
                          ' ${contests[index].id!} ',
                          style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    contests[index].phase! == 'FINISHED'
                        ? Ink(
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FittedBox(
                              child: Text(
                                ' Finished ',
                                style: TextStyle(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      width: 4,
                    ),
                    Ink(
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FittedBox(
                        child: Text(
                          ' ${contests[index].durationSeconds! ~/ 3600}h${(contests[index].durationSeconds! % 3600) ~/ 60}m ',
                          style: TextStyle(
                              color: colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Expanded(child: Text(contests[index].name!)),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: contests.length,
      ),
    );
  }
}
