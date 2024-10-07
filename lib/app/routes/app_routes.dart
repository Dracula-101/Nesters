// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/features/auth/view/auth_view.dart';
import 'package:nesters/features/home/view/home_view.dart';
import 'package:nesters/features/marketplace/detail/view/marketplace_detail_page.dart';
import 'package:nesters/features/marketplace/form/view/marketplace_form_page.dart';
import 'package:nesters/features/onboarding/view/onboarding_view.dart';
import 'package:nesters/features/settings/view/settings_view.dart';
import 'package:nesters/features/splash/view/splash_view.dart';
import 'package:nesters/features/sublet/detail/view/sublet_detail_page.dart';
import 'package:nesters/features/sublet/form/view/sublet_form_page.dart';
import 'package:nesters/features/user/chat/view/user_chat_view.dart';
import 'package:nesters/features/user/detail/view/profile.dart';
import 'package:nesters/features/user/profile-forms/forms/view/advance_form_view.dart';
import 'package:nesters/features/user/profile-forms/forms/view/basic_form_view.dart';
import 'package:nesters/features/user/request/request.dart';

class AppRouter {
  // Navigator key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Current Route
  String get currentRoute =>
      ModalRoute.of(navigatorKey.currentContext!)?.settings.name ??
      Routes.SPLASH.toString();

  // Routes
  final routes = <String, Widget Function(BuildContext)>{
    // Splash screen
    '${Routes.SPLASH}': (context) => const SplashPage(),

    // Onboarding screen
    '${Routes.ONBOARDING}': (context) => const OnboardingPage(),

    // Login screen
    '${Routes.LOGIN}': (context) => const AuthPage(),

    // Basic form screen
    '${Routes.BASIC_FORM}': (context) => const UserProfileBasicForm(),

    // Advanced form screen
    '${Routes.ADVANCE_FORM}': (context) => const UserProfileAdvanceForm(),

    // Home screen
    '${Routes.HOME}': (context) {
      int page = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
      return HomeScaffold(initialIndex: page);
    },

    // Basic form screen
    '${Routes.HOME}/${SubRoutes.USER_CHAT_HOME}': (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      final chatId = arguments is Map<String, dynamic>
          ? arguments['chatId'] as String
          : '';
      User? user;
      if (arguments?.containsKey('user') ?? false) {
        try {
          user = User.fromJson(jsonDecode(arguments?['user'] as String));
        } catch (e) {
          user = null;
        }
      }
      if (user == null) throw Exception('User not found');
      return UserChatPage(
        chatId: chatId,
        userProfile: user,
      );
    },

    // Basic form screen
    '${Routes.HOME}/${SubRoutes.USER_PROFILE}': (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      String id = arguments?['id'] as String;
      bool showRequestDialog = false;
      if (arguments?.containsKey('showRequestDialog') ?? false) {
        showRequestDialog = arguments?['showRequestDialog'] as bool? ?? false;
      }
      return UserProfilePage(
        id: id,
        showRequestDialog: showRequestDialog,
      );
    },

    // Basic form screen
    '${Routes.HOME}/${SubRoutes.SUBLET_DETAIL}': (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      SubletModel? sublet;
      if (arguments?.containsKey('sublet') ?? false) {
        try {
          sublet =
              SubletModel.fromMap(jsonDecode(arguments?['sublet'] as String));
        } catch (e) {
          sublet = null;
        }
      }
      if (sublet == null) throw Exception('Sublet not found');
      return SubletDetailPage(sublet: sublet);
    },

    // Basic form screen
    '${Routes.HOME}/${SubRoutes.USER_REQUEST}': (context) =>
        const RequestPage(),

    // Basic form screen
    '${Routes.HOME}/${SubRoutes.SUBLETTING_FORM}': (context) =>
        const SubletFormPage(),

    // Basic form screen
    '${Routes.HOME}/${SubRoutes.MARKETPLACE_FORM}': (context) =>
        const MarketplaceFormPage(),

    // Basic form screen
    '${Routes.HOME}/${SubRoutes.MARKETPLACE_DETAIL}': (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      MarketplaceModel? marketplace;
      if (arguments?.containsKey('marketplace') ?? false) {
        try {
          marketplace = MarketplaceModel.fromJson(
              jsonDecode(arguments?['marketplace'] as String));
        } catch (e) {
          marketplace = null;
        }
      }
      if (marketplace == null) throw Exception('Marketplace not found');
      return MarketplaceDetailPage(marketplace: marketplace);
    },

    // Basic form screen
    '${Routes.HOME}/${SubRoutes.SETTINGS}': (context) => const SettingsView(),
  };

