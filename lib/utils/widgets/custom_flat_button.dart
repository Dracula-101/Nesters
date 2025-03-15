part of 'widgets.dart';

class CustomFlatButton extends StatelessWidget {
  final String text;
  final bool? isLoading;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onPressed;
  const CustomFlatButton(
      {super.key,
      required this.onPressed,
      this.padding,
      required this.text,
      this.textStyle,
      this.isLoading});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            width: constraints.maxWidth,
            alignment: Alignment.center,
            padding: padding ?? const EdgeInsets.all(10),
            child: (isLoading ?? false)
                ? AspectRatio(
                    aspectRatio: 1,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.onPrimary),
                      strokeWidth: 1.5,
                    ),
                  )
                : Text(
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
