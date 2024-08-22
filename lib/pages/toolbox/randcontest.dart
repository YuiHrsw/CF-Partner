import 'package:flutter/material.dart';

class Playground extends StatefulWidget {
  const Playground({super.key});

  @override
  PlaygroundState createState() => PlaygroundState();
}

class PlaygroundState extends State<Playground> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: const Text(
          'Rand Contest',
        ),
        actions: [
          IconButton(
            tooltip: 'Restart',
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(
            width: 6,
          )
        ],
      ),
      body: const Center(
        child: Text('not finished yet'),
      ),
    );
  }
}
