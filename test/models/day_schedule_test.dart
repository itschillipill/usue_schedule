import 'package:flutter_test/flutter_test.dart';
import 'package:usue_schedule/models/day_schedule.dart';
import 'package:usue_schedule/models/pair.dart';
import 'package:usue_schedule/models/schedule_pair.dart';

void main() {
  group("DaySchedule", () {
    DaySchedule dayScheduleExample = DaySchedule(
      date: "16.02.2026",
      weekDay: "Понедельник",
      pairs: [
        Pair(number: 4, time: "17:10-18:40", schedulePairs: [
          SchedulePair(
              subject: "Бизнес-планирование ИТ-инфраструктуры (Лаб.раб.)",
              teacher: "Панова М.В.",
              group: "ИДО ЗБ ПОАС-24 Арт, Ирб, КТ, НУ, Пр",
              audience: "ИДО",
              comment: "13.50-15.20 CDE",
              teacherId: 1626,
              groupId: 18933,
              pairId: 4),
          SchedulePair(
              subject: "Бизнес-планирование ИТ-инфраструктуры (Лаб.раб.)",
              teacher: "Панова М.В.",
              group: "ИДО ЗБ ПОАС-24-2 СБ",
              audience: "ИДО",
              comment: "13.50-15.20 CDE",
              teacherId: 1626,
              groupId: 18929,
              pairId: 4),
        ]),
        Pair(number: 5, time: "15:30-17:00", schedulePairs: [
          SchedulePair(
              subject:
                  "Автоматизация прикладных экономических процессов (Экзамен)",
              teacher: "Панова М.В.",
              group: "ЗПИ-22-1",
              audience: "559",
              comment: "15.30-17.00 INDO",
              teacherId: 1626,
              groupId: 18126,
              pairId: 5)
        ]),
      ],
    );

    Map<String, dynamic> jsonExample = {
      "date": "16.02.2026",
      "weekDay": "Понедельник",
      "pairs": [
        {
          "N": 4,
          "time": "17:10-18:40",
          "schedulePairs": [
            {
              "subject": "Бизнес-планирование ИТ-инфраструктуры (Лаб.раб.)",
              "teacher": "Панова М.В.",
              "group": "ИДО ЗБ ПОАС-24 Арт, Ирб, КТ, НУ, Пр",
              "aud": "ИДО",
              "comm": "13.50-15.20 CDE",
              "prepod_id": 1626,
              "group_id": 18933,
              "par_id": 4
            },
            {
              "subject": "Бизнес-планирование ИТ-инфраструктуры (Лаб.раб.)",
              "teacher": "Панова М.В.",
              "group": "ИДО ЗБ ПОАС-24-2 СБ",
              "aud": "ИДО",
              "comm": "13.50-15.20 CDE",
              "prepod_id": 1626,
              "group_id": 18929,
              "par_id": 4
            }
          ]
        },
        {
          "N": 5,
          "time": "15:30-17:00",
          "schedulePairs": [
            {
              "subject":
                  "Автоматизация прикладных экономических процессов (Экзамен)",
              "teacher": "Панова М.В.",
              "group": "ЗПИ-22-1",
              "aud": "559",
              "comm": "15.30-17.00 INDO",
              "prepod_id": 1626,
              "group_id": 18126,
              "par_id": 5
            }
          ]
        },
      ]
    };

    test("fromJson", () {
      expect(DaySchedule.fromJson(jsonExample), dayScheduleExample);
    });

    test("empty", () {
      final emptyDaySchedule = dayScheduleExample.empty();
      expect(emptyDaySchedule.pairs.length, 0);
    });

    test("toJson", () {
      expect(dayScheduleExample.toJson(), jsonExample);
    });

    test("nonEptyPairs", () {
      expect(dayScheduleExample.nonEmptyPairs.length, 2);
      expect(dayScheduleExample.empty().nonEmptyPairs.length, 0);
    });

    test("hasPairs", () {
      expect(dayScheduleExample.hasPairs, true);
      expect(dayScheduleExample.empty().hasPairs, false);
    });

    test("getAllGroups", () {
      expect(dayScheduleExample.getAllGroups(), {
        "ИДО ЗБ ПОАС-24 Арт, Ирб, КТ, НУ, Пр",
        "ИДО ЗБ ПОАС-24-2 СБ",
        "ЗПИ-22-1"
      });
    });

    test("getAllTeachers", () {
      expect(dayScheduleExample.getAllTeachers(), {"Панова М.В."});
    });

    test("getAllAudiences", () {
      expect(dayScheduleExample.getAllAudiences(), {"ИДО", "559"});
    });

    test("filterByGroup", () {
      final filteredDaySchedule =
          dayScheduleExample.filterByGroup("ИДО ЗБ ПОАС-24-2 СБ");
      expect(filteredDaySchedule.nonEmptyPairs.length, 1);
    });

    test("filterByTeacher", () {
      final filteredDaySchedule =
          dayScheduleExample.filterByTeacher("Панова М.В.");
      expect(filteredDaySchedule.nonEmptyPairs.length, 2);
    });
  });
}
