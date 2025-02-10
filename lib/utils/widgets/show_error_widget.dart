part of 'widgets.dart';

class ShowErrorWidget extends StatelessWidget {
  final String? message;
  final Exception? error;
  final double? height;
  const ShowErrorWidget({
    super.key,
    this.error,
    this.message,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                color: AppTheme.error,
                size: 90,
              ),
              Text(
                message != null
                    ? "Error"
                    : (error is NoNetworkError)
                        ? "Network Issue"
                        : (error is DatabaseError)
                            ? 'Server Error'
                            : (error is SocketException)
                                ? 'Network Issue'
                                : (error is TimeoutException)
                                    ? 'Time Out'
                                    : (error is FormatException)
                                        ? 'Invalid Response'
                                        : (error is HttpException)
                                            ? 'Server Error'
                                            : (error is FileSystemException)
                                                ? 'File system error'
                                                : (error is AppException)
                                                    ? "Error"
                                                    : 'Unknown Error',
                style:
                    AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message != null
                    ? message!
                    : (error is AppException)
                        ? (error as AppException).message
                        : (error is SocketException)
                            ? 'Please check your internet connection and try again'
                            : 'Please try again later',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
