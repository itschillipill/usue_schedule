import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usue_schedule/core/theme/theme.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'package:usue_schedule/features/schedule/widgets/date_picker.dart';
import 'package:usue_schedule/features/schedule/widgets/day_view.dart';
import 'package:usue_schedule/features/schedule/widgets/load_view.dart';
import 'package:usue_schedule/shared/services/message_service.dart';

import '../../export/services/export_service.dart';
import '../../export/widgets/filter_selector.dart';
import '../controllers/schedule_view_provider.dart';
import '../models/schedule_model.dart';
import '../models/schedule_view_type.dart';

import '../widgets/build_empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/schedule_header.dart';
import '../widgets/custom_range_view.dart';

class ShowScheduleScreen extends StatelessWidget {
  static Route<ScheduleModel> route({required ScheduleModel params}) {
    return MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider(
        create: (_) => ScheduleViewProvider(
          apiService: DependenciesScope.of(context).apiService,
          params: params,
        ),
        child: ShowScheduleScreen(params: params),
      ),
    );
  }

  final ScheduleModel params;

  const ShowScheduleScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleViewProvider>();

    return Scaffold(
      backgroundColor: context.isDarkMode ? Colors.black12 : Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            _buildAppBar(context, provider),
            _buildHeader(context, provider),
          ],
          body: _buildBody(provider),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, ScheduleViewProvider provider) {
    return SliverAppBar(
      floating: true,
      snap: true,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(params.queryValue, style: const TextStyle(fontSize: 16)),
          Text(
            params.requestType.text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: (provider.selectedFilter != null) ? Colors.amber : null,
          ),
          onPressed: () async {
            final filter = await FilterSelector.show(context, provider,
                filter: provider.selectedFilter);
            if (filter != null) {
              provider.toggleFilter(filter: filter.isEmpty ? null : filter);
            }
          },
          tooltip: 'Фильтр',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "force_update_schedule") {
              provider.loadSchedule(force: true);
            }
            if (value == "download_schedule") {
              if (provider.lastResponse == null) return;
              final filtredData = provider.lastResponse!.schedules
                  .where((s) => s.pairs.any((p) => p.schedulePairs.isNotEmpty));
              if (filtredData.isEmpty) {
                MessageService.showSnackBar(
                    "На этот период расписание не найдено");
                return;
              }
              ExportService.exportSchedule(context, provider);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: "force_update_schedule",
              child: Text("Обновить с сервером"),
            ),
            PopupMenuItem(
              value: "download_schedule",
              child: Text("Скачать расписание"),
            ),
          ],
          child: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  SliverPersistentHeader _buildHeader(
      BuildContext context, ScheduleViewProvider provider) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: ScheduleHeaderDelegate(
        viewType: provider.viewType,
        rangeStart: provider.rangeStart,
        rangeEnd: provider.rangeEnd,
        navigatePrevious: provider.navigatePrevious,
        navigateNext: provider.navigateNext,
        onViewTypeChanged: provider.setViewType,
        showCalendar: () async {
          if (provider.viewType == ScheduleViewType.custom) {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now().subtract(Duration(days: 365)),
              lastDate: DateTime.now().add(Duration(days: 365)),
              initialEntryMode: DatePickerEntryMode.inputOnly,
              initialDateRange: DateTimeRange(
                start: provider.rangeStart,
                end: provider.rangeEnd,
              ),
            );

            if (range != null) {
              provider.setCustomRange(range.start, range.end);
            }
          } else {
            DatePicker(
              selectedDate: provider.rangeStart,
              onDateSelected: provider.onDateSelected,
              context: context,
            ).call();
          }
        },
      ),
    );
  }

  Widget _buildBody(ScheduleViewProvider provider) {
    if (provider.isLoading) return const LoadView();

    if (provider.error != null) {
      return ErrorView(
        error: provider.error!,
        onRetry: provider.loadSchedule,
      );
    }

    if (provider.lastResponse == null) {
      return const Center(child: Text('Загрузка данных...'));
    }

    final filteredData = provider.lastResponse!
        .getFiltredData(params.requestType, provider.selectedFilter);

    final emptyState = BuildEmptyState(
      isFiltered: provider.isFiltered,
      isDayView: provider.viewType == ScheduleViewType.day,
      clearFilters: provider.clearFilters,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: provider.viewType == ScheduleViewType.day
          ? DayView(
              data: filteredData,
              selectedDate: provider.rangeStart,
              groupColors: provider.groupColors,
              buildEmptyState: emptyState,
            )
          : CustomRangeView(
              data: filteredData,
              rangeStart: provider.rangeStart,
              rangeEnd: provider.rangeEnd,
              groupColors: provider.groupColors,
              buildEmptyState: emptyState,
            ),
    );
  }
}
