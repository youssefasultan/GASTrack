import 'package:flutter/material.dart';

import 'ui/powered_by_ecs.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/images/logo.png',
            ),
          ),
          const PoweredByEcs(),
        ],
      ),
    );
  }
}
