import 'package:cf_partner/backend/cfapi/cf_helper.dart';
import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/pages/dashboard/task_editor.dart';
import 'package:flutter/material.dart';

class Bingo extends StatefulWidget {
  const Bingo({super.key});

  @override
  State<Bingo> createState() => _BingoState();
}

class _BingoState extends State<Bingo> {
  final List<bool> _selectedStates = List.filled(6, false);
  // final List<Color> colors = [
  //   Colors.purple,
  //   Colors.deepPurple,
  //   Colors.deepPurple,
  //   Colors.amber,
  //   Colors.amber,
  //   Colors.amber,
  // ];

  @override
  void initState() {
    super.initState();
    int msk = AppStorage().settings.taskStatus;
    for (int i = 0; i < 6; i++) {
      _selectedStates[i] = (msk >> i & 1) == 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedCount = _selectedStates.where((selected) => selected).length;
    List<Color> colors = List.generate(
      6,
      (index) => CFHelper.getColorDetailed(
        AppStorage().settings.taskRatings[index],
      ),
    );
    double progress = selectedCount / _selectedStates.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Tasks - $selectedCount / ${_selectedStates.length} Finished',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                tooltip: 'Edit Tasks',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const TaskEditor(),
                  ).then((_) {
                    setState(() {});
                  });
                },
                icon: const Icon(Icons.drive_file_rename_outline),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStates[index] = !_selectedStates[index];
                  });
                  int msk = 0;
                  for (int i = 0; i < 6; i++) {
                    if (_selectedStates[i]) msk |= 1 << i;
                  }
                  AppStorage().settings.taskStatus = msk;
                  AppStorage().saveSettings();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[index],
                  ),
                  child: _selectedStates[index]
                      ? Icon(
                          Icons.check,
                          color: ColorScheme.fromSeed(seedColor: colors[index])
                              .onPrimary,
                          size: 30,
                        )
                      : null,
                ),
              );
            }),
          ),
        ),
        // Text(
        //   '$selectedCount / ${_selectedStates.length} Finished',
        //   style: const TextStyle(fontSize: 16),
        // ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: LinearProgressIndicator(
            borderRadius: BorderRadius.circular(10),
            value: progress,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
