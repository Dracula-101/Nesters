import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserQuickProfileWidget extends StatelessWidget {
  final UserQuickProfile userQuickProfile;
  final EdgeInsets? contentPadding;
  final EdgeInsets? marginPadding;
  const UserQuickProfileWidget(
      {super.key,
      required this.userQuickProfile,
      this.contentPadding,
      this.marginPadding});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).go(
          '${AppRouterService.homeScreen}/${AppRouterService.userProfile}/${userQuickProfile.id}',
        );
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
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
                      fit: BoxFit.cover,
                      fadeInDuration: 150.ms,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 8,
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
                              const SizedBox(height: 2),
                              Text(
                                userQuickProfile.toUserLocation(),
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
                            GoRouter.of(context).go(
                              '${AppRouterService.homeScreen}/${AppRouterService.userProfile}/${userQuickProfile.id}',
                              extra: true,
                            );
                          },
                          child: Icon(
                            FontAwesomeIcons.telegram,
                            color: AppTheme.primary,
                            size: 30,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
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
                                  userQuickProfile.selectedCourseName ?? '',
                                  style: AppTheme.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userQuickProfile.selectedCollegeName ?? '',
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
}
