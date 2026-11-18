import 'package:material_ui/material_ui.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'schedule/presentation/add_schedule_screen.dart';
import 'schedule/presentation/schedule_screen.dart';
import 'settings/settings_screen.dart';

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  int selectedIndex = 0;

  static const List<Widget> screens = [
    ScheduleScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selectedIndex == 0,
      // ignore: deprecated_member_use
      onPopInvoked: (_) => setState(() => selectedIndex = 0),
      child: Scaffold(
        body: screens[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (i) => setState(() {
                  selectedIndex = i;
                }),
            type: BottomNavigationBarType.shifting,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), label: "Расписания"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "Настройки"),
            ]),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () async {
                  final newSchedule = await Navigator.push(
                    context,
                    AddScheduleScreen.route(),
                  );
                  if (newSchedule case final schadule? when context.mounted) {
                    DependenciesScope.of(context)
                        .scheduleCubit
                        .addSchedule(schadule);
                  }
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
