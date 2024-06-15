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
          _buildFirstPage(),
          _buildSecondPage(),
          _buildThirdPage(),
        ],
      ),
    );
  }

  Widget _buildFirstPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primary,
                width: 2,
              ),
            ),
            child: SvgPicture.asset(
              AppVectorImages.onboardingPreviewImage,
              height: MediaQuery.of(context).size.height * 0.3,
            ),
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              text: 'Find ',
              style: AppTheme.displayMedium,
              children: [
                TextSpan(
                  text: 'your ',
                  style: AppTheme.displaySmallLightVariant,
                ),
                TextSpan(
                  text: 'perfect ',
                  style: AppTheme.displaySmallLightVariant,
                ),
                TextSpan(
                  text: 'roommate',
                  style: AppTheme.displaySmallLightVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondPage() {
    return SizedBox();
  }

  Widget _buildThirdPage() {
    return SizedBox();
  }

  Widget _buildOnboardingPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buildProgressDot(context, currentIndex),
    );
  }

  List<Widget> buildProgressDot(BuildContext context, int index) {
    return List.generate(
      3,
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
          if (currentIndex == 2) {
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
          currentIndex == 2 ? 'Continue' : 'Next',
          style: AppTheme.titleSmall.copyWith(
            color: AppTheme.surface,
          ),
        ),
      ),
    );
  }
}
