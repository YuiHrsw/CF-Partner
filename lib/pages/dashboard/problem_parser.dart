import 'package:cf_partner/backend/problem_item.dart';
import 'package:cf_partner/pages/dashboard/models/challenge_problem.dart';

List<ChallengeProblem> parse(String markdownContent) {
  List<ChallengeProblem> res = [];

  final tableStartPattern =
      RegExp(r'\| Difficulty \| Problems \| Hints \| Solution \|');
  final tableEndPattern = RegExp(r'\| (-+) \| (-+) \| (-+) \| (-+) \|');
  final rowPattern =
      RegExp(r'^\| ([^\|]+) \| ([^\|]+) \| (.+?) \| ([^\|]+) \|$'); // 精确匹配表格行

  final lines = markdownContent.split('\n');

  bool isTableSection = false;

  for (final line in lines) {
    if (tableStartPattern.hasMatch(line)) {
      isTableSection = true;
      continue;
    } else if (isTableSection && tableEndPattern.hasMatch(line)) {
      continue;
    } else if (isTableSection && line.trim().isEmpty) {
      isTableSection = false;
      continue;
    }

    if (isTableSection) {
      final match = rowPattern.firstMatch(line);
      if (match != null) {
        final difficulty = match.group(1)?.trim() ?? 'N/A';
        final problemColumn = match.group(2)?.trim() ?? '';
        final hints = match.group(3)?.trim() ?? 'N/A';
        final solutionColumn = match.group(4)?.trim() ?? '';

        final problemName =
            RegExp(r'\[(.*?)\]').firstMatch(problemColumn)?.group(1) ?? 'N/A';
        final problemLink =
            RegExp(r'\((.*?)\)').firstMatch(problemColumn)?.group(1) ?? 'N/A';
        final solutionLink =
            RegExp(r'\((.*?)\)').firstMatch(solutionColumn)?.group(1) ?? 'N/A';

        res.add(
          ChallengeProblem(
            title: problemName,
            source: 'Codeforces',
            url: problemLink,
            status: 'unknown',
            note: '',
            tags: [],
            hint: hints,
            tutorial: solutionLink,
            difficulty: difficulty,
          ),
        );
      }
    }
  }

  return res;
}

List<ProblemItem> parseToLocal(String markdownContent) {
  List<ProblemItem> res = [];

  final tableStartPattern =
      RegExp(r'\| Difficulty \| Problems \| Hints \| Solution \|');
  final tableEndPattern = RegExp(r'\| (-+) \| (-+) \| (-+) \| (-+) \|');
  final rowPattern =
      RegExp(r'^\| ([^\|]+) \| ([^\|]+) \| (.+?) \| ([^\|]+) \|$'); // 精确匹配表格行

  final lines = markdownContent.split('\n');

  bool isTableSection = false;

  for (final line in lines) {
    if (tableStartPattern.hasMatch(line)) {
      isTableSection = true;
      continue;
    } else if (isTableSection && tableEndPattern.hasMatch(line)) {
      continue;
    } else if (isTableSection && line.trim().isEmpty) {
      isTableSection = false;
      continue;
    }

    if (isTableSection) {
      final match = rowPattern.firstMatch(line);
      if (match != null) {
        final difficulty = match.group(1)?.trim() ?? 'N/A';
        final problemColumn = match.group(2)?.trim() ?? '';
        final hints = match.group(3)?.trim() ?? 'N/A';
        final solutionColumn = match.group(4)?.trim() ?? '';

        final problemName =
            RegExp(r'\[(.*?)\]').firstMatch(problemColumn)?.group(1) ?? 'N/A';
        final problemLink =
            RegExp(r'\((.*?)\)').firstMatch(problemColumn)?.group(1) ?? 'N/A';
        final solutionLink =
            RegExp(r'\((.*?)\)').firstMatch(solutionColumn)?.group(1) ?? 'N/A';

        res.add(
          ProblemItem(
            title: problemName,
            source: 'Codeforces',
            url: problemLink,
            status: difficulty,
            note: 'Hint:\n$hints\n\nTutorial:\n$solutionLink',
            tags: [],
          ),
        );
      }
    }
  }

  return res;
}
