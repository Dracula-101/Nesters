import 'package:flutter/cupertino.dart';
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
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/home.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/components/top_bar_action_button.dart';
import 'package:nesters/features/home/view/components/user_quick_profile_widget.dart';
import 'package:nesters/features/home/view/shimmer_home_view.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/custom_flat_button.dart';

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
        //just a formality to notify the bloc that the profiles are loaded, pagination is handled by the paging controller library
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: SizedBox(
                height: 50,
                child: _buildTopActionsBar(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopActionsBar() {
    return BlocBuilder<HomeBloc, HomeState>(
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
                  onPressed: () {
                    showFilterDialog(context, homeState, userState);
                  },
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
                    isActive: homeState.singleUserFilter is UniversityFilter,
                    onPressed: () async {
                      if (homeState.singleUserFilter is UniversityFilter) {
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
                          scrollControlDisabledMaxHeightRatio: 0.5,
                          useSafeArea: true,
                          builder: (context) {
                            return DraggableScrollableSheet(
                              expand: false,
                              builder: (context, scrollController) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        child: CircularProgressIndicator(),
                                      )
                                    else
                                      Expanded(
                                        child: ListView.builder(
                                          controller: scrollController,
                                          itemCount:
                                              userState.universities.length,
                                          itemBuilder: (context, index) {
                                            return UniversityFilterTile(
                                              isSelected: false,
                                              onTap: () {
                                                Navigator.of(context).pop(
                                                  userState
                                                      .universities[index]!,
                                                );
                                              },
                                              university: userState
                                                  .universities[index]!,
                                            );
                                          },
                                        ),
                                      ),
                                  ],
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
                        ? (homeState.singleUserFilter as BranchFilter).branch
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
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        child: CircularProgressIndicator(),
                                      )
                                    else
                                      Expanded(
                                        child: ListView.builder(
                                          controller: scrollController,
                                          itemCount: userState.degrees.length,
                                          itemBuilder: (context, index) {
                                            return DegreeFilterTile(
                                              isSelected: false,
                                              onTap: () {
                                                Navigator.of(context).pop(
                                                  userState.degrees[index]!,
                                                );
                                              },
                                              degree: userState.degrees[index]!,
                                            );
                                          },
                                        ),
                                      ),
                                  ],
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
                        ? (homeState.singleUserFilter as GenderFilter).gender
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                          color: AppTheme.greyShades.shade800,
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pop('Male');
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Female'),
                                        onTap: () {
                                          Navigator.of(context).pop('Female');
                                        },
                                        leading: Icon(
                                          Icons.female,
                                          color: AppTheme.greyShades.shade800,
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('Other'),
                                        onTap: () {
                                          Navigator.of(context).pop('Other');
                                        },
                                        leading: Icon(
                                          Icons.transgender,
                                          color: AppTheme.greyShades.shade800,
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

  void showFilterDialog(
      BuildContext context, HomeState state, UserState userState) {
    UserFilterTypes userFilterTypeSelected = UserFilterTypes.University;
    String selectedUniversity = state.userFilter?.universityName ?? '';
    String selectedBranch = state.userFilter?.branchName ?? '';
    String selectedGender = state.userFilter?.gender ?? '';
    UserFoodHabit selectedEatingHabit =
        state.userFilter?.foodHabit ?? UserFoodHabit.UNKNOWN;
    UserHabit selectedSmokingHabit =
        state.userFilter?.smokingHabit ?? UserHabit.NEVER;
    UserHabit selectedDrinkingHabit =
        state.userFilter?.drinkingHabit ?? UserHabit.NEVER;
    UserRoomType selectedRoomType =
        state.userFilter?.roomType ?? UserRoomType.UNKNOWN;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return BlocProvider.value(
              value: context.read<HomeBloc>(),
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, homeState) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Material(
                      color: AppTheme.surface,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 4, left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Filters',
                                  style: AppTheme.titleLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  iconSize: 20,
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                )
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: [
                                        ...UserFilterTypes.values.map(
                                          (e) => filterTab(
                                            e.toString(),
                                            e == userFilterTypeSelected,
                                            onTap: () {
                                              setState(() {
                                                userFilterTypeSelected = e;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.65,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: AppTheme.greyShades.shade300,
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                          child: switch (
                                              userFilterTypeSelected) {
                                        UserFilterTypes.University =>
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                userState.universities.length,
                                            itemBuilder: (context, index) {
                                              return UniversityFilterTile(
                                                isSelected:
                                                    selectedUniversity ==
                                                        userState
                                                            .universities[
                                                                index]!
                                                            .title,
                                                isDense: true,
                                                onTap: () {
                                                  setState(() {
                                                    selectedUniversity =
                                                        userState
                                                                .universities[
                                                                    index]
                                                                ?.title ??
                                                            '';
                                                  });
                                                },
                                                university: userState
                                                    .universities[index]!,
                                              );
                                            },
                                          ),
                                        UserFilterTypes.Branch =>
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: userState.degrees.length,
                                            itemBuilder: (context, index) {
                                              return DegreeFilterTile(
                                                isSelected: selectedBranch ==
                                                    userState
                                                        .degrees[index]!.name,
                                                isDense: true,
                                                onTap: () {
                                                  setState(() {
                                                    selectedBranch = userState
                                                        .degrees[index]!.name;
                                                  });
                                                },
                                                degree:
                                                    userState.degrees[index]!,
                                              );
                                            },
                                          ),
                                        UserFilterTypes.Gender => ListView(
                                            children: [
                                              filterTile(
                                                'Male',
                                                selectedGender == 'Male',
                                                onTap: () {
                                                  setState(() {
                                                    selectedGender = 'Male';
                                                  });
                                                },
                                              ),
                                              filterTile(
                                                'Female',
                                                selectedGender == 'Female',
                                                onTap: () {
                                                  setState(() {
                                                    selectedGender = 'Female';
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        UserFilterTypes.EatingHabits =>
                                          ListView(
                                            children: [
                                              ...UserFoodHabit.toList().map(
                                                (e) => filterTile(
                                                  e
                                                      .toUserFriendlyString()
                                                      .capitalize,
                                                  selectedEatingHabit == e,
                                                  onTap: () {
                                                    setState(() {
                                                      selectedEatingHabit = e;
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        UserFilterTypes.SmokingHabits =>
                                          ListView(
                                            children: [
                                              ...UserHabit.toList().map(
                                                (e) => filterTile(
                                                  e.toString().capitalize,
                                                  selectedSmokingHabit == e,
                                                  onTap: () {
                                                    setState(() {
                                                      selectedSmokingHabit = e;
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        UserFilterTypes.DrinkingHabits =>
                                          ListView(
                                            children: [
                                              ...UserHabit.toList().map(
                                                (e) => filterTile(
                                                  e.toString().capitalize,
                                                  selectedDrinkingHabit == e,
                                                  onTap: () {
                                                    setState(() {
                                                      selectedDrinkingHabit = e;
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        UserFilterTypes.RoomType => ListView(
                                            children: [
                                              ...UserRoomType.toList().map(
                                                (e) => filterTile(
                                                  e.toUI(),
                                                  selectedRoomType == e,
                                                  onTap: () {
                                                    setState(() {
                                                      selectedRoomType = e;
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                      }),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                'Apply',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppColor.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget filterTile(
    String title,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Transform.scale(
            scale: 0.8,
            child: CupertinoCheckbox(
              activeColor: AppTheme.primary,
              value: isSelected,
              onChanged: (value) {
                onTap?.call();
              },
            ),
          ),
          Flexible(
            child: Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget filterTab(String title, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.greyShades.shade300,
            ),
            left: BorderSide(
              color: isSelected ? AppTheme.primary : Colors.transparent,
              width: isSelected ? 6 : 0,
            ),
            right: BorderSide(
              color: AppTheme.greyShades.shade300,
            ),
          ),
          color: !isSelected ? AppTheme.greyShades.shade100 : AppTheme.surface,
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UniversityFilterTile extends StatelessWidget {
  final bool isSelected;
  final bool isDense;
  final VoidCallback? onTap;
  final University university;
  const UniversityFilterTile({
    super.key,
    required this.isSelected,
    this.isDense = false,
    required this.onTap,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected && isDense
              ? AppTheme.primary.withOpacity(0.1)
              : AppTheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isDense && isSelected
                            ? Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppColor.white,
                                width: 2,
                              )
                            : null,
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColor.white,
                        child: ClipOval(
                          child: Image.network(
                            university.logo ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      university.title ?? '',
                      style: isDense
                          ? AppTheme.bodySmall.copyWith(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.bodyMedium.color,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            )
                          : AppTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected && !isDense)
                    const Icon(
                      Icons.check,
                    )
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class DegreeFilterTile extends StatelessWidget {
  final bool isSelected;
  final bool isDense;
  final VoidCallback? onTap;
  final Degree degree;
  const DegreeFilterTile({
    super.key,
    required this.isSelected,
    this.isDense = false,
    required this.onTap,
    required this.degree,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected && isDense
              ? AppTheme.primary.withOpacity(0.1)
              : AppTheme.surface,
        ),
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
                      style: isDense
                          ? AppTheme.bodySmall.copyWith(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.bodyMedium.color,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            )
                          : AppTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected && !isDense)
                    const Icon(
                      Icons.check,
                    )
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}

enum UserFilterTypes {
  University,
  Branch,
  Gender,
  EatingHabits,
  SmokingHabits,
  DrinkingHabits,
  RoomType;

  //to string
  @override
  String toString() {
    switch (this) {
      case UserFilterTypes.University:
        return 'University';
      case UserFilterTypes.Branch:
        return 'Branch';
      case UserFilterTypes.Gender:
        return 'Gender';
      case UserFilterTypes.EatingHabits:
        return 'Eating Habits';
      case UserFilterTypes.SmokingHabits:
        return 'Smoking Habits';
      case UserFilterTypes.DrinkingHabits:
        return 'Drinking Habits';
      case UserFilterTypes.RoomType:
        return 'Room Type';
    }
  }
}
