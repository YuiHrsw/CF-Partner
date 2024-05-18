import 'dart:convert';
import 'dart:io';

import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/problem_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:path/path.dart';

class LibraryHelper {
  static Future<List<ListItem>> loadLists() async {
    var playlists = <ListItem>[];
    var dir = Directory('${AppStorage().dataPath}/lists/');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await for (var item in dir.list()) {
      if (item is File && extension(item.path) == '.json') {
        var pl = ListItem.fromJson(jsonDecode(await item.readAsString()));
        playlists.add(pl);
      }
    }
    return playlists;
  }

  static void saveList(ListItem list) {
    var fp = File('${AppStorage().dataPath}/lists/${list.title}.json');
    if (!fp.existsSync()) {
      fp.createSync(recursive: true);
    }
    var data = list.toJson();
    fp.writeAsString(jsonEncode(data));
  }

  static void deleteList(ListItem list) {
    var fp = File('${AppStorage().dataPath}/lists/${list.title}.json');
    if (fp.existsSync()) {
      fp.deleteSync();
    }
  }

  static void addProblemToList(ListItem list, ProblemItem p) {
    list.items.add(p);
    saveList(list);
  }

  static void removeProblemFromList(ListItem list, ProblemItem p) {
    list.items.remove(p);
    saveList(list);
  }

  static void addTagToProblem(ListItem list, int index, String tag) {
    var p = list.items[index].tags;
    p.add(tag);
    saveList(list);
  }

  static void removeTagToProblem(ListItem list, int index, String tag) {
    var p = list.items[index].tags;
    p.remove(tag);
    saveList(list);
  }

  static void saveListFile(String location) async {
    var fp = File(location);
    var pl = ListItem.fromJson(jsonDecode(await fp.readAsString()));
    AppStorage().problemlists.add(pl);
    saveList(pl);
  }

  static void exportListFile(ListItem list, String location) {
    var dst = File(location);
    if (!dst.existsSync()) {
      dst.createSync();
    }
    var fp = File('${AppStorage().dataPath}/lists/${list.title}.json');
    fp.copy(location);
  }
}
