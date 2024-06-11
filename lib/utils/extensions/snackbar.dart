part of 'extensions.dart';

extension CustomSnackBar on BuildContext {
  void showSnackBar(
    String message, {
    Widget? icon,
    Color? color,
  }) {
    DelightToastBar(
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 2),
      builder: (context) {
        return ToastCard(
          title: Text(message, style: AppTheme.bodyMedium),
          leading: icon,
          shadowColor: AppTheme.blackShades.shade100,
        );
      },
    ).show(this);
  }

  void showErrorSnackBar(String message) {
    showSnackBar(message,
        icon: Icon(
          FontAwesomeIcons.triangleExclamation,
          color: AppTheme.error,
        ));
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(message,
        icon: Icon(
          FontAwesomeIcons.circleCheck,
          color: AppTheme.successColor,
        ));
  }
}
