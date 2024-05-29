import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/home.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/pages/user_list_view_page.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/features/user/chat/view/chat_home_view.dart';
import 'package:nesters/theme/theme.dart';

class HomeScaffold extends StatefulWidget {
  final int initialIndex;
  const HomeScaffold({super.key, required this.initialIndex});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  late final ValueNotifier<int> _selectedIndex =
      ValueNotifier<int>(widget.initialIndex);

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
    return BlocProvider(
      create: (context) => UserBloc(
        context.read<AuthBloc>().state.maybeWhen(
              authenticated: (user) => user,
              orElse: () => throw Exception('User not authenticated'),
            ),
      ),
      child: Scaffold(
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: _selectedIndex,
          builder: (context, selectedIndex, child) {
            return BottomNavigationBar(
              onTap: (index) {
                if (index == selectedIndex) {
                  return;
                } else {
                  _selectedIndex.value = index;
                }
              },
              currentIndex: selectedIndex,
              type: BottomNavigationBarType.fixed,
              enableFeedback: true,
              iconSize: 24.0,
              selectedFontSize: AppTheme.labelMedium.fontSize!,
              unselectedFontSize: AppTheme.labelMedium.fontSize!,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Icon(
                      FontAwesomeIcons.house,
                    ),
                  ),
                  label: 'Home',
                  tooltip: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Icon(
                      FontAwesomeIcons.solidMessage,
                    ),
                  ),
                  tooltip: 'Messages',
                  label: 'Messages',
                ),
              ],
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
      ),
    );
  }
}
