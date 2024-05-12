import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/domain/models/university.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/utils/debouncer.dart';
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
  Stream<List<University>?>? _universitiesStream;
  final AppLoggerService _logger = GetIt.I<AppLoggerService>();
  final Debouncer _debouncer = Debouncer(milliseconds: 400);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _rebuildUniversitiesStream(String query) {
    if (query.isNotEmpty) {
      _universitiesStream = GetIt.I<DatabaseRepository>()
          .searchData('universities', 'title', query)
          .map((event) => event.map((e) => University.fromJson(e)).toList());
      setState(() {});
    } else {
      _universitiesStream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        _buildUniversityList(),
      ],
    );
  }

  // APp bar 500px height

  Widget _buildAppBar() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
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
                  child: ClipOval(
                    child: state.user.photoUrl != ""
                        ? Image.network(state.user.photoUrl)
                        : const Icon(
                            Icons.person,
                            size: 20,
                          ),
                  ),
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
                      state.user.name,
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: _buildSearchBar(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for a university',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textCapitalization: TextCapitalization.words,
        onChanged: (value) =>
            _debouncer.run(() => _rebuildUniversitiesStream(value)),
        onSubmitted: (value) => _rebuildUniversitiesStream(value),
      ),
    );
  }

  Widget _buildUniversityList() {
    return StreamBuilder<List<University>?>(
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
                  title: Text(university?.title ?? ''),
                  subtitle: Text(university?.region ?? ''),
                  leading: Image.network(
                    university?.logo ?? '',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {},
                  ),
                );
              },
              childCount: universities?.length,
            ),
          );
        } else if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
