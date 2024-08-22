import 'dart:io';

import 'package:cf_partner/backend/storage.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';

import 'package:highlight/languages/cpp.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class AntiMacros extends StatefulWidget {
  const AntiMacros({super.key});

  @override
  AntiMacrosState createState() => AntiMacrosState();
}

class AntiMacrosState extends State<AntiMacros> {
  final CodeController _inputController =
      CodeController(text: '// copy your code here\n', language: cpp);
  final CodeController _outputController =
      CodeController(text: '// click run to see result\n', language: cpp);

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
                    child: CodeTheme(
                      data: const CodeThemeData(styles: monokaiSublimeTheme),
                      child: CodeField(
                        expands: true,
                        controller: _inputController,
                        textStyle: const TextStyle(
                          fontFamily: "Fira Code",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CodeTheme(
                      data: const CodeThemeData(styles: monokaiSublimeTheme),
                      child: CodeField(
                        expands: true,
                        controller: _outputController,
                        textStyle: const TextStyle(
                          fontFamily: "Fira Code",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                  // TODO: pick files
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

                      List<String> lines = _inputController.text.split('\n');
                      List<String> filteredLines = lines
                          .where((line) => !line.trim().startsWith('#include'))
                          .toList();
                      await orignFile.writeAsString(filteredLines.join('\n'));

                      try {
                        await shell.run('''

gcc -E -P "$orignPath" -o "$outputPath"

''');
                        _outputController.text =
                            await outputFile.readAsString();
                        setState(() {});
                      } catch (e) {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text(
                              'Error',
                            ),
                            content: const Text('Failed to run command gcc.'),
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
