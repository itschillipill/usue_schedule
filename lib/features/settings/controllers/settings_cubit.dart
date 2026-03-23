import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usue_schedule/core/logger/session_logger.dart';
import 'package:usue_schedule/features/schedule/models/schedule_view_type.dart';

class SettingsState {
  final ThemeMode themeMode;
  final ScheduleViewType viewType;

  SettingsState({required this.themeMode, required this.viewType});

  factory SettingsState.initial() => SettingsState(
      themeMode: ThemeMode.system, viewType: ScheduleViewType.day);

  SettingsState copyWith({
    ThemeMode? themeMode,
    ScheduleViewType? viewType,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      viewType: viewType ?? this.viewType,
    );
  }

  @override
  String toString() =>
      'SettingsState(themeMode: $themeMode, viewType: ${viewType.name})';

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      viewType: ScheduleViewType.values[map['viewType'] ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'viewType': viewType.index,
    };
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  static const String name = "SettingsCubit";
  final settingsKey = "settings";
  final SharedPreferences prefs;
  SettingsCubit({required this.prefs}) : super(SettingsState.initial()) {
    _loadSettings();
    SessionLogger.instance.onCreate(name);
  }

  @override
  void onChange(Change<SettingsState> change) {
    SessionLogger.instance
        .onTransition(name, change.currentState, change.nextState);
    super.onChange(change);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    SessionLogger.instance.onError(name, error, stackTrace);
    super.onError(error, stackTrace);
  }

  void _loadSettings() async {
    final settingsString = prefs.getString(settingsKey);
    if (settingsString != null) {
      emit(SettingsState.fromMap(jsonDecode(settingsString)));
    }
  }

  void setThemeMode(ThemeMode? themeMode) {
    if (themeMode == null) return;
    emit(state.copyWith(themeMode: themeMode));
    prefs.setString(settingsKey, jsonEncode(state.toMap()));
  }

  void setViewType(ScheduleViewType? viewType) {
    if (viewType == null ||
        viewType == state.viewType ||
        viewType == ScheduleViewType.custom) {
      return;
    }
    emit(state.copyWith(viewType: viewType));
    prefs.setString(settingsKey, jsonEncode(state.toMap()));
  }
}
