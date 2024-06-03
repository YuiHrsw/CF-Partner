import 'package:cf_partner/backend/storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        ),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: [
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
            title: const Text('Codeforces Handle'),
            trailing: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: 140,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: TextField(
                textAlign: TextAlign.center,
                controller: controller,
                maxLines: 1,
                decoration: InputDecoration.collapsed(
                  hintText: AppStorage().settings.handle,
                ),
                onSubmitted: (value) {
                  AppStorage().settings.handle = value;
                  AppStorage().saveSettings();
                  setState(() {});
                  controller.clear();
                },
              ),
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
            title: const Text('Theme Color'),
            trailing: SizedBox(
              height: 50,
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
              title: const Text('Theme Mode follow system'),
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
                  title: const Text('Dark Mode'),
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
            title: const Text('Open Data Folder'),
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
              Icons.bar_chart,
            ),
            title: const Text('CF Partner 2'),
            trailing: const Text(
              'v 2.0',
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
