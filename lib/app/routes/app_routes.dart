import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/view/app_scaffold.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/features/apartment/detail/view/apartment_detail_page.dart';
import 'package:nesters/features/apartment/form/view/apartment_form_page.dart';
import 'package:nesters/features/auth/view/auth_view.dart';
import 'package:nesters/features/home/view/home_view.dart';
import 'package:nesters/features/marketplace/detail/view/marketplace_detail_page.dart';
import 'package:nesters/features/marketplace/form/view/marketplace_form_page.dart';
import 'package:nesters/features/onboarding/view/onboarding_view.dart';
import 'package:nesters/features/settings/view/settings_view.dart';
import 'package:nesters/features/splash/view/splash_view.dart';
import 'package:nesters/features/sublet/detail/view/sublet_detail_page.dart';
import 'package:nesters/features/sublet/form/view/sublet_form_page.dart';
import 'package:nesters/features/user/chat/view/chat_home_view.dart';
import 'package:nesters/features/user/chat/view/user_chat_view.dart';
import 'package:nesters/features/user/detail/view/profile.dart';
import 'package:nesters/features/user/edit-profile/edit_profile.dart';
import 'package:nesters/features/user/favourite_posts/user_favourite_post.dart';
import 'package:nesters/features/user/posts/cubit/user_post_state.dart';
import 'package:nesters/features/user/posts/view/user_post_view.dart';
import 'package:nesters/features/user/profile-forms/forms/view/advance_form_view.dart';
import 'package:nesters/features/user/profile-forms/forms/view/basic_form_view.dart';
import 'package:nesters/features/user/request/request.dart';

class AppRouterService {
  static const String homeScreen = '/home';
  static const String loginScreen = '/login';
  static const String marketplaceDetail = 'marketplace_detail';
  static const String marketplaceForm = 'marketplace_form';
  static const String notificationScreen = '/notification';
  static const String onboardingScreen = '/onboarding';
  static const String splashScreen = '/';
  static const String sublet = 'sublet';
  static const String subletDetail = 'sublet_detail';
  static const String sublettingForm = 'subletting_form';
  static const String apartment = 'apartment';
  static const String apartmentDetail = 'apartment_detail';
  static const String apartmentForm = 'apartment_form';
  static const String userChatHome = 'main_chat';
  static const String userChatPage = "chat";
  static const String userProfile = 'user_profile';
  static const String userProfileAdvanceFormScreen = 'advance_form';
  static const String userProfileBasicFormScreen = '/basic_form';
  static const String userRequest = 'request';
  static const String settings = 'settings';
  static const String editProfile = 'edit_profile';
  static const String userPosts = 'user_posts';
  static const String favouritePosts = 'favourite_posts';

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
                userChatHome,
                (params) => const ChatHomePage(),
                routes: [
                  AppRoute(
                    '$userChatPage/:chatId',
                    (params) => UserChatPage(
                      chatId: params.pathParameters['chatId'] ?? '',
                      userProfile: params.extra as User,
                    ),
                  ),
                ],
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
                userProfileAdvanceFormScreen,
                (_) => const UserProfileAdvanceForm(),
              ),
              AppRoute(
                subletDetail,
                (params) => SubletDetailPage(
                  sublet: params.extra as SubletModel,
                ),
              ),
              AppRoute(
                apartmentDetail,
                (params) => ApartmentDetailPage(
                  apartment: params.extra as ApartmentModel,
                ),
              ),
              AppRoute(
                userRequest,
                (_) => const RequestPage(),
              ),
              AppRoute(
                sublettingForm,
                (_) => const SubletFormPage(),
              ),
              AppRoute(
                apartmentForm,
                (_) => const ApartmentFormPage(),
              ),
              AppRoute(
                marketplaceForm,
                (_) => const MarketplaceFormPage(),
              ),
              AppRoute(
                marketplaceDetail,
                (params) => MarketplaceDetailPage(
                  marketplace: params.extra as MarketplaceModel,
                ),
              ),
              AppRoute(
                settings,
                (_) => const SettingsPage(),
                routes: [
                  AppRoute(
                    editProfile,
                    (_) => const EditProfileScreen(),
                  ),
                  AppRoute(
                    "$userPosts/:view",
                    (params) {
                      final view = PostView.values.firstWhere((element) =>
                          element.toString() == params.pathParameters['view']);
                      return UserPostScreen(view: view);
                    },
                    routes: [
                      AppRoute(
                        sublettingForm,
                        (params) {
                          final sublet = params.extra as SubletModel?;
                          return SubletFormPage(sublet: sublet);
                        },
                      ),
                      AppRoute(
                        apartmentForm,
                        (params) {
                          final apartment = params.extra as ApartmentModel?;
                          return ApartmentFormPage(apartment: apartment);
                        },
                      ),
                      AppRoute(
                        marketplaceForm,
                        (params) {
                          final marketplace = params.extra as MarketplaceModel?;
                          return MarketplaceFormPage(marketplace: marketplace);
                        },
                      ),
                    ],
                  ),
                  AppRoute(
                    favouritePosts,
                    (_) => const UserFavouritePostPage(),
                  )
                ],
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
