import 'dart:convert';

import 'package:fluffychat/utils/custom_http_client.dart';
import 'package:http/http.dart' as http;

DateTime? _parseMessieDateTime(String? value) =>
    value == null || value.isEmpty ? null : DateTime.tryParse(value);

class MessieTodoList {
  MessieTodoList({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MessieTodoList.fromJson(Map<String, Object?> json) => MessieTodoList(
    id: (json['id'] ?? '').toString(),
    ownerId: (json['ownerId'] ?? json['owner_id'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    createdAt: _parseMessieDateTime(
      (json['createdAt'] ?? json['created_at'])?.toString(),
    ),
    updatedAt: _parseMessieDateTime(
      (json['updatedAt'] ?? json['updated_at'])?.toString(),
    ),
  );
}

class MessieTodoItem {
  MessieTodoItem({
    required this.id,
    required this.listId,
    required this.title,
    required this.description,
    required this.completed,
    required this.position,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String listId;
  final String title;
  final String description;
  final bool completed;
  final String position;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MessieTodoItem.fromJson(Map<String, Object?> json) => MessieTodoItem(
    id: (json['id'] ?? '').toString(),
    listId: (json['listId'] ?? json['list_id'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    completed: json['completed'] == true,
    position: (json['position'] ?? '').toString(),
    dueDate: _parseMessieDateTime(
      (json['dueDate'] ?? json['due_date'])?.toString(),
    ),
    createdAt: _parseMessieDateTime(
      (json['createdAt'] ?? json['created_at'])?.toString(),
    ),
    updatedAt: _parseMessieDateTime(
      (json['updatedAt'] ?? json['updated_at'])?.toString(),
    ),
  );
}

class MessieTodoService {
  MessieTodoService({http.Client? httpClient})
    : _httpClient = httpClient ?? CustomHttpClient.createHTTPClient();

  final http.Client _httpClient;

  Future<List<MessieTodoList>> getTodoLists({
    required String apiBaseUrl,
    required String jwt,
    required String userId,
  }) async {
    final uri = Uri.parse(
      '$apiBaseUrl/todolists',
    ).replace(queryParameters: {'userId': userId});
    final response = await _httpClient.get(
      uri,
      headers: {'authorization': 'Bearer $jwt'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to load todos (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final items = switch (decoded) {
      List<dynamic> list => list,
      {'data': List<dynamic> list} => list,
      _ => throw const FormatException('Unexpected todos response shape'),
    };

    return items
        .map((item) => MessieTodoList.fromJson(Map<String, Object?>.from(item)))
        .toList();
  }

  Future<List<MessieTodoItem>> getTodoItems({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
  }) async {
    final response = await _httpClient.get(
      Uri.parse('$apiBaseUrl/todolists/$listId/items'),
      headers: {'authorization': 'Bearer $jwt'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to load todo items (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final items = switch (decoded) {
      List<dynamic> list => list,
      {'data': List<dynamic> list} => list,
      _ => throw const FormatException('Unexpected todo items response shape'),
    };

    return items
        .map((item) => MessieTodoItem.fromJson(Map<String, Object?>.from(item)))
        .toList();
  }
}
