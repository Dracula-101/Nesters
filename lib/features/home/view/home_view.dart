import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

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
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Map<String, dynamic>>>? _universitiesStream;
  final AppLoggerService _logger = GetIt.I<AppLoggerService>();
  final supabase.SupabaseClient _supabaseClient =
      supabase.Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _handleSearchBar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchBar() {
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        _buildSearchBar(),
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
                      // Logout icon
                      FontAwesomeIcons.rightFromBracket,
                      size: 20,
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignOutEvent());
                    },
                  ),
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

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for a university',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onSubmitted: (value) {
            _supabaseClient
                .from('universities')
                .select('title')
                .then((response) {
              _logger.info('Response: ${response}');
            });
          },
        ),
      ),
    );
  }

  Widget _buildUniversityList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _universitiesStream,
      builder: (context, snapshot) {
        _logger.info('Snapshot: ${snapshot.data}');
        if (snapshot.hasData) {
          final universities = snapshot.data;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final university = universities?[index];
                return ListTile(
                  title: Text(university?['name'] ?? ''),
                  subtitle: Text(university?['location'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {},
                  ),
                );
              },
              childCount: universities?.length,
            ),
          );
        }
        return const SliverToBoxAdapter(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
