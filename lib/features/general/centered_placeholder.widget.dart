import 'package:liso/core/utils/styles.dart';
import 'package:flutter/material.dart';

class CenteredPlaceholder extends StatelessWidget {
  final IconData iconData;
  final String message;
  final Widget? child;

  const CenteredPlaceholder({
    Key? key,
    required this.iconData,
    required this.message,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: Styles.containerConstraints,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, size: 100, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              if (child != null) ...[
                const SizedBox(height: 25),
                child!,
              ]
            ],
          ),
        ),
      ),
    );
  }
}
