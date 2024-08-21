import 'package:flutter/material.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:sizer/sizer.dart';

import 'ui/powered_by_ecs.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    required this.stage,
  });

  final VPNStage stage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              'assets/images/logo.png',
            ),
          ),
          Text(
            getStageName(stage, context),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: context.theme.primaryColor,
            ),
          ),
          const PoweredByEcs(),
        ],
      ),
    );
  }

  String getStageName(VPNStage stage, BuildContext context) {
    switch (stage) {
      case VPNStage.error:
        return context.translate.error;

      default:
        return context.translate.plesaeWait;
    }
  }
}
