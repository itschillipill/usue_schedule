import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usue_schedule/features/guide/presentation/guide_screen.dart';

import '../../../core/theme/schedule_styles.dart';
import '../controllers/schedule_cubit.dart';
import '../models/schedule_model.dart';
import '../../../shared/services/message_service.dart';
import 'show_schedule_screen.dart';
import '../widgets/schedule_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String query = "";
  bool isTextFieldVisible = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isTextFieldVisible,
      // ignore: deprecated_member_use
      onPopInvoked: (_) {
        setState(() {
          isTextFieldVisible = false;
          query = "";
        });
      },
      child: BlocBuilder<MyScheduleCubit, MyScheduleState>(
        builder: (context, state) {
          final mySchedules = state.schedules;
          final scheduleCubit = context.read<MyScheduleCubit>();
          final filtredSchedule = mySchedules.where((schedule) =>
              schedule.queryValue.toLowerCase().contains(query.toLowerCase()));
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Мои расписания",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              actions: [
                if (!isTextFieldVisible && mySchedules.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isTextFieldVisible = true;
                      });
                    },
                    icon: const Icon(Icons.search),
                  ),
                IconButton(
                    onPressed: () {
                      Navigator.push(context, GuideScreen.route());
                    },
                    icon: const Icon(Icons.help_outline_rounded)),
              ],
              centerTitle: true,
            ),
            body: DecoratedBox(
              decoration: ScheduleStyles.linearBackgroundDecoration(context),
              child: mySchedules.isNotEmpty
                  ? Column(
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: isTextFieldVisible
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8),
                                  child: TextField(
                                    onChanged: (value) => setState(() {
                                      query = value;
                                    }),
                                    decoration: InputDecoration(
                                      hintText: "Поиск...",
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => setState(() {
                                          isTextFieldVisible = false;
                                          query = "";
                                        }),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: filtredSchedule.length,
                              itemBuilder: (context, index) {
                                final schedule =
                                    filtredSchedule.elementAt(index);
                                return ScheduleCard(
                                  key: ValueKey(schedule.queryValue),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      ShowScheduleScreen.route(
                                          params: schedule),
                                    );
                                  },
                                  scheduleModel: schedule,
                                  trailing: _buildTrailingMenu(
                                      schedule, scheduleCubit),
                                );
                              }),
                        ),
                      ],
                    )
                  : buildEmptyState(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrailingMenu(ScheduleModel schedule, MyScheduleCubit cubit) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'delete':
            MessageService.confirmAction(
                onOk: () => cubit.removeSchedules([schedule]),
                title: "Удалить расписание",
                message:
                    "Вы действительно хотите удалить расписание '${schedule.queryValue}'?");
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            spacing: 5,
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 18),
              Text('Удалить', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 80,
          ),
          const Text(
            "Расписаний пока нет",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "Добавьте свое первое расписание",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
