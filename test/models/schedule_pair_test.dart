import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usue_schedule/models/schedule_pair.dart';
import 'package:usue_schedule/models/schedule_response.dart';

void main() {
  late SchedulePair schedulePair;
  late String jsonString;

  setUp(() async {
    jsonString = await File(
      'test/fixtures/schedule_response.json',
    ).readAsString();

    schedulePair = ScheduleResponse.parseFromApiResponse(jsonString)
        .schedules[1]
        .pairs
        .elementAt(1)
        .schedulePairs
        .first;
  });

  group("SchedulePair - basic fields", () {
    test("fields parsed correctly", () {
      expect(schedulePair.subject, isNotEmpty);
      expect(schedulePair.teacher, isNotEmpty);
      expect(schedulePair.group, isNotEmpty);
      expect(schedulePair.audience, isNotEmpty);
      expect(schedulePair.teacherId, isNonZero);
      expect(schedulePair.groupId, isNonZero);
      expect(schedulePair.pairId, isNonZero);
    });
  });

  group("SchedulePair - serialization", () {
    test("toJson returns correct map", () {
      final json = schedulePair.toJson();

      expect(json['subject'], schedulePair.subject);
      expect(json['teacher'], schedulePair.teacher);
      expect(json['group'], schedulePair.group);
      expect(json['aud'], schedulePair.audience);
      expect(json['comm'], schedulePair.comment);
      expect(json['prepod_id'], schedulePair.teacherId);
      expect(json['group_id'], schedulePair.groupId);
      expect(json['par_id'], schedulePair.pairId);
    });

    test("fromJson restores object correctly", () {
      final restored = SchedulePair.fromJson(schedulePair.toJson());

      expect(restored, equals(schedulePair));
    });
  });

  group("SchedulePair - cleanGroup", () {
    test("removes subgroup suffix", () {
      expect(schedulePair.cleanGroup, 'ИВТ-23-1');
    });
  });

  group("SchedulePair - subgroupNumber", () {
    test("extracts subgroup number correctly", () {
      expect(schedulePair.subgroupNumber, 2);
    });

    test("returns null if no subgroup", () {
      const pair = SchedulePair(
        subject: '',
        teacher: '',
        group: 'ИВТ-23-1',
        audience: '',
        comment: '',
        teacherId: 0,
        groupId: 0,
        pairId: 0,
      );

      expect(pair.subgroupNumber, isNull);
    });
  });

  group("SchedulePair - lessonType", () {
    test("detects lessonType", () {
      expect(schedulePair.lessonType, 'Лабораторная');
    });

    test("returns default when unknown", () {
      const pair = SchedulePair(
        subject: 'Что-то странное',
        teacher: '',
        group: '',
        audience: '',
        comment: '',
        teacherId: 0,
        groupId: 0,
        pairId: 0,
      );

      expect(pair.lessonType, 'Занятие');
    });
  });

  group("SchedulePair - isSubgroup", () {
    test("true when subgroup exists", () {
      expect(schedulePair.isSubgroup, true);
    });
  });

  group("SchedulePair List extension", () {
    test("groups returns unique clean groups", () {
      final list = [
        const SchedulePair(
          subject: '',
          teacher: '',
          group: 'ИВТ-23-1 (1 п/гр.)',
          audience: '',
          comment: '',
          teacherId: 0,
          groupId: 0,
          pairId: 0,
        ),
        const SchedulePair(
          subject: '',
          teacher: '',
          group: 'ИВТ-23-1 (2 п/гр.)',
          audience: '',
          comment: '',
          teacherId: 0,
          groupId: 0,
          pairId: 0,
        ),
      ];

      expect(list.groups.length, 1);
      expect(list.hasMultipleGroups, false);
    });

    test("hasMultipleGroups true when more than one clean group", () {
      final list = [
        const SchedulePair(
          subject: '',
          teacher: '',
          group: 'ИВТ-23-1',
          audience: '',
          comment: '',
          teacherId: 0,
          groupId: 0,
          pairId: 0,
        ),
        const SchedulePair(
          subject: '',
          teacher: '',
          group: 'ИВТ-24-1',
          audience: '',
          comment: '',
          teacherId: 0,
          groupId: 0,
          pairId: 0,
        ),
      ];

      expect(list.hasMultipleGroups, true);
    });

    test("teachers returns unique teachers", () {
      final list = [
        const SchedulePair(
          subject: '',
          teacher: 'Иванов',
          group: '',
          audience: '',
          comment: '',
          teacherId: 0,
          groupId: 0,
          pairId: 0,
        ),
        const SchedulePair(
          subject: '',
          teacher: 'Иванов',
          group: '',
          audience: '',
          comment: '',
          teacherId: 0,
          groupId: 0,
          pairId: 0,
        ),
      ];

      expect(list.teachers.length, 1);
    });

    test("subgroups returns unique subgroup numbers", () {
      final list = [
        const SchedulePair(
          subject: '',
          teacher: '',
          group: 'ИВТ-23-1 (1 п/гр.)',
          audience: '',
          comment: '',
          teacherId: 0,
          groupId: 0,
          pairId: 0,
        ),
        const SchedulePair(
          subject: '',
          teacher: '',
          group: 'ИВТ-23-1 (2 п/гр.)',
          audience: '',
          comment: '',
          teacherId: 0,
          groupId: 0,
          pairId: 0,
        ),
      ];

      expect(list.subgroups.length, 2);
      expect(list.subgroups.contains('1'), true);
      expect(list.subgroups.contains('2'), true);
    });
  });
}
