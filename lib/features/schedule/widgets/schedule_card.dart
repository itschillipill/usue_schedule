import 'package:material_ui/material_ui.dart';
import 'package:usue_schedule/shared/widgets/custom_list_tile.dart';

import '../models/schedule_model.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleModel scheduleModel;
  final bool isSelected;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int index;

  const ScheduleCard({
    super.key,
    required this.scheduleModel,
    this.index = -1,
    this.isSelected = false,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = scheduleModel.scheduleType.color;

    return CustomListTile(
      mainColor: typeColor,
      title: scheduleModel.queryValue,
      subTitle: scheduleModel.scheduleType.text,
      leadingIcon: scheduleModel.scheduleType.icon,
      onTap: onTap,
      onLongPress: onLongPress,
      // Делаем бордер более акцентным, если карточка выбрана
      border:
          isSelected ? BorderSide(color: typeColor, width: 2) : BorderSide.none,
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isSelected
            ? Icon(
                Icons.check_circle,
                key: const ValueKey('selected'),
                color: typeColor,
                size: 28,
              )
            : (trailing ??
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20)),
      ),
    );
  }
}
