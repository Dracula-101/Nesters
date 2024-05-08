import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocProvider(
        create: (context) => UserBloc(
          context.read<AuthBloc>().state.maybeWhen(
                authenticated: (user) => user,
                orElse: () => throw Exception('User not authenticated'),
              ),
        ),
        child: SafeArea(
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return const HomeView();
            },
          ),
        ),
      ),
    );
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
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        _buildUniversityList(),
      ],
    );
  }

  Widget _buildAppBar() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return state.maybeWhen(
          authenticated: (user) {
            return SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              sliver: SliverAppBar(
                floating: true,
                elevation: 8,
                scrolledUnderElevation: 8,
                shadowColor: AppTheme.greyShades.shade100,
                leadingWidth: 0,
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome,',
                          style: AppTheme.bodyLarge,
                        ),
                        Text(
                          user.name,
                          style: AppTheme.bodySmallLightVariant,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 20,
                    ),
                    onPressed: () {},
                  )
                ],
              ),
            );
          },
          orElse: () => const SliverAppBar(
            title: Text(
              'Nesters',
            ),
          ),
        );
      },
    );
  }

  Widget _buildUniversityList() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return !state.isLoadingUniversities && state.universities.isNotEmpty
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ListTile(
                      title: Text(
                        state.universities[index]?.title ?? "",
                        style: AppTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        state.universities[index]?.region ?? "",
                        style: AppTheme.bodySmallLightVariant,
                      ),
                      leading: Image.network(
                        state.universities[index]?.logo ?? "",
                        width: 35,
                        height: 35,
                      ),
                    );
                  },
                  childCount: state.universities.length,
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}
