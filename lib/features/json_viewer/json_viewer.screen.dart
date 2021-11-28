import 'package:flutter/material.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';

class JSONViewerScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const JSONViewerScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSON Viewer')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: JsonObjectViewer(data),
        ),
      ),
    );
  }
}
