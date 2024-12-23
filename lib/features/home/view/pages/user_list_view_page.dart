import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/home.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/components/top_bar_action_button.dart';
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
          _buildTopActionsBar(),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return state.filteredProfiles != null
                  ? _buildFilteredUserList(state.filteredProfiles!)
                  : _buildUserList();
            },
          ),
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

  Widget _buildTopActionsBar() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  children: [
                    TopActionButton(
                      icon: Icons.filter,
                      title: 'Filter',
                      onPressed: () {},
                      isActive: false,
                    ),
                    if (homeState.singleUserFilter == null ||
                        homeState.singleUserFilter is UniversityFilter)
                      TopActionButton(
                        icon: Icons.school,
                        title: homeState.singleUserFilter is UniversityFilter
                            ? (homeState.singleUserFilter as UniversityFilter)
                                .university
                            : "University",
                        isActive:
                            homeState.singleUserFilter is UniversityFilter,
                        onPressed: () async {
                          if (homeState.singleUserFilter is UniversityFilter) {
                            context
                                .read<HomeBloc>()
                                .add(SingleRemoveFilterProfileEvent());
                          } else {
                            // open a modal bottom sheet
                            if (userState.universities.isEmpty) {
                              context
                                  .read<UserBloc>()
                                  .add(const UserEvent.loadUniversities());
                            }
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              enableDrag: true,
                              isDismissible: true,
                              scrollControlDisabledMaxHeightRatio: 0.5,
                              useSafeArea: true,
                              builder: (context) {
                                return DraggableScrollableSheet(
                                  expand: false,
                                  builder: (context, scrollController) {
                                    return SingleChildScrollView(
                                      controller: scrollController,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 12, bottom: 16),
                                              child: Text(
                                                "Universities",
                                                style: AppTheme.titleLarge,
                                              )),
                                          if (userState.universities.isEmpty)
                                            const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          else
                                            ...userState.universities
                                                .map((university) =>
                                                    UniversityFilterTile(
                                                      isSelected: false,
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop(university);
                                                      },
                                                      university: university!,
                                                    ))
                                                .toList(),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ).then((value) {
                              if (value != null && value is University) {
                                context.read<HomeBloc>().add(
                                    SingleAddFilterProfileEvent(
                                        UniversityFilter(value.title ?? '')));
                              }
                            });
                          }
                        },
                      ),
                    if (homeState.singleUserFilter == null ||
                        homeState.singleUserFilter is BranchFilter)
                      TopActionButton(
                        icon: Icons.book,
                        title: homeState.singleUserFilter is BranchFilter
                            ? (homeState.singleUserFilter as BranchFilter)
                                .branch
                            : "Branch",
                        onPressed: () async {
                          if (homeState.singleUserFilter is BranchFilter) {
                            context
                                .read<HomeBloc>()
                                .add(SingleRemoveFilterProfileEvent());
                          } else {
                            if (userState.degrees.isEmpty) {
                              context
                                  .read<UserBloc>()
                                  .add(const UserEvent.loadDegrees());
                            }
                            // open a modal bottom sheet
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              enableDrag: true,
                              isDismissible: true,
                              scrollControlDisabledMaxHeightRatio: 0.5,
                              useSafeArea: true,
                              builder: (context) {
                                return DraggableScrollableSheet(
                                  expand: false,
                                  builder: (context, scrollController) {
                                    return SingleChildScrollView(
                                      controller: scrollController,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12, bottom: 16),
                                            child: Text(
                                              "Branches",
                                              style: AppTheme.titleLarge,
                                            ),
                                          ),
                                          if (userState.degrees.isEmpty)
                                            const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          else
                                            ...userState.degrees
                                                .map((degree) =>
                                                    DegreeFilterTile(
                                                      isSelected: false,
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop(degree);
                                                      },
                                                      degree: degree!,
                                                    ))
                                                .toList()
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ).then((value) {
                              if (value != null && value is Degree) {
                                context.read<HomeBloc>().add(
                                    SingleAddFilterProfileEvent(
                                        BranchFilter(value.name)));
                              }
                            });
                          }
                        },
                        isActive: homeState.singleUserFilter is BranchFilter,
                      ),
                    if (homeState.singleUserFilter == null ||
                        homeState.singleUserFilter is GenderFilter)
                      TopActionButton(
                        icon: Icons.person,
                        title: homeState.singleUserFilter is GenderFilter
                            ? (homeState.singleUserFilter as GenderFilter)
                                .gender
                            : 'Gender',
                        onPressed: () async {
                          if (homeState.singleUserFilter is GenderFilter) {
                            context
                                .read<HomeBloc>()
                                .add(SingleRemoveFilterProfileEvent());
                          } else {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              enableDrag: true,
                              isDismissible: true,
                              useSafeArea: true,
                              builder: (context) {
                                return DraggableScrollableSheet(
                                  expand: false,
                                  initialChildSize: 0.3,
                                  builder: (context, scrollController) {
                                    return SingleChildScrollView(
                                      controller: scrollController,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12, bottom: 16),
                                            child: Text(
                                              "Gender",
                                              style: AppTheme.titleLarge,
                                            ),
                                          ),
                                          // male
                                          ListTile(
                                            title: const Text('Male'),
                                            leading: Icon(
                                              Icons.male,
                                              color:
                                                  AppTheme.greyShades.shade800,
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop('Male');
                                            },
                                          ),
                                          ListTile(
                                            title: const Text('Female'),
                                            onTap: () {
                                              Navigator.of(context)
                                                  .pop('Female');
                                            },
                                            leading: Icon(
                                              Icons.female,
                                              color:
                                                  AppTheme.greyShades.shade800,
                                            ),
                                          ),
                                          ListTile(
                                            title: const Text('Other'),
                                            onTap: () {
                                              Navigator.of(context)
                                                  .pop('Other');
                                            },
                                            leading: Icon(
                                              Icons.transgender,
                                              color:
                                                  AppTheme.greyShades.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ).then((value) {
                              if (value != null && value is String) {
                                context.read<HomeBloc>().add(
                                    SingleAddFilterProfileEvent(
                                        GenderFilter(value)));
                              }
                            });
                          }
                        },
                        isActive: homeState.singleUserFilter is GenderFilter,
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
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

  Widget _buildFilteredUserList(List<UserQuickProfile> profiles) {
    return SliverList.builder(
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        return UserQuickProfileWidget(
          userQuickProfile: profiles[index],
        );
      },
    );
  }
}

class UniversityFilterTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;
  final University university;
  const UniversityFilterTile({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColor.white,
                  child: ClipOval(
                    child: Image.network(
                      university.logo ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    university.title ?? '',
                    style: AppTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check,
                  )
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class DegreeFilterTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;
  final Degree degree;
  const DegreeFilterTile({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.degree,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    degree.name,
                    style: AppTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check,
                  )
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
