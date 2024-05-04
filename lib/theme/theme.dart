import 'package:flutter/material.dart';
import 'package:nesters/app/app.dart';
part 'color.dart';

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
);

String _poppinsFontFamily = 'Poppins';

TextTheme _appTextTheme = TextTheme(
  headlineLarge: TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w900,
    color: onSurfaceLight,
  ),
  headlineMedium: TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w700,
    color: onSurfaceLight,
  ),
  headlineSmall: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: onSurfaceLight,
  ),
  displayLarge: TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.w800,
    color: onSurfaceLight,
  ),
  displayMedium: TextStyle(
    fontSize: 31,
    fontWeight: FontWeight.w700,
    color: onSurfaceLight,
  ),
  displaySmall: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: onSurfaceLight,
  ),
  titleLarge: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: onSurfaceLight,
  ),
  titleMedium: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: onSurfaceLight,
  ),
  titleSmall: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: onSurfaceLight,
  ),
  bodyLarge: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: onSurfaceLight,
  ),
  bodyMedium: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: onSurfaceLight,
  ),
  bodySmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: onSurfaceLight,
  ),
  labelLarge: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: onSurfaceLight,
  ),
  labelMedium: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: onSurfaceLight,
  ),
  labelSmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: onSurfaceLight,
  ),
);

ThemeData _lightThemeData = ThemeData(
  primaryColor: primaryLight,
  primaryColorLight: primaryLight,
  primaryColorDark: primaryLight,
  scaffoldBackgroundColor: backgroundLight,
  dialogBackgroundColor: surfaceLight,
  brightness: Brightness.light,
  disabledColor: onSurfaceVariantLight,
  textTheme: _appTextTheme,
  colorScheme: _lightColorScheme,
  fontFamily: _poppinsFontFamily,
);

class AppTheme {
  AppTheme._();

  static final BuildContext _context = RootApp.navigatorKey.currentContext!;
  static ThemeData get lightTheme => _lightThemeData;

  static Color get primary => Theme.of(_context).primaryColor;
  static Color get secondary => Theme.of(_context).colorScheme.secondary;
  static Color get error => Theme.of(_context).colorScheme.error;
  static Color get background => Theme.of(_context).colorScheme.background;
  static Color get surface => Theme.of(_context).colorScheme.surface;
  static Color get onPrimary => Theme.of(_context).colorScheme.onPrimary;
  static Color get onSecondary => Theme.of(_context).colorScheme.onSecondary;
  static Color get onBackground => Theme.of(_context).colorScheme.onBackground;
  static Color get onSurface => Theme.of(_context).colorScheme.onSurface;
  static Color get shadowColor => Theme.of(_context).shadowColor;
  static Color get errorColor => Theme.of(_context).colorScheme.error;

  // font
  static TextStyle get displayLarge =>
      Theme.of(_context).textTheme.displayLarge!;
  static TextStyle get displayMedium =>
      Theme.of(_context).textTheme.displayMedium!;
  static TextStyle get displaySmall =>
      Theme.of(_context).textTheme.displaySmall!;
  static TextStyle get bodyLarge => Theme.of(_context).textTheme.bodyLarge!;
  static TextStyle get bodyMedium => Theme.of(_context).textTheme.bodyMedium!;
  static TextStyle get bodySmall => Theme.of(_context).textTheme.bodySmall!;
  static TextStyle get labelLarge => Theme.of(_context).textTheme.labelLarge!;
  static TextStyle get labelMedium => Theme.of(_context).textTheme.labelMedium!;
  static TextStyle get labelSmall => Theme.of(_context).textTheme.labelSmall!;
  static TextStyle get titleLarge => Theme.of(_context).textTheme.titleLarge!;
  static TextStyle get titleMedium => Theme.of(_context).textTheme.titleMedium!;
  static TextStyle get titleSmall => Theme.of(_context).textTheme.titleSmall!;
  static TextStyle get headlineLarge =>
      Theme.of(_context).textTheme.headlineLarge!;
  static TextStyle get headlineMedium =>
      Theme.of(_context).textTheme.headlineMedium!;
  static TextStyle get headlineSmall =>
      Theme.of(_context).textTheme.headlineSmall!;
}
