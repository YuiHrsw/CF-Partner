import 'dart:convert';
import 'dart:io';

import 'package:cf_partner/backend/cfapi/models/problem.dart';
import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:path/path.dart';

class LibraryHelper {
  static Future<List<ListItem>> loadLists() async {
    var playlists = <ListItem>[];
    var dir = Directory('${AppStorage().dataPath}/lists/');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
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

  static void addProblemToList(ListItem list, Problem p) {
    list.items.add(p);
    saveList(list);
  }

  static void removeProblemFromList(ListItem list, Problem p) {
    list.items.remove(p);
    saveList(list);
  }
}
