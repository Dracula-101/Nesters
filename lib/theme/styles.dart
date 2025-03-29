part of 'theme.dart';

// Light Theme Color Scheme
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

  // Tertiary color Scheme
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
  onInverseSurface: inverseOnSurfaceLight,
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

// Dark Theme Color Scheme
ColorScheme _darkColorScheme = ColorScheme.dark(
  // Primary color Scheme
  primary: primaryDark,
  onPrimary: onPrimaryDark,
  // Primary Container color Scheme
  primaryContainer: primaryContainerDark,
  onPrimaryContainer: onPrimaryContainerDark,
  inversePrimary: inversePrimaryDark,

  // Secondary color Scheme
  secondary: secondaryDark,
  onSecondary: onSecondaryDark,
  // Secondary Container color Scheme
  secondaryContainer: secondaryContainerDark,
  onSecondaryContainer: onSecondaryContainerDark,

  // Tertiary color Scheme
  tertiary: tertiaryDark,
  onTertiary: onTertiaryDark,
  tertiaryContainer: tertiaryContainerDark,
  onTertiaryContainer: onTertiaryContainerDark,

  // Background color Scheme
  surface: surfaceDark,
  onSurface: onSurfaceDark,
  surfaceTint: surfaceDark,
  surfaceVariant: surfaceVariantDark,
  onSurfaceVariant: onSurfaceVariantDark,
  inverseSurface: inverseSurfaceDark,
  onInverseSurface: inverseOnSurfaceDark,
  background: backgroundDark,
  onBackground: onBackgroundDark,

  // Error color Scheme
  error: errorDark,
  onError: onErrorDark,
  errorContainer: errorContainerDark,
  onErrorContainer: onErrorContainerDark,
  brightness: Brightness.dark,

  // Outline color Scheme
  outline: outlineDark,
  outlineVariant: outlineVariantDark,
  scrim: scrimDark,

  shadow: outlineDark,
);

String _poppinsFontFamily = 'Poppins';

// Light Theme TextTheme
TextTheme _lightTextTheme = TextTheme(
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

// Dark Theme TextTheme
TextTheme _darkTextTheme = TextTheme(
  headlineLarge: TextStyle(
    color: onSurfaceDark,
    fontSize: 45,
  ),
  headlineMedium: TextStyle(
    color: onSurfaceDark,
    fontSize: 38,
  ),
  headlineSmall: TextStyle(
    color: onSurfaceDark,
    fontSize: 32,
  ),
  displayLarge: TextStyle(
    color: onSurfaceDark,
  ),
  displayMedium: TextStyle(
    color: onSurfaceDark,
  ),
  displaySmall: TextStyle(
    color: onSurfaceDark,
  ),
  titleLarge: TextStyle(
    color: onSurfaceDark,
  ),
  titleMedium: TextStyle(
    color: onSurfaceDark,
  ),
  titleSmall: TextStyle(
    color: onSurfaceDark,
  ),
  bodyLarge: TextStyle(
    color: onSurfaceDark,
  ),
  bodyMedium: TextStyle(
    color: onSurfaceDark,
  ),
  bodySmall: TextStyle(
    color: onSurfaceDark,
  ),
  labelLarge: TextStyle(
    color: onSurfaceDark,
  ),
  labelMedium: TextStyle(
    color: onSurfaceDark,
  ),
  labelSmall: TextStyle(
    color: onSurfaceDark,
  ),
);

// Light SnackBar Theme
SnackBarThemeData _lightSnackBarTheme = SnackBarThemeData(
  backgroundColor: surfaceVariantLight,
  contentTextStyle: _lightTextTheme.bodyMedium,
  actionTextColor: onSurfaceVariantLight,
);

// Dark SnackBar Theme
SnackBarThemeData _darkSnackBarTheme = SnackBarThemeData(
  backgroundColor: surfaceVariantDark,
  contentTextStyle: _darkTextTheme.bodyMedium,
  actionTextColor: onSurfaceVariantDark,
);

// Light Elevated Button Theme
ElevatedButtonThemeData _lightElevatedButtonTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all(primaryLight),
    foregroundColor: MaterialStateProperty.all(onPrimaryLight),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 24,
      ),
    ),
    enableFeedback: true,
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.standard,
  ),
);

// Dark Elevated Button Theme
ElevatedButtonThemeData _darkElevatedButtonTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all(primaryDark),
    foregroundColor: MaterialStateProperty.all(onPrimaryDark),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 24,
      ),
    ),
    enableFeedback: true,
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.standard,
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

  // These shades will be used for light theme
  Color get _lightShade100 => const Color(0xFFf5f5f5);
  Color get _lightShade200 => const Color(0xFFeeeeee);
  Color get _lightShade300 => const Color(0xFFe0e0e0);
  Color get _lightShade400 => const Color(0xFFbdbdbd);
  Color get _lightShade500 => const Color(0xFF9e9e9e);
  Color get _lightShade600 => const Color(0xFF757575);
  Color get _lightShade700 => const Color(0xFF616161);
  Color get _lightShade800 => const Color(0xFF424242);
  Color get _lightShade900 => const Color(0xFF212121);

  // These shades will be used for dark theme - better suited for dark mode
  Color get _darkShade100 => const Color(0xFF1A1A1A);
  Color get _darkShade200 => const Color(0xFF212121);
  Color get _darkShade300 => const Color(0xFF282828);
  Color get _darkShade400 => const Color(0xFF303030);
  Color get _darkShade500 => const Color(0xFF505050);
  Color get _darkShade600 => const Color(0xFF707070);
  Color get _darkShade700 => const Color(0xFF909090);
  Color get _darkShade800 => const Color(0xFFB5B5B5);
  Color get _darkShade900 => const Color(0xFFDDDDDD);

  // Check for the current theme and return the appropriate shade
  static bool get _isDarkMode => 
      AppRouterService.navigatorKey.currentContext != null 
      ? Theme.of(AppRouterService.navigatorKey.currentContext!).brightness == Brightness.dark
      : false;

  @override
  Color get shade100 => _isDarkMode ? _darkShade100 : _lightShade100;

  @override
  Color get shade200 => _isDarkMode ? _darkShade200 : _lightShade200;

  @override
  Color get shade300 => _isDarkMode ? _darkShade300 : _lightShade300;

  @override
  Color get shade400 => _isDarkMode ? _darkShade400 : _lightShade400;

  @override
  Color get shade500 => _isDarkMode ? _darkShade500 : _lightShade500;

  @override
  Color get shade600 => _isDarkMode ? _darkShade600 : _lightShade600;

  @override
  Color get shade700 => _isDarkMode ? _darkShade700 : _lightShade700;

  @override
  Color get shade800 => _isDarkMode ? _darkShade800 : _lightShade800;

  @override
  Color get shade900 => _isDarkMode ? _darkShade900 : _lightShade900;
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