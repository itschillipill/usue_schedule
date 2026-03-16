import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;
import 'package:usue_schedule/core/logger/session_logger.dart';

import '../../core/constants.dart';

class InitializationErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const InitializationErrorScreen(
      {super.key, required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                "Произошла ошибка при запуске",
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SelectableText(
                error.toString(),
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _sendEmail(context),
                icon: const Icon(Icons.bug_report),
                label: const Text("Сообщить об ошибке"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _sendEmail(BuildContext context) async {
  final email = Uri(
    scheme: 'mailto',
    path: 'development.flutter.contact@gmail.com',
    queryParameters: {
      'subject': 'Обратная связь ${Constants.appName}',
      'body': """
\n
\n 
        logs: ${SessionLogger.instance.getLogs().take(10)}
"""
    },
  );

  await launchUrl(email);
}
