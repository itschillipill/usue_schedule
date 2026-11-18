import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usue_schedule/core/logger/session_logger.dart';
import 'package:usue_schedule/features/schedule/models/schedule_model.dart';

class MyScheduleState {
  MyScheduleState({required this.schedules, this.current});

  final List<ScheduleModel> schedules;
  final ScheduleModel? current;

  factory MyScheduleState.initial() => MyScheduleState(schedules: []);

  MyScheduleState copyWith(
      {List<ScheduleModel>? schedules, ScheduleModel? current}) {
    return MyScheduleState(
      schedules: schedules ?? this.schedules,
      current: current ?? this.current,
    );
  }

  @override
  String toString() =>
      "MyScheduleState(schedules: ${schedules.toString()}, current: ${current.toString()})";
}

class MyScheduleCubit extends Cubit<MyScheduleState> {
  MyScheduleCubit({required this.prefs}) : super(MyScheduleState.initial()) {
    _loadSchedules();
    SessionLogger.instance.onCreate(name);
  }

  final SharedPreferences prefs;

  static const String name = "MyScheduleCubit";
  static const mySchedulesKey = "mySchedules";
  static const currentScheduleKey = "currentSchedule";

  @override
  void onError(Object error, StackTrace stackTrace) {
    SessionLogger.instance.onError(name, error, stackTrace);
    super.onError(error, stackTrace);
  }

  @override
  void onChange(Change<MyScheduleState> change) {
    final oldSchedules = change.currentState.schedules;
    final newSchedules = change.nextState.schedules;

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
    final List<String> schedulesString =
        prefs.getStringList(mySchedulesKey) ?? [];
    final String? currentString = prefs.getString(currentScheduleKey);

    if (schedulesString.isEmpty) return;

    List<ScheduleModel> schedules = schedulesString
        .map((e) => ScheduleModel.fromJson(jsonDecode(e)))
        .toList(growable: false);

    ScheduleModel? currentSchedule;
    if (currentString != null) {
      try {
        final decodedCurrent =
            ScheduleModel.fromJson(jsonDecode(currentString));
        currentSchedule = schedules.firstWhere(
          (s) => s == decodedCurrent,
          orElse: () => schedules.first,
        );
      } catch (_) {
        currentSchedule = schedules.isNotEmpty ? schedules.first : null;
      }
    } else if (schedules.isNotEmpty) {
      currentSchedule = schedules.first;
    }

    emit(MyScheduleState(schedules: schedules, current: currentSchedule));
  }

  Future<void> setCurrentSchedule(ScheduleModel schedule) async {
    if (!state.schedules.contains(schedule)) return;

    await prefs.setString(currentScheduleKey, jsonEncode(schedule.toJson()));
    emit(state.copyWith(current: schedule));
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    if (!state.schedules.contains(schedule)) {
      final List<ScheduleModel> schedules = <ScheduleModel>[
        ...state.schedules,
        schedule
      ];

      await prefs.setStringList(
        mySchedulesKey,
        schedules.map((e) => jsonEncode(e.toJson())).toList(),
      );

      ScheduleModel? newCurrent = state.current;
      if (schedules.length == 1) {
        newCurrent = schedules.first;
        await prefs.setString(
            currentScheduleKey, jsonEncode(newCurrent.toJson()));
      }

      emit(MyScheduleState(schedules: schedules, current: newCurrent));
    }
  }

  Future<void> removeSchedules(List<ScheduleModel> schedulesToRemove) async {
    final List<ScheduleModel> newSchedules = state.schedules
        .where((element) =>
            element == state.current || !schedulesToRemove.contains(element))
        .toList();

    await prefs.setStringList(
      mySchedulesKey,
      newSchedules.map((e) => jsonEncode(e.toJson())).toList(),
    );

    emit(state.copyWith(schedules: newSchedules));
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    List<ScheduleModel> schedules = List.of(state.schedules);
    final modelIndex = schedules.indexOf(schedule);
    if (modelIndex == -1) return;

    schedules[modelIndex] = schedule.update();

    await prefs.setStringList(
      mySchedulesKey,
      schedules.map((e) => jsonEncode(e.toJson())).toList(),
    );

    ScheduleModel? updatedCurrent = state.current;
    if (state.current == schedule) {
      updatedCurrent = schedules[modelIndex];
      await prefs.setString(
          currentScheduleKey, jsonEncode(updatedCurrent.toJson()));
    }

    emit(MyScheduleState(schedules: schedules, current: updatedCurrent));
  }

  bool contains(ScheduleModel model) => state.schedules.contains(model);

  Future<void> onDeleteCache(List<ScheduleModel> models) async {
    final modelsSet = Set.of(models);

    List<ScheduleModel> schedules = state.schedules
        .map((element) =>
            modelsSet.contains(element) ? element.resetUpdate() : element)
        .toList();

    await prefs.setStringList(
      mySchedulesKey,
      schedules.map((e) => jsonEncode(e.toJson())).toList(),
    );

    ScheduleModel? updatedCurrent = state.current;
    if (updatedCurrent != null) {
      final index = schedules.indexOf(updatedCurrent);
      if (index != -1) {
        updatedCurrent = schedules[index];
        await prefs.setString(
            currentScheduleKey, jsonEncode(updatedCurrent.toJson()));
      }
    }

    emit(MyScheduleState(schedules: schedules, current: updatedCurrent));
  }
}
