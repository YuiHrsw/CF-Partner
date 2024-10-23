import 'package:cf_partner/backend/problem_item.dart';

class ChallengeProblem extends ProblemItem {
  ChallengeProblem({
    required super.title,
    required super.source,
    required super.url,
    required super.status,
    required super.note,
    required super.tags,
    required this.hint,
    required this.tutorial,
    required this.difficulty,
  });
  String difficulty;
  String hint;
  String tutorial;
}
