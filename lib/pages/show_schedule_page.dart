import 'dart:async';
import 'package:flutter/material.dart';
import 'package:usue_schedule/models/request_type.dart';
import 'package:usue_schedule/widgets/day_view.dart';
import 'package:usue_schedule/widgets/filter_button.dart';
import 'package:usue_schedule/widgets/load_view.dart';
import '../models/schedule_model.dart';
import '../models/schedule_response.dart';
import '../services/api.dart';
import '../widgets/build_empty_state.dart';
import '../widgets/date_picker.dart';
import '../widgets/error_view.dart';
import '../widgets/schedule_header.dart';
import '../widgets/week_view.dart';
import 'export_schedule_page.dart';

class ShowSchedulePage extends StatefulWidget {
  static Route<ScheduleModel> route({required ScheduleModel params}) {
    return MaterialPageRoute(
      builder: (_) => ShowSchedulePage(params: params),
    );
  }

  final ScheduleModel params;

  const ShowSchedulePage({super.key, required this.params});

  @override
  State<ShowSchedulePage> createState() => _ShowSchedulePageState();
}

class _ShowSchedulePageState extends State<ShowSchedulePage> {
  late final ApiService _apiService;

  DateTime _selectedDate = DateTime.now();
  DateTime _weekStart = DateTime.now();
  bool _isDayView = true;
  List<DateTime> _selectedWeek = [];

  String? _selectedGroupFilter;
  List<String> _availableGroups = [];
  String? _selectedTeacherFilter;
  List<String> _availableTeachers = [];
  Map<String, Color> _groupColors = {};
  Map<String, Color> _generatedColors = {};

  ScheduleResponse? _lastResponse;
  String? _error;
  bool _isLoading = false;

  StreamSubscription<ScheduleResponse?>? _subscription;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _updateWeekDates();

    _subscription = _apiService.results.listen(
      (response) {
        if (mounted) {
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
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = error.toString();
          });
        }
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
    _weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    _selectedWeek =
        List.generate(7, (index) => _weekStart.add(Duration(days: index)));
  }

  void _loadSchedule() {
    setState(() {
      _isLoading = true;
    });

    if (widget.params.requestType == RequestType.audience) {
      _apiService.search(
        (
          _isDayView ? _selectedDate : _selectedWeek.first,
          _isDayView ? _selectedDate : _selectedWeek.last,
          widget.params.requestType,
          widget.params.queryValue.replaceAll(RegExp(r'[^0-9]'), ''),
        ),
      );
    } else {
      _apiService.search(
        (
          _isDayView ? _selectedDate : _selectedWeek.first,
          _isDayView ? _selectedDate : _selectedWeek.last,
          widget.params.requestType,
          widget.params.queryValue,
        ),
      );
    }
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

    setState(() {
      _availableGroups = groups.toList()..sort();
      _availableTeachers = teachers.toList()..sort();
      _generateGroupColors();
    });
  }

  void _generateGroupColors() {
    final colorList = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
    ];

    _generatedColors = {};
    for (var i = 0; i < _availableGroups.length; i++) {
      _generatedColors[_availableGroups[i]] = colorList[i % colorList.length];
    }

    _groupColors = {..._generatedColors};
    if (_selectedGroupFilter != null &&
        _generatedColors.containsKey(_selectedGroupFilter)) {
      _groupColors[_selectedGroupFilter!] = Colors.amber.shade600;
    }
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

  void _navigateToPrevious() {
      _selectedDate =
          _selectedDate.subtract(Duration(days: _isDayView ? 1 : 7));
      _updateWeekDates();
    _loadSchedule();
  }

  void _navigateToNext() {
      _selectedDate = _selectedDate.add(Duration(days: _isDayView ? 1 : 7));
      _updateWeekDates();
    _loadSchedule();
  }

  void _toggleFilter({required String? group, required String? teacher}){
    _selectedGroupFilter = _selectedGroupFilter == group ? null : group;
    _selectedTeacherFilter=_selectedTeacherFilter == teacher ? null : teacher;
    _generateGroupColors();
    setState(() {});
  }

  void clearFilters() {
    setState(() {
      _selectedGroupFilter = null;
      _selectedTeacherFilter = null;
    });
  }

  void _retry() {
    _loadSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverAppBar(
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
                    selectedGroupFilter: _selectedGroupFilter,
                    selectedTeacherFilter: _selectedTeacherFilter,
                    availableGroups: _availableGroups,
                    availableTeachers: _availableTeachers,
                    requestType: widget.params.requestType,
                    generatedColors: _generatedColors,
                    toggleFilter: _toggleFilter,
                  ),
               PopupMenuButton<String>(
      onSelected: (value) {
        if (value == "export_schedule") {
          Navigator.push(context, ExportSchedulePage.route(
            widget.params,
            _apiService.getSchedule,
            ));
        }
      },
      itemBuilder:(context) => [
        PopupMenuItem(
          value: "export_schedule",
          child: Text("Экспорт расписания"))
      ],
      child:  Icon(Icons.more_vert)),
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
    if (_isLoading) {
      return LoadView();
    }

    if (_error != null) {
      return ErrorView(
        error: _error!,
        onRetry: _retry,
      );
    }

    if (_lastResponse == null) {
      return const Center(
        child: Text('Загрузка данных...'),
      );
    }

    final data = _lastResponse!;
    final filteredData = data
        .filterResponseByGroup(_selectedGroupFilter)
        .filterResponseByTeacher(_selectedTeacherFilter);

    if (_isDayView) {
      return DayView(
        data: filteredData,
        isFiltered:
            (_selectedGroupFilter != null || _selectedTeacherFilter != null),
        selectedDate: _selectedDate,
        groupColors: _groupColors,
        buildEmptyState: BuildEmptyState(
          isFiltered:
              (_selectedGroupFilter != null || _selectedTeacherFilter != null),
          isDayView: true,
          clearFilters: clearFilters,
        ),
      );
    } else {
      return WeekView(
        buildEmptyState: BuildEmptyState(
          isFiltered:
              (_selectedGroupFilter != null || _selectedTeacherFilter != null),
          isDayView: false,
          clearFilters: clearFilters,
        ),
        data: filteredData,
        selectedWeek: _selectedWeek,
        groupColors: _groupColors,
      );
    }
  }
}