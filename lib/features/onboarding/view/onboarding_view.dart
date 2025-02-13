import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/constants/app_assets.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: OnboardingView(),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int currentIndex = 0;
  int pageCount = 4;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildOnboardingInfo(),
          _buildOnboardingPageIndicator(),
          _buildNavigateButton(context),
        ],
      ),
    );
  }

  Widget _buildOnboardingInfo() {
    return Expanded(
      child: PageView(
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        children: [
          _buildRommatePage(),
          _buildCollegeCommunityPage(),
          _buildSubletPage(),
          _buildMarketplacePage(),
        ],
      ),
    );
  }

  Widget _buildRommatePage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            AppVectorImages.onboardingRoomates,
            height: MediaQuery.of(context).size.height * 0.4,
          ),
          const SizedBox(height: 20),
          Text(
            'Find Your Perfect Roommate',
            style: AppTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Text(
              // short description
              "Find your perfect roommate or just vibe with peers & seniors—your way! 🎯",
              style: AppTheme.labelLargeLightVariant,
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
        ],
      ),
    );
  }

  Widget _buildSubletPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            AppVectorImages.onboardingSublet,
            height: MediaQuery.of(context).size.height * 0.4,
          ),
          const SizedBox(height: 20),
          Text(
            'Sublet Your Room Effortlessly',
            style: AppTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Text(
              "Moving out for a few months? 💸 Sublet your place & make some extra cash!",
              style: AppTheme.labelLargeLightVariant,
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplacePage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            AppVectorImages.onboardingMarketplace,
            height: MediaQuery.of(context).size.height * 0.4,
          ),
          const SizedBox(height: 20),
          Text(
            "Student Marketplace",
            style: AppTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Text(
              "Shop smart, sell easy! 💸 Buy & sell second-hand student essentials hassle-free.",
              style: AppTheme.labelLargeLightVariant,
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeCommunityPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            AppVectorImages.onboardingCommunity,
            height: MediaQuery.of(context).size.height * 0.4,
          ),
          const SizedBox(height: 20),
          Text(
            'Looking for an Apartment?',
            style: AppTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Text(
              "Get broker-free apartments by connecting with students who are moving out! 🏡",
              style: AppTheme.labelLargeLightVariant,
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buildProgressDot(context, currentIndex),
    );
  }

  List<Widget> buildProgressDot(BuildContext context, int index) {
    return List.generate(
      pageCount,
      (index) => AnimatedContainer(
        duration: 200.ms,
        height: 10,
        width: currentIndex == index ? 25 : 10,
        margin: const EdgeInsets.only(
          right: 5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            20,
          ),
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildNavigateButton(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(
        30,
      ),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (currentIndex == pageCount - 1) {
            unawaited(GetIt.I<UserRepository>().setOnBoardingComplete());
            context.read<AppBloc>().isOnboardingCompleted = true;
            GoRouter.of(context).go(AppRouterService.loginScreen);
          } else {
            _pageController.nextPage(
              duration: const Duration(
                milliseconds: 200,
              ),
              curve: Curves.easeInOut,
            );
          }
        },
        child: Text(
          currentIndex == pageCount - 1 ? 'Continue' : 'Next',
          style: AppTheme.titleSmall.copyWith(
            color: AppTheme.surface,
          ),
        ),
      ),
    );
  }
}
