import 'package:flutter/material.dart';
import 'package:usue_schedule/core/api_exceptions.dart';
import 'package:usue_schedule/core/theme/schedule_styles.dart';
import 'package:usue_schedule/features/schedule/models/schedule_model.dart';
import 'package:usue_schedule/features/schedule/models/schedule_response.dart';
import 'package:usue_schedule/features/schedule/services/api.dart';

import '../models/request_type.dart';
import '../models/schedule_view_type.dart';

class ScheduleViewProvider extends ChangeNotifier {
  final ApiService apiService;
  final Function(ScheduleModel model) onUpdate;
  ScheduleModel params;

  ScheduleViewProvider({
    required this.apiService,
    required this.params,
    required this.onUpdate,
  }) {
    _init();
  }

  /// режим отображения
  ScheduleViewType _viewType = ScheduleViewType.day;

  ScheduleViewType get viewType => _viewType;

  bool get hasFilters => params.requestType == RequestType.group
      ? availableTeachers.isNotEmpty
      : availableGroups.isNotEmpty;

  List<String> get availableFilters => params.requestType == RequestType.group
      ? availableTeachers
      : availableGroups;

  /// диапазон дат
  DateTime rangeStart = DateTime.now();
  DateTime rangeEnd = DateTime.now();

  /// фильтр
  String? selectedFilter;

  /// доступные параметры
  List<String> availableGroups = [];
  List<String> availableTeachers = [];

  /// цвета групп
  final Map<String, Color> groupColors = {};

  /// данные
  ScheduleResponse? lastResponse;

  /// состояние
  String? error;
  bool isLoading = false;

  bool get isFiltered => selectedFilter != null;

  /// инициализация
  void _init() {
    // устанавливаем параметры по умолчанию
    rangeStart = DateTime.now();
    rangeEnd = rangeStart;
    _viewType = ScheduleViewType.day;

    loadSchedule();
  }

  /// загрузка расписания
  Future<void> loadSchedule({bool force = false}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response = await apiService.search(
        (
          startDate: rangeStart,
          endDate: rangeEnd,
          scheduleModel: params,
          forceUpdate: force
        ),
        onUpdateModel: (model) {
          onUpdate(model);
          updateParams(model);
        },
      );

      if (response != null) {
        lastResponse = response;
        _extractParamsFrom(response);
      }
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = "Неизвестная ошибка";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateParams(ScheduleModel model) => params = model;

  /// DAY RANGE
  void _setDayRange(DateTime date) {
    _viewType = ScheduleViewType.day;

    rangeStart = DateTime(date.year, date.month, date.day);
    rangeEnd = rangeStart;

    notifyListeners();
  }

  /// WEEK RANGE
  void _setWeekRange(DateTime date) {
    _viewType = ScheduleViewType.week;

    final start = date.subtract(Duration(days: date.weekday - 1));
    final end = start.add(const Duration(days: 6));

    rangeStart = DateTime(start.year, start.month, start.day);
    rangeEnd = DateTime(end.year, end.month, end.day);

    notifyListeners();
  }

  /// CUSTOM RANGE
  void setCustomRange(DateTime start, DateTime end) {
    _viewType = ScheduleViewType.custom;

    rangeStart = DateTime(start.year, start.month, start.day);
    rangeEnd = DateTime(end.year, end.month, end.day);

    loadSchedule();
  }

  /// переключение режима
  void setViewType(ScheduleViewType type) {
    switch (type) {
      case ScheduleViewType.day:
        _setDayRange(DateTime.now());
        break;

      case ScheduleViewType.week:
        _setWeekRange(rangeStart);
        break;

      case ScheduleViewType.custom:
        _viewType = ScheduleViewType.custom;
        break;
    }

    loadSchedule();
  }

  /// навигация вперед
  void navigateNext() {
    switch (_viewType) {
      case ScheduleViewType.day:
        _setDayRange(rangeStart.add(const Duration(days: 1)));
        break;

      case ScheduleViewType.week:
        _setWeekRange(rangeStart.add(const Duration(days: 7)));
        break;

      default:
        break;
    }

    loadSchedule();
  }

  /// навигация назад
  void navigatePrevious() {
    switch (_viewType) {
      case ScheduleViewType.day:
        _setDayRange(rangeStart.subtract(const Duration(days: 1)));
        break;

      case ScheduleViewType.week:
        _setWeekRange(rangeStart.subtract(const Duration(days: 7)));
        break;
      default:
        break;
    }

    loadSchedule();
  }

  /// выбор даты из календаря
  void onDateSelected(DateTime date) {
    switch (_viewType) {
      case ScheduleViewType.day:
        _setDayRange(date);
        break;

      case ScheduleViewType.week:
        _setWeekRange(date);
        break;

      default:
        return;
    }

    loadSchedule();
  }

  /// фильтр
  void toggleFilter({required String? filter}) {
    selectedFilter = filter;
    _generateGroupColors();
    notifyListeners();
  }

  void clearFilters() {
    selectedFilter = null;
    notifyListeners();
  }

  /// извлечение параметров
  void _extractParamsFrom(ScheduleResponse response) {
    availableGroups = response.getAllGroups();
    availableTeachers = response.getAllTeachers();
    _generateGroupColors();
  }

  /// генерация цветов
  void _generateGroupColors() {
    groupColors
      ..clear()
      ..addEntries(
        availableGroups.asMap().entries.map((entry) {
          final index = entry.key;
          final group = entry.value;

          return MapEntry(
            group,
            ScheduleStyles.getGroupColor(index),
          );
        }),
      );
  }
}
