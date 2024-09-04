import 'dart:convert';
import 'dart:io';

import 'package:cf_partner/backend/library_helper.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/problem_item.dart';
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

// TODO: rename problem
class ListDetailState extends State<ListDetail> {
  final TextEditingController _editingController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final bool _locked = false;
  late final HttpServer _server;
  bool _listening = true;

  @override
  void initState() {
    super.initState();
    if (!widget.online) {
      initServer();
    }
  }

  void initServer() async {
    _server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      10043,
    );
    // listen to competitive companion
    await for (HttpRequest request in _server) {
      if (request.method == 'POST' && request.uri.path == '/' && _listening) {
        try {
          String content = await utf8.decoder.bind(request).join();
          Map<String, dynamic> data = jsonDecode(content);

          // print('Received JSON data');
          var p = ProblemItem(
            title: data['name'],
            url: data['url'],
            status: 'unknown',
            source: 'others',
            tags: [],
            note: '',
          );
          if (data['url'].contains('codeforces.com')) {
            p.source = 'Codeforces';
          } else if (data['url'].contains('atcoder.jp')) {
            p.source = 'AtCoder';
          }
          LibraryHelper.addProblemToList(
            widget.listItem,
            p,
          );
          setState(() {});
        } catch (e) {
          // print('Error processing request: $e');
          request.response
            ..statusCode = HttpStatus.internalServerError
            ..write('Error processing request')
            ..close();
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!widget.online) {
      _server.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;

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
            // IconButton(
            //   tooltip: 'Refresh',
            //   onPressed: _locked || widget.online
            //       ? null
            //       : () async {
            //           LibraryHelper.refreshList(widget.listItem).then((value) {
            //             setState(() {});
            //           });
            //         },
            //   icon: const Icon(Icons.refresh_rounded),
            // ),
            IconButton(
              tooltip: 'New problem',
              onPressed: _locked || widget.online
                  ? null
                  : () {
                      _titleController.clear();
                      _urlController.clear();
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
                                  controller: _titleController,
                                  decoration: const InputDecoration(
                                    label: Text('Title'),
                                    border: OutlineInputBorder(),
                                    hintText: 'A + B Problem',
                                  ),
                                ),
                                TextField(
                                  autofocus: true,
                                  maxLines: 3,
                                  controller: _urlController,
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
                                  title: _titleController.text,
                                  url: _urlController.text,
                                  status: 'unknown',
                                  source: 'others',
                                  tags: [],
                                  note: '',
                                );
                                if (_urlController.text
                                    .contains('codeforces.com')) {
                                  p.source = 'Codeforces';
                                } else if (_urlController.text
                                    .contains('atcoder.jp')) {
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
                Icons.add,
              ),
            ),
            const SizedBox(
              width: 6,
            )
          ],
        ),
        body: Column(
          children: [
            widget.online
                ? const SizedBox()
                : SizedBox(
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: SwitchListTile(
                        tileColor: _listening
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.4)
                            : Theme.of(context)
                                .colorScheme
                                .tertiaryContainer
                                .withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: Container(
                          alignment: Alignment.centerLeft,
                          height: 40,
                          child: Text(
                            'Automatically add parsed problems',
                            style: TextStyle(
                              color: _listening
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer,
                            ),
                          ),
                        ),
                        value: _listening,
                        onChanged: (bool value) {
                          setState(() {
                            _listening = value;
                          });
                        },
                      ),
                    ),
                  ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      buildListItem(colorScheme, index, widget.listItem.items),
                      const SizedBox(
                        height: 4,
                      ),
                      SizedBox(
                        height:
                            widget.listItem.items[index].tags.isEmpty ? 0 : 20,
                        child: ListView.separated(
                          padding: const EdgeInsets.only(left: 4),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, tagIndex) {
                            return Container(
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              height: widget.listItem.items[index].tags.isEmpty
                                  ? 0
                                  : 20,
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: FittedBox(
                                    child: Text(
                                      widget
                                          .listItem.items[index].tags[tagIndex],
                                      style: TextStyle(
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.w500,
                                      ),
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
            )
          ],
        ));
  }

  Widget buildListItem(
      ColorScheme colorScheme, int index, List<ProblemItem> items) {
    return SizedBox(
      height: 46,
      child: InkWell(
        onTap: () {
          launchUrl(Uri.parse(items[index].url));
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 4,
              ),
              items[index].status == 'unknown'
                  ? const SizedBox()
                  : Container(
                      decoration: BoxDecoration(
                        color: items[index].status == 'Accepted'
                            ? colorScheme.primaryContainer
                            : colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FittedBox(
                        child: Text(
                          ' ${items[index].status} ',
                          style: TextStyle(
                            color: items[index].status == 'Accepted'
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
              Expanded(
                child: Text(
                  // AppStorage().problemlists[index].title,
                  items[index].title,
                  style: TextStyle(
                    fontSize: 18,
                    color: items[index].status == 'Accepted'
                        ? colorScheme.onPrimaryContainer
                        : null,
                    fontWeight: items[index].status == 'Accepted'
                        ? FontWeight.w500
                        : null,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              widget.online
                  ? const SizedBox()
                  : IconButton(
                      tooltip: 'Mark',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
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
                                            widget.listItem, index, 'Accepted');
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
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
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.tertiaryContainer,
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
                                                  .onTertiaryContainer,
                                            ),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            Text(
                                              'Attempted',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: colorScheme
                                                    .onTertiaryContainer,
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
                                            widget.listItem, index, 'unknown');
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: const Row(
                                        children: [
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Icon(Icons.remove_circle_outline),
                                          SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            'Clear Status',
                                            style: TextStyle(fontSize: 18),
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
                      tooltip: 'Tags',
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                StatefulBuilder(builder: (context, setState) {
                                  return AlertDialog(
                                    title: Row(
                                      children: [
                                        const Expanded(
                                            child: Text('Edit Tags')),
                                        IconButton(
                                          tooltip: 'Add a tag',
                                          onPressed: () {
                                            _editingController.clear();
                                            showDialog(
                                              barrierColor: colorScheme
                                                  .surfaceTint
                                                  .withOpacity(0.06),
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                title: const Text('Add a tag'),
                                                content: TextField(
                                                  autofocus: true,
                                                  maxLines: 1,
                                                  controller:
                                                      _editingController,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: 'tag name',
                                                  ),
                                                  onSubmitted: (value) {
                                                    LibraryHelper
                                                        .addTagToProblem(
                                                            widget.listItem,
                                                            index,
                                                            value);
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
                                                      LibraryHelper
                                                          .addTagToProblem(
                                                              widget.listItem,
                                                              index,
                                                              _editingController
                                                                  .text);
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
                                          icon: const Icon(
                                            Icons.new_label,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: SizedBox(
                                      width: 400,
                                      height: 300,
                                      child: ListView.builder(
                                        itemBuilder: (context, indexList) {
                                          return SizedBox(
                                            height: 40,
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  width: 6,
                                                ),
                                                const Icon(
                                                  Icons.label_outline_rounded,
                                                ),
                                                const SizedBox(
                                                  width: 6,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    widget.listItem.items[index]
                                                        .tags[indexList],
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    LibraryHelper
                                                        .removeTagFromProblem(
                                                            widget.listItem,
                                                            index,
                                                            widget
                                                                    .listItem
                                                                    .items[index]
                                                                    .tags[
                                                                indexList]);
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
                                        itemCount: widget
                                            .listItem.items[index].tags.length,
                                      ),
                                    ),
                                  );
                                })).then((value) {
                          setState(() {});
                        });
                      },
                      icon: const Icon(Icons.label_outline),
                    ),
              widget.online
                  ? const SizedBox()
                  : IconButton(
                      tooltip: 'Note',
                      onPressed: () {
                        _editingController.text = items[index].note;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text(
                              items[index].title,
                            ),
                            content: SizedBox(
                              height: 400,
                              width: 600,
                              child: TextField(
                                autofocus: true,
                                minLines: null,
                                maxLines: null,
                                expands: true,
                                controller: _editingController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) {
                                  LibraryHelper.changeProblemNote(
                                    widget.listItem,
                                    index,
                                    value,
                                  );
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
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
                                  LibraryHelper.changeProblemNote(
                                    widget.listItem,
                                    index,
                                    _editingController.text,
                                  );
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
                      icon: const Icon(Icons.notes_outlined),
                    ),
              widget.online
                  ? const SizedBox()
                  : IconButton(
                      tooltip: 'Rename',
                      onPressed: () {
                        _editingController.text = items[index].title;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Rename'),
                            content: TextField(
                              autofocus: true,
                              controller: _editingController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (value) {
                                LibraryHelper.renameProblem(
                                  widget.listItem,
                                  index,
                                  value,
                                );
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
                                  LibraryHelper.renameProblem(
                                    widget.listItem,
                                    index,
                                    _editingController.text,
                                  );
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
                      icon: const Icon(Icons.drive_file_rename_outline),
                    ),
              IconButton(
                tooltip: 'Copy',
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
                                      items[index]);
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
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      height: 50,
                                      width: 50,
                                      child: Icon(
                                        Icons.star_rounded,
                                        color: colorScheme.onPrimaryContainer,
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
              widget.online
                  ? const SizedBox()
                  : IconButton(
                      tooltip: 'Delete',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text(
                              'Confirm',
                            ),
                            content: Text(
                              'Delete problem ${items[index].title}',
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
                                  LibraryHelper.removeProblemFromList(
                                      widget.listItem, items[index]);
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline),
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
