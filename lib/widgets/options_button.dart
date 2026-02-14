import 'package:flutter/material.dart';

class OptionsButton extends StatefulWidget {
  const OptionsButton({super.key});

  @override
  State<OptionsButton> createState() => _OptionsButtonState();
}

class _OptionsButtonState extends State<OptionsButton> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {},
      itemBuilder:(context) => [
        PopupMenuItem(
          value: "export_schedule",
          child: Text("Экспорт расписания"))
      ],
      child:  Icon(Icons.more_vert));
  }
}