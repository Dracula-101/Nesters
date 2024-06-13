part of 'widgets.dart';

class DottedLine extends StatelessWidget {
  final double height;
  final double width;
  final Color color;
  final double dashWidth;
  final double spaceWidth;

  const DottedLine({
    super.key,
    this.height = 3,
    this.color = Colors.black,
    required this.width,
    this.dashWidth = 15,
    this.spaceWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final boxWidth = constraints.constrainWidth();
          // const dashWidth = 15.0;
          final dashHeight = height;
          final dashCount = (boxWidth / (dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return Container(
                padding: EdgeInsets.only(right: spaceWidth),
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
