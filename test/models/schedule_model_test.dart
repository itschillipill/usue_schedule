import 'package:flutter_test/flutter_test.dart';
import 'package:usue_schedule/features/schedule/models/schedule_model.dart';
import 'package:usue_schedule/features/schedule/models/request_type.dart';

void main() {
  group("ScheduleModel - factory constructors", () {
    test("teacher factory creates correct model", () {
      final model = ScheduleModel.teacher("Иванов");

      expect(model.requestType, RequestType.teacher);
      expect(model.queryValue, "Иванов");
      expect(model.lastUpdated, isNull);
    });

    test("group factory creates correct model", () {
      final model = ScheduleModel.group("ИВТ-23-1");

      expect(model.requestType, RequestType.group);
      expect(model.queryValue, "ИВТ-23-1");
      expect(model.lastUpdated, isNull);
    });

    test("audience factory creates correct model", () {
      final model = ScheduleModel.audience("338TV");

      expect(model.requestType, RequestType.audience);
      expect(model.queryValue, "338TV");
      expect(model.lastUpdated, isNull);
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

      expect(json['requestType'], RequestType.group.index);
      expect(json['queryValue'], "ИВТ-23-1");
      expect(json['lastUpdated'], isNull);
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
        "ScheduleModel(requestType: teacher, value: Иванов, lastUpdated: null)",
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

  group("ScheduleModel - needsUpdate / update", () {
    test("needsUpdate returns true when lastUpdated is null", () {
      final model = ScheduleModel.teacher("Иванов");

      expect(model.needsUpdate(), true);
    });

    test("needsUpdate returns false when lastUpdated is recent", () {
      final model =
          ScheduleModel.teacher("Иванов", lastUpdated: DateTime.now());

      expect(model.needsUpdate(), false);
    });

    test("needsUpdate returns true when lastUpdated is older than maxAge", () {
      final oldDate = DateTime.now().subtract(const Duration(days: 10));
      final model = ScheduleModel.teacher("Иванов", lastUpdated: oldDate);

      expect(model.needsUpdate(maxAge: const Duration(days: 7)), true);
    });

    test("update returns new model with updated lastUpdated", () {
      final model = ScheduleModel.teacher("Иванов");

      final updated = model.update();

      expect(updated.queryValue, model.queryValue);
      expect(updated.requestType, model.requestType);
      expect(updated.lastUpdated, isNotNull);
      expect(
          updated.lastUpdated!
              .isAfter(DateTime.now().subtract(const Duration(seconds: 1))),
          true);
    });
  });
}
