import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/home.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/pages/user_list_view_page.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/features/user/chat/view/chat_home_view.dart';
import 'package:nesters/features/user/request/bloc/request_bloc.dart';
import 'package:nesters/theme/theme.dart';

class HomeScaffold extends StatefulWidget {
  final int initialIndex;
  const HomeScaffold({super.key, required this.initialIndex});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  @override
  void initState() {
    super.initState();
    String userId = context.read<AuthBloc>().state.maybeWhen(
          authenticated: (user) => user.id,
          orElse: () => throw Exception('User not authenticated'),
        );
    context
        .read<CentralChatBloc>()
        .add(CentralChatEvent.initalizeUserStatusSocket(userId));
    context.read<CentralChatBloc>().add(const CentralChatEvent.loadProfiles());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc(),
        ),
        BlocProvider(
          create: (context) => UserBloc(
            context.read<AuthBloc>().state.maybeWhen(
                  authenticated: (user) => user,
                  orElse: () => throw Exception('User not authenticated'),
                ),
          ),
        ),
      ],
      child: HomeView(initialIndex: widget.initialIndex),
    );
  }
}

class HomeView extends StatefulWidget {
  final int initialIndex;
  const HomeView({super.key, required this.initialIndex});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final ValueNotifier<int> _selectedIndex =
      ValueNotifier<int>(widget.initialIndex);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _selectedIndex,
        builder: (context, selectedIndex, child) {
          return NavigationBar(
            destinations: [
              NavigationDestination(
                label: 'Home',
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Icon(
                    FontAwesomeIcons.house,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              NavigationDestination(
                label: 'Chat',
                icon: StreamBuilder(
                  stream: context
                      .read<CentralChatBloc>()
                      .showMessageNotificationStream(),
                  builder: (context, snapshot) {
                    return Badge.count(
                      count: snapshot.data ?? 0,
                      isLabelVisible:
                          snapshot.data != 0 && snapshot.data != null,
                      textStyle: AppTheme.labelSmall,
                      offset: const Offset(10, -4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Icon(
                          FontAwesomeIcons.solidMessage,
                          color: AppTheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            onDestinationSelected: (index) {
              if (index == selectedIndex) {
                return;
              } else {
                _selectedIndex.value = index;
              }
            },
            selectedIndex: selectedIndex,
            indicatorColor: AppTheme.primary.withOpacity(0.15),
            shadowColor: AppTheme.shadowColor,
            elevation: 12,
            height: 70,
          );
        },
      ),
      body: SafeArea(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            return BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return ValueListenableBuilder(
                  valueListenable: _selectedIndex,
                  builder: (context, value, child) {
                    return IndexedStack(
                      index: value,
                      children: const [
                        UserListPage(),
                        ChatHomePage(),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
