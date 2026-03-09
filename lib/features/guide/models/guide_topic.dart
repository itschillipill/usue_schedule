import 'package:flutter/material.dart';

import 'guide_question.dart';

class GuideTopic {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<GuideQuestion> questions;

  GuideTopic({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.questions,
  });
}
