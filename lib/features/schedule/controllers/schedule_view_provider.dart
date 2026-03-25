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
  final ScheduleViewType initialViewType;
  final bool isDarkMode;
  ScheduleModel params;

  ScheduleViewProvider({
    required this.apiService,
    required this.params,
    required this.onUpdate,
    required this.isDarkMode,
    this.initialViewType = ScheduleViewType.day,
  }) {
    _init();
  }

  /// режим отображения
  late ScheduleViewType _viewType;

  ScheduleViewType get viewType => _viewType;

  List<String> get _activeFilters => params.requestType == RequestType.group
      ? availableTeachers
      : availableGroups;

  bool get hasFilters => _activeFilters.isNotEmpty;
  List<String> get availableFilters => _activeFilters;

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
    setViewType(initialViewType);
  }

  /// проверяем нужно ли обновить расписание, на случай если расписание обновили.
  bool _checkForceUpdate(bool force, ScheduleModel model) {
    if (force) return true;
    return model.needsUpdate();
  }

  /// загрузка расписания
  Future<void> loadSchedule({bool force = false}) async {
    force = _checkForceUpdate(force, params);

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response = await apiService.fetch(
        (
          startDate: rangeStart,
          endDate: rangeEnd,
          scheduleModel: params,
          forceUpdate: force,
          onUpdateModel: (model) {
            onUpdate(model);
            updateParams(model);
          },
        ),
      );

      if (response case final r?) {
        lastResponse = r;
        _extractParamsFrom(r);
      }
    } on ApiException catch (e) {
      error = [e.message, e.tip].whereType<String>().join('\n');
    } catch (_) {
      error = "Неизвестная ошибка";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateParams(ScheduleModel model) => params = model;

  /// DAY RANGE
  void _setDayRange(DateTime date, {bool notify = true}) {
    rangeStart = DateTime(date.year, date.month, date.day);
    rangeEnd = rangeStart;

    if (notify) notifyListeners();
  }

  /// WEEK RANGE
  void _setWeekRange(DateTime date, {bool notify = true}) {
    final start = date.subtract(Duration(days: date.weekday - 1));
    final end = start.add(const Duration(days: 6));

    rangeStart = DateTime(start.year, start.month, start.day);
    rangeEnd = DateTime(end.year, end.month, end.day);

    if (notify) notifyListeners();
  }

  /// MONTH RANGE
  void _setMonthRange(DateTime date, {bool notify = true}) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);

    rangeStart = DateTime(start.year, start.month, start.day);
    rangeEnd = DateTime(end.year, end.month, end.day);

    if (notify) notifyListeners();
  }

  /// CUSTOM RANGE
  void setCustomRange(DateTime start, DateTime end) {
    rangeStart = DateTime(start.year, start.month, start.day);
    rangeEnd = DateTime(end.year, end.month, end.day);

    loadSchedule();
  }

  /// переключение режима
  void setViewType(ScheduleViewType type, {DateTime? date}) {
    _viewType = type;

    final fn = switch (type) {
      ScheduleViewType.day => _setDayRange,
      ScheduleViewType.week => _setWeekRange,
      ScheduleViewType.month => _setMonthRange,
      ScheduleViewType.custom => (_) {},
    };

    fn(date ?? DateTime.now());

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

      case ScheduleViewType.month:
        _setMonthRange(DateTime(rangeStart.year, rangeStart.month + 1));
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

      case ScheduleViewType.month:
        _setMonthRange(DateTime(rangeStart.year, rangeStart.month - 1));
        break;

      default:
        break;
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
            ScheduleStyles.getGroupColor(index, isDarkMode),
          );
        }),
      );
  }
}
