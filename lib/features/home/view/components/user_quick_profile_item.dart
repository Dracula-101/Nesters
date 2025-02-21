import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/theme/theme.dart';

class UserQuickProfileItem extends StatelessWidget {
  final UserQuickProfile userQuickProfile;
  final EdgeInsets? contentPadding;

  const UserQuickProfileItem(
      {super.key, required this.userQuickProfile, this.contentPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: contentPadding ??
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(
                userQuickProfile.profileImage!,
              ),
              radius: 40,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userQuickProfile.fullName ?? '',
                  style: AppTheme.titleLarge.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                // Text(userQuickProfile.workExperience == 0
                //     ? 'Fresher'
                //     : '${userQuickProfile.workExperience} Years Work Experience'),
                Text(
                  userQuickProfile.selectedCourseName ?? '',

                  maxLines: 2, // Set maximum lines as per your requirement
                ),
                Text('@ ${userQuickProfile.userCollege}'),
                Text(
                  '${userQuickProfile.city}, ${userQuickProfile.state}',
                  style: AppTheme.bodySmallLightVariant,
                ),
                Divider(
                  thickness: 1,
                  color: AppColor.greyAccent,
                )
              ],
            ),
          ),
          //icon for connect
          IconButton(
            onPressed: () {},
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // border: Border.all(
                //   color: AppTheme.greyShades.shade600,
                //   width: 1,
                // ),
              ),
              // padding: const EdgeInsets.all(3),
              child: Icon(
                FontAwesomeIcons.locationArrow,
                color: AppTheme.greyShades.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
