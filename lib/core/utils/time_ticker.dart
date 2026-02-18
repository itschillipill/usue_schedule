import 'dart:async' show Timer;
import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;

class TimeTicker extends ChangeNotifier {
  TimeTicker() {
    _start();
  }

  late final Timer _timer;

  void _start() {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      debugPrint("TimeTicker worked!");
      notifyListeners();
    });
  }

  DateTime get now => DateTime.now();

 @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
