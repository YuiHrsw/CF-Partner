import 'dart:io';

import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/backend/web_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _handleController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        ),
      ),
      body: ListView(
        children: [
          // Container(
          //   padding: const EdgeInsets.all(12),
          //   child: Text(
          //     'General',
          //     style: TextStyle(
          //       fontSize: 20,
          //       fontWeight: FontWeight.w500,
          //       color: Theme.of(context).colorScheme.primary,
          //     ),
          //   ),
          // ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Codeforces handle'),
            trailing: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: 140,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: TextField(
                textAlign: TextAlign.center,
                controller: _handleController,
                maxLines: 1,
                decoration: InputDecoration.collapsed(
                  hintText: AppStorage().settings.handle,
                ),
                onSubmitted: (value) {
                  AppStorage().settings.handle = value;
                  AppStorage().saveSettings();
                  setState(() {});
                  _handleController.clear();
                },
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cookie_outlined),
            title: const Text('Clist sessionid'),
            trailing: OutlinedButton(
              onPressed: () {
                _controller.clear();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    surfaceTintColor: Colors.transparent,
                    title: const Text('cookies'),
                    content: SizedBox(
                      width: 400,
                      height: 300,
                      child: TextField(
                        autofocus: true,
                        maxLines: null,
                        minLines: null,
                        expands: true,
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Clist sessonid',
                        ),
                        onSubmitted: (value) async {
                          await WebHelper.cookieManager.cookieJar
                              .saveFromResponse(Uri.parse('https://clist.by'),
                                  [Cookie('sessionid', value)]);
                          if (!context.mounted) return;
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
                        onPressed: () async {
                          String value = _controller.text;
                          await WebHelper.cookieManager.cookieJar
                              .saveFromResponse(Uri.parse('https://clist.by'),
                                  [Cookie('sessionid', value)]);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Set'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Theme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Theme color'),
            trailing: SizedBox(
              height: 40,
              width: 140,
              child: DropdownButtonFormField(
                // icon: const SizedBox(),
                isExpanded: true,
                borderRadius: BorderRadius.circular(16),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fillColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
                value: AppStorage().settings.themeCode,
                items: List.generate(AppStorage().colors.length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Row(
                      children: [
                        ColoredBox(
                          color: AppStorage().colors[index],
                          child: const SizedBox(
                            height: 16,
                            width: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(AppStorage().themes[index]),
                      ],
                    ),
                  );
                }),
                onChanged: (value) {
                  AppStorage().settings.themeCode = value!;
                  AppStorage().saveSettings();
                  AppStorage().updateStatus();
                },
              ),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          SwitchListTile(
              title: const Row(
                children: [
                  Icon(
                    Icons.brightness_auto_outlined,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text('Follow system theme mode')
                ],
              ),
              value: AppStorage().settings.themeMode == ThemeMode.system,
              onChanged: (bool value) {
                if (value) {
                  setState(() {
                    AppStorage().settings.themeMode = ThemeMode.system;
                  });
                } else {
                  setState(() {
                    AppStorage().settings.themeMode =
                        Theme.of(context).brightness == Brightness.dark
                            ? ThemeMode.dark
                            : ThemeMode.light;
                  });
                }
                AppStorage().saveSettings();
                AppStorage().updateStatus();
              }),
          const SizedBox(
            height: 8,
          ),
          AppStorage().settings.themeMode == ThemeMode.system
              ? const SizedBox()
              : SwitchListTile(
                  title: const Row(
                    children: [
                      Icon(
                        Icons.dark_mode_outlined,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text('Dark mode')
                    ],
                  ),
                  value: AppStorage().settings.themeMode == ThemeMode.dark,
                  onChanged: (bool value) {
                    if (value) {
                      setState(() {
                        AppStorage().settings.themeMode = ThemeMode.dark;
                      });
                    } else {
                      setState(() {
                        AppStorage().settings.themeMode = ThemeMode.light;
                      });
                    }
                    AppStorage().saveSettings();
                    AppStorage().updateStatus();
                  },
                ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Storage',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              launchUrl(Uri.directory(AppStorage().dataPath));
            },
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Open data folder'),
            subtitle: Text(AppStorage().dataPath),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.assessment_outlined,
            ),
            title: const Text('CF Partner'),
            trailing: const Text(
              'v 3.1',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () {
              launchUrl(Uri.https('github.com', '/YuiHrsw/CF-Partner'));
            },
          )
        ],
      ),
    );
  }
}
