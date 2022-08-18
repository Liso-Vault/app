import 'package:flutter/material.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';

import '../../core/utils/utils.dart';
import '../app/routes.dart';

class JSONViewerScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const JSONViewerScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Viewer'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
            child: const Text('Need Help ?'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: JsonObjectViewer(data),
      ),
    );
  }
}
