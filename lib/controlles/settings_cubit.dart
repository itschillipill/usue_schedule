import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usue_schedule/core/utils/logger/session_logger.dart';

class SettingsState {
  final ThemeMode themeMode;

  SettingsState({required this.themeMode});

  factory SettingsState.initial() {
    return SettingsState(themeMode: ThemeMode.system);
  }
  SettingsState copyWith({
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  String toString() => 'SettingsState(themeMode: $themeMode)';

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
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
    SessionLogger.instance.onTransition(name, change.currentState, change.nextState);
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
}
