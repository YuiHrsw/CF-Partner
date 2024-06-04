import 'package:cf_partner/backend/cfapi/cf_helper.dart';
import 'package:cf_partner/backend/library_helper.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';
import 'package:cf_partner/pages/list_detail.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  ExplorePageState createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  List<ListItem> contests = [];
  bool locked = true;
  bool urlMode = true;
  final int pageCount = 100;
  int currentPage = 0;
  int totalPage = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    contests.addAll(await CFHelper.getContestsWithProblems());
    setState(() {
      locked = false;
      totalPage = (contests.length + pageCount - 1) ~/ 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    final Map<String, Color> statusColor = {
      'Accepted': colorScheme.primaryContainer,
      'Attempted': colorScheme.errorContainer,
      'unknown': colorScheme.background,
    };
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Contests',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
            ),
            const SizedBox(
              width: 10,
            ),
            locked
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : const SizedBox(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                urlMode = !urlMode;
              });
            },
            child: Text(
              urlMode ? 'URL Mode' : 'Copy Mode',
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                currentPage--;
                currentPage %= totalPage;
              });
            },
            icon: const Icon(
              Icons.skip_previous,
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: 50,
            child: Text('${currentPage + 1} / $totalPage'),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                currentPage++;
                currentPage %= totalPage;
              });
            },
            icon: const Icon(
              Icons.skip_next,
            ),
          ),
          IconButton(
            onPressed: locked
                ? () {
                    WebHelper().cancel(token: CancelToken());
                    setState(() {
                      locked = false;
                    });
                  }
                : () async {
                    setState(() {
                      currentPage = 0;
                      totalPage = 1;
                      locked = true;
                    });
                    contests.clear();
                    contests.addAll(await CFHelper.getContestsWithProblems());
                    setState(() {
                      totalPage = (contests.length + pageCount - 1) ~/ 100;
                      locked = false;
                    });
                  },
            icon: Icon(locked ? Icons.close : Icons.refresh),
          ),
          const SizedBox(
            width: 6,
          )
        ],
        scrolledUnderElevation: 0,
      ),
      body: contests.isEmpty
          ? const Center(
              child: Text('Loading...'),
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                index += pageCount * currentPage;
                return SizedBox(
                  height: 100,
                  child: Column(
                    children: [
                      Card.filled(
                        color: colorScheme.secondaryContainer,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ListDetail(
                                  listItem: contests[index],
                                  online: true,
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 30,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    contests[index].title,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(left: 4),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, problemIndex) {
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (urlMode) {
                                  launchUrl(Uri.parse(
                                      contests[index].items[problemIndex].url));
                                } else {
                                  showDialog(
                                    barrierColor: colorScheme.surfaceTint
                                        .withOpacity(0.12),
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      surfaceTintColor: Colors.transparent,
                                      title: const Text('Copy to'),
                                      content: SizedBox(
                                        width: 200,
                                        height: 300,
                                        child: ListView.builder(
                                          itemBuilder: (context, indexList) {
                                            return SizedBox(
                                              height: 60,
                                              child: InkWell(
                                                onTap: () {
                                                  LibraryHelper
                                                      .addProblemToList(
                                                          AppStorage()
                                                                  .problemlists[
                                                              indexList],
                                                          contests[index].items[
                                                              problemIndex]);
                                                  Navigator.pop(context);
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 6,
                                                    ),
                                                    Ink(
                                                      decoration: BoxDecoration(
                                                        color: colorScheme
                                                            .primaryContainer,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      height: 50,
                                                      width: 50,
                                                      child: Icon(
                                                        Icons.star_rounded,
                                                        color: colorScheme
                                                            .onPrimaryContainer,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 6,
                                                    ),
                                                    Text(
                                                      AppStorage()
                                                          .problemlists[
                                                              indexList]
                                                          .title,
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          itemCount:
                                              AppStorage().problemlists.length,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: colorScheme.secondary),
                                  color: statusColor[contests[index]
                                      .items[problemIndex]
                                      .status],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(4),
                                height: 20,
                                width: 100,
                                child: Text(
                                  contests[index].items[problemIndex].title,
                                  maxLines: 2,
                                ),
                              ),
                            );
                          },
                          itemCount: contests[index].items.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              width: 4,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: currentPage == totalPage - 1
                  ? contests.length % pageCount
                  : pageCount,
            ),
    );
  }
}
