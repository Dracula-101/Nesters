part of 'extensions.dart';

extension CustomSnackBar on BuildContext {
  void showSnackBar(
    String message, {
    String? subtitle,
    Widget? icon,
    Color? color,
  }) {
    DelightToastBar(
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 2),
      builder: (context) {
        return ToastCard(
          title: Text(message, style: AppTheme.bodySmall),
          subtitle: subtitle != null
              ? Text(subtitle, style: AppTheme.labelMedium)
              : null,
          leading: icon,
          shadowColor: AppTheme.blackShades.shade100,
        );
      },
    ).show(this);
  }

  void showErrorSnackBar(String message, {String? subtitle}) {
    showSnackBar(
      message,
      subtitle: subtitle,
      icon: Icon(
        FontAwesomeIcons.triangleExclamation,
        color: AppTheme.error,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(message,
        icon: Icon(
          FontAwesomeIcons.circleCheck,
          color: AppTheme.success,
        ));
  }
}
