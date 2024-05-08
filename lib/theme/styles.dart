part of 'theme.dart';

ColorScheme _lightColorScheme = ColorScheme.light(
  // Primary color Scheme
  primary: primaryLight,
  onPrimary: onPrimaryLight,
  // Primary Container color Scheme
  primaryContainer: primaryContainerLight,
  onPrimaryContainer: onPrimaryContainerLight,
  inversePrimary: inversePrimaryLight,

  // Secondary color Scheme
  secondary: secondaryLight,
  onSecondary: onSecondaryLight,
  // Secondary Container color Scheme
  secondaryContainer: secondaryContainerLight,
  onSecondaryContainer: onSecondaryContainerLight,

  // Teritary color Scheme
  tertiary: tertiaryLight,
  onTertiary: onTertiaryLight,
  tertiaryContainer: tertiaryContainerLight,
  onTertiaryContainer: onTertiaryContainerLight,

  // Background color Scheme
  surface: surfaceLight,
  onSurface: onSurfaceLight,
  surfaceTint: surfaceLight,
  surfaceVariant: surfaceVariantLight,
  onSurfaceVariant: onSurfaceVariantLight,
  inverseSurface: inverseSurfaceLight,
  onInverseSurface: inverseSurfaceLight,
  background: backgroundLight,
  onBackground: onBackgroundLight,

  // Error color Scheme
  error: errorLight,
  onError: onErrorLight,
  errorContainer: errorContainerLight,
  onErrorContainer: onErrorContainerLight,
  brightness: Brightness.light,

  // Outline color Scheme
  outline: outlineLight,
  outlineVariant: outlineVariantLight,
  scrim: scrimLight,

  shadow: outlineLight,
);

String _poppinsFontFamily = 'Poppins';

TextTheme _appTextTheme = TextTheme(
  headlineLarge: TextStyle(
    color: onSurfaceLight,
    fontSize: 45,
  ),
  headlineMedium: TextStyle(
    color: onSurfaceLight,
    fontSize: 38,
  ),
  headlineSmall: TextStyle(
    color: onSurfaceLight,
    fontSize: 32,
  ),
  displayLarge: TextStyle(
    color: onSurfaceLight,
  ),
  displayMedium: TextStyle(
    color: onSurfaceLight,
  ),
  displaySmall: TextStyle(
    color: onSurfaceLight,
  ),
  titleLarge: TextStyle(
    color: onSurfaceLight,
  ),
  titleMedium: TextStyle(
    color: onSurfaceLight,
  ),
  titleSmall: TextStyle(
    color: onSurfaceLight,
  ),
  bodyLarge: TextStyle(
    color: onSurfaceLight,
  ),
  bodyMedium: TextStyle(
    color: onSurfaceLight,
  ),
  bodySmall: TextStyle(
    color: onSurfaceLight,
  ),
  labelLarge: TextStyle(
    color: onSurfaceLight,
  ),
  labelMedium: TextStyle(
    color: onSurfaceLight,
  ),
  labelSmall: TextStyle(
    color: onSurfaceLight,
  ),
);

class PrimaryShades extends ColorShades {
  PrimaryShades() : super(AppColor.appBlue.value);

  @override
  Color get shade100 => const Color(0xFFecedf6);

  @override
  Color get shade200 => const Color(0xFFc5c9e4);

  @override
  Color get shade300 => const Color(0xFF9ea4d3);

  @override
  Color get shade400 => const Color(0xFF7780c1);

  @override
  Color get shade500 => const Color(0xFF505caf);

  @override
  Color get shade600 => const Color(0xFF3e4788);

  @override
  Color get shade700 => const Color(0xFF2c3361);

  @override
  Color get shade800 => const Color(0xFF1b1f3a);

  @override
  Color get shade900 => const Color(0xFF090a13);
}

class SecondaryShades extends ColorShades {
  SecondaryShades() : super(AppColor.secondaryYellow.value);

  @override
  Color get shade100 => const Color(0xFFfffae3);

  @override
  Color get shade200 => const Color(0xFFfeefab);

  @override
  Color get shade300 => const Color(0xFFfde473);

  @override
  Color get shade400 => const Color(0xFFfdd93b);

  @override
  Color get shade500 => const Color(0xFFfcce03);

  @override
  Color get shade600 => const Color(0xFFc4a002);

  @override
  Color get shade700 => const Color(0xFFc4a002);

  @override
  Color get shade800 => const Color(0xFFc4a002);

  @override
  Color get shade900 => const Color(0xFFc4a002);
}

class GreyShades extends ColorShades {
  GreyShades() : super(AppColor.lightGrey.value);

  @override
  Color get shade100 => const Color(0xFFf5f5f5);

  @override
  Color get shade200 => const Color(0xFFeeeeee);

  @override
  Color get shade300 => const Color(0xFFe0e0e0);

  @override
  Color get shade400 => const Color(0xFFbdbdbd);

  @override
  Color get shade500 => const Color(0xFF9e9e9e);

  @override
  Color get shade600 => const Color(0xFF757575);

  @override
  Color get shade700 => const Color(0xFF616161);

  @override
  Color get shade800 => const Color(0xFF424242);

  @override
  Color get shade900 => const Color(0xFF212121);
}

abstract class ColorShades extends Color {
  ColorShades(int value) : super(value);

  Color get shade100;
  Color get shade200;
  Color get shade300;
  Color get shade400;
  Color get shade500;
  Color get shade600;
  Color get shade700;
  Color get shade800;
  Color get shade900;
}
