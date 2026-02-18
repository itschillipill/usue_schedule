import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final settingsKey = "settings";
  final SharedPreferences prefs;
  SettingsCubit({required this.prefs}) : super(SettingsState.initial()) {
    _loadSettings();
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
