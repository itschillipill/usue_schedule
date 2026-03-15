/// Кастомные исключения для API
abstract class ApiException implements Exception {
  final String message;
  final dynamic originalError;
  final String? tip;

  ApiException(this.message, [this.originalError, this.tip]);

  @override
  String toString() => "$message: $originalError,${tip != null ? " $tip" : ""}";
}

class NetworkException extends ApiException {
  NetworkException([dynamic originalError])
      : super('Нет подключения к интернету', originalError,
            "Текущее расписание может быть устаревшим.\nПроверьте подключение к интернету и VPN — серверы университета могут быть недоступны через VPN.");
}

class TimeoutException extends ApiException {
  TimeoutException([dynamic originalError])
      : super('Превышено время ожидания ответа от сервера');
}

class ServerException extends ApiException {
  final int? statusCode;

  ServerException(this.statusCode, [dynamic originalError])
      : super(
            'Ошибка сервера${statusCode != null ? ' (код $statusCode)' : ''}');
}

class ParseException extends ApiException {
  ParseException([dynamic originalError]) : super('Ошибка обработки данных');
}

class UnknownException extends ApiException {
  UnknownException(super.message, [dynamic originalError]);
}
