import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/user_quick_profile.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/user_quick_profile_item.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/logger/logger.dart';

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
  final UserRepository userRepository = GetIt.I<UserRepository>();
  static const _pageSize = 20;
  final PagingController<int, UserQuickProfile> _pagingController =
      PagingController(firstPageKey: 0);
  final AppLoggerService _logger = GetIt.I<AppLoggerService>();

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          await userRepository.getUserQuickProfiles(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        _buildRefreshIndicator(),
        _buildUserList(),
      ],
    );
  }

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
          ),
        );
      },
    );
  }

  Widget _buildRefreshIndicator() {
    return CupertinoSliverRefreshControl(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
    );
  }

  Widget _buildUserList() {
    return PagedSliverList<int, UserQuickProfile>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<UserQuickProfile>(
        animateTransitions: true,
        transitionDuration: const Duration(milliseconds: 500),
        itemBuilder: (context, item, index) => UserQuickProfileItem(
          userQuickProfile: item,
        ),
        firstPageErrorIndicatorBuilder: (_) => Container(
          height: 100,
          child: const Center(
            child: Text('First Page Error'),
          ),
        ),
        newPageErrorIndicatorBuilder: (_) => Container(
          height: 100,
          child: const Center(
            child: Text('New Page Error'),
          ),
        ),
        firstPageProgressIndicatorBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        newPageProgressIndicatorBuilder: (_) => Container(
          height: 100,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        noItemsFoundIndicatorBuilder: (_) => Container(
          child: const Center(
            child: Text('No items found'),
          ),
        ),
        noMoreItemsIndicatorBuilder: (_) => Container(
          child: const Center(
            child: Text('No more items'),
          ),
        ),
      ),
    );
  }
}
