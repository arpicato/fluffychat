import 'package:flutter/material.dart';

import 'todos_view.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => TodosPageController();
}

class TodosPageController extends State<TodosPage> {
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) => TodosPageView(this);
}
