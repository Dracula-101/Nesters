import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/constants/app_assets.dart';
import 'package:nesters/data/repository/user/chat/remote_chat_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/features/user/detail/bloc/profile_bloc.dart';
import 'package:nesters/features/user/detail/view/shimmer_profile.dart';
import 'package:nesters/features/user/request/bloc/request_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';

class UserProfilePage extends StatefulWidget {
  final String id;
  final bool showRequestDialog;
  const UserProfilePage(
      {super.key, required this.id, required this.showRequestDialog});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isDialogShown = false;

  void _handleOuterRequest(String userId, UserProfile otherUserProfile) {
    final User currentUser = context.read<AuthBloc>().state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => throw Exception('User not authenticated'),
        );
    String currentUserId = currentUser.id;
    String chatId = GetIt.I<RemoteChatRepository>().generateChatId(
      currentUserId,
      otherUserProfile.id ?? '',
    );
    bool doesChatExists =
        context.read<CentralChatBloc>().doesChatExists(chatId);
    if (doesChatExists && widget.showRequestDialog) {
      GoRouter.of(context).go(
        '${AppRouterService.homeScreen}/${AppRouterService.userChatHome}/${AppRouterService.userChatPage}/$chatId',
        extra: otherUserProfile.toUser(),
      );
    } else {
      showRequestDialog(
        context,
        otherUserProfile.id ?? '',
        otherUserProfile.fullName ?? '',
        otherUserProfile.profileImage ?? '',
        () {
          context.read<RequestBloc>().add(
                RequestEvent.sendRequest(
                  otherUserProfile.id ?? '',
                ),
              );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: Scaffold(
        floatingActionButton: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return FloatingActionButton(
              child: const Icon(
                FontAwesomeIcons.telegram,
              ),
              onPressed: () {
                if (state.isLoading) return;
                _handleOuterRequest(widget.id, state.userProfile!);
              },
            );
          },
        ),
        resizeToAvoidBottomInset: true,
        body: BlocListener<RequestBloc, RequestState>(
          listener: (context, state) {
            if (state.requestSendState.exception != null) {
              context.showErrorSnackBar(
                state.requestSendState.exception!.message,
                subtitle: "REQ_SEND_FAIL_ERROR",
              );
            } else if (state.requestSendState.isSuccess) {
              context.showSuccessSnackBar(
                'Request Sent Successfully',
              );
            }
          },
          child: ProfileView(
            userId: widget.id,
            onShowRequestDialog: (userId, otherUserProfile) {
              if (widget.showRequestDialog) {
                _handleOuterRequest(userId, otherUserProfile);
              }
            },
          ),
        ),
      ),
    );
  }

  void showRequestDialog(
    BuildContext context,
    String userId,
    String name,
    String photoUrl,
    VoidCallback onSendRequest,
  ) {
    if (isDialogShown) return;
    setState(() {
      isDialogShown = true;
    });
    showGeneralDialog(
      context: GoRouter.of(context).routerDelegate.navigatorKey.currentContext!,
      barrierDismissible: true,
      useRootNavigator: false,
      routeSettings: const RouteSettings(name: 'accept_request'),
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
                    width: double.maxFinite,
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: iconSize / 2 + 5),
                    margin: EdgeInsets.only(top: iconSize / 2),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: AppTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'is not in your chat list',
                          style: AppTheme.bodySmallLightVariant,
                          textAlign: TextAlign.center,
                        ),
                        const Divider(),
                        Text(
                          'Do you want to send a request?',
                          style: AppTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                onSendRequest();
                                Navigator.of(buildContext).pop();
                              },
                              child: const Text('Send'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(buildContext).pop();
                              },
                              child: const Text('Cancel'),
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
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          photoUrl,
                        ),
                      ),
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
    ).then((value) => setState(() => isDialogShown = false));
  }
}

