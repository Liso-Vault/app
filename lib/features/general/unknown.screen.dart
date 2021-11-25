import 'package:flutter/material.dart';

class UnknownScreen extends StatelessWidget {
  const UnknownScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Unknown Route')),
        body: const Center(
          child: Text("You're in the wrong route."),
        ),
      ),
    );
  }
}
