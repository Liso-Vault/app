import 'package:flutter/material.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/globals.dart';

class ProText extends StatelessWidget {
  final double? size;
  const ProText({Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ConfigService.to.appName,
          style: TextStyle(fontSize: size, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          'Pro',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: proColor,
          ),
        ),
      ],
    );
  }
}
