part of 'widgets.dart';

class ShowNoInfoWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  const ShowNoInfoWidget(
      {super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppRasterImages.emptyIcon,
              color: AppTheme.primaryShades.shade300,
              colorBlendMode: BlendMode.srcIn,
              width: 90,
              height: 90,
            ),
            Text(
              title,
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
