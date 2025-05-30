import 'package:flutter/material.dart';
import 'package:gas_track/core/extentions/context_ext.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.text = ''});

  final String text;

  @override
  Widget build(BuildContext context) {
    var displayedText = text;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _getLoadingIndicator(),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              context.translate.plesaeWait,
              style: TextStyle(
                color: context.theme.primaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _getText(displayedText, context)
        ],
      ),
    );
  }

  Padding _getLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }

  Text _getText(String displayedText, BuildContext context) {
    return Text(
      displayedText,
      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }
}
