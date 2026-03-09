import 'dart:io' show File;

import 'package:flutter_test/flutter_test.dart';
import 'package:usue_schedule/features/schedule/models/pair.dart';
import 'package:usue_schedule/features/schedule/models/schedule_response.dart';

void main() {
  late Pair pair;
  late String jsonString;

  setUp(() async {
    jsonString = await File(
      'test/fixtures/schedule_response.json',
    ).readAsString();

    pair = ScheduleResponse.parseFromApiResponse(jsonString)
        .schedules[1]
        .pairs
        .elementAt(1);
  });

  group("Pair model tests", () {
    test("number parsed correctly", () {
      expect(pair.number, 2);
    });

    test("time parsed correctly", () {
      expect(pair.time, "10:10-11:40");
    });

    test("schedulePairs not empty", () {
      expect(pair.schedulePairs, isNotEmpty);
      expect(pair.schedulePairs.length, 1);
    });

    test("toJson returns correct map", () {
      expect(pair.toJson(), {
        "N": 2,
        "time": "10:10-11:40",
        "schedulePairs": [
          {
            "subject":
                "Алгоритмы и вычислительные методы оптимизации (Лаб.раб.)",
            "teacher": "Кольева Н.С.",
            "group": "ИВТ-23-1 (2 п/гр.)",
            "aud": "338TV",
            "comm": "10.10-11.40 INDO",
            "prepod_id": 2788,
            "group_id": 18375,
            "par_id": 2
          }
        ]
      });
    });

    test("timeRange returns correct start and end", () {
      final (start, end) = pair.timeRange;

      expect(start, "10:10");
      expect(end, "11:40");
    });

    test("timeRange returns empty values for invalid format", () {
      const invalidPair = Pair(
        number: 1,
        time: "invalid",
        schedulePairs: [],
      );

      final (start, end) = invalidPair.timeRange;

      expect(start, "");
      expect(end, "");
    });

    test("getAllGroups returns unique groups", () {
      final groups = pair.getAllGroups();

      expect(groups.length, 1);
      expect(groups.first, "ИВТ-23-1");
    });

    test("getAllTeachers returns unique teachers", () {
      final teachers = pair.getAllTeachers();

      expect(teachers.length, 1);
      expect(teachers.first, "Кольева Н.С.");
    });

    test("getAllAudiences returns unique audiences", () {
      final audiences = pair.getAllAudiences();

      expect(audiences.length, 1);
      expect(audiences.first, "338TV");
    });

    test("filterByGroup returns matching pair", () {
      final filtered = pair.filterByGroup("ИВТ-23-1");

      expect(filtered.schedulePairs.length, 1);
    });

    test("filterByGroup returns empty if no match", () {
      final filtered = pair.filterByGroup("NON_EXISTING");

      expect(filtered.schedulePairs, isEmpty);
    });

    test("filterByTeacher matches by partial name", () {
      final filtered = pair.filterByTeacher("Кольева");

      expect(filtered.schedulePairs.length, 1);
    });

    test("filterByTeacher returns empty if not found", () {
      final filtered = pair.filterByTeacher("Unknown");

      expect(filtered.schedulePairs, isEmpty);
    });

    test("Pairs with same values are equal", () {
      final copy = Pair.fromJson(pair.toJson());

      expect(pair, equals(copy));
    });

    test("Pairs with different number are not equal", () {
      final modified = Pair(
        number: 999,
        time: pair.time,
        schedulePairs: pair.schedulePairs,
      );

      expect(pair == modified, false);
    });
  });
}
