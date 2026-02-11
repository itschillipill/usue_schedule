import 'package:flutter/material.dart';

class EmptyDay extends StatelessWidget {
  const EmptyDay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          Icon(
            Icons.celebration_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          Text(
            'Выходной!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
