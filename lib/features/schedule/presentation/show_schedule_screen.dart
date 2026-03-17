import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usue_schedule/core/api_exceptions.dart';
import 'package:usue_schedule/core/theme/theme.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'package:usue_schedule/features/schedule/widgets/date_picker.dart';
import 'package:usue_schedule/features/schedule/widgets/day_view.dart';
import 'package:usue_schedule/features/schedule/widgets/load_view.dart';
import 'package:usue_schedule/shared/services/message_service.dart';
import 'package:usue_schedule/shared/widgets/border_box.dart';

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
    return MaterialPageRoute(builder: (context) {
      final deps = DependenciesScope.of(context);
      return ChangeNotifierProvider(
        create: (_) => ScheduleViewProvider(
          apiService: deps.apiService,
          onUpdate: deps.scheduleCubit.updateSchedule,
          params: params,
          initialViewType: deps.settingsCubit.state.viewType,
        ),
        child: ShowScheduleScreen(params: params),
      );
    });
  }

  final ScheduleModel params;

  const ShowScheduleScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleViewProvider>();

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            _buildAppBar(context, provider),
            _buildHeader(context, provider),
            if (provider.lastResponse?.exception case ApiException exception
                when provider.lastResponse?.isFromCache == true)
              _buildWarning(exception, context)
          ],
          body: DecoratedBox(
              decoration: BoxDecoration(color: context.backgroundColor),
              child: _buildBody(provider)),
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
      titleSpacing: 0,
      title: Text(params.queryValue, style: const TextStyle(fontSize: 16)),
      actions: [
        Badge(
          smallSize: 10,
          padding: EdgeInsets.zero,
          backgroundColor: (provider.groupColors[provider.selectedFilter] ??
              Theme.of(context).colorScheme.primary),
          isLabelVisible: (provider.selectedFilter != null),
          child: IconButton(
            icon: Icon(
              Icons.filter_list,
              color: (provider.selectedFilter != null)
                  ? (provider.groupColors[provider.selectedFilter] ??
                      Theme.of(context).colorScheme.primary)
                  : null,
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
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
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
              onDateSelected: (date) =>
                  provider.setViewType(provider.viewType, date: date),
              context: context,
            ).call();
          }
        },
      ),
    );
  }

  SliverToBoxAdapter _buildWarning(
      ApiException exception, BuildContext context) {
    return SliverToBoxAdapter(
      child: ColoredBox(
        color: context.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: BorderBox(
            borderColor: Colors.orange,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade800,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        exception.message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Текущее расписание может быть устаревшим.",
                          style: TextStyle(
                            fontSize: 14,
                          )),
                      Text(
                        exception.tip ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
