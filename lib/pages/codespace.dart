import 'package:flutter/material.dart';

class Codespace extends StatefulWidget {
  const Codespace({super.key});

  @override
  CodespaceState createState() => CodespaceState();
}

class CodespaceState extends State<Codespace> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '<Problem Title>',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        ),
        actions: [
          IconButton(
            tooltip: 'Config',
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
          const SizedBox(
            width: 6,
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.add,
            ),
            title: const Text('New testcase'),
            onTap: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Row(
          children: [
            Icon(
              Icons.play_arrow,
              size: 30,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Run',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
