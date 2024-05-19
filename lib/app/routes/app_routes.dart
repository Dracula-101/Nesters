import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/view/app_scaffold.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/features/auth/view/auth_view.dart';
import 'package:nesters/features/home/view/home_view.dart';
import 'package:nesters/features/onboarding/view/onboarding_view.dart';
import 'package:nesters/features/splash/view/splash_view.dart';
import 'package:nesters/features/user/chat/view/chat_home_view.dart';
import 'package:nesters/features/user/chat/view/user_chat_view.dart';
import 'package:nesters/features/user/detail/view/profile.dart';
import 'package:nesters/features/user/profile-forms/forms/view/advance_form_view.dart';
import 'package:nesters/features/user/profile-forms/forms/view/basic_form_view.dart';

class AppRouterService {
  static const String splashScreen = '/';
  static const String onboardingScreen = '/onboarding';
  static const String homeScreen = '/home';
  static const String notificationScreen = '/notification';
  static const String loginScreen = '/login';
  static const String userProfileBasicFormScreen = '/basic_form';
  static const String userProfileAdvanceFormScreen = '/advance_form';
  static const String userProfile = 'user_profile';
  static const String userChatHome = 'chat';

  // Navigator key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final appRouter = GoRouter(
    errorPageBuilder: (
      context,
      state,
    ) =>
        const MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text(
            'Page not found',
          ),
        ),
      ),
    ),
    navigatorKey: navigatorKey,
    routes: [
      ShellRoute(
        builder: (
          context,
          router,
          navigator,
        ) {
          return RootAppScaffold(
            child: navigator,
          );
        },
        routes: [
          AppRoute(
            splashScreen,
            (_) => const SplashPage(),
          ),
          AppRoute(
            onboardingScreen,
            (_) => const OnboardingPage(),
          ),
          AppRoute(
            loginScreen,
            (_) => const AuthPage(),
          ),
          AppRoute(
            userProfileBasicFormScreen,
            (_) => const UserProfileBasicForm(),
          ),
          AppRoute(
            userProfileAdvanceFormScreen,
            (_) => const UserProfileAdvanceForm(),
          ),
          AppRoute(
            homeScreen,
            (params) {
              int page = params.pathParameters['page'] == null
                  ? 0
                  : int.parse(params.pathParameters['page']!);
              return HomeScaffold(initialIndex: page);
            },
            routes: [
              AppRoute(
                '$userProfile/:id',
                (params) {
                  return UserProfilePage(id: params.pathParameters['id'] ?? '');
                },
              ),
              AppRoute(
                userChatHome,
                (_) => const ChatHomePage(),
              ),
              AppRoute(
                '$userChatHome/:chatId',
                (params) => UserChatPage(
                  chatId: params.pathParameters['chatId'] ?? '',
                  userProfile: params.extra as User,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class AppRoute extends GoRoute {
  AppRoute(String path, Widget Function(GoRouterState s) builder,
      {List<GoRoute> routes = const [], this.useFade = false})
      : super(
          path: path,
          routes: routes,
          pageBuilder: (context, state) {
            final pageContent = builder(
              state,
            );
            if (useFade) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: pageContent,
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            } else {
              return CustomTransitionPage(
                key: state.pageKey,
                child: pageContent,
                transitionDuration: const Duration(
                  milliseconds: 200,
                ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(
                        1,
                        0,
                      ),
                      end: Offset.zero,
                    ).animate(
                      animation,
                    ),
                    child: child,
                  );
                },
              );
            }
          },
        );
  final bool useFade;
}
