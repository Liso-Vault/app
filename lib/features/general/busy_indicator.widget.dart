import 'package:flutter/material.dart';

class BusyIndicator extends StatelessWidget {
  final String message;
  final double size;
  final EdgeInsets padding;

  const BusyIndicator({
    Key? key,
    this.message = '',
    this.size = 35,
    this.padding = const EdgeInsets.all(20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: size,
              width: size,
              child: const CircularProgressIndicator(),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 25),
              Text(
                message,
                style: const TextStyle(color: Colors.grey),
              )
            ]
          ],
        ),
      ),
    );
  }
}
