import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/view/app_scaffold.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/features/auth/view/auth_view.dart';
import 'package:nesters/features/home/view/home_view.dart';
import 'package:nesters/features/onboarding/view/onboarding_view.dart';
import 'package:nesters/features/splash/view/splash_view.dart';
import 'package:nesters/features/sublet/detail/view/sublet_detail_page.dart';
import 'package:nesters/features/sublet/form/view/sublet_form_page.dart';
import 'package:nesters/features/user/chat/view/chat_home_view.dart';
import 'package:nesters/features/user/chat/view/user_chat_view.dart';
import 'package:nesters/features/user/detail/view/profile.dart';
import 'package:nesters/features/user/profile-forms/forms/view/advance_form_view.dart';
import 'package:nesters/features/user/profile-forms/forms/view/basic_form_view.dart';
import 'package:nesters/features/user/request/request.dart';

class AppRouterService {
  static const String homeScreen = '/home';
  static const String loginScreen = '/login';
  static const String notificationScreen = '/notification';
  static const String onboardingScreen = '/onboarding';
  static const String splashScreen = '/';
  static const String userChatHome = 'chat';
  static const String sublet = 'sublet';
  static const String userProfile = 'user_profile';
  static const String userProfileAdvanceFormScreen = '/advance_form';
  static const String userProfileBasicFormScreen = '/basic_form';
  static const String userRequest = 'request';
  static const String sublettingForm = 'subletting_form';
  static const String subletDetail = 'sublet_detail';

  // Navigator key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final appRouter = GoRouter(
    errorPageBuilder: (
      context,
      state,
    ) =>
        MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text(
            'Page not found Route: ${state.fullPath}',
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
            homeScreen,
            (params) {
              int page = params.pathParameters['page'] == null
                  ? 0
                  : int.parse(params.pathParameters['page']!);
              return HomeScaffold(initialIndex: page);
            },
            routes: [
              AppRoute(
                '$userChatHome/:chatId',
                (params) => UserChatPage(
                  chatId: params.pathParameters['chatId'] ?? '',
                  userProfile: params.extra as User,
                ),
              ),
              AppRoute(
                '$userProfile/:id',
                (params) {
                  bool showDialog =
                      params.extra is bool ? params.extra as bool : false;
                  return UserProfilePage(
                    id: params.pathParameters['id'] ?? '',
                    showRequestDialog: showDialog,
                  );
                },
              ),
              AppRoute(
                subletDetail,
                (params) => SubletDetailPage(
                  sublet: params.extra as SubletModel,
                ),
              ),
              AppRoute(
                userRequest,
                (_) => const RequestPage(),
              ),
              AppRoute(
                sublettingForm,
                (_) => const SubletFormPage(),
              )
            ],
          ),
          AppRoute(
            loginScreen,
            (_) => const AuthPage(),
          ),
          AppRoute(
            onboardingScreen,
            (_) => const OnboardingPage(),
          ),
          AppRoute(
            splashScreen,
            (_) => const SplashPage(),
          ),
          AppRoute(
            userProfileAdvanceFormScreen,
            (_) => const UserProfileAdvanceForm(),
          ),
          AppRoute(
            userProfileBasicFormScreen,
            (_) => const UserProfileBasicForm(),
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
