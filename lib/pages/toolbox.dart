import 'package:cf_partner/pages/toolbox/anti_macros.dart';
import 'package:cf_partner/pages/toolbox/randcontest.dart';
import 'package:cf_partner/pages/toolbox/tracker.dart';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

class Toolbox extends StatefulWidget {
  const Toolbox({super.key});

  @override
  ToolboxState createState() => ToolboxState();
}

class ToolboxState extends State<Toolbox> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Toolbox',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.track_changes_outlined,
            ),
            title: const Text('CF Tracker'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TrackerPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.find_replace,
            ),
            title: const Text('Anti-Macros'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AntiMacros(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.bar_chart_rounded,
            ),
            title: const Text('Rand Contest'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Playground(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
