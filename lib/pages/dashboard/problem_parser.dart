import 'package:cf_partner/backend/problem_item.dart';
import 'package:cf_partner/pages/dashboard/models/challenge_problem.dart';

List<ChallengeProblem> parse(String markdownContent) {
  List<ChallengeProblem> res = [];

  final tableStartPattern =
      RegExp(r'\| Difficulty \| Problems \| Hints \| Solution \|');
  final tableEndPattern =
      RegExp(r'\| -------- \| -------- \| -------- \| -------- \|');

  final lines = markdownContent.split('\n');

  bool isTableSection = false;
  final tableContent = <String>[];

  for (final line in lines) {
    if (tableStartPattern.hasMatch(line)) {
      isTableSection = true;
      continue;
    } else if (isTableSection && tableEndPattern.hasMatch(line)) {
      continue;
    } else if (isTableSection && line.trim().isEmpty) {
      isTableSection = false;
    } else if (isTableSection) {
      tableContent.add(line);
    }
  }

  for (final row in tableContent) {
    final columns = row
        .split('|')
        .map((col) => col.trim())
        .where((col) => col.isNotEmpty)
        .toList();
    if (columns.length == 4) {
      final difficulty = columns[0];
      final problemName =
          RegExp(r'\[(.*?)\]').firstMatch(columns[1])?.group(1) ?? 'N/A';
      final problemLink =
          RegExp(r'\((.*?)\)').firstMatch(columns[1])?.group(1) ?? 'N/A';
      final hint = columns[2];
      final solutionLink =
          RegExp(r'\((.*?)\)').firstMatch(columns[3])?.group(1) ?? 'N/A';

      res.add(
        ChallengeProblem(
          title: problemName,
          source: 'Codeforces',
          url: problemLink,
          status: 'unknown',
          note: '',
          tags: [],
          hint: hint,
          tutorial: solutionLink,
          difficulty: difficulty,
        ),
      );
    }
  }

  return res;
}

List<ProblemItem> parseToLocal(String markdownContent) {
  List<ProblemItem> res = [];

  final tableStartPattern =
      RegExp(r'\| Difficulty \| Problems \| Hints \| Solution \|');
  final tableEndPattern =
      RegExp(r'\| -------- \| -------- \| -------- \| -------- \|');

  final lines = markdownContent.split('\n');

  bool isTableSection = false;
  final tableContent = <String>[];

  for (final line in lines) {
    if (tableStartPattern.hasMatch(line)) {
      isTableSection = true;
      continue;
    } else if (isTableSection && tableEndPattern.hasMatch(line)) {
      continue;
    } else if (isTableSection && line.trim().isEmpty) {
      isTableSection = false;
    } else if (isTableSection) {
      tableContent.add(line);
    }
  }

  for (final row in tableContent) {
    final columns = row
        .split('|')
        .map((col) => col.trim())
        .where((col) => col.isNotEmpty)
        .toList();
    if (columns.length == 4) {
      // final difficulty = columns[0];
      final problemName =
          RegExp(r'\[(.*?)\]').firstMatch(columns[1])?.group(1) ?? 'N/A';
      final problemLink =
          RegExp(r'\((.*?)\)').firstMatch(columns[1])?.group(1) ?? 'N/A';
      final hint = columns[2];
      final solutionLink =
          RegExp(r'\((.*?)\)').firstMatch(columns[3])?.group(1) ?? 'N/A';

      res.add(
        ProblemItem(
          title: problemName,
          source: 'Codeforces',
          url: problemLink,
          status: 'unknown',
          note: 'Hint:\n$hint\n\nTutorial:\n$solutionLink',
          tags: [],
        ),
      );
    }
  }

  return res;
}
