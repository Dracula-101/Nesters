import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/home.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/components/user_quick_profile_widget.dart';
import 'package:nesters/features/home/view/shimmer_home_view.dart';
import 'package:nesters/theme/theme.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final UserRepository userRepository = GetIt.I<UserRepository>();
  final PagingController<int, UserQuickProfile> _pagingController =
      PagingController(firstPageKey: 0);
  final int _pageSize = 20;

  @override
  void initState() {
    _addPageListener();
    super.initState();
  }

  void _addPageListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _fetchPage(
          pageKey,
        );
      },
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      String userId = context.read<AuthBloc>().state.maybeWhen(
            authenticated: (user) => user.id,
            orElse: () => throw Exception('User not authenticated'),
          );
      final newItems =
          await userRepository.getUserQuickProfiles(pageKey, _pageSize, userId);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
      if (mounted) {
        context
            .read<HomeBloc>()
            .add(LoadProfileCompleteEvent(_pagingController.itemList ?? []));
      }
    } on Exception catch (error) {
      _pagingController.error = error;
      if (mounted) {
        context.read<HomeBloc>().add(LoadProfileErrorEvent(error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      edgeOffset: const SliverAppBar().toolbarHeight * 1.3,
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildUserList(),
        ],
      ),
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
                  backgroundColor: AppColor.white,
                  backgroundImage: const AssetImage(
                    'assets/images/user/user_placeholder.png',
                  ),
                  child: ClipOval(
                    child: state.user.photoUrl != ''
                        ? Image.network(
                            state.user.photoUrl,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person,
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome,',
                      style: AppTheme.bodyLarge,
                    ),
                    Text(
                      state.user.fullName,
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
                  context.read<AuthBloc>().add(const AuthEvent.authSignOut());
                },
              ),
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.gear,
                  size: 20,
                ),
                onPressed: () {
                  GoRouter.of(context).go(
                    '${AppRouterService.homeScreen}/${AppRouterService.settings}',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList() {
    return PagedSliverList<int, UserQuickProfile>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<UserQuickProfile>(
        animateTransitions: true,
        transitionDuration: const Duration(milliseconds: 500),
        itemBuilder: (context, item, index) => UserQuickProfileWidget(
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
        firstPageProgressIndicatorBuilder: (_) => const ShimmerHomePage(),
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
