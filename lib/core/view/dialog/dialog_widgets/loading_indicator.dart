import 'package:flutter/material.dart';

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
          _getHeading(context),
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

  Widget _getHeading(context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        context.translate.plesaeWait,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
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
