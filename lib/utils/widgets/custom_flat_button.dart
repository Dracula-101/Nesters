import 'package:flutter/material.dart';
import 'package:nesters/theme/theme.dart';

class CustomFlatButton extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onPressed;
  const CustomFlatButton(
      {super.key,
      required this.onPressed,
      this.padding,
      required this.text,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            width: constraints.maxWidth,
            alignment: Alignment.center,
            padding: padding ?? const EdgeInsets.all(10),
            child: Text(
              text,
              style: textStyle ??
                  AppTheme.bodyMedium.copyWith(color: AppTheme.onPrimary),
            ),
          ),
        );
      },
    );
  }
}
