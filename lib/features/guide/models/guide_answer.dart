class GuideAnswer {
  final String content; // Основной текст ответа
  final List<String> steps; // Пошаговая инструкция
  final String? videoUrl; // Ссылка на видео
  final List<String>? tips; // Полезные советы
  final List<String>? warnings; // Предупреждения

  GuideAnswer({
    required this.content,
    required this.steps,
    this.videoUrl,
    this.tips,
    this.warnings,
  });
}
