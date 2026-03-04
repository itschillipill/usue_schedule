import 'package:flutter/material.dart';
import 'package:usue_schedule/core/theme/schedule_styles.dart';
import 'package:usue_schedule/models/schedule_model.dart';
import 'package:usue_schedule/models/schedule_response.dart';
import 'package:usue_schedule/services/api.dart';

class ScheduleViewProvider extends ChangeNotifier {
  final ApiService apiService;
  final ScheduleModel params;

  ScheduleViewProvider({
    required this.apiService,
    required this.params,
  }) {
    _init();
  }

  DateTime selectedDate = DateTime.now();
  bool isDayView = true;
  List<DateTime> selectedWeek = [];

  String? selectedFilter;

  List<String> availableGroups = [];
  List<String> availableTeachers = [];
  final Map<String, Color> groupColors = {};

  ScheduleResponse? lastResponse;
  String? error;
  bool isLoading = false;

  bool get isFiltered => selectedFilter != null;

  void _init() {
    _updateWeekDates();
    apiService.results.listen(_onResponse, onError: _onError);
    loadSchedule();
  }

  void _onResponse(ScheduleResponse? response) {
    isLoading = false;

    if (response != null) {
      lastResponse = response;
      error = null;
      _extractParamsFrom(response);
    } else {
      error = 'Ошибка при загрузке данных';
    }

    notifyListeners();
  }

  void _onError(dynamic e) {
    isLoading = false;
    error = e.toString();
    notifyListeners();
  }

  void loadSchedule({bool force = false}) {
    isLoading = true;
    notifyListeners();

    final start = isDayView ? selectedDate : selectedWeek.first;
    final end = isDayView ? selectedDate : selectedWeek.last;

    apiService.search((
      startDate: start,
      endDate: end,
      scheduleModel: params,
      forceUpdate: force
    ));
  }

  void _updateWeekDates() {
    final weekStart =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    selectedWeek = List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  void toggleView() {
    isDayView = !isDayView;
    loadSchedule();
  }

  void shiftDate(int days) {
    selectedDate = selectedDate.add(Duration(days: days));
    _updateWeekDates();
    loadSchedule();
  }

  void onDateSelected(DateTime date) {
    selectedDate = date;
    _updateWeekDates();
    loadSchedule();
  }

  void toggleFilter({required String? filter}) {
    selectedFilter = filter;
    _generateGroupColors();
    notifyListeners();
  }

  void clearFilters() {
    selectedFilter = null;
    notifyListeners();
  }

  void _extractParamsFrom(ScheduleResponse response) {
    availableGroups = response.getAllGroups();
    availableTeachers = response.getAllTeachers();
    _generateGroupColors();
  }

  void _generateGroupColors() {
    groupColors
      ..clear()
      ..addEntries(
        availableGroups.asMap().entries.map((entry) {
          final index = entry.key;
          final group = entry.value;
          return MapEntry(
            group,
            group == selectedFilter
                ? Colors.amber.shade600
                : ScheduleStyles.getGroupColor(index),
          );
        }),
      );
  }
}
