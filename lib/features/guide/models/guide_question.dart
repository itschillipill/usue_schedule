import 'guide_answer.dart';

class GuideQuestion {
  final String title;
  final String shortDescription;
  final GuideAnswer answer;

  GuideQuestion({
    required this.title,
    required this.shortDescription,
    required this.answer,
  });
}
