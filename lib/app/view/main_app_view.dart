import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/bloc/home_bloc.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/features/user/request/bloc/request_bloc.dart';
import 'package:nesters/theme/theme.dart';

class RootApp extends StatelessWidget with WidgetsBindingObserver {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouterService = GetIt.I.get<AppRouterService>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppBloc(),
        ),
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => CentralChatBloc(),
        ),
        BlocProvider(
          create: (context) => RequestBloc(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouterService.appRouter,
        title: 'Nesters',
        theme: AppTheme.lightTheme,
        onNavigationNotification: (notification) {
          print(notification);
          return true;
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(
                1.0,
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
