import 'package:flutter_test/flutter_test.dart';
import 'package:usue_schedule/features/schedule/models/schedule_response.dart';

import 'dart:io';

void main() {
  late ScheduleResponse scheduleResponse;

  setUp(() async {
    final jsonString = await File(
      'test/fixtures/schedule_response.json',
    ).readAsString();

    scheduleResponse = ScheduleResponse.parseFromApiResponse(jsonString);
  });

  test('parseFromApiResponse', () {
    expect(scheduleResponse.schedules.length, 7);
  });

  test("cut", () {
    expect(
        scheduleResponse
            .cut(DateTime(2026, 2, 22), DateTime(2026, 2, 22))
            .schedules
            .length,
        0);
    expect(
        scheduleResponse
            .cut(DateTime(2026, 2, 23), DateTime(2026, 2, 24))
            .schedules
            .length,
        2);
  });

  test("fillEmptyDates", () {
    expect(
        scheduleResponse
            .fillEmptyDates(DateTime(2026, 2, 23), DateTime(2026, 3, 1))
            .schedules
            .length,
        7);
  });
}