class ProfileView extends StatefulWidget {
  final String userId;
  final Function(String, UserProfile) onShowRequestDialog;
  const ProfileView(
      {super.key, required this.userId, required this.onShowRequestDialog});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final UserRepository userRepository = GetIt.I<UserRepository>();

  @override
  void initState() {
    context.read<ProfileBloc>().add(ProfileEvent.load(widget.userId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.userProfile != null) {
          widget.onShowRequestDialog(
            state.userProfile!.id!,
            state.userProfile!,
          );
        }
      },
      builder: (context, state) {
        return state.isLoading
            ? const ShimmerProfile()
            : state.userProfile != null
                ? _buildProfile(state.userProfile!)
                : const Center(
                    child: Text('No user profile found!'),
                  );
      },
    );
  }

  CustomScrollView _buildProfile(UserProfile profile) {
    return CustomScrollView(
      slivers: <Widget>[
        _buildSliverAppBar(profile.profileImage ?? ''),
        _buildSliverList(profile),
      ],
    );
  }

  String _buildUserLanguage(Language? primaryLang, Language? otherLang) {
    String language = "";
    if (primaryLang != null && otherLang != null) {
      language =
          '${primaryLang.toString()} But I Also Speak ${otherLang.toString()}';
    } else if (primaryLang != null) {
      language = 'I Can Speak ${primaryLang.toString()}';
    } else if (otherLang != null) {
      language = 'I Can Speak ${otherLang.toString()}';
    }
    return language;
  }

  SliverList _buildSliverList(UserProfile userProfile) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          _buildSizedBox(91),
          Center(
            child: Text(
              userProfile.fullName.capitalizeEachWord,
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Text(
              userProfile.toUserLocation(),
              style: AppTheme.bodyLargeLightVariant.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Divider(
              thickness: 2,
              color: AppColor.primaryBlueLightVariant,
            ),
          ),
          _buildCard(
            userProfile.selectedCourseName ?? '',
            '@${userProfile.selectedCollegeName}',
            Icons.school,
          ),
          userProfile.bio != ""
              ? _buildCard(
                  'About Me',
                  userProfile.bio,
                  FontAwesomeIcons.solidUser,
                )
              : const SizedBox(),
          userProfile.primaryLang != null || userProfile.otherLang != null
              ? _buildCard(
                  'Mother Tongue',
                  _buildUserLanguage(
                    userProfile.primaryLang,
                    userProfile.otherLang,
                  ),
                  FontAwesomeIcons.language,
                )
              : const SizedBox(),
          (userProfile.foodHabit != UserFoodHabit.UNKNOWN ||
                  userProfile.cookingSkill != UserCookingSkill.UNKNOWN)
              ? _buildCard(
                  'I Am',
                  _getSubtitleTextFoodAndCooking(
                    userProfile.foodHabit,
                    userProfile.cookingSkill,
                  ),
                  FontAwesomeIcons.bowlFood,
                )
              : const SizedBox(),
          _buildCard(
            'Smoke & Sip',
            _getSmokingDrinkingSubtitle(
              userProfile.drinkingHabit,
              userProfile.smokingHabit,
            ),
            FontAwesomeIcons.wineGlass,
          ),
          userProfile.personType != null &&
                  userProfile.personType != PersonType.UNKNOWN
              ? _buildCard(
                  'In Terms of Personality',
                  _getSubtitleTextPersonTypeAndCleanlinessHabit(
                    userProfile.personType,
                  ),
                  FontAwesomeIcons.cloudBolt,
                )
              : const SizedBox(),
          userProfile.cleanlinessHabit != UserCleanlinessHabit.UNKNOWN
              ? _buildCard(
                  'When It Comes To Cleanliness',
                  _getSubtitleTextCleanlinessHabit(
                    userProfile.cleanlinessHabit,
                  ),
                  FontAwesomeIcons.broom,
                )
              : const SizedBox(),
          userProfile.workExperience != 0 ||
                  (userProfile.undergradCollegeName != null &&
                      userProfile.undergradCollegeName != "")
              ? _buildCard(
                  'College & Career Snapshot',
                  _getSubtitleTextCollegeAndWorkExp(
                    userProfile.undergradCollegeName,
                    userProfile.workExperience,
                  ),
                  FontAwesomeIcons.graduationCap,
                )
              : const SizedBox(),
          _buildCard(
            'Living Arrangements',
            _getRoomSubtitle(
              userProfile.flatmatesGenderPrefs,
              userProfile.roomType.toString(),
            ),
            FontAwesomeIcons.house,
          ),
          userProfile.hobbies != ""
              ? _buildCard(
                  'Hobbies',
                  userProfile.hobbies,
                  FontAwesomeIcons.heartPulse,
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(String profileUrl) {
    return SliverAppBar(
      expandedHeight: 175,
      flexibleSpace: _buildProfileBanner(profileUrl),
    );
  }

  SizedBox _buildSizedBox(double height) {
    return SizedBox(
      height: height,
    );
  }

  Card _buildCard(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      elevation: 2, // Add some elevation for the shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            8), // Add some border radius for rounded corners
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColor.appBlue,
        ),
        title: Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodyMediumLightVariant,
        ),
      ),
    );
  }

  String _getSubtitleTextFoodAndCooking(
      UserFoodHabit? foodHabit, UserCookingSkill? cookingSkill) {
    if (foodHabit != UserFoodHabit.UNKNOWN &&
        cookingSkill != UserCookingSkill.UNKNOWN) {
      return '${foodHabit?.toUserFriendlyString().capitalize ?? UserFoodHabit.UNKNOWN.toUserFriendlyString()} and ${cookingSkill?.toUserFriendlyString() ?? UserCookingSkill.UNKNOWN.toUserFriendlyString()}';
    }

    if (foodHabit != UserFoodHabit.UNKNOWN) {
      return '${foodHabit?.toUserFriendlyString().capitalize ?? UserFoodHabit.UNKNOWN.toUserFriendlyString()}';
    }
    if (cookingSkill != UserCookingSkill.UNKNOWN) {
      return '${cookingSkill?.toUserFriendlyString() ?? UserCookingSkill.UNKNOWN.toUserFriendlyString()}';
    }
    return '';
  }

  String _getSmokingDrinkingSubtitle(
      UserHabit? smokingHabit, UserHabit? drinkingHabit) {
    if (smokingHabit == UserHabit.NEVER && drinkingHabit == UserHabit.NEVER) {
      return 'I\'m Not A Smoker or A Drinker';
    }
    if (smokingHabit != UserHabit.UNKNOWN &&
        drinkingHabit != UserHabit.UNKNOWN) {
      return 'I\'m ${(smokingHabit ?? UserHabit.UNKNOWN).toSmokingHabitText()} and ${(drinkingHabit ?? UserHabit.UNKNOWN).toDrinkingHabitText()}'
          .capitalizeEachWord;
    }
    if (smokingHabit != UserHabit.UNKNOWN) {
      return 'I\'m ${(smokingHabit ?? UserHabit.UNKNOWN).toSmokingHabitText()}'
          .capitalizeEachWord;
    }
    if (drinkingHabit != UserHabit.UNKNOWN) {
      return 'I\'m ${(drinkingHabit ?? UserHabit.UNKNOWN).toDrinkingHabitText()}'
          .capitalizeEachWord;
    }
    return 'I\'m Not A Smoker or A Drinker';
  }

  String _getSubtitleTextPersonTypeAndCleanlinessHabit(PersonType? personType) {
    return 'I\'m all about ${(personType ?? PersonType.UNKNOWN).toPersonTypeText()}.';
  }

  String _getSubtitleTextCleanlinessHabit(
      UserCleanlinessHabit? cleanlinessHabit) {
    return 'I\'m All About ${(cleanlinessHabit ?? UserCleanlinessHabit.UNKNOWN).toUserFriendlyString().capitalizeEachWord}';
  }

  String _getSubtitleTextCollegeAndWorkExp(
      String? undergradCollegeName, int? workExperience) {
    String collegeText = "";
    String workExperienceText = "";
    if (undergradCollegeName != null && undergradCollegeName != "") {
      collegeText = 'I graduated from ${undergradCollegeName.capitalize}';
    }
    if (workExperience != null && workExperience != 0) {
      workExperienceText = 'I have $workExperience years of work experience';
    }
    if (collegeText != "" && workExperienceText != "") {
      return '${collegeText.capitalizeEachWord} and ${workExperienceText.capitalizeEachWord}';
    } else if (collegeText != "") {
      return collegeText.capitalizeEachWord;
    } else if (workExperienceText != "") {
      return workExperienceText.capitalizeEachWord;
    } else {
      return '';
    }
  }

  String _getRoomSubtitle(String flatmatesGenderPrefs, String roomType) {
    roomType = roomType[0].toUpperCase() + roomType.substring(1).toLowerCase();
    String roomSubtitle = '';
    if (flatmatesGenderPrefs == 'Male' && roomType == 'Private') {
      roomSubtitle =
          'I\'m Looking for a private room and prefer male flatmates!';
    } else if (flatmatesGenderPrefs == 'Male' && roomType == 'Shared') {
      roomSubtitle =
          'I\'m looking for a shared room and okay with male flatmates!';
    } else if (flatmatesGenderPrefs == 'Male' && roomType == 'Anything') {
      roomSubtitle = 'I\'m open to any room type and male flatmates!';
    } else if (flatmatesGenderPrefs == 'Female' && roomType == 'Private') {
      roomSubtitle =
          'I\'m looking for a private room and prefer female flatmates!';
    } else if (flatmatesGenderPrefs == 'Female' && roomType == 'Shared') {
      roomSubtitle =
          'I\'m looking for a shared room and okay with female flatmates!';
    } else if (flatmatesGenderPrefs == 'Female' && roomType == 'Anything') {
      roomSubtitle = 'I\'m open to any room type and female flatmates!';
    } else if (flatmatesGenderPrefs == 'Mix' && roomType == 'Private') {
      roomSubtitle =
          'I\'m looking for a private room and okay with mix gender flatmates!';
    } else if (flatmatesGenderPrefs == 'Mix' && roomType == 'Shared') {
      roomSubtitle =
          'I\'m looking for a shared room and okay with mix gender flatmates!';
    } else if (flatmatesGenderPrefs == 'Mix' && roomType == 'Anything') {
      roomSubtitle =
          'I\'m open to any room type and okay with mix gender flatmates!';
    } else {
      roomSubtitle =
          'Hmm, my flatmates gender preferences and room type are quite simple!';
    }
    return roomSubtitle.capitalizeEachWord;
  }

  Stack _buildProfileBanner(String photoUrl) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: <Widget>[
        // Add the background image
        Image.asset(
          AppRasterImages.userProfileBackgroundBanner,
          fit: BoxFit.cover,
          color: AppColor.appBlue,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              top: 12 + MediaQuery.of(context).padding.top,
            ),
            child: Text(
              'User Profile',
              style: AppTheme.titleLargeLightVariant.copyWith(
                color: AppColor.appBlue,
              ),
            ),
          ),
        ),
        Positioned(
          height: 150,
          width: 150,
          bottom: -75,
          left: MediaQuery.of(context).size.width / 2 - 75,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: 0.0),
            duration: const Duration(milliseconds: 500),
            builder: (BuildContext context, double value, Widget? child) {
              return Transform.scale(
                scale: 1 + value, // Scale factor for the title
                child: Opacity(
                  opacity: 1 - value, // Opacity factor for the title
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(75),
                    child: CachedNetworkImage(
                      imageUrl: photoUrl,
                      fadeInDuration: 150.ms,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
