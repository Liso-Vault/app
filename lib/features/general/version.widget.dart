import 'package:flutter/material.dart';

import '../../core/utils/globals.dart';

class VersionText extends StatelessWidget {
  const VersionText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5, right: 10),
          child: Text(
            Globals.metadata?.app.formattedVersion ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
      ),
    );
  }
}
