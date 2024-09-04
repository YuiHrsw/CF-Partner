import 'package:cf_partner/backend/library_helper.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/pages/list_detail.dart';
import 'package:flutter/material.dart';

class Exercises extends StatefulWidget {
  const Exercises({super.key});

  @override
  ExercisesState createState() => ExercisesState();
}

class ExercisesState extends State<Exercises> {
  final TextEditingController _editingController = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    AppStorage().problemlists.addAll(await LibraryHelper.loadLists());
    if (!mounted) return;
    setState(() {
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        ),
        actions: [
          // IconButton(
          //   tooltip: 'Refresh',
          //   onPressed: () async {
          //     setState(() {
          //       _loaded = false;
          //     });
          //     AppStorage().problemlists.clear();
          //     AppStorage().problemlists.addAll(await LibraryHelper.loadLists());
          //     setState(() {
          //       _loaded = true;
          //     });
          //   },
          //   icon: const Icon(Icons.refresh_rounded),
          // ),
          // IconButton(
          //   tooltip: 'Open folder',
          //   onPressed: () {
          //     var path = "${AppStorage().dataPath}/lists/";
          //     launchUrl(Uri.directory(path));
          //   },
          //   icon: const Icon(Icons.folder),
          // ),
          IconButton(
              tooltip: 'New list',
              onPressed: () {
                _editingController.clear();
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('New Problems List'),
                    content: TextField(
                      autofocus: true,
                      maxLines: 1,
                      controller: _editingController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'name',
                      ),
                      onSubmitted: (value) {
                        var pl = ListItem(
                          items: [],
                          title: value,
                        );
                        LibraryHelper.saveList(pl);
                        setState(() {
                          AppStorage().problemlists.add(pl);
                        });
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
                          var pl = ListItem(
                            items: [],
                            title: _editingController.text,
                          );
                          LibraryHelper.saveList(pl);
                          setState(() {
                            AppStorage().problemlists.add(pl);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.add)),
          const SizedBox(
            width: 6,
          )
        ],
      ),
      body: _loaded
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 60,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ListDetail(
                            listItem: AppStorage().problemlists[index],
                            online: false,
                          ),
                        ),
                      );
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 50,
                          width: 50,
                          child: Icon(
                            Icons.star_rounded,
                            // TODO: custom icon
                            // const IconData(57344, fontFamily: 'MaterialIcons'),
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          AppStorage().problemlists[index].title,
                          style: const TextStyle(fontSize: 18),
                        ),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              tooltip: 'Rename list',
                              onPressed: () {
                                // _editingController.clear();
                                _editingController.text =
                                    AppStorage().problemlists[index].title;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text('Rename List'),
                                    content: TextField(
                                      autofocus: true,
                                      maxLines: 1,
                                      controller: _editingController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'name',
                                      ),
                                      onSubmitted: (value) {
                                        LibraryHelper.renameList(
                                            AppStorage().problemlists[index],
                                            value);
                                        AppStorage().problemlists[index].title =
                                            value;
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
                                          LibraryHelper.renameList(
                                              AppStorage().problemlists[index],
                                              _editingController.text);
                                          AppStorage()
                                              .problemlists[index]
                                              .title = _editingController.text;
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
                                Icons.drive_file_rename_outline,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete list',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text(
                                      'Confirm',
                                    ),
                                    content: Text(
                                      'Delete list ${AppStorage().problemlists[index].title}',
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
                                          LibraryHelper.deleteList(
                                              AppStorage().problemlists[index]);
                                          AppStorage()
                                              .problemlists
                                              .removeAt(index);
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline,
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
                );
              },
              itemCount: AppStorage().problemlists.length,
            )
          : const Center(
              heightFactor: 10,
              child: CircularProgressIndicator(),
            ),
    );
  }
}
