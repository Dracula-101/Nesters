part of 'widgets.dart';

class DynamicProgressIndicator extends StatefulWidget {
  final double currentValue;
  final double totalValue;
  final Widget child;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? progressColor;

  const DynamicProgressIndicator({
    super.key,
    required this.currentValue,
    required this.totalValue,
    required this.child,
    this.height,
    this.width,
    this.backgroundColor,
    this.progressColor,
  });

  @override
  State<DynamicProgressIndicator> createState() =>
      _DynamicProgressIndicatorState();
}

class _DynamicProgressIndicatorState extends State<DynamicProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 10,
      width: widget.width ?? 100,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.primaryShades.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: widget.height ?? 10,
                width: constraints.maxWidth *
                    (widget.currentValue / widget.totalValue),
                decoration: BoxDecoration(
                  color: widget.progressColor ?? AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Center(
                child: widget.child,
              ),
            ],
          );
        },
      ),
    );
  }
}
