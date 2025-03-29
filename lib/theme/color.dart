part of 'theme.dart';

class AppColor {
  static Color appBlue = const Color(0xFF4A55A2);
  static Color primaryBlue = const Color(0xFF35408C);
  static Color primaryBlueVariant = const Color(0xFF404B98);
  static Color primaryBlueLight = const Color(0xFF5A65B3);
  static Color primaryBlueLight2 = const Color(0xFFE6E9FF);
  static Color primaryBlueLightVariant = const Color(0xFFBCC3FF);
  static Color primaryBlueDark = const Color(0xFF1C2874);
  static Color primaryBlueDarkAccent = const Color(0xFF454651);
  static Color primaryBlueDarkVariant = const Color(0xFF454651);
  static Color primaryBlueLightGreyAccent = const Color(0xFFC6C5D3);
  static Color primaryBlueBlackAccent = const Color(0xFF303035);

  static Color secondaryYellow = const Color(0xFFFDDE55);
  static Color secondaryYellowDark = const Color(0xFF6F5D00);
  static Color secondaryYellowLight = const Color(0xFFFFE36D);
  static Color secondaryYellowAccent = const Color(0xFF564800);

  static Color tertiaryPurple = const Color(0xFFFDCEDF);
  static Color tertiaryPurpleDark = const Color(0xFF785462);
  static Color tertiaryPurpleDarkVariant = const Color(0xFF452734);
  static Color tertiaryPurpleDarkAccent = const Color(0xFF563643);
  static Color tertiaryPurpleLight = const Color(0xFFFFD4E3);
  static Color tertiaryPurpleLightVariant = const Color(0xFFF2EFF7);

  static Color tertiaryPurpleAccent = const Color(0xFF4F3A4A);

  static Color errorRed = const Color(0xFFBA1A1A);
  static Color errorRedVariant = const Color(0xFF93000A);
  static Color errorRedWhiteAccent = const Color(0xFFFFDAD6);
  static Color errorRedDark = const Color(0xFF410002);
  static Color errorRedDarkVariant = const Color(0xFF690005);
  static Color errorRedLight = const Color(0xFFFFB4AB);

  //White
  static Color white = const Color(0xFFFFFFFF);
  static Color whiteAccent = const Color(0xFFFFDAD6);
  static Color backgroundWhite = const Color(0xFFFBF8FF);
  static Color backgroundWhiteVariant = const Color(0xFFE4E1E9);
  static Color surfaceWhite = const Color(0xFFFBF8FF);
  static Color surfaceVariantWhite = const Color(0xFFE2E1EF);

  //Black
  static Color black = const Color(0xFF000000);
  static Color surfaceBlack = const Color(0xFF1B1B20);
  static Color backgroundBlack = const Color(0xFF131318);

  //Grey
  static Color grey = const Color(0xFF767682);
  static Color lightGrey = const Color(0xFFF4F2FF);
  static Color greyAccent = AppTheme.greyShades.shade300;
  static Color greyVariant = const Color(0xFF90909C);

  //Green
  static Color successGreen = const Color.fromARGB(255, 54, 212, 62);
}

// ==================== Light Theme ====================
Color primaryLight = AppColor.primaryBlue;
Color onPrimaryLight = AppColor.white;
Color primaryContainerLight = AppColor.primaryBlueLight;
Color onPrimaryContainerLight = AppColor.white;
Color secondaryLight = AppColor.secondaryYellowDark;
Color onSecondaryLight = AppColor.white;
Color secondaryContainerLight = AppColor.secondaryYellowLight;
Color onSecondaryContainerLight = AppColor.secondaryYellowAccent;
Color tertiaryLight = AppColor.tertiaryPurpleDark;
Color onTertiaryLight = AppColor.white;
Color tertiaryContainerLight = AppColor.tertiaryPurpleLight;
Color onTertiaryContainerLight = AppColor.tertiaryPurpleAccent;
Color errorLight = AppColor.errorRed;
Color onErrorLight = AppColor.white;
Color errorContainerLight = AppColor.errorRedWhiteAccent;
Color onErrorContainerLight = AppColor.errorRedDark;
Color backgroundLight = AppColor.backgroundWhite;
Color onBackgroundLight = AppColor.surfaceBlack;
Color surfaceLight = AppColor.surfaceWhite;
Color onSurfaceLight = AppColor.surfaceBlack;
Color surfaceVariantLight = AppColor.surfaceVariantWhite;
Color onSurfaceVariantLight = AppColor.primaryBlueDarkVariant;
Color outlineLight = AppColor.grey;
Color outlineVariantLight = AppColor.primaryBlueLightGreyAccent;
Color scrimLight = AppColor.black;
Color inverseSurfaceLight = AppColor.primaryBlueBlackAccent;
Color inverseOnSurfaceLight = AppColor.tertiaryPurpleLightVariant;
Color inversePrimaryLight = AppColor.primaryBlueLightVariant;

// ==================== Dark Theme ====================
Color primaryDark = AppColor.primaryBlueLightVariant;
Color onPrimaryDark = AppColor.primaryBlueDark;
Color primaryContainerDark = AppColor.primaryBlueVariant;
Color onPrimaryContainerDark = AppColor.lightGrey;
Color secondaryDark = AppColor.white;
Color onSecondaryDark = AppColor.secondaryYellowAccent;
Color secondaryContainerDark = AppColor.secondaryYellowLight;
Color onSecondaryContainerDark = const Color(0xFF4B3F00);
Color tertiaryDark = AppColor.white;
Color onTertiaryDark = AppColor.tertiaryPurpleDarkVariant;
Color tertiaryContainerDark = AppColor.tertiaryPurpleLight;
Color onTertiaryContainerDark = AppColor.tertiaryPurpleDarkAccent;
Color errorDark = AppColor.errorRedLight;
Color onErrorDark = AppColor.errorRedDarkVariant;
Color errorContainerDark = AppColor.errorRedVariant;
Color onErrorContainerDark = AppColor.errorRedWhiteAccent;
Color backgroundDark = AppColor.backgroundBlack;
Color onBackgroundDark = AppColor.backgroundWhiteVariant;
Color surfaceDark = AppColor.backgroundBlack;
Color onSurfaceDark = AppColor.backgroundWhiteVariant;
Color surfaceVariantDark = AppColor.primaryBlueDarkAccent;
Color onSurfaceVariantDark = AppColor.primaryBlueLightGreyAccent;
Color outlineDark = AppColor.greyVariant;
Color outlineVariantDark = AppColor.primaryBlueDarkAccent;
Color scrimDark = AppColor.black;
Color inverseSurfaceDark = AppColor.backgroundWhiteVariant;
Color inverseOnSurfaceDark = AppColor.primaryBlueBlackAccent;
Color inversePrimaryDark = AppColor.primaryBlueLight;
