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
              width: 120,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: TextField(
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
              'Theme Mode',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
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
              'Colors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          RadioListTile(
              title: const Text('Pink'),
              value: 0,
              groupValue: AppStorage().settings.themeCode,
              onChanged: (int? value) {
                setState(() {
                  AppStorage().settings.themeCode = value!;
                });
                AppStorage().saveSettings();
                AppStorage().updateStatus();
              }),
          RadioListTile(
              title: const Text('Orange'),
              value: 1,
              groupValue: AppStorage().settings.themeCode,
              onChanged: (int? value) {
                setState(() {
                  AppStorage().settings.themeCode = value!;
                });
                AppStorage().saveSettings();
                AppStorage().updateStatus();
              }),
          RadioListTile(
              title: const Text('Amber'),
              value: 2,
              groupValue: AppStorage().settings.themeCode,
              onChanged: (int? value) {
                setState(() {
                  AppStorage().settings.themeCode = value!;
                });
                AppStorage().saveSettings();
                AppStorage().updateStatus();
              }),
          RadioListTile(
              title: const Text('Teal'),
              value: 3,
              groupValue: AppStorage().settings.themeCode,
              onChanged: (int? value) {
                setState(() {
                  AppStorage().settings.themeCode = value!;
                });
                AppStorage().saveSettings();
                AppStorage().updateStatus();
              }),
          RadioListTile(
              title: const Text('Blue'),
              value: 4,
              groupValue: AppStorage().settings.themeCode,
              onChanged: (int? value) {
                setState(() {
                  AppStorage().settings.themeCode = value!;
                });
                AppStorage().saveSettings();
                AppStorage().updateStatus();
              }),
          RadioListTile(
              title: const Text('Indigo'),
              value: 5,
              groupValue: AppStorage().settings.themeCode,
              onChanged: (int? value) {
                setState(() {
                  AppStorage().settings.themeCode = value!;
                });
                AppStorage().saveSettings();
                AppStorage().updateStatus();
              }),
          RadioListTile(
              title: const Text('Purple'),
              value: 6,
              groupValue: AppStorage().settings.themeCode,
              onChanged: (int? value) {
                setState(() {
                  AppStorage().settings.themeCode = value!;
                });
                AppStorage().saveSettings();
                AppStorage().updateStatus();
              }),
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
              Icons.bar_chart_rounded,
              size: 34,
            ),
            title: const Text('CF Partner'),
            trailing: const Text(
              'v 0.3',
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
