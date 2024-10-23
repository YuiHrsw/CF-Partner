import 'package:cf_partner/backend/cfapi/cf_helper.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/problem_item.dart';
import 'package:cf_partner/backend/web_helper.dart';
import 'package:cf_partner/pages/dashboard/models/online_list.dart';
import 'package:cf_partner/pages/dashboard/problem_parser.dart';
import 'package:cf_partner/pages/list_detail.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class OnlineCategories extends StatefulWidget {
  const OnlineCategories({super.key});

  @override
  OnlineCategoriesState createState() => OnlineCategoriesState();
}

class OnlineCategoriesState extends State<OnlineCategories> {
  bool _locked = false;
  static const _baseUrl =
      'https://raw.githubusercontent.com/Yawn-Sean/Daily_CF_Problems/refs/heads/main/categories';
  final _categories = [
    OnlineList(
      icon: Icons.data_array,
      title: 'DP',
      url: '$_baseUrl/DP.md',
    ),
    OnlineList(
      icon: Icons.search,
      title: 'Binary Search',
      url: '$_baseUrl/binary_search.md',
    ),
    OnlineList(
      icon: Icons.looks_one_outlined,
      title: 'Bitmask',
      url: '$_baseUrl/bitmask.md',
    ),
    OnlineList(
      icon: Icons.tag,
      title: 'Brainteaser',
      url: '$_baseUrl/brain_teaser.md',
    ),
    OnlineList(
      icon: Icons.lightbulb_outline,
      title: 'Constructive',
      url: '$_baseUrl/constructive.md',
    ),
    OnlineList(
      icon: Icons.calculate_outlined,
      title: 'Counting',
      url: '$_baseUrl/counting.md',
    ),
    OnlineList(
      icon: Icons.line_style,
      title: 'Data Structures',
      url: '$_baseUrl/data_structures.md',
    ),
    OnlineList(
      icon: Icons.games_outlined,
      title: 'Games',
      url: '$_baseUrl/games.md',
    ),
    OnlineList(
      icon: Icons.join_left,
      title: 'Geometry',
      url: '$_baseUrl/geometry.md',
    ),
    OnlineList(
      icon: Icons.linear_scale_rounded,
      title: 'Graph',
      url: '$_baseUrl/graph.md',
    ),
    OnlineList(
      icon: Icons.tag_faces,
      title: 'Greedy',
      url: '$_baseUrl/greedy.md',
    ),
    OnlineList(
      icon: Icons.functions_rounded,
      title: 'Number Theory',
      url: '$_baseUrl/number_theory.md',
    ),
    OnlineList(
      icon: Icons.percent,
      title: 'Probabilities',
      url: '$_baseUrl/probabilities.md',
    ),
    OnlineList(
      icon: Icons.casino_outlined,
      title: 'Random',
      url: '$_baseUrl/random.md',
    ),
    OnlineList(
      icon: Icons.linear_scale,
      title: 'Shortest Path',
      url: '$_baseUrl/shortest_path.md',
    ),
    OnlineList(
      icon: Icons.sort,
      title: 'Sortings',
      url: '$_baseUrl/sortings.md',
    ),
    OnlineList(
      icon: Icons.abc,
      title: 'Strings',
      url: '$_baseUrl/strings.md',
    ),
    OnlineList(
      icon: Icons.forest_outlined,
      title: 'Trees',
      url: '$_baseUrl/trees.md',
    ),
    OnlineList(
      icon: Icons.keyboard_double_arrow_right,
      title: 'Two Pointers',
      url: '$_baseUrl/two_pointers.md',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
              'Online Categories',
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
          _locked
              ? IconButton(
                  tooltip: 'Cancel loading',
                  onPressed: () {
                    WebHelper().cancel(token: CancelToken());
                    setState(() {
                      _locked = false;
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : const SizedBox(),
          const SizedBox(
            width: 6,
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(_categories[index].icon),
            title: Text(_categories[index].title),
            onTap: _locked
                ? null
                : () async {
                    setState(() {
                      _locked = true;
                    });
                    var problems = await _loadCategory(_categories[index].url);
                    problems = await CFHelper.refreshProblemStatus(problems);
                    setState(() {
                      _locked = false;
                    });
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ListDetail(
                          listItem: ListItem(
                            items: problems,
                            title: _categories[index].title,
                          ),
                          online: true,
                        ),
                      ),
                    );
                  },
          );
        },
        itemCount: _categories.length,
      ),
    );
  }

  Future<List<ProblemItem>> _loadCategory(String url) async {
    try {
      var res = await WebHelper().get(url);
      return parseToLocal(res.data);
    } catch (e) {
      return [];
    }
  }
}
