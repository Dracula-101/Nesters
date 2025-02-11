part of 'widgets.dart';

class ShowWarningWidget extends StatelessWidget {
  final String message;
  final String subtitle;
  const ShowWarningWidget(
      {super.key, required this.message, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.primaryShades.shade300,
              size: 90,
            ),
            Text(
              message,
              style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
