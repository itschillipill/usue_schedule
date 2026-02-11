import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:usue_schedule/v2/models/request_type.dart';
import 'package:usue_schedule/v2/models/schedule_model.dart';

class ScheduleSearchService {
  final _querySubject = PublishSubject<ScheduleModel>();

  late final Stream<List<ScheduleModel>> results = _querySubject
      .debounceTime(const Duration(milliseconds: 300))
      .distinct((a, b) =>
          a.queryValue == b.queryValue && a.requestType == b.requestType)
      .switchMap(
          (model) => Stream.fromFuture(_search(model)).onErrorResume((err, st) {
                debugPrint('Ошибка поиска: $err');
                return Stream.value([]);
              }));

  void search(ScheduleModel query) => _querySubject.add(query);

  Future<List<ScheduleModel>> _search(ScheduleModel model) async {
    return _load(
      action: '${model.requestType.query}-list',
      query: model.queryValue,
      type: model.requestType,
    );
  }

  Future<List<ScheduleModel>> _load({
    required String action,
    required String query,
    required RequestType type,
  }) async {
    final uri = Uri.parse(
      'https://www.usue.ru/schedule/?action=$action&term=$query',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final List data = jsonDecode(utf8.decode(response.bodyBytes));

    return data
        .map((e) => ScheduleModel(
            queryValue: switch (type) {
              RequestType.teacher =>
                (e as Map<String, dynamic>)["label"].toString(),
              _ => e.toString(),
            },
            requestType: type))
        .toList();
  }

  void dispose() => _querySubject.close();
}
