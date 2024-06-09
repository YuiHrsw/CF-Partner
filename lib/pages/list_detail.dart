import 'package:cf_partner/backend/library_helper.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/problem_item.dart';
import 'package:cf_partner/backend/storage.dart';
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
    final TextEditingController titleController = TextEditingController();
    final TextEditingController urlController = TextEditingController();

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
        title: Text(widget.listItem.title),
        actions: [
          IconButton(
            tooltip: 'Export list',
            onPressed: () async {
              String? outputFile = await FilePicker.platform.saveFile(
                dialogTitle: 'Export problem list file',
                fileName: '${widget.listItem.title}.json',
                type: FileType.custom,
                allowedExtensions: ["json"],
              );

              if (outputFile == null) {
                return;
              }

              LibraryHelper.exportListFile(widget.listItem, outputFile);
            },
            icon: const Icon(Icons.save),
          ),
          IconButton(
            tooltip: 'New problem',
            onPressed: locked || widget.online
                ? null
                : () {
                    titleController.clear();
                    urlController.clear();
                    showDialog(
                      barrierColor: colorScheme.surfaceTint.withOpacity(0.12),
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        surfaceTintColor: Colors.transparent,
                        title: const Text('Add a problem'),
                        content: SizedBox(
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextField(
                                autofocus: true,
                                maxLines: 1,
                                controller: titleController,
                                decoration: const InputDecoration(
                                  label: Text('Title'),
                                  border: OutlineInputBorder(),
                                  hintText: 'A + B Problem',
                                ),
                              ),
                              TextField(
                                autofocus: true,
                                maxLines: 3,
                                controller: urlController,
                                decoration: const InputDecoration(
                                  label: Text('URL'),
                                  border: OutlineInputBorder(),
                                  hintText:
                                      'https://codeforces.com/problemset/problem/1772/A',
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              var p = ProblemItem(
                                title: titleController.text,
                                url: urlController.text,
                                status: 'unknown',
                                source: 'others',
                                tags: [],
                                note: '',
                              );
                              if (urlController.text
                                  .contains('codeforces.com')) {
                                p.source = 'Codeforces';
                              } else if (urlController.text
                                  .contains('atcoder.com')) {
                                p.source = 'AtCoder';
                              }
                              LibraryHelper.addProblemToList(
                                widget.listItem,
                                p,
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ).then((value) {
                      setState(() {});
                    });
                  },
            icon: const Icon(
              Icons.add_circle,
            ),
          ),
          const SizedBox(
            width: 6,
          )
        ],
        scrolledUnderElevation: 0,
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) {
          return const Divider();
        },
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        itemBuilder: (context, index) {
          return Column(
            children: [
              buildListItem(colorScheme, index),
              const SizedBox(
                height: 4,
              ),
              SizedBox(
                height: 20,
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 4),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, tagIndex) {
                    return Container(
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
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
      height: 46,
      child: InkWell(
          onTap: () {
            launchUrl(Uri.parse(widget.listItem.items[index].url));
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
                widget.listItem.items[index].status == 'unknown'
                    ? const SizedBox()
                    : Ink(
                        decoration: BoxDecoration(
                          color:
                              widget.listItem.items[index].status == 'Accepted'
                                  ? colorScheme.primaryContainer
                                  : colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FittedBox(
                          child: Text(
                            ' ${widget.listItem.items[index].status} ',
                            style: TextStyle(
                              color: widget.listItem.items[index].status ==
                                      'Accepted'
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onErrorContainer,
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
                  widget.listItem.items[index].title,
                  style: TextStyle(
                      fontSize: 18,
                      color: widget.listItem.items[index].status == 'Accepted'
                          ? colorScheme.primary
                          : null,
                      fontWeight:
                          widget.listItem.items[index].status == 'Accepted'
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
                            tooltip: 'Change status',
                            onPressed: () {
                              showDialog(
                                barrierColor:
                                    colorScheme.surfaceTint.withOpacity(0.12),
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  surfaceTintColor: Colors.transparent,
                                  title: const Text('Change status'),
                                  content: SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: ListView(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          child: InkWell(
                                            onTap: () {
                                              LibraryHelper.changeProblemStatus(
                                                  widget.listItem,
                                                  index,
                                                  'Accepted');
                                              setState(() {});
                                              Navigator.pop(context);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                color: colorScheme
                                                    .primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Icon(
                                                    Icons.check_circle_outline,
                                                    color: colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                  const SizedBox(
                                                    width: 6,
                                                  ),
                                                  Text(
                                                    'Accepted',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: colorScheme
                                                          .onPrimaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          height: 50,
                                          child: InkWell(
                                            onTap: () {
                                              LibraryHelper.changeProblemStatus(
                                                  widget.listItem,
                                                  index,
                                                  'Attempted');
                                              setState(() {});
                                              Navigator.pop(context);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                color:
                                                    colorScheme.errorContainer,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Icon(
                                                    Icons.cancel_outlined,
                                                    color: colorScheme
                                                        .onErrorContainer,
                                                  ),
                                                  const SizedBox(
                                                    width: 6,
                                                  ),
                                                  Text(
                                                    'Attempted',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: colorScheme
                                                          .onErrorContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        // TODO: custom status
                                        SizedBox(
                                          height: 50,
                                          child: InkWell(
                                            onTap: () {
                                              LibraryHelper.changeProblemStatus(
                                                  widget.listItem,
                                                  index,
                                                  'unknown');
                                              setState(() {});
                                              Navigator.pop(context);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: const Row(
                                              children: [
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Icon(Icons
                                                    .remove_circle_outline),
                                                SizedBox(
                                                  width: 6,
                                                ),
                                                Text(
                                                  'Clear Status',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.flag_outlined,
                            ),
                          ),
                    widget.online
                        ? const SizedBox()
                        : IconButton(
                            tooltip: 'Edit tags',
                            onPressed: () {
                              showDialog(
                                  barrierColor:
                                      colorScheme.surfaceTint.withOpacity(0.12),
                                  context: context,
                                  builder: (context) => StatefulBuilder(
                                          builder: (context, setState) {
                                        return AlertDialog(
                                          surfaceTintColor: Colors.transparent,
                                          title: Row(
                                            children: [
                                              const Expanded(
                                                  child: Text('Edit Tags')),
                                              IconButton(
                                                onPressed: () {
                                                  editingController.clear();
                                                  showDialog(
                                                    barrierColor: colorScheme
                                                        .surfaceTint
                                                        .withOpacity(0.12),
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      surfaceTintColor:
                                                          Colors.transparent,
                                                      title: const Text(
                                                          'Add a tag'),
                                                      content: TextField(
                                                        autofocus: true,
                                                        maxLines: 1,
                                                        controller:
                                                            editingController,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          labelText: 'tag name',
                                                        ),
                                                        onSubmitted: (value) {
                                                          LibraryHelper
                                                              .addTagToProblem(
                                                                  widget
                                                                      .listItem,
                                                                  index,
                                                                  value);
                                                          setState(() {});
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            LibraryHelper
                                                                .addTagToProblem(
                                                                    widget
                                                                        .listItem,
                                                                    index,
                                                                    editingController
                                                                        .text);
                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text('OK'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  setState(() {});
                                                },
                                                icon: const Icon(
                                                  Icons.new_label,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: SizedBox(
                                            width: 200,
                                            height: 300,
                                            child: ListView.builder(
                                              itemBuilder:
                                                  (context, indexList) {
                                                return SizedBox(
                                                  height: 40,
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 6,
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .label_outline_rounded,
                                                      ),
                                                      const SizedBox(
                                                        width: 6,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          widget
                                                              .listItem
                                                              .items[index]
                                                              .tags[indexList],
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          LibraryHelper
                                                              .removeTagFromProblem(
                                                                  widget
                                                                      .listItem,
                                                                  index,
                                                                  widget
                                                                      .listItem
                                                                      .items[
                                                                          index]
                                                                      .tags[indexList]);
                                                          setState(() {});
                                                        },
                                                        icon: const Icon(
                                                          Icons.close,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              itemCount: widget.listItem
                                                  .items[index].tags.length,
                                            ),
                                          ),
                                        );
                                      })).then((value) {
                                setState(() {});
                              });
                            },
                            icon: const Icon(Icons.label_outline),
                          ),
                    IconButton(
                      tooltip: 'Copy problem',
                      onPressed: () {
                        showDialog(
                          barrierColor:
                              colorScheme.surfaceTint.withOpacity(0.12),
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
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
                                              color:
                                                  colorScheme.primaryContainer,
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
                      icon: const Icon(
                        Icons.copy_rounded,
                      ),
                    ),
                    widget.online
                        ? const SizedBox()
                        : IconButton(
                            tooltip: 'Delete problem',
                            onPressed: () {
                              LibraryHelper.removeProblemFromList(
                                  widget.listItem,
                                  widget.listItem.items[index]);
                              if (index < mark.length) {
                                mark.removeAt(index);
                              }
                              setState(() {});
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                  ],
                )),
                const SizedBox(
                  width: 6,
                )
              ],
            ),
          )),
    );
  }
}
