import 'dart:convert';
import 'dart:io';

import 'package:cf_partner/backend/list_item.dart';
import 'package:cf_partner/backend/settings.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AppStorage extends ChangeNotifier {
  late AppSettings settings;
  List<ListItem> problemlists = [];

  String dataPath = '';

  static final AppStorage _instance = AppStorage._internal();
  factory AppStorage() => _instance;
  AppStorage._internal() {
    settings = AppSettings();
  }

  Future<void> init() async {
    dataPath = (await getApplicationSupportDirectory()).path;
    await loadSettings();
  }

  Future<void> loadSettings() async {
    var settingsPath = "$dataPath/config/settings.json";
    var fp = File(settingsPath);
    if (!await fp.exists()) {
      await fp.create(recursive: true);
      var data = AppSettings().toJson();
      var str = jsonEncode(data);
      await fp.writeAsString(str);
    }
    settings = AppSettings.fromJson(jsonDecode(await fp.readAsString()));
    // notifyListeners();
  }

  Future<void> saveSettings() async {
    var settingsPath = "$dataPath/config/settings.json";
    var fp = File(settingsPath);
    var data = settings.toJson();
    var str = jsonEncode(data);
    await fp.writeAsString(str);
    // notifyListeners();
  }

  void updateStatus() {
    notifyListeners();
  }
}