  Future<void> _navigateTo(String routeName, {Object? arguments}) async {
    log('==================================================================');
    log('Navigating to: $routeName');
    log('==================================================================');
    await navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  Future<void> _navigateToAndRemoveUntil(String routeName,
      bool Function(Route<dynamic> route) predicate, Object? arguments) async {
    log('==================================================================');
    log('Removing all pages to: $routeName');
    log('==================================================================');
    await navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  Future<void> _navigateToReplacement(String routeName,
      {Object? arguments}) async {
    log('==================================================================');
    log('Navigating to: $routeName (Replacement)');
    log('==================================================================');
    await navigatorKey.currentState
        ?.pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<void> initRoute(String routeName) async {
    _navigateToAndRemoveUntil(routeName, (route) => false, null);
  }

  Future<void> navigateToOnboarding({bool replace = false}) async {
    if (replace) {
      await _navigateToAndRemoveUntil(
          '${Routes.ONBOARDING}', (route) => false, null);
    } else {
      await _navigateTo('${Routes.ONBOARDING}');
    }
  }

  Future<void> navigateToLogin({bool replace = false}) async {
    if (replace) {
      await _navigateToAndRemoveUntil(
          '${Routes.LOGIN}', (route) => false, null);
    } else {
      await _navigateTo('${Routes.LOGIN}');
    }
  }

  Future<void> navigateToHome({int? initialIndex = 0}) async {
    await _navigateToAndRemoveUntil(
        '${Routes.HOME}', (route) => false, initialIndex);
  }

  Future<void> navigateToUserProfile(
      {required String id, bool showRequestDialog = false}) async {
    await _navigateTo('${Routes.HOME}/${SubRoutes.USER_PROFILE}', arguments: {
      'id': id,
      'showRequestDialog': showRequestDialog,
    });
  }

  Future<void> navigateToUserChat(
      {required String chatId, required User user}) async {
    await _navigateTo('${Routes.HOME}/${SubRoutes.USER_CHAT_HOME}', arguments: {
      'chatId': chatId,
      'user': jsonEncode(user.toJson()),
    });
  }

  Future<void> navigateToUserRequest() async {
    await _navigateTo('${Routes.HOME}/${SubRoutes.USER_REQUEST}');
  }

  Future<void> navigateToSubletDetail({required SubletModel sublet}) async {
    await _navigateTo('${Routes.HOME}/${SubRoutes.SUBLET_DETAIL}', arguments: {
      'sublet': jsonEncode(sublet.toMap()),
    });
  }

  Future<void> navigateToSubletForm() async {
    await _navigateTo('${Routes.HOME}/${SubRoutes.SUBLETTING_FORM}');
  }

  Future<void> navigateToMarketplaceForm() async {
    await _navigateTo('${Routes.HOME}/${SubRoutes.MARKETPLACE_FORM}');
  }

  Future<void> navigateToMarketplaceDetail(
      {required MarketplaceModel marketplace}) async {
    await _navigateTo('${Routes.HOME}/${SubRoutes.MARKETPLACE_DETAIL}',
        arguments: {
          'marketplace': jsonEncode(marketplace.toJson()),
        });
  }

  Future<void> navigateToSettings() async {
    await _navigateTo('${Routes.HOME}/${SubRoutes.SETTINGS}');
  }

  Future<void> navigateToBasicForm() async {
    await _navigateTo('${Routes.BASIC_FORM}');
  }

  Future<void> navigateToAdvanceForm() async {
    await _navigateTo('${Routes.ADVANCE_FORM}');
  }
}

enum Routes {
  SPLASH,
  ONBOARDING,
  LOGIN,
  HOME,
  NOTIFICATION,
  ADVANCE_FORM,
  BASIC_FORM;

  @override
  String toString() {
    switch (this) {
      case Routes.SPLASH:
        return '/';
      case Routes.ONBOARDING:
        return '/onboarding';
      case Routes.LOGIN:
        return '/login';
      case Routes.HOME:
        return '/home';
      case Routes.NOTIFICATION:
        return '/notification';
      case Routes.ADVANCE_FORM:
        return '/advance_form';
      case Routes.BASIC_FORM:
        return '/basic_form';
      default:
        return '';
    }
  }
}

enum SubRoutes {
  SUBLET,
  SUBLET_DETAIL,
  SUBLETTING_FORM,
  USER_CHAT_HOME,
  USER_PROFILE,
  MARKETPLACE_DETAIL,
  MARKETPLACE_FORM,
  USER_REQUEST,
  SETTINGS;

  @override
  String toString() {
    switch (this) {
      case SubRoutes.SUBLET:
        return 'sublet';
      case SubRoutes.SUBLET_DETAIL:
        return 'sublet_detail';
      case SubRoutes.SUBLETTING_FORM:
        return 'subletting_form';
      case SubRoutes.USER_CHAT_HOME:
        return 'chat';
      case SubRoutes.USER_PROFILE:
        return 'user_profile';
      case SubRoutes.MARKETPLACE_DETAIL:
        return 'marketplace_detail';
      case SubRoutes.MARKETPLACE_FORM:
        return 'marketplace_form';
      case SubRoutes.USER_REQUEST:
        return 'request';
      case SubRoutes.SETTINGS:
        return 'settings';
      default:
        return '';
    }
  }
}
