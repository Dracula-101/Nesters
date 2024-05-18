import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/home.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/pages/user_list_view_page.dart';

class HomeScaffold extends StatefulWidget {
  final Widget innerContent;
  const HomeScaffold({super.key, required this.innerContent});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

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
                  if (index == 0) {
                    GoRouter.of(context).go(AppRouterService.homeScreen);
                  } else {
                    GoRouter.of(context)
                        .go(AppRouterService.notificationScreen);
                  }
                }
              },
              currentIndex: selectedIndex,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.house,
                  ),
                  label: 'Home',
                  tooltip: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.solidBell,
                  ),
                  tooltip: 'Notifications',
                  label: 'Notifications',
                ),
              ],
            );
          },
        ),
        body: SafeArea(
          child: widget.innerContent,
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeView();
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return const UserListPage();
          },
        );
      },
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Notifications Page'));
  }
}
