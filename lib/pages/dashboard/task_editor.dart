import 'package:cf_partner/backend/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskEditor extends StatefulWidget {
  const TaskEditor({super.key});

  @override
  TaskEditorState createState() => TaskEditorState();
}

class TaskEditorState extends State<TaskEditor> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task Ratings'),
      content: SingleChildScrollView(
        child: Column(
          children: List.generate(6, (index) {
            return TextField(
              controller: _controllers[index],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Rating ${index + 1}'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newRatings = _controllers.map((controller) => int.tryParse(controller.text) ?? 800).toList();
            AppStorage().settings.taskRatings = newRatings;
            AppStorage().saveSettings();
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}