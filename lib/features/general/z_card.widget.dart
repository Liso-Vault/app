import 'package:liso/features/general/titled_divider.widget.dart';
import 'package:flutter/material.dart';

class ZCard extends StatelessWidget {
  final String? title;
  final Widget child;

  const ZCard({
    Key? key,
    required this.child,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: title == null
            ? child
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitledDivider(title: title!),
                  child,
                ],
              ),
      ),
    );
  }
}
