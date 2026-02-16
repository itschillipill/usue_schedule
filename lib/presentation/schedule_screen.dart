import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/schedule_styles.dart';
import '../cubit/schedule.dart';
import 'widgets/borde_box.dart';
import 'add_schedule_screen.dart';
import 'show_schedule_screen.dart';
import 'widgets/schedule_card.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyScheduleCubit, MyScheduleState>(
      builder: (context, state) {
        final mySchedules = state.schedules;
        final scheduleCubit = context.read<MyScheduleCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Расписание занятий",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            centerTitle: true,
          ),
          body: DecoratedBox(
            decoration: ScheduleStyles.linearBackgroundDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mySchedules.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 80,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Расписаний пока нет",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Добавьте первое расписание",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Text(
                      "Мои расписания",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: mySchedules.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final schedule = mySchedules[index];
                        return OpenContainer(
                            closedColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            closedElevation: 0,
                            closedBuilder: (context, action) => BorderBox(
                                  child: ScheduleCard(
                                    schedule: schedule,
                                    onDelete: () =>
                                        scheduleCubit.removeSchedule(schedule),
                                  ),
                                ),
                            openBuilder: (context, action) =>
                                ShowScheduleScreen(params: schedule));
                      },
                    ),
                  ),
                ]
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final newSchedule = await Navigator.push(
                context,
                AddScheduleScreen.route(),
              );
              if (newSchedule == null) return;
              scheduleCubit.addSchedule(newSchedule);
            },
            icon: Icon(Icons.add, size: 24),
            label: Text(
              "Добавить",
            ),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
