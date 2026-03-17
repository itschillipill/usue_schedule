import 'package:flutter/material.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import '../../features/schedule/presentation/add_schedule_screen.dart';
import '../../features/schedule/presentation/schedule_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppGate extends StatelessWidget {
  AppGate({super.key});

  final ValueNotifier<int> selectedIndex = ValueNotifier(0);

   final List<Widget> screens = const[
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
                const BottomNavigationBarItem(
                    icon: Icon(Icons.list), label: "Расписания"),
                const BottomNavigationBarItem(
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
                  child: const Icon(Icons.add),
                )
              : null,
        ),
      ),
    );
  }
}
