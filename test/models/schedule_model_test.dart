import 'package:flutter_test/flutter_test.dart';
import 'package:usue_schedule/features/schedule/models/schedule_model.dart';
import 'package:usue_schedule/features/schedule/models/request_type.dart';

void main() {
  group("ScheduleModel - factory constructors", () {
    test("teacher factory creates correct model", () {
      final model = ScheduleModel.teacher("Иванов");

      expect(model.requestType, RequestType.teacher);
      expect(model.queryValue, "Иванов");
    });

    test("group factory creates correct model", () {
      final model = ScheduleModel.group("ИВТ-23-1");

      expect(model.requestType, RequestType.group);
      expect(model.queryValue, "ИВТ-23-1");
    });

    test("audience factory creates correct model", () {
      final model = ScheduleModel.audience("338TV");

      expect(model.requestType, RequestType.audience);
      expect(model.queryValue, "338TV");
    });
  });

  group("ScheduleModel - cacheKey", () {
    test("generates correct cacheKey without special chars", () {
      final model = ScheduleModel.teacher("Иванов");

      expect(model.cacheKey, "teacher_Иванов");
    });

    test("replaces unsupported symbols with underscore", () {
      final model = ScheduleModel.group("ИВТ@23#1!");

      expect(model.cacheKey, "group_ИВТ_23_1_");
    });

    test("keeps allowed characters (letters, numbers, dash, dot, space)", () {
      final model = ScheduleModel.group("ИВТ-23.1");

      expect(model.cacheKey, "group_ИВТ-23.1");
    });
  });

  group("ScheduleModel - displayName", () {
    test("displayName returns correct format", () {
      final model = ScheduleModel.teacher("Иванов");

      expect(
        model.displayName,
        "${RequestType.teacher}: Иванов",
      );
    });
  });

  group("ScheduleModel - serialization", () {
    test("toJson returns correct map", () {
      final model = ScheduleModel.group("ИВТ-23-1");

      final json = model.toJson();

      expect(json, {
        'requestType': RequestType.group.index,
        'queryValue': "ИВТ-23-1",
      });
    });

    test("fromJson restores object correctly", () {
      final original = ScheduleModel.audience("338TV");

      final json = original.toJson();
      final restored = ScheduleModel.fromJson(json);

      expect(restored, equals(original));
    });
  });

  group("ScheduleModel - toString", () {
    test("toString returns readable string", () {
      final model = ScheduleModel.teacher("Иванов");

      expect(
        model.toString(),
        "ScheduleModel(requestType: teacher, value: Иванов)",
      );
    });
  });

  group("ScheduleModel - Equatable", () {
    test("models with same values are equal", () {
      final m1 = ScheduleModel.teacher("Иванов");
      final m2 = ScheduleModel.teacher("Иванов");

      expect(m1, equals(m2));
    });

    test("models with different type are not equal", () {
      final m1 = ScheduleModel.teacher("Иванов");
      final m2 = ScheduleModel.group("Иванов");

      expect(m1 == m2, false);
    });

    test("models with different queryValue are not equal", () {
      final m1 = ScheduleModel.teacher("Иванов");
      final m2 = ScheduleModel.teacher("Петров");

      expect(m1 == m2, false);
    });
  });
}
