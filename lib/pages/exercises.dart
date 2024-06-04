import 'package:cf_partner/backend/library_helper.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/pages/list_detail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Exercises extends StatefulWidget {
  const Exercises({super.key});

  @override
  ExercisesState createState() => ExercisesState();
}

// TODO: random exercise
class ExercisesState extends State<Exercises> {
  final TextEditingController editingController = TextEditingController();
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    AppStorage().problemlists.addAll(await LibraryHelper.loadLists());
    if (!mounted) return;
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exercises',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                dialogTitle: 'Import a json problem list file...',
                type: FileType.custom,
                allowedExtensions: ["json"],
              );

              if (result == null) {
                return;
              }

              LibraryHelper.saveListFile(result.files.single.path!);
              setState(() {});
            },
            icon: const Icon(Icons.insert_drive_file),
          ),
          IconButton(
              onPressed: () {
                editingController.clear();
                showDialog(
                  barrierColor: colorScheme.surfaceTint.withOpacity(0.12),
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    surfaceTintColor: Colors.transparent,
                    title: const Text('New List'),
                    content: TextField(
                      autofocus: true,
                      maxLines: 1,
                      controller: editingController,
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
                            title: editingController.text,
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
              icon: const Icon(Icons.add_circle)),
          const SizedBox(
            width: 6,
          )
        ],
        scrolledUnderElevation: 0,
      ),
      body: loaded
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
                                onPressed: () {
                                  LibraryHelper.deleteList(
                                      AppStorage().problemlists[index]);
                                  AppStorage().problemlists.removeAt(index);
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
              itemCount: AppStorage().problemlists.length,
            )
          : const Center(
              heightFactor: 10,
              child: CircularProgressIndicator(),
            ),
    );
  }
}
