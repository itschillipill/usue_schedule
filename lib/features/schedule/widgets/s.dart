import 'package:material_ui/material_ui.dart';

class S extends StatelessWidget {
  const S(this.data, {super.key});

  final (IconData, String, String) data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Icon(
            data.$1,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Text(
            data.$2,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            data.$3,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
