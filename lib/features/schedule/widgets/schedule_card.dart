import 'package:flutter/material.dart';
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
    return CustomListTile(
        mainColor: scheduleModel.requestType.color,
        title: scheduleModel.queryValue,
        subTitle: scheduleModel.requestType.text,
        leadingIcon: scheduleModel.requestType.icon,
        onTap: onTap,
        onLongPress: onLongPress,
        border: isSelected
            ? BorderSide(color: scheduleModel.requestType.color)
            : BorderSide.none,
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: scheduleModel.requestType.color,
              )
            : trailing);
  }
}
