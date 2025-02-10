part of 'widgets.dart';

class HeartIcon extends StatefulWidget {
  final Future<void> Function(bool favouriteState)? onPressed;
  final bool isFavourite;
  const HeartIcon({super.key, this.onPressed, required this.isFavourite});

  @override
  State<HeartIcon> createState() => _HeartIconState();
}

class _HeartIconState extends State<HeartIcon>
    with SingleTickerProviderStateMixin {
  late bool isFavourite = widget.isFavourite;
  final debouncer = Debouncer(milliseconds: 500);
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      reverseDuration: const Duration(milliseconds: 500),
      lowerBound: 0,
      upperBound: 0.5,
    );
    if (isFavourite) {
      _controller?.value = 0.5;
    } else {
      _controller?.value = 0;
    }
    _controller?.stop();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -15,
      right: -15,
      child: GestureDetector(
        child: Lottie.asset(
          'assets/lottie/like_lottie.json',
          width: 90,
          height: 90,
          controller: _controller,
          fit: BoxFit.cover,
        ),
        onTap: () {
          debouncer.run(() {
            try {
              widget.onPressed?.call(isFavourite);
              _controller?.reset();
              if (!isFavourite) {
                _controller?.forward();
              } else {
                _controller?.reverse();
              }
              setState(() {
                isFavourite = !isFavourite;
              });
            } on AppException catch (e) {
              // ignore: use_build_context_synchronously
              context.showErrorSnackBar(e.message);
            }
          });
        },
      ),
    );
  }
}
