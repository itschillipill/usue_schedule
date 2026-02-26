import 'package:flutter/material.dart';
import 'package:usue_schedule/presentation/widgets/custom_list_tile.dart';
import 'package:usue_schedule/services/message_service.dart';

import '../../models/schedule_model.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleModel scheduleModel;
  final bool isSelected;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ScheduleCard({
    super.key,
    required this.scheduleModel,
    this.isSelected = false,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
        mainColor: scheduleModel.requestType.color,
        title: scheduleModel.queryValue,
        subTitle: scheduleModel.requestType.text,
        leadingIcon: scheduleModel.requestType.icon,
        onTap: onTap,
        border: isSelected
            ? BorderSide(color: scheduleModel.requestType.color)
            : BorderSide.none,
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: scheduleModel.requestType.color,
              )
            : onDelete != null
                ? IconButton(
                    onPressed: () => MessageServise.confirmAction(
                        onOk: () => onDelete?.call(),
                        title: "Удалить расписание",
                        message:
                            "Вы действительно хотите удалить расписание '${scheduleModel.queryValue}'?"),
                    icon: Icon(Icons.delete_outline),
                  )
                : null);
  }
}
