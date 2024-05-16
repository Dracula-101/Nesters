import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/constants/app_assets.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/user/profile/view/shimmer_profile.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:shimmer/shimmer.dart';

class UserProfilePage extends StatelessWidget {
  final String id;
  const UserProfilePage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGrey,
      resizeToAvoidBottomInset: true,
      body: BlocProvider(
        create: (context) => UserBloc(
          context.read<AuthBloc>().state.maybeWhen(
                authenticated: (user) => user,
                orElse: () => throw Exception('User not authenticated'),
              ),
        ),
        child: SafeArea(
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return ProfileView(
                id: id,
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProfileView extends StatefulWidget {
  final String id;
  const ProfileView({super.key, required this.id});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final UserRepository userRepository = GetIt.I<UserRepository>();
  final AppLoggerService _loggerService = GetIt.I<AppLoggerService>();
  late UserProfile userProfile;
  bool _loading = true;

  @override
  void initState() {
    _fetchUserProfile();
    super.initState();
  }

  Future<void> _fetchUserProfile() async {
    // Fetch user profile
    final profileData = await userRepository.getUserProfile(widget.id);
    _loggerService.info('User Profile: $profileData');
    setState(
      () {
        userProfile = profileData;
      },
    );
    //after 2 sec set loading to false
    Future.delayed(
      const Duration(seconds: 2),
      () {
        setState(() {
          _loading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? const ShimmerProfile() : _buildProfile();
  }

  CustomScrollView _buildProfile() {
    return CustomScrollView(
      slivers: <Widget>[
        _buildSliverAppBar(),
        _buildSliverList(),
      ],
    );
  }

  SliverList _buildSliverList() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          _buildSizedBox(91),
          Center(
            child: Text(
              userProfile?.fullName ?? '',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Center(
            child: Text(
              '${userProfile.city as String}, ${userProfile.state as String}',
              style: AppTheme.bodyLargeLightVariant.copyWith(
                fontWeight: FontWeight.w500,
              ),
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
            userProfile.selectedCourseName as String,
            '@${userProfile.selectedCollegeName}',
            Icons.school,
          ),
          _buildCard(
            'About Me',
            userProfile.bio,
            FontAwesomeIcons.user,
          ),
          _buildCard(
            'Mother Tongue',
            (userProfile.primaryLang as String) +
                        (userProfile.otherLang as String) !=
                    ''
                ? '${userProfile.primaryLang} but I also speak ${userProfile.otherLang}'
                : ' ',
            FontAwesomeIcons.language,
          ),
          _buildCard(
            'I am',
            getSubtitleText(userProfile.foodHabit as String,
                userProfile.cookingSkill as String),
            FontAwesomeIcons.bowlFood,
          ),
          _buildCard(
            'Smoke & Sip',
            getSmokingDrinkingSubtitle(
              userProfile.drinkingHabit as String,
              userProfile.smokingHabit as String,
            ),
            FontAwesomeIcons.wineGlass,
          ),
          _buildCard(
            'In terms of personality',
            getSubtitleTextPersonTypeAndCleanlinessHabit(
              userProfile.personType as String,
            ),
            FontAwesomeIcons.cloudBolt,
          ),
          _buildCard(
            'When it comes to cleanliness',
            getSubtitleTextCleanlinessHabit(
              userProfile.cleanlinessHabit as String,
            ),
            FontAwesomeIcons.broom,
          ),
          _buildCard(
            'College & Career Snapshot',
            getSubtitleTextCollegeAndWorkExp(
              userProfile.undergradCollegeName as String,
              userProfile.workExperience,
            ),
            FontAwesomeIcons.graduationCap,
          ),
          _buildCard(
            'Living Arrangements',
            getRoomSubtitle(
              userProfile.flatmatesGenderPrefs,
              userProfile.roomType as String,
            ),
            FontAwesomeIcons.house,
          ),
          _buildCard(
            'Hobbies',
            userProfile?.hobbies ?? '',
            FontAwesomeIcons.heartPulse,
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 175,
      flexibleSpace: _buildProfileBanner(),
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

  String getSubtitleText(String foodHabit, String cookingSkill) {
    if (foodHabit == 'Vegan' && cookingSkill == 'Newbie') {
      return 'Vegan and just starting to cook.';
    } else if (foodHabit == 'Vegetarian' && cookingSkill == 'Newbie') {
      return 'Vegetarian and just starting to cook.';
    } else if (foodHabit == 'Pescatarian' && cookingSkill == 'Newbie') {
      return 'Pescatarian and just starting to cook.';
    } else if (foodHabit == 'Eggetarian' && cookingSkill == 'Newbie') {
      return 'Eggetarian and just starting to cook.';
    } else if ((foodHabit == 'Non vegetarian' ||
            foodHabit == 'Non Vegetarian') &&
        cookingSkill == 'Newbie') {
      return 'Non-vegetarian and just starting to cook.';
    } else if (foodHabit == 'Vegan' && cookingSkill == 'Intermediate') {
      return 'Vegan and have some experience in cooking.';
    } else if (foodHabit == 'Vegetarian' && cookingSkill == 'Intermediate') {
      return 'Vegetarian and have some experience in cooking.';
    } else if (foodHabit == 'Pescatarian' && cookingSkill == 'Intermediate') {
      return 'Pescatarian and have some experience in cooking.';
    } else if (foodHabit == 'Eggetarian' && cookingSkill == 'Intermediate') {
      return 'Eggetarian and have some experience in cooking.';
    } else if ((foodHabit == 'Non vegetarian' ||
            foodHabit == 'Non Vegetarian') &&
        cookingSkill == 'Intermediate') {
      return 'Non-vegetarian and have some experience in cooking.';
    } else if (foodHabit == 'Vegan' && cookingSkill == 'Chef') {
      return 'Vegan and an experienced cook.';
    } else if (foodHabit == 'Vegetarian' && cookingSkill == 'Chef') {
      return 'Vegetarian and an experienced cook.';
    } else if (foodHabit == 'Pescatarian' && cookingSkill == 'Chef') {
      return 'Pescatarian and an experienced cook.';
    } else if (foodHabit == 'Eggetarian' && cookingSkill == 'Chef') {
      return 'Eggetarian and an experienced cook.';
    } else if ((foodHabit == 'Non vegetarian' ||
            foodHabit == 'Non Vegetarian') &&
        cookingSkill == 'Chef') {
      return 'Non-vegetarian and an experienced cook.';
    } else {
      return 'Unknown food habit and cooking skill combination.';
    }
  }

  String getSmokingDrinkingSubtitle(String smokingHabit, String drinkingHabit) {
    String smokingText = '';
    String drinkingText = '';

    switch (smokingHabit) {
      case 'Regular':
        smokingText = 'Puffing away regularly';
        break;
      case 'Occasionally':
        smokingText = 'Enjoying a smoke occasionally';
        break;
      case 'Rarely':
        smokingText = 'Smoking only rarely';
        break;
      case 'Never':
        smokingText = 'Not a smoker';
        break;
      default:
        smokingText = 'having an unknown smoking habit';
        break;
    }

    switch (drinkingHabit) {
      case 'Regular':
        drinkingText = 'sipping drinks regularly';
        break;
      case 'Occasionally':
        drinkingText = 'indulging in drinks occasionally';
        break;
      case 'Rarely':
        drinkingText = 'rarely touching a drop';
        break;
      case 'Never':
        drinkingText = 'not a drinker';
        break;
      default:
        drinkingText = 'having an unknown drinking habit';
        break;
    }

    return '$smokingText and $drinkingText.';
  }

  String getSubtitleTextPersonTypeAndCleanlinessHabit(String personType) {
    String personText = '';

    switch (personType) {
      case 'Ambivert':
        personText = 'being an ambivert';
        break;
      case 'Extrovert':
        personText = 'rocking the extrovert vibes';
        break;
      case 'Introvert':
        personText = 'embracing the introvert lifestyle';
        break;
      default:
        personText = 'having an unknown personality type';
        break;
    }

    return 'I\'m all about $personText.';
  }

  String getSubtitleTextCleanlinessHabit(String cleanlinessHabit) {
    String cleanlinessText = '';
    switch (cleanlinessHabit) {
      case 'Messy':
        cleanlinessText = 'living in organized chaos';
        break;
      case 'Decently Clean':
        cleanlinessText = 'maintaining a decent level of cleanliness';
        break;
      case 'Very Clean':
        cleanlinessText = 'keeping things very clean';
        break;
      case 'Obsessively Clean':
        cleanlinessText = 'being obsessively clean';
        break;
      default:
        cleanlinessText = 'having an unknown cleanliness habit';
        break;
    }
    return 'I\'m all about $cleanlinessText.';
  }

  String getSubtitleTextCollegeAndWorkExp(
      String undergradCollegeName, int workExperience) {
    String capitalize(String str) {
      return "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}";
    }

    String collegeText = undergradCollegeName
        .split(' ')
        .map((word) => capitalize(word))
        .join(' ');
    String experienceText = workExperience == 0
        ? 'fresher'
        : 'with $workExperience years of experience';

    return 'I graduated from $collegeText $experienceText!';
  }

  String getRoomSubtitle(String flatmatesGenderPrefs, String roomType) {
    if (flatmatesGenderPrefs == 'Male' && roomType == 'Private') {
      return 'I\'m looking for a private room and prefer male flatmates!';
    } else if (flatmatesGenderPrefs == 'Male' && roomType == 'Shared') {
      return 'I\'m looking for a shared room and okay with male flatmates!';
    } else if (flatmatesGenderPrefs == 'Male' && roomType == 'Anything') {
      return 'I\'m open to any room type and male flatmates!';
    } else if (flatmatesGenderPrefs == 'Female' && roomType == 'Private') {
      return 'I\'m looking for a private room and prefer female flatmates!';
    } else if (flatmatesGenderPrefs == 'Female' && roomType == 'Shared') {
      return 'I\'m looking for a shared room and okay with female flatmates!';
    } else if (flatmatesGenderPrefs == 'Female' && roomType == 'Anything') {
      return 'I\'m open to any room type and female flatmates!';
    } else if (flatmatesGenderPrefs == 'Mix' && roomType == 'Private') {
      return 'I\'m looking for a private room and okay with mix gender flatmates!';
    } else if (flatmatesGenderPrefs == 'Mix' && roomType == 'Shared') {
      return 'I\'m looking for a shared room and okay with mix gender flatmates!';
    } else if (flatmatesGenderPrefs == 'Mix' && roomType == 'Anything') {
      return 'I\'m open to any room type and okay with mix gender flatmates!';
    } else {
      return 'Hmm, my flatmates gender preferences and room type are quite unique!';
    }
  }

  Stack _buildProfileBanner() {
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
            padding: const EdgeInsets.only(
              top: 16.0,
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
                    child: Image.network(
                      userProfile?.profileImage ?? '',
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
