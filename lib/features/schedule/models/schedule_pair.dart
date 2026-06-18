import 'package:equatable/equatable.dart';

import '../../../core/utils/date_utils.dart';

final class SchedulePair extends Equatable {
  SchedulePair({
    required this.subject,
    required this.teacher,
    required this.group,
    required this.audience,
    required this.comment,
    required this.teacherId,
    required this.groupId,
    required this.pairId,
  })  : cleanGroup = group.replaceAll(_groupCleanupRegex, '').trim(),
        subgroupNumber = _extractSubgroup(group);

  final String subject;
  final String teacher;
  final String group;
  final String audience;
  final String comment;
  final int teacherId;
  final int groupId;
  final int pairId;

  final String cleanGroup;
  final int? subgroupNumber;

  static final RegExp _groupCleanupRegex = RegExp(r'\([^)]*\)');
  static final RegExp _subgroupRegex = RegExp(r'\((\d+)\s*п/гр\.\)');

  static const List<(String, String)> _lessonTypes = [
    ('лекц', 'Лекция'),
    ('практ', 'Практика'),
    ('лаб', 'Лабораторная'),
    ('экза', 'Экзамен'),
    ('зач', 'Зачет'),
    ('консул', 'Консультация'),
  ];

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

  static int? _extractSubgroup(String group) {
    final match = _subgroupRegex.firstMatch(group);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  String get lessonType {
    final s = subject.toLowerCase();

    for (final lt in _lessonTypes) {
      if (s.contains(lt.$1)) {
        return lt.$2;
      }
    }

    return 'Занятие';
  }

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

  String? get correctedTime => DateTimeUtils.parseTimeFromComment(comment);

  @override
  List<Object?> get props => [
        subject,
        teacher,
        group,
        audience,
        comment,
        teacherId,
        groupId,
        pairId,
      ];
}

extension X on List<SchedulePair> {
  bool get hasMultipleGroups => groups.length > 1;

  Set<String> get groups => {for (final p in this) p.cleanGroup};

  Set<String> get teachers => {for (final p in this) p.teacher};

  Set<String> get subgroups => {
        for (final p in this)
          if (p.subgroupNumber != null) '${p.subgroupNumber}'
      };

  String get audience {
    for (final p in this) {
      if (p.audience.isNotEmpty) return p.audience;
    }
    return 'Не указана';
  }
}
