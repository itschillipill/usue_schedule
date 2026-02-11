import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usue_schedule/v2/models/schedule_model.dart';

class MyScheduleState {
  final ScheduleModel? currentSchedule;
  final List<ScheduleModel> schedules;

  MyScheduleState({required this.currentSchedule, required this.schedules});

  factory MyScheduleState.initial() {
    return MyScheduleState(
      currentSchedule: null,
      schedules: [],
    );
  }

  MyScheduleState copyWith({
    ScheduleModel? currentSchedule,
    List<ScheduleModel>? schedules,
  }) {
    return MyScheduleState(
      currentSchedule: currentSchedule ?? this.currentSchedule,
      schedules: schedules ?? this.schedules,
    );
  }
}

class MyScheduleCubit extends Cubit<MyScheduleState> {
  final SharedPreferences prefs;

  final mySchedulesKey = "mySchedules";
  final currentScheduleKey = "currentSchedule";
  MyScheduleCubit({required this.prefs}) : super(MyScheduleState.initial()) {
    _loadSchedules();
  }

  void _loadSchedules() async {
    List<ScheduleModel> schedules = <ScheduleModel>[];
    ScheduleModel? currentSchedule;
    final List<String> schedulesString =
        prefs.getStringList(mySchedulesKey) ?? [];
    if (schedulesString.isNotEmpty) {
      schedules = schedulesString
          .map((e) => ScheduleModel.fromJson(jsonDecode(e)))
          .toList();
    }
    final currentString = prefs.getString(currentScheduleKey);
    if (currentString != null) {
      currentSchedule = ScheduleModel.fromJson(jsonDecode(currentString));
    }
    emit(
        state.copyWith(schedules: schedules, currentSchedule: currentSchedule));
  }

  void addSchedule(ScheduleModel schedule) {
    final List<ScheduleModel> schedules = List.from(state.schedules)
      ..add(schedule);
    prefs.setStringList(
        mySchedulesKey, schedules.map((e) => jsonEncode(e.toJson())).toList());
    emit(state.copyWith(schedules: schedules));
  }

  void setCurrentSchedule(ScheduleModel schedule) {
    prefs.setString(currentScheduleKey, jsonEncode(schedule.toJson()));
    emit(state.copyWith(currentSchedule: schedule));
  }

  void removeSchedule(ScheduleModel schedule) {
    final List<ScheduleModel> schedules = List.from(state.schedules)
      ..remove(schedule);
    prefs.setStringList(
        mySchedulesKey, schedules.map((e) => jsonEncode(e.toJson())).toList());
    emit(state.copyWith(schedules: schedules));
  }
}
