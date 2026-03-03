import 'package:flutter/material.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'add_schedule_screen.dart';
import 'schedule_screen.dart';
import 'settings_screen.dart';

class AppGate extends StatelessWidget {
  AppGate({super.key});

  final ValueNotifier<int> selectedIndex = ValueNotifier(0);

  final List<Widget> screens = [
    ScheduleScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedIndex,
      builder: (_, index, __) => PopScope(
        canPop: index == 0,
        // ignore: deprecated_member_use
        onPopInvoked: (_) => selectedIndex.value = 0,
        child: Scaffold(
          body: screens[index],
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: index,
              onTap: (i) => selectedIndex.value = i,
              type: BottomNavigationBarType.shifting,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.list), label: "Расписания"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: "Настройки"),
              ]),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: index == 0
              ? FloatingActionButton(
                  onPressed: () async {
                    final newSchedule = await Navigator.push(
                      context,
                      AddScheduleScreen.route(),
                    );
                    if (newSchedule != null && context.mounted) {
                      DependenciesScope.of(context)
                          .scheduleCubit
                          .addSchedule(newSchedule);
                    }
                  },
                  child: Icon(Icons.add),
                )
              : null,
        ),
      ),
    );
  }
}
