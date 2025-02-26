part of 'widgets.dart';

class LoadingWidget extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback onTap;
  const LoadingWidget(
      {super.key,
      required this.isLoading,
      required this.text,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLoading ? AppTheme.primaryShades.shade400 : AppTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryShades.shade500,
                  strokeWidth: 1.5,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Text(
              text,
              style: AppTheme.titleLarge.copyWith(
                color: isLoading
                    ? AppTheme.primaryShades.shade300
                    : AppTheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
