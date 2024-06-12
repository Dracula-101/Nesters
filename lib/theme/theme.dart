import 'package:flutter/material.dart';
import 'package:nesters/app/routes/app_routes.dart';
part 'color.dart';
part 'styles.dart';

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
  snackBarTheme: _appSnackBarTheme,
  elevatedButtonTheme: _appElevatedButtonTheme,
);

class AppTheme {
  AppTheme._();

  static final BuildContext _context =
      AppRouterService.navigatorKey.currentContext!;
  static ThemeData get lightTheme => _lightThemeData;

  static Color get primary => Theme.of(_context).primaryColor;
  static Color get lightPrimary => AppColor.primaryBlueLight2;
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
  static Color get success => AppColor.successGreen;

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
  static TextStyle get headlineVerySmall =>
      Theme.of(_context).textTheme.headlineSmall!.copyWith(fontSize: 28);

  // Light Variant Fonts
  static final Color _lightVariantColor = AppColor.grey;
  static TextStyle get displayLargeLightVariant =>
      displayLarge.copyWith(color: _lightVariantColor);
  static TextStyle get displayMediumLightVariant =>
      displayMedium.copyWith(color: _lightVariantColor);
  static TextStyle get displaySmallLightVariant =>
      displaySmall.copyWith(color: _lightVariantColor);
  static TextStyle get bodyLargeLightVariant =>
      bodyLarge.copyWith(color: _lightVariantColor);
  static TextStyle get bodyMediumLightVariant =>
      bodyMedium.copyWith(color: _lightVariantColor);
  static TextStyle get bodySmallLightVariant =>
      bodySmall.copyWith(color: _lightVariantColor);
  static TextStyle get labelLargeLightVariant =>
      labelLarge.copyWith(color: _lightVariantColor);
  static TextStyle get labelMediumLightVariant =>
      labelMedium.copyWith(color: _lightVariantColor);
  static TextStyle get labelSmallLightVariant =>
      labelSmall.copyWith(color: _lightVariantColor);
  static TextStyle get titleLargeLightVariant =>
      titleLarge.copyWith(color: _lightVariantColor);
  static TextStyle get titleMediumLightVariant =>
      titleMedium.copyWith(color: _lightVariantColor);
  static TextStyle get titleSmallLightVariant =>
      titleSmall.copyWith(color: _lightVariantColor);
  static TextStyle get headlineLargeLightVariant =>
      headlineLarge.copyWith(color: _lightVariantColor);
  static TextStyle get headlineMediumLightVariant =>
      headlineMedium.copyWith(color: _lightVariantColor);
  static TextStyle get headlineSmallLightVariant =>
      headlineSmall.copyWith(color: _lightVariantColor);
  static TextStyle get headlineVerySmallLightVariant =>
      headlineVerySmall.copyWith(color: _lightVariantColor);

  static ColorShades get primaryShades => PrimaryShades();
  static ColorShades get secondaryShades => SecondaryShades();
  static ColorShades get greyShades => GreyShades();
  static ColorShades get blackShades => BlackShades();

  static LinearGradient get shimmerGradient => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          greyShades.shade100,
          greyShades.shade300,
          greyShades.shade100,
        ],
        stops: const [0.1, 0.5, 0.9],
      );
}
