import 'package:flutter/material.dart';
import 'package:gas_track/core/extentions/context_ext.dart';

class DialogButton extends StatelessWidget {
  const DialogButton({
    super.key,
    required this.fun,
    required this.title,
    required this.bgColor,
    this.borderColor,
    this.textColor,
    this.isEnabled = true,
  });

  final Function()? fun;
  final String title;
  final Color bgColor;
  final Color? borderColor;
  final Color? textColor;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    var textColorCheck = bgColor == context.theme.primaryColor;
    return TextButton(
      onPressed: isEnabled ? fun : null,
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            side: BorderSide(
              color: borderColor ?? bgColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(
            horizontal: 30.0,
            vertical: 8.0,
          ),
        ),
        backgroundColor: WidgetStateProperty.all(
          isEnabled ? bgColor : Colors.grey,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Bebas',
          fontSize: 20.0,
          color: textColor ??
              (textColorCheck ? Colors.white : Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
