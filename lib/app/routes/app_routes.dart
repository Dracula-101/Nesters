import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/view/app_scaffold.dart';
import 'package:nesters/features/auth/view/auth_view.dart';
import 'package:nesters/features/home/view/home_view.dart';
import 'package:nesters/features/splash/view/splash_view.dart';

class AppRouterService {
  static const String splashScreen = '/';
  static const String homeScreen = '/home';
  static const String loginScreen = '/login';

  // Navigator key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final appRouter = GoRouter(
    errorPageBuilder: (context, state) => const MaterialPage(
        child: Scaffold(body: Center(child: Text('Page not found')))),
    navigatorKey: navigatorKey,
    routes: [
      ShellRoute(
        builder: (context, router, navigator) {
          return RootAppScaffold(child: navigator);
        },
        routes: [
          AppRoute(splashScreen, (_) => SplashView()), // This will be hidden
          AppRoute(loginScreen, (_) => AuthView()),
          AppRoute(homeScreen, (_) => HomeView()),
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
            final pageContent = Scaffold(
              body: builder(state),
              resizeToAvoidBottomInset: false,
            );
            if (useFade) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: pageContent,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              );
            }
            return CupertinoPage(child: pageContent);
          },
        );
  final bool useFade;
}
