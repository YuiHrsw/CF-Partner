import 'package:cf_partner/backend/cfapi/cf_helper.dart';
import 'package:cf_partner/backend/library_helper.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';
import 'package:cf_partner/pages/list_detail.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  TrackerPageState createState() => TrackerPageState();
}

class TrackerPageState extends State<TrackerPage> {
  final ScrollController _scrollController = ScrollController();
  final List<ListItem> _contests = [];
  bool _locked = true;
  bool _urlMode = true;
  final int _pageCount = 100;
  int _currentPage = 0;
  int _totalPage = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _contests.addAll(await CFHelper.getContestsWithProblems());
    if (!mounted) return;
    setState(() {
      _locked = false;
      _totalPage = (_contests.length + _pageCount - 1) ~/ 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    final Map<String, Color> statusColor = {
      'Accepted': Colors.green.withOpacity(0.15),
      'Attempted': Colors.red.withOpacity(0.15),
      'unknown': colorScheme.surface,
    };
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const Text(
              'CF Tracker',
              // style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
            ),
            const SizedBox(
              width: 10,
            ),
            _locked
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : const SizedBox(),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Click to switch mode',
            child: TextButton(
              onPressed: () {
                setState(() {
                  _urlMode = !_urlMode;
                });
              },
              child: Text(
                _urlMode ? 'URL Mode' : 'Copy Mode',
              ),
            ),
          ),
          IconButton(
            tooltip: 'Refresh personal status',
            onPressed: _locked
                ? null
                : () async {
                    setState(() {
                      _currentPage = 0;
                      _totalPage = 1;
                      _locked = true;
                    });
                    _contests.clear();
                    _contests
                        .addAll(await CFHelper.getContestsWithProblemsCached());
                    setState(() {
                      _totalPage = (_contests.length + _pageCount - 1) ~/ 100;
                      _locked = false;
                    });
                  },
            icon: const Icon(
              Icons.person_search,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentPage--;
                _currentPage %= _totalPage;
              });
              _scrollController.jumpTo(0);
            },
            icon: const Icon(
              Icons.skip_previous,
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: 50,
            child: Text('${_currentPage + 1} / $_totalPage'),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentPage++;
                _currentPage %= _totalPage;
              });
              _scrollController.jumpTo(0);
            },
            icon: const Icon(
              Icons.skip_next,
            ),
          ),
          IconButton(
            tooltip:
                _locked ? 'Cancel loading' : 'Reload problems and contests',
            onPressed: _locked
                ? () {
                    WebHelper().cancel(token: CancelToken());
                    setState(() {
                      _locked = false;
                    });
                  }
                : () async {
                    setState(() {
                      _currentPage = 0;
                      _totalPage = 1;
                      _locked = true;
                    });
                    _contests.clear();
                    _contests.addAll(await CFHelper.getContestsWithProblems());
                    setState(() {
                      _totalPage = (_contests.length + _pageCount - 1) ~/ 100;
                      _locked = false;
                    });
                  },
            icon: Icon(_locked ? Icons.close : Icons.refresh),
          ),
          const SizedBox(
            width: 6,
          )
        ],
      ),
      body: _contests.isEmpty
          ? const Center(
              child: Text('List is empty'),
            )
          : ListView.builder(
              itemExtent: 110,
              controller: _scrollController,
              itemBuilder: (context, index) {
                index += _pageCount * _currentPage;
                return SizedBox(
                  height: 100,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ListDetail(
                                listItem: _contests[index],
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
                                  _contests[index].title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(left: 4),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, problemIndex) {
                            var problem = _contests[index].items[problemIndex];
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (_urlMode) {
                                  launchUrl(Uri.parse(_contests[index]
                                      .items[problemIndex]
                                      .url));
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
                                        width: 400,
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
                                                          _contests[index]
                                                                  .items[
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
                                                    Container(
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
                                                        fontSize: 18,
                                                      ),
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
                              child: Tooltip(
                                waitDuration: const Duration(seconds: 1),
                                message:
                                    '${problem.title} - ${problem.tags.last}\n${problem.url}\n\nClick to ${_urlMode ? 'open url' : 'copy problem'}',
                                child: Ink(
                                  decoration: BoxDecoration(
                                    border: problem.status == 'unknown'
                                        ? Border.all(
                                            color: colorScheme
                                                .secondaryContainer
                                                .withOpacity(0.6),
                                            width: 4,
                                          )
                                        : null,
                                    color: statusColor[problem.status],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  width: 150,
                                  child: Text(
                                    problem.title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: TextStyle(
                                      color: problem.tags.last == 'N/A'
                                          ? colorScheme.onSurface
                                          : CFHelper.getColor(
                                              int.parse(problem.tags.last)),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: _contests[index].items.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              width: 4,
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                    ],
                  ),
                );
              },
              itemCount: _currentPage == _totalPage - 1
                  ? _contests.length % _pageCount
                  : _pageCount,
            ),
    );
  }
}
