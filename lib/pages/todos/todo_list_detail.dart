import 'package:flutter/material.dart';

import 'todo_list_detail_view.dart';

class TodoListDetailPage extends StatefulWidget {
  const TodoListDetailPage({
    required this.listId,
    this.initialTitle,
    this.initialDescription,
    super.key,
  });

  final String listId;
  final String? initialTitle;
  final String? initialDescription;

  @override
  State<TodoListDetailPage> createState() => TodoListDetailPageController();
}

class TodoListDetailPageController extends State<TodoListDetailPage> {
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) => TodoListDetailPageView(this);
}
