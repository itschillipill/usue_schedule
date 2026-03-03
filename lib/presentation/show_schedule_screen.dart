import 'dart:async';
import 'package:flutter/material.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'package:usue_schedule/models/request_type.dart';
import 'package:usue_schedule/presentation/widgets/day_view.dart';
import 'package:usue_schedule/presentation/widgets/filter_button.dart';
import 'package:usue_schedule/presentation/widgets/load_view.dart';
import '../core/theme/schedule_styles.dart';
import '../models/schedule_model.dart';
import '../models/schedule_response.dart';
import '../services/api.dart';
import 'widgets/build_empty_state.dart';
import 'widgets/date_picker.dart';
import 'widgets/error_view.dart';
import 'widgets/schedule_header.dart';
import 'widgets/week_view.dart';
import 'export_schedule_screen.dart';

class ShowScheduleScreen extends StatefulWidget {
  static Route<ScheduleModel> route({required ScheduleModel params}) {
    return MaterialPageRoute(
      builder: (_) => ShowScheduleScreen(params: params),
    );
  }

  final ScheduleModel params;

  const ShowScheduleScreen({super.key, required this.params});

  @override
  State<ShowScheduleScreen> createState() => _ShowScheduleScreenState();
}

class _ShowScheduleScreenState extends State<ShowScheduleScreen> {
  late final ApiService _apiService;

  DateTime _selectedDate = DateTime.now();
  bool _isDayView = true;
  List<DateTime> _selectedWeek = [];

  String? _selectedFilter;
  List<String> _availableGroups = [];
  List<String> _availableTeachers = [];
  final Map<String, Color> _groupColors = {};

  ScheduleResponse? _lastResponse;
  String? _error;
  bool _isLoading = false;

  StreamSubscription<ScheduleResponse?>? _subscription;

  bool get _isFiltered => _selectedFilter != null;

  @override
  void initState() {
    super.initState();
    _apiService = DependenciesScope.of(context).apiService;
    _updateWeekDates();

    _subscription = _apiService.results.listen(
      (response) {
        setState(() {
          _isLoading = false;
          if (response != null) {
            _lastResponse = response;
            _error = null;
            _extractGroupsAndTeachersFromResponse(response);
          } else {
            _error = 'Ошибка при загрузке данных';
          }
        });
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _error = error.toString();
        });
      },
    );
    _loadSchedule();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _updateWeekDates() {
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    _selectedWeek =
        List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  void _loadSchedule({bool force = false}) {
    setState(() => _isLoading = true);

    final start = _isDayView ? _selectedDate : _selectedWeek.first;
    final end = _isDayView ? _selectedDate : _selectedWeek.last;

    _apiService.search((
      startDate: start,
      endDate: end,
      scheduleModel: widget.params,
      forceUpdate: force
    ));
  }

  void _extractGroupsAndTeachersFromResponse(ScheduleResponse response) {
    final groups = <String>{};
    final teachers = <String>{};

    for (var day in response.schedules) {
      for (var pair in day.pairs) {
        for (var schedulePair in pair.schedulePairs) {
          groups.add(schedulePair.cleanGroup);
          teachers.add(schedulePair.teacher);
        }
      }
    }

    _availableGroups = groups.toList()..sort();
    _availableTeachers = teachers.toList()..sort();
    _generateGroupColors();
  }

  void _generateGroupColors() {
    _groupColors
      ..clear()
      ..addEntries(
        _availableGroups.asMap().entries.map((entry) {
          final index = entry.key;
          final group = entry.value;
          return MapEntry(
              group,
              identical(group, _selectedFilter)
                  ? Colors.amber.shade600
                  : ScheduleStyles.getGroupColor(index));
        }),
      );
  }

  void _onDateSelected(DateTime date) {
    _selectedDate = date;
    _updateWeekDates();
    _loadSchedule();
  }

  void _toggleView() {
    _isDayView = !_isDayView;
    _loadSchedule();
  }

  void _shiftDate(int days) {
    _selectedDate = _selectedDate.add(Duration(days: days));
    _updateWeekDates();
    _loadSchedule();
  }

  void _navigateToPrevious() => _shiftDate(_isDayView ? -1 : -7);
  void _navigateToNext() => _shiftDate(_isDayView ? 1 : 7);

  void _toggleFilter({required String? filter}) {
    _selectedFilter = filter;
    _generateGroupColors();
    setState(() {});
  }

  void clearFilters() {
    setState(() => _selectedFilter = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverAppBar(
                actionsPadding: EdgeInsets.symmetric(horizontal: 4),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.params.queryValue,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      widget.params.requestType.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                actions: [
                  FilterButton(
                    selectedFilter: _selectedFilter,
                    availableGroups: _availableGroups,
                    availableTeachers: _availableTeachers,
                    requestType: widget.params.requestType,
                    generatedColors: _groupColors,
                    toggleFilter: _toggleFilter,
                  ),
                  PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "export_schedule") {
                          Navigator.push(
                              context,
                              ExportScheduleScreen.route(
                                widget.params,
                                _apiService.getSchedule,
                              ));
                        }
                        if (value == "force_update_schedule") {
                          _loadSchedule(force: true);
                        }
                      },
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                value: "export_schedule",
                                child: Text("Экспорт расписания")),
                            PopupMenuItem(
                                value: "force_update_schedule",
                                child: Text("Обновить с сервером")),
                          ],
                      child: Icon(Icons.more_vert)),
                ],
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: ScheduleHeaderDelegate(
                  isDayView: _isDayView,
                  selectedDate: _selectedDate,
                  selectedWeek: _selectedWeek,
                  navigatePrevious: _navigateToPrevious,
                  navigateNext: _navigateToNext,
                  toggleView: _toggleView,
                  showCalendar: DatePicker(
                          context: context,
                          selectedDate: _selectedDate,
                          onDateSelected: _onDateSelected)
                      .call,
                ),
              ),
            ];
          },
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return LoadView();
    if (_error != null) {
      return ErrorView(error: _error!, onRetry: _loadSchedule);
    }
    if (_lastResponse == null) {
      return const Center(child: Text('Загрузка данных...'));
    }

    final filteredData = switch (widget.params.requestType) {
      RequestType.group => _lastResponse!.filterByTeacher(_selectedFilter),
      RequestType.teacher => _lastResponse!.filterByGroup(_selectedFilter),
      _ => _lastResponse!,
    };

    final emptyState = BuildEmptyState(
      isFiltered: _isFiltered,
      isDayView: _isDayView,
      clearFilters: clearFilters,
    );

    return RefreshIndicator(
      onRefresh: () async => _loadSchedule(force: true),
      child: _isDayView
          ? DayView(
              data: filteredData,
              selectedDate: _selectedDate,
              groupColors: _groupColors,
              buildEmptyState: emptyState,
            )
          : WeekView(
              data: filteredData,
              selectedWeek: _selectedWeek,
              groupColors: _groupColors,
              buildEmptyState: emptyState,
            ),
    );
  }
}
