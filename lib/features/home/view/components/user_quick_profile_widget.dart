import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/domain/models/user_quick_profile.dart';
import 'package:nesters/theme/theme.dart';

class UserQuickProfileWidget extends StatelessWidget {
  final UserQuickProfile userQuickProfile;
  final EdgeInsets? contentPadding;

  const UserQuickProfileWidget(
      {super.key, required this.userQuickProfile, this.contentPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: contentPadding ??
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SizedBox(),
    );
  }
}
