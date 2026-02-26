import 'package:flutter/material.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'add_schedule_screen.dart';
import 'schedule_screen.dart';
import 'settings_screen.dart';

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  int _selectedIndex = 0;
  List<Widget> screens = [
    ScheduleScreen(),
    SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedIndex],
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: _selectedIndex == 0
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
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.shifting,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.list), label: "Расписания"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Настройки"),
          ]),
    );
  }
}
