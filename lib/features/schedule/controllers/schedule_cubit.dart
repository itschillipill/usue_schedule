import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usue_schedule/core/logger/session_logger.dart';
import 'package:usue_schedule/features/schedule/models/schedule_model.dart';

class MyScheduleState {
  final List<ScheduleModel> schedules;

  MyScheduleState({required this.schedules});

  factory MyScheduleState.initial() {
    return MyScheduleState(
      schedules: [],
    );
  }

  MyScheduleState copyWith({
    List<ScheduleModel>? schedules,
  }) {
    return MyScheduleState(
      schedules: schedules ?? this.schedules,
    );
  }

  @override
  String toString() => "MyScheduleState(schedules: ${schedules.toString()})";
}

class MyScheduleCubit extends Cubit<MyScheduleState> {
  final SharedPreferences prefs;

  static const String name = "MyScheduleCubit";

  final mySchedulesKey = "mySchedules";
  final currentScheduleKey = "currentSchedule";
  MyScheduleCubit({required this.prefs}) : super(MyScheduleState.initial()) {
    _loadSchedules();
    SessionLogger.instance.onCreate(name);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    SessionLogger.instance.onError(name, error, stackTrace);
    super.onError(error, stackTrace);
  }

  @override
  void onChange(Change<MyScheduleState> change) {
    final oldSchedules = change.currentState.schedules;
    final newSchedules = change.nextState.schedules;

    // Найти какие расписания изменились
    final List<ScheduleModel> updated = <ScheduleModel>[];
    for (int i = 0; i < newSchedules.length; i++) {
      if (i >= oldSchedules.length ||
          oldSchedules[i] != newSchedules[i] ||
          oldSchedules[i].lastUpdated != newSchedules[i].lastUpdated) {
        updated.add(newSchedules[i]);
      }
    }

    final List<ScheduleModel> removed = <ScheduleModel>[];
    for (int i = 0; i < oldSchedules.length; i++) {
      if (!newSchedules.contains(oldSchedules[i])) {
        removed.add(oldSchedules[i]);
      }
    }

    SessionLogger.instance.onTransition(
      name,
      'old: count=${oldSchedules.length}',
      'new: count=${newSchedules.length}${updated.isEmpty ? "" : ", updated=$updated"}${removed.isEmpty ? "" : ", removed=$removed"}',
    );

    super.onChange(change);
  }

  void _loadSchedules() async {
    List<ScheduleModel> schedules = <ScheduleModel>[];
    final List<String> schedulesString =
        prefs.getStringList(mySchedulesKey) ?? [];
    if (schedulesString.isNotEmpty) {
      schedules = schedulesString
          .map((e) => ScheduleModel.fromJson(jsonDecode(e)))
          .toList();
    }
    emit(state.copyWith(schedules: schedules));
  }

  void addSchedule(ScheduleModel schedule) {
    if (!state.schedules.contains(schedule)) {
      final List<ScheduleModel> schedules = List.from(state.schedules)
        ..add(schedule);
      prefs.setStringList(mySchedulesKey,
          schedules.map((e) => jsonEncode(e.toJson())).toList());
      emit(state.copyWith(schedules: schedules));
    }
  }

  void removeSchedules(List<ScheduleModel> schedules) {
    final List<ScheduleModel> newSchedules = List.from(state.schedules)
      ..removeWhere((element) => schedules.contains(element));
    prefs.setStringList(mySchedulesKey,
        newSchedules.map((e) => jsonEncode(e.toJson())).toList());
    emit(MyScheduleState(schedules: newSchedules));
  }

  void reorderSchedules(int oldIndex, int newIndex) {
    List<ScheduleModel> schedules = List.from(state.schedules);
    final schedule = schedules.removeAt(oldIndex);
    schedules.insert(newIndex, schedule);
    prefs.setStringList(
        mySchedulesKey, schedules.map((e) => jsonEncode(e.toJson())).toList());
    emit(MyScheduleState(schedules: schedules));
  }

  void updateSchedule(ScheduleModel schedule) {
    List<ScheduleModel> schedules = List.from(state.schedules);
    final modelIndex = schedules.indexOf(schedule);
    if (modelIndex != -1) {
      schedules[modelIndex] = schedule.update();
    }
    prefs.setStringList(
      mySchedulesKey,
      schedules.map((e) => jsonEncode(e.toJson())).toList(),
    );
    emit(MyScheduleState(schedules: schedules));
  }

  Future<void> onDeleteCache(List<ScheduleModel> models) async {
    List<ScheduleModel> schedules = List<ScheduleModel>.from(state.schedules)
        .map((element) => element.resetUpdate())
        .toList();
    await prefs.setStringList(
      mySchedulesKey,
      schedules.map((e) => jsonEncode(e.toJson())).toList(),
    );
    emit(MyScheduleState(schedules: schedules));
  }
}
