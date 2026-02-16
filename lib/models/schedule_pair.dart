class SchedulePair {
  final String subject;
  final String teacher;
  final String group;
  final String audience;
  final String comment;
  final int teacherId;
  final int groupId;
  final int pairId;

  SchedulePair({
    required this.subject,
    required this.teacher,
    required this.group,
    required this.audience,
    required this.comment,
    required this.teacherId,
    required this.groupId,
    required this.pairId,
  });

  factory SchedulePair.fromJson(Map<String, dynamic> json) {
    return SchedulePair(
      subject: json['subject'] as String? ?? '',
      teacher: json['teacher'] as String? ?? '',
      group: json['group'] as String? ?? '',
      audience: json['aud'] as String? ?? '',
      comment: json['comm'] as String? ?? '',
      teacherId: json['prepod_id'] as int? ?? 0,
      groupId: json['group_id'] as int? ?? 0,
      pairId: json['par_id'] as int? ?? 0,
    );
  }

  String get cleanGroup {
    // Убираем "(1 п/гр.)" и подобные приписки
    final regex = RegExp(r'\(.*\)');
    return group.replaceAll(regex, '').trim();
  }

  // Извлечь номер подгруппы, если есть
  int? get subgroupNumber {
    final match = RegExp(r'\((\d+)\s*п/гр\.\)').firstMatch(group);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  String get lessonType {
    if (subject.toLowerCase().contains('лекц')) return 'Лекция';
    if (subject.toLowerCase().contains('лаб')) return 'Лабораторная';
    if (subject.toLowerCase().contains('консул')) return 'Консультация';
    if (subject.toLowerCase().contains('экза')) return 'Экзамен';
    if (subject.toLowerCase().contains('зач')) return 'Зачет';
    if (subject.toLowerCase().contains('практ')) return 'Практика';
    return 'Занятие';
  }

  bool get isSubgroup => subgroupNumber != null;

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'teacher': teacher,
      'group': group,
      'aud': audience,
      'comm': comment,
      'prepod_id': teacherId,
      'group_id': groupId,
      'par_id': pairId,
    };
  }
}

extension X on List<SchedulePair> {
  bool get hasMultipleGroups => groups.length > 1;

  Iterable<String> get groups => map((p) => p.cleanGroup).toSet();

  Iterable<String> get teachers => map((p) => p.teacher).toSet();

  Iterable<String> get subgroups =>
      where((p) => p.isSubgroup).map((p) => '${p.subgroupNumber}').toSet();
}
