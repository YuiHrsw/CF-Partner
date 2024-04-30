import 'package:cf_partner/backend/cfapi/cf_helper.dart';
import 'package:cf_partner/backend/library_helper.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
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
    final TextEditingController editingController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listItem.title),
        actions: [
          IconButton(
            onPressed: () async {
              String? outputFile = await FilePicker.platform.saveFile(
                dialogTitle: 'Save Problem List As...',
                fileName: '${widget.listItem.title}.json',
                type: FileType.custom,
                allowedExtensions: ["json"],
              );

              if (outputFile == null) {
                return;
              }

              LibraryHelper.exportListFile(widget.listItem, outputFile);
            },
            icon: const Icon(Icons.save_outlined),
          ),
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
                    mark = await CFHelper.getListStatus(widget.listItem.items);
                    if (mounted) {
                      setState(() {
                        locked = false;
                      });
                    }
                  },
                  icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: locked || widget.online
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
                                      try {
                                        var res = await CFHelper.getProblem(
                                            int.parse(value.substring(
                                                0, value.length - 1)),
                                            value.substring(value.length - 1));

                                        if (res == null) {
                                          setState(() {
                                            locked = false;
                                          });
                                          if (!context.mounted) return;
                                          Navigator.pop(context);
                                          return;
                                        }

                                        LibraryHelper.addProblemToList(
                                            widget.listItem, res);
                                        mark.add(
                                            await CFHelper.getPloblemStatus(
                                                res));
                                      } catch (e) {}
                                      setState(() {
                                        locked = false;
                                      });
                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                    },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (locked) {
                                    WebHelper().cancel(token: CancelToken());
                                    setState(() {
                                      locked = false;
                                    });
                                  } else {
                                    Navigator.pop(context);
                                  }
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
                                        try {
                                          var res = await CFHelper.getProblem(
                                              int.parse(value.substring(
                                                  0, value.length - 1)),
                                              value
                                                  .substring(value.length - 1));

                                          if (res == null) {
                                            setState(() {
                                              locked = false;
                                            });
                                            if (!context.mounted) return;
                                            Navigator.pop(context);
                                            return;
                                          }

                                          LibraryHelper.addProblemToList(
                                              widget.listItem, res);
                                          mark.add(
                                              await CFHelper.getPloblemStatus(
                                                  res));
                                        } catch (e) {}
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
          return Column(
            children: [
              buildListItem(colorScheme, index),
              SizedBox(
                height: 20,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, tagIndex) {
                    return Ink(
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 20,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: FittedBox(
                            child: Text(
                              widget.listItem.items[index].tags[tagIndex],
                              style: TextStyle(
                                  color: colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: widget.listItem.items[index].tags.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      width: 4,
                    );
                  },
                ),
              )
            ],
          );
        },
        itemCount: widget.listItem.items.length,
      ),
    );
  }

  Widget buildListItem(ColorScheme colorScheme, int index) {
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
                  fontWeight: index < mark.length && mark[index]
                      ? FontWeight.w500
                      : null),
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.online
                    ? const SizedBox()
                    : IconButton(
                        onPressed: () {
                          editingController.clear();
                          showDialog(
                            barrierColor:
                                colorScheme.surfaceTint.withOpacity(0.12),
                            useRootNavigator: false,
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              surfaceTintColor: Colors.transparent,
                              title: const Text('Add a tag'),
                              content: TextField(
                                autofocus: true,
                                maxLines: 1,
                                controller: editingController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'tag name',
                                ),
                                onSubmitted: (value) {
                                  LibraryHelper.addTagToProblem(
                                      widget.listItem, index, value);
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    LibraryHelper.addTagToProblem(
                                        widget.listItem,
                                        index,
                                        editingController.text);
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          setState(() {});
                        },
                        icon: const Icon(Icons.new_label_outlined),
                      ),
                widget.online
                    ? const SizedBox()
                    : IconButton(
                        onPressed: () {
                          showDialog(
                            barrierColor:
                                colorScheme.surfaceTint.withOpacity(0.12),
                            useRootNavigator: false,
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              surfaceTintColor: Colors.transparent,
                              title: const Text('Remove Tags'),
                              content: SizedBox(
                                width: 200,
                                height: 300,
                                child: ListView.builder(
                                  itemBuilder: (context, indexList) {
                                    return SizedBox(
                                        height: 40,
                                        child: InkWell(
                                          onTap: () {
                                            LibraryHelper.removeTagToProblem(
                                                widget.listItem,
                                                index,
                                                widget.listItem.items[index]
                                                    .tags[indexList]);
                                            setState(() {});
                                            Navigator.pop(context);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              const Icon(
                                                  Icons.label_outline_rounded),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                widget.listItem.items[index]
                                                    .tags[indexList],
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ));
                                  },
                                  itemCount:
                                      widget.listItem.items[index].tags.length,
                                ),
                              ),
                            ),
                          );
                          setState(() {});
                        },
                        icon: const Icon(Icons.label_off_outlined),
                      ),
                widget.online
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            barrierColor:
                                colorScheme.surfaceTint.withOpacity(0.12),
                            useRootNavigator: false,
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
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
                                              AppStorage()
                                                  .problemlists[indexList],
                                              widget.listItem.items[index]);
                                          Navigator.pop(context);
                                        },
                                        borderRadius: BorderRadius.circular(20),
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
                                                    BorderRadius.circular(20),
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
                                              style:
                                                  const TextStyle(fontSize: 18),
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
                        icon: const Icon(Icons.add_circle_outline))
                    : IconButton(
                        onPressed: () {
                          LibraryHelper.removeProblemFromList(
                              widget.listItem, widget.listItem.items[index]);
                          if (index < mark.length) {
                            mark.removeAt(index);
                          }
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
  }
}
