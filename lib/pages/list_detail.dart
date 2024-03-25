import 'package:cf_partner/backend/cfapi/cf_helper.dart';
import 'package:cf_partner/backend/library_helper.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ListDetail extends StatefulWidget {
  const ListDetail({super.key, required this.listItem, required this.online});
  final ListItem listItem;
  final bool online;

  @override
  ListDetailState createState() => ListDetailState();
}

class ListDetailState extends State<ListDetail> {
  final TextEditingController editingController = TextEditingController();
  bool locked = false;
  late List<bool> mark;

  @override
  void initState() {
    super.initState();
    mark = List.filled(widget.listItem.items.length, false, growable: true);
  }

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listItem.title),
        actions: [
          locked
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  onPressed: () async {
                    setState(() {
                      locked = true;
                    });
                    mark = await CFHelper.getListStatus(widget.listItem.items);
                    setState(() {
                      locked = false;
                    });
                  },
                  icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: locked
                  ? null
                  : () {
                      editingController.clear();
                      showDialog(
                        barrierDismissible: false,
                        barrierColor: colorScheme.surfaceTint.withOpacity(0.12),
                        useRootNavigator: false,
                        context: context,
                        builder: (BuildContext context) =>
                            StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                            surfaceTintColor: Colors.transparent,
                            title: const Text('Add Problem'),
                            content: TextField(
                              autofocus: true,
                              maxLines: 1,
                              controller: editingController,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'id',
                                  hintText: 'e.g. 1946D'),
                              onSubmitted: locked
                                  ? null
                                  : (value) async {
                                      setState(() {
                                        locked = true;
                                      });
                                      var res = await CFHelper.getProblem(
                                          int.parse(value.substring(
                                              0, value.length - 1)),
                                          value.substring(value.length - 1));
                                      LibraryHelper.addProblemToList(
                                          widget.listItem, res);
                                      mark.add(await CFHelper.accepted(res));
                                      setState(() {
                                        locked = false;
                                      });
                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                    },
                            ),
                            actions: [
                              TextButton(
                                onPressed: locked
                                    ? null
                                    : () {
                                        Navigator.pop(context);
                                      },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: locked
                                    ? null
                                    : () async {
                                        setState(() {
                                          locked = true;
                                        });
                                        var value = editingController.text;
                                        var res = await CFHelper.getProblem(
                                            int.parse(value.substring(
                                                0, value.length - 1)),
                                            value.substring(value.length - 1));
                                        LibraryHelper.addProblemToList(
                                            widget.listItem, res);
                                        mark.add(await CFHelper.accepted(res));
                                        setState(() {
                                          locked = false;
                                        });
                                        if (!context.mounted) return;
                                        Navigator.pop(context);
                                      },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        }),
                      ).then((value) {
                        setState(() {});
                      });
                    },
              icon: const Icon(Icons.add)),
          const SizedBox(
            width: 6,
          )
        ],
        scrolledUnderElevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            height: 60,
            child: InkWell(
              onTap: () {
                launchUrl(Uri.https('codeforces.com',
                    '/contest/${widget.listItem.items[index].contestId!}/problem/${widget.listItem.items[index].index!}'));
              },
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  const SizedBox(
                    width: 6,
                  ),
                  Ink(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 20,
                    width: 50,
                    child: Center(
                      child: Text(
                        widget.listItem.items[index].contestId!.toString() +
                            widget.listItem.items[index].index!,
                        style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    // AppStorage().problemlists[index].title,
                    widget.listItem.items[index].name!,
                    style: TextStyle(
                      fontSize: 18,
                      color: index < mark.length && mark[index]
                          ? colorScheme.primary
                          : null,
                    ),
                  ),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      widget.online
                          ? IconButton(
                              onPressed: () {
                                showDialog(
                                  barrierColor:
                                      colorScheme.surfaceTint.withOpacity(0.12),
                                  useRootNavigator: false,
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    surfaceTintColor: Colors.transparent,
                                    title: const Text('Add to list'),
                                    content: SizedBox(
                                      width: 200,
                                      height: 300,
                                      child: ListView.builder(
                                        itemBuilder: (context, indexList) {
                                          return SizedBox(
                                            height: 60,
                                            child: InkWell(
                                              onTap: () {
                                                LibraryHelper.addProblemToList(
                                                    AppStorage().problemlists[
                                                        indexList],
                                                    widget
                                                        .listItem.items[index]);
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
                                                          BorderRadius.circular(
                                                              20),
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
                                                        .problemlists[indexList]
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
                              },
                              icon: const Icon(Icons.add_circle_outline))
                          : IconButton(
                              onPressed: () {
                                LibraryHelper.removeProblemFromList(
                                    widget.listItem,
                                    widget.listItem.items[index]);
                                setState(() {});
                              },
                              icon: const Icon(Icons.delete_outline)),
                    ],
                  )),
                  const SizedBox(
                    width: 6,
                  )
                ],
              ),
            ),
          );
        },
        itemCount: widget.listItem.items.length,
      ),
    );
  }
}
