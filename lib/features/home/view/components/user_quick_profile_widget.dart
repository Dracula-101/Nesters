import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/domain/models/user/pref/user_intake.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserQuickProfileWidget extends StatelessWidget {
  final UserQuickProfile userQuickProfile;
  final EdgeInsets? contentPadding;
  final EdgeInsets? marginPadding;
  final bool canNavigate;
  const UserQuickProfileWidget({
    super.key,
    required this.userQuickProfile,
    required this.canNavigate,
    this.contentPadding,
    this.marginPadding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (canNavigate) {
          GoRouter.of(context).go(
            '${AppRouterService.homeScreen}/${AppRouterService.userProfile}/${userQuickProfile.id}',
          );
        } else {
          showProfileIncompleteDialog(
            context,
            onNavigate: () {
              GoRouter.of(context).go(
                '${AppRouterService.homeScreen}/${AppRouterService.userProfileAdvanceFormScreen}',
              );
            },
          );
        }
      },
      child: Container(
        padding: contentPadding ?? const EdgeInsets.all(12),
        margin: marginPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppTheme.greyShades.shade300,
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(
                0,
                2,
              ),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: CachedNetworkImage(
                          imageUrl: userQuickProfile.profileImage ?? '',
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.person,
                              color: AppTheme.greyShades.shade300,
                              size: 60,
                            ),
                          ),
                          placeholder: (context, url) => Container(
                            color: AppTheme.greyShades.shade300,
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Center(
                              child: Icon(
                                Icons.person,
                                color: AppTheme.greyShades.shade100,
                                size: 45,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          cacheKey: userQuickProfile.id,
                          height: 60,
                          width: 60,
                          filterQuality: FilterQuality.high,
                          memCacheHeight: 500,
                          fit: BoxFit.cover,
                          fadeInDuration: 150.ms,
                        ),
                      ),
                      // if (userQuickProfile.intakePeriod != null &&
                      //     userQuickProfile.intakeYear != null)
                      //   Container(
                      //     width: double.infinity,
                      //     height: 20,
                      //     decoration: BoxDecoration(
                      //       color: AppTheme.surface,
                      //     ),
                      //     child: Text(
                      //       _buildIntakeString(
                      //         userQuickProfile.intakePeriod,
                      //         userQuickProfile.intakeYear,
                      //       ),
                      //       style: AppTheme.labelMedium
                      //           .copyWith(fontWeight: FontWeight.w600),
                      //       maxLines: 1,
                      //       overflow: TextOverflow.ellipsis,
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                userQuickProfile.fullName?.capitalize ?? "",
                                maxLines: 1,
                                style: AppTheme.bodyLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                userQuickProfile.selectedCourseName ?? '',
                                style: AppTheme.labelMedium.copyWith(
                                    color: AppTheme.greyShades.shade700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (canNavigate) {
                              GoRouter.of(context).go(
                                '${AppRouterService.homeScreen}/${AppRouterService.userProfile}/${userQuickProfile.id}',
                                extra: true,
                              );
                            } else {
                              showProfileIncompleteDialog(
                                context,
                                onNavigate: () {
                                  GoRouter.of(context).go(
                                    '${AppRouterService.homeScreen}/${AppRouterService.userProfileAdvanceFormScreen}',
                                  );
                                },
                              );
                            }
                          },
                          child: Icon(
                            FontAwesomeIcons.telegram,
                            color: AppTheme.primary,
                            size: 30,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userQuickProfile.userCollege ?? '',
                                  style: AppTheme.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${userQuickProfile.intakePeriod ?? ''} - ${userQuickProfile.intakeYear ?? ''}',
                                  style: AppTheme.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildIntakeString(UserIntake? intakePeriod, int? intakeYear) {
    String intakeText = "";
    if (intakePeriod != null && intakeYear != null) {
      intakeText = '$intakePeriod \'${intakeYear.toString().substring(2)}';
    }
    return intakeText;
  }

  void showProfileIncompleteDialog(BuildContext context,
      {required Function onNavigate}) {
    showGeneralDialog(
      context: GoRouter.of(context).routerDelegate.navigatorKey.currentContext!,
      barrierDismissible: true,
      useRootNavigator: false,
      routeSettings: const RouteSettings(name: 'incomplete_profile'),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        double iconSize = 100;
        return Material(
          color: Colors.transparent,
          child: Center(
            child: SizedBox(
              width: (MediaQuery.of(context).size.width * 0.75).clamp(250, 290),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: 250 - iconSize / 2,
                    padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: iconSize / 2 + 10,
                        bottom: 10),
                    margin: EdgeInsets.only(top: iconSize / 2),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Profile Incomplete",
                          style: AppTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Please complete your profile to view this user\'s profile.',
                          style: AppTheme.bodyMediumLightVariant,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(buildContext).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(buildContext).pop();
                                onNavigate();
                              },
                              child: const Text('Proceed'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: iconSize,
                    width: iconSize,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.greyShades.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person_pin,
                      size: 60,
                      color: AppTheme.greyShades.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }
}
