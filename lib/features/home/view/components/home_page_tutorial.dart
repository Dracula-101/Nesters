import 'package:flutter/material.dart';
import 'package:nesters/theme/theme.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> addTargetHomePage({
  required GlobalKey firstIconKey,
  required GlobalKey secondIconKey,
  required GlobalKey thirdIconKey,
  required GlobalKey fourthIconKey,
  required GlobalKey chatIconKey,
  required GlobalKey requestIconKey,
  required GlobalKey settingsIconKey,
}) {
  List<TargetFocus> targets = [];

  targets.add(
    TargetFocus(
      keyTarget: firstIconKey,
      radius: 10,
      shape: ShapeLightFocus.Circle,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find your perfect roommate or just vibe with peers & seniors—your way! 🎯',
                  style: AppTheme.headlineVerySmall.copyWith(
                      color: AppTheme.surface, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  targets.add(
    TargetFocus(
      keyTarget: secondIconKey,
      shape: ShapeLightFocus.Circle,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moving out for a few months? 💸 Sublet your place & make some extra cash!',
                  style: AppTheme.headlineVerySmall.copyWith(
                      color: AppTheme.surface, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  targets.add(
    TargetFocus(
      keyTarget: thirdIconKey,
      radius: 10,
      shape: ShapeLightFocus.Circle,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get broker-free apartments by connecting with students who are moving out 🚀🏡',
                  style: AppTheme.headlineVerySmall.copyWith(
                      color: AppTheme.surface, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  targets.add(
    TargetFocus(
      keyTarget: fourthIconKey,
      radius: 10,
      shape: ShapeLightFocus.Circle,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shop smart, sell easy! 💸 Buy & sell second-hand student essentials hassle-free.',
                  style: AppTheme.headlineVerySmall.copyWith(
                      color: AppTheme.surface, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  targets.add(
    TargetFocus(
      keyTarget: chatIconKey,
      radius: 10,
      shape: ShapeLightFocus.Circle,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Share with ease! 📩 Send messages and photos to your connections in a snap.",
                  style: AppTheme.headlineVerySmall.copyWith(
                      color: AppTheme.surface, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  targets.add(
    TargetFocus(
      keyTarget: requestIconKey,
      radius: 10,
      shape: ShapeLightFocus.Circle,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check out who\'s eager to connect with you! 🤝',
                  style: AppTheme.headlineVerySmall.copyWith(
                      color: AppTheme.surface, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  targets.add(
    TargetFocus(
      keyTarget: settingsIconKey,
      radius: 10,
      shape: ShapeLightFocus.Circle,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚀 Manage your profile & keep your info up to date.',
                  style: AppTheme.headlineVerySmall.copyWith(
                      color: AppTheme.surface, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  return targets;
}
