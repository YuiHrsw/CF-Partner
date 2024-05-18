import 'package:cf_partner/backend/cfapi/cf_helper.dart';
import 'package:cf_partner/backend/library_helper.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
  bool gym = false;
  late List<bool> mark;

  @override
  void initState() {
    super.initState();
    mark = List.filled(widget.listItem.items.length, false, growable: true);
  }

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    final TextEditingController contestIdController = TextEditingController();
    final TextEditingController problemIdController = TextEditingController();

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
            icon: const Icon(Icons.file_upload_outlined),
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
                    // mark = await CFHelper.getListStatus(widget.listItem.items);
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
                    contestIdController.clear();
                    showDialog(
                      barrierDismissible: false,
                      barrierColor: colorScheme.surfaceTint.withOpacity(0.12),
                      useRootNavigator: false,
                      context: context,
                      builder: (BuildContext context) =>
                          StatefulBuilder(builder: (context, setState) {
                        return AlertDialog(
                          surfaceTintColor: Colors.transparent,
                          title: const Text('Add CF Problems'),
                          content: SizedBox(
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        autofocus: true,
                                        maxLines: 1,
                                        controller: contestIdController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: '1561',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    SizedBox(
                                      width: 70,
                                      child: TextField(
                                        autofocus: true,
                                        maxLines: 1,
                                        controller: problemIdController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'D2',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SwitchListTile(
                                  title: const Text('Gym'),
                                  value: gym,
                                  onChanged: (value) {
                                    setState(() {
                                      gym = value;
                                    });
                                  },
                                ),
                              ],
                            ),
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
                                      var cid = contestIdController.text;
                                      var pid = problemIdController.text;
                                      try {
                                        var res = await CFHelper.getProblem(
                                          int.parse(cid),
                                          pid,
                                        );

                                        if (res == null) {
                                          setState(() {
                                            locked = false;
                                          });
                                          if (!context.mounted) return;
                                          Navigator.pop(context);
                                          return;
                                        }
                                        if (gym) {
                                          res.gym = true;
                                        }

                                        LibraryHelper.addProblemToList(
                                          widget.listItem,
                                          CFHelper.toLocalProblem(res),
                                        );
                                        mark.add(
                                            await CFHelper.getPloblemStatus(
                                                res));
                                      } catch (e) {
                                        if (kDebugMode) {
                                          print(
                                              "can not get problem status: $cid$pid");
                                        }
                                      }
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
            icon: const Icon(
              Icons.add_chart_rounded,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    return Ink(
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
                                  : colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FittedBox(
                          child: Text(
                            ' ${widget.listItem.items[index].status} ',
                            style: TextStyle(
                              color: widget.listItem.items[index].status ==
                                      'Accepted'
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSecondaryContainer,
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
                            onPressed: () {
                              //show note
                            },
                            icon: const Icon(Icons.notes),
                          ),
                    widget.online
                        ? const SizedBox()
                        : IconButton(
                            onPressed: () {
                              //add/remove label, edit note, change status
                            },
                            icon: const Icon(
                                Icons.drive_file_rename_outline_outlined),
                          ),
                    // widget.online
                    //     ? const SizedBox()
                    //     : IconButton(
                    //         onPressed: () {
                    //           editingController.clear();
                    //           showDialog(
                    //             barrierColor:
                    //                 colorScheme.surfaceTint.withOpacity(0.12),
                    //             useRootNavigator: false,
                    //             context: context,
                    //             builder: (BuildContext context) => AlertDialog(
                    //               surfaceTintColor: Colors.transparent,
                    //               title: const Text('Add a tag'),
                    //               content: TextField(
                    //                 autofocus: true,
                    //                 maxLines: 1,
                    //                 controller: editingController,
                    //                 decoration: const InputDecoration(
                    //                   border: OutlineInputBorder(),
                    //                   labelText: 'tag name',
                    //                 ),
                    //                 onSubmitted: (value) {
                    //                   LibraryHelper.addTagToProblem(
                    //                       widget.listItem, index, value);
                    //                   setState(() {});
                    //                   Navigator.pop(context);
                    //                 },
                    //               ),
                    //               actions: <Widget>[
                    //                 TextButton(
                    //                   onPressed: () {
                    //                     Navigator.pop(context);
                    //                   },
                    //                   child: const Text('Cancel'),
                    //                 ),
                    //                 TextButton(
                    //                   onPressed: () {
                    //                     LibraryHelper.addTagToProblem(
                    //                         widget.listItem,
                    //                         index,
                    //                         editingController.text);
                    //                     setState(() {});
                    //                     Navigator.pop(context);
                    //                   },
                    //                   child: const Text('OK'),
                    //                 ),
                    //               ],
                    //             ),
                    //           );
                    //           setState(() {});
                    //         },
                    //         icon: const Icon(Icons.new_label_outlined),
                    //       ),
                    // widget.online
                    //     ? const SizedBox()
                    //     : IconButton(
                    //         onPressed: () {
                    //           showDialog(
                    //             barrierColor:
                    //                 colorScheme.surfaceTint.withOpacity(0.12),
                    //             useRootNavigator: false,
                    //             context: context,
                    //             builder: (BuildContext context) => AlertDialog(
                    //               surfaceTintColor: Colors.transparent,
                    //               title: const Text('Remove Tags'),
                    //               content: SizedBox(
                    //                 width: 200,
                    //                 height: 300,
                    //                 child: ListView.builder(
                    //                   itemBuilder: (context, indexList) {
                    //                     return SizedBox(
                    //                         height: 40,
                    //                         child: InkWell(
                    //                           onTap: () {
                    //                             LibraryHelper
                    //                                 .removeTagToProblem(
                    //                                     widget.listItem,
                    //                                     index,
                    //                                     widget
                    //                                         .listItem
                    //                                         .items[index]
                    //                                         .tags[indexList]);
                    //                             setState(() {});
                    //                             Navigator.pop(context);
                    //                           },
                    //                           borderRadius:
                    //                               BorderRadius.circular(20),
                    //                           child: Row(
                    //                             children: [
                    //                               const SizedBox(
                    //                                 width: 6,
                    //                               ),
                    //                               const Icon(Icons
                    //                                   .label_outline_rounded),
                    //                               const SizedBox(
                    //                                 width: 6,
                    //                               ),
                    //                               Text(
                    //                                 widget.listItem.items[index]
                    //                                     .tags[indexList],
                    //                                 style: const TextStyle(
                    //                                     fontSize: 18),
                    //                               ),
                    //                             ],
                    //                           ),
                    //                         ));
                    //                   },
                    //                   itemCount: widget
                    //                       .listItem.items[index].tags.length,
                    //                 ),
                    //               ),
                    //             ),
                    //           );
                    //           setState(() {});
                    //         },
                    //         icon: const Icon(Icons.label_off_outlined),
                    //       ),
                    IconButton(
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
                        Icons.add_circle_outline,
                      ),
                    ),
                    widget.online
                        ? const SizedBox()
                        : IconButton(
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
