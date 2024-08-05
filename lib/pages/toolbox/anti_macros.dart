import 'dart:io';

import 'package:cf_partner/backend/storage.dart';
import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';

class AntiMacros extends StatefulWidget {
  const AntiMacros({super.key});

  @override
  AntiMacrosState createState() => AntiMacrosState();
}

class AntiMacrosState extends State<AntiMacros> {
  TextEditingController inputController = TextEditingController();
  TextEditingController outputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Anti-Macros',
        ),
        actions: [
          IconButton(
            tooltip: 'Help',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text(
                    'Help',
                  ),
                  content: const Text(
                    'Remove #define from C/C++ code, this feature needs gcc in your path variables.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.help_outline),
          ),
          const SizedBox(
            width: 6,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      minLines: null,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller: inputController,
                      textAlign: TextAlign.start,
                      expands: true,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      minLines: null,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller: outputController,
                      textAlign: TextAlign.start,
                      expands: true,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text('Open File'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      var shell = Shell();

                      var orignPath = "${AppStorage().dataPath}/orign.cpp";
                      var outputPath = "${AppStorage().dataPath}/output.cpp";

                      var orignFile = File(orignPath);
                      var outputFile = File(outputPath);

                      if (!await orignFile.exists()) {
                        await orignFile.create();
                      }
                      if (!await outputFile.exists()) {
                        await outputFile.create();
                      }

                      List<String> lines = inputController.text.split('\n');
                      List<String> filteredLines = lines
                          .where((line) => !line.trim().startsWith('#include'))
                          .toList();
                      await orignFile.writeAsString(filteredLines.join('\n'));

                      try {
                        await shell.run('''

# Display dart version
gcc -E -P "$orignPath" -o "$outputPath"

''');
                        outputController.text = await outputFile.readAsString();
                        setState(() {});
                      } catch (e) {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text(
                              'Error',
                            ),
                            content: const Text('Failed to run command g++.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.primaryContainer,
                    )),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Run'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
