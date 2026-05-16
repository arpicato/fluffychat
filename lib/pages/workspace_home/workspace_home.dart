import 'package:flutter/material.dart';

import 'workspace_home_view.dart';

class WorkspaceHomePage extends StatefulWidget {
  const WorkspaceHomePage({super.key});

  @override
  State<WorkspaceHomePage> createState() => WorkspaceHomePageController();
}

class WorkspaceHomePageController extends State<WorkspaceHomePage> {
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) => WorkspaceHomePageView(this);
}
