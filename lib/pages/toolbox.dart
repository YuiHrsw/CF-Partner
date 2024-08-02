import 'package:cf_partner/pages/tracker.dart';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

class Toolbox extends StatefulWidget {
  const Toolbox({super.key});

  @override
  ToolboxState createState() => ToolboxState();
}

class ToolboxState extends State<Toolbox> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Toolbox',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        ),
        actions: [
          IconButton(
            tooltip: 'Request new features',
            onPressed: () {},
            icon: const Icon(Icons.message),
          ),
          const SizedBox(
            width: 6,
          )
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.fact_check_outlined,
            ),
            title: const Text('Comparer'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.baby_changing_station,
            ),
            title: const Text('Testcase Generator'),
            onTap: () {},
          ),
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
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.link,
            ),
            title: const Text('Link Generator'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
