import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/constants/app_assets.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/domain/models/user/profile/user_filter.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/home.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/components/filter_tab.dart';
import 'package:nesters/features/home/view/components/filter_tile.dart';
import 'package:nesters/features/home/view/components/top_bar_action_button.dart';
import 'package:nesters/features/home/view/components/user_quick_profile_widget.dart';
import 'package:nesters/features/home/view/shimmer_home_view.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/features/user/request/bloc/request_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';
import 'package:nesters/utils/widgets/show_error_widget.dart';

class UserListPage extends StatefulWidget {
  final GlobalKey chatIconKey;
  final GlobalKey requestIconKey;
  final GlobalKey settingsIconKey;
  const UserListPage(
      {super.key,
      required this.chatIconKey,
      required this.requestIconKey,
      required this.settingsIconKey});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final UserRepository userRepository = GetIt.I<UserRepository>();
  final PagingController<int, UserQuickProfile> _pagingController =
      PagingController(firstPageKey: 0);
  final int _pageSize = 20;
  final TextEditingController intakeYearController = TextEditingController();
  @override
  void initState() {
    _addPageListener();
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    intakeYearController.dispose();
    super.dispose();
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
      log("Fetching page $pageKey, page size $_pageSize");
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
    } catch (error) {
      _pagingController.error = error;
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
            title: GestureDetector(
              onTap: () {
                GoRouter.of(context).go(
                  '${AppRouterService.homeScreen}/${AppRouterService.settings}',
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    key: widget.settingsIconKey,
                    radius: 20,
                    backgroundColor: AppColor.white,
                    backgroundImage: const AssetImage(
                      'assets/images/user/user_placeholder.png',
                    ),
                    foregroundImage: NetworkImage(state.user.photoUrl),
                    child: state.user.photoUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 20,
                          )
                        : null,
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
                        state.user.fullName.toTitleCase,
                        style: AppTheme.bodySmallLightVariant,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            actions: [
              BlocBuilder<RequestBloc, RequestState>(
                builder: (context, state) {
                  int count = state.requestReceivedUsers.fold(0,
                      (previousValue, element) {
                    if (!element.isAccepted && !element.isBanned) {
                      return (previousValue) + 1;
                    } else {
                      return previousValue;
                    }
                  });
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        key: widget.requestIconKey,
                        icon: Icon(
                          (count > 0)
                              ? Icons.notifications_active
                              : Icons.notifications_none_outlined,
                          size: 26,
                        ),
                        onPressed: () {
                          GoRouter.of(context).go(
                              '${AppRouterService.homeScreen}/${AppRouterService.userRequest}');
                        },
                      ),
                      if (count > 0)
                        Positioned(
                          top: 10,
                          right: 6,
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              StreamBuilder(
                stream: context
                    .read<CentralChatBloc>()
                    .showMessageNotificationStream(),
                builder: (context, snapshot) {
                  return IconButton(
                    onPressed: () {
                      GoRouter.of(context).go(
                          '${AppRouterService.homeScreen}/${AppRouterService.userChatHome}');
                    },
                    icon: Badge.count(
                      key: widget.chatIconKey,
                      count: snapshot.data ?? 0,
                      isLabelVisible:
                          snapshot.data != 0 && snapshot.data != null,
                      textStyle: AppTheme.labelSmall.copyWith(
                        fontSize: 10,
                      ),
                      offset: const Offset(10, -4),
                      child: Icon(
                        (snapshot.data != 0 && snapshot.data != null)
                            ? Icons.chat
                            : Icons.chat_outlined,
                        // weight: 10,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              //add some space to its right
              const SizedBox(
                width: 10,
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
                  isActive: homeState.userFilter != null,
                  closeIcon: false,
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
                                      ),
                                    ),
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
                                    BranchFilter(
                                      value.name,
                                    ),
                                  ),
                                );
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
        transitionDuration: const Duration(
          milliseconds: 500,
        ),
        itemBuilder: (context, item, index) => UserQuickProfileWidget(
          userQuickProfile: item,
        ),
        firstPageProgressIndicatorBuilder: (_) => const ShimmerHomePage(),
        firstPageErrorIndicatorBuilder: (_) => SizedBox(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Image.asset(
                AppRasterImages.emptyIcon,
                width: 100.0,
                height: 100.0,
              ),
            ),
          ),
        ),
        newPageErrorIndicatorBuilder: (_) => SizedBox(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Image.asset(
                AppRasterImages.endIcon,
                width: 50.0,
                height: 50.0,
              ),
            ),
          ),
        ),
        newPageProgressIndicatorBuilder: (_) => const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        noItemsFoundIndicatorBuilder: (_) => SizedBox(
          child: Center(
            child: Image.asset(
              AppRasterImages.emptyIcon,
              width: 100.0,
              height: 100.0,
            ),
          ),
        ),
        noMoreItemsIndicatorBuilder: (_) => SizedBox(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Image.asset(
                AppRasterImages.endIcon,
                width: 50.0,
                height: 50.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredUserList(List<UserQuickProfile> profiles) {
    if (profiles.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Image.asset(
            AppRasterImages.emptyIcon,
            width: 100.0,
            height: 100.0,
          ),
        ),
      );
    }
    return SliverList.builder(
      itemCount: profiles.length + 1, // Increase itemCount by 1
      itemBuilder: (context, index) {
        if (index < profiles.length) {
          return UserQuickProfileWidget(
            userQuickProfile: profiles[index],
          );
        } else {
          // Add your custom widget at the end
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Image.asset(
              AppRasterImages.endIcon,
              width: 50.0,
              height: 50.0,
            ),
          );
        }
      },
    );
  }

  void showFilterDialog(
      BuildContext context, HomeState state, UserState userState) {
    UserFilterTypes userFilterTypeSelected = UserFilterTypes.University;
    String selectedUniversity = state.userFilter?.universityName ?? '';
    String selectedBranch = state.userFilter?.branchName ?? '';
    String selectedIntakePeriod = state.userFilter?.intakePeriod ?? '';
    String selectedGender = state.userFilter?.flatmateGenderPref ?? '';
    UserFoodHabit selectedEatingHabit =
        state.userFilter?.foodHabit ?? UserFoodHabit.UNKNOWN;
    UserHabit selectedSmokingHabit =
        state.userFilter?.smokingHabit ?? UserHabit.UNKNOWN;
    UserHabit selectedDrinkingHabit =
        state.userFilter?.drinkingHabit ?? UserHabit.UNKNOWN;
    UserRoomType selectedRoomType =
        state.userFilter?.roomType ?? UserRoomType.UNKNOWN;
    List<University?> filterUniversities = userState.universities;
    DateTime selectedYearDateTime = DateTime.now();
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
                                          (e) => FilterTab(
                                            title: e.toString(),
                                            isSelected:
                                                e == userFilterTypeSelected,
                                            onTap: () {
                                              setState(
                                                () {
                                                  userFilterTypeSelected = e;
                                                },
                                              );
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
                                      child: SizedBox(
                                          child: switch (
                                              userFilterTypeSelected) {
                                        UserFilterTypes.University => Column(
                                            children: [
                                              TextField(
                                                decoration: InputDecoration(
                                                  hintText: 'Search University',
                                                  hintStyle: AppTheme.bodySmall,
                                                  prefixIcon: Icon(
                                                    Icons.search,
                                                    color: AppTheme
                                                        .greyShades.shade800,
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets.all(8),
                                                  isDense: true,
                                                ),
                                                onChanged: (value) {
                                                  if (value == "") {
                                                    setState(() {
                                                      filterUniversities =
                                                          userState
                                                              .universities;
                                                    });
                                                  } else {
                                                    setState(
                                                      () {
                                                        filterUniversities = userState
                                                            .universities
                                                            .where((element) =>
                                                                element?.title
                                                                    ?.toLowerCase()
                                                                    .contains(
                                                                      value
                                                                          .toLowerCase(),
                                                                    ) ??
                                                                false)
                                                            .toList();
                                                      },
                                                    );
                                                  }
                                                },
                                              ),
                                              const Divider(
                                                height: 1,
                                                thickness: 1,
                                              ),
                                              Expanded(
                                                  child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    filterUniversities.length,
                                                itemBuilder: (context, index) {
                                                  return UniversityFilterTile(
                                                    isSelected:
                                                        selectedUniversity ==
                                                            filterUniversities[
                                                                    index]
                                                                ?.title,
                                                    isDense: true,
                                                    onTap: () {
                                                      setState(() {
                                                        selectedUniversity =
                                                            filterUniversities[
                                                                        index]
                                                                    ?.title ??
                                                                '';
                                                      });
                                                    },
                                                    university:
                                                        filterUniversities[
                                                            index]!,
                                                  );
                                                },
                                              ))
                                            ],
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
                                        UserFilterTypes.IntakePeriod =>
                                          ListView(
                                            children: [
                                              FilterTile(
                                                title: 'Fall',
                                                isSelected:
                                                    selectedIntakePeriod ==
                                                        'Fall',
                                                onTap: () {
                                                  setState(() {
                                                    selectedIntakePeriod =
                                                        'Fall';
                                                  });
                                                },
                                              ),
                                              FilterTile(
                                                title: 'Spring',
                                                isSelected:
                                                    selectedIntakePeriod ==
                                                        'Spring',
                                                onTap: () {
                                                  setState(() {
                                                    selectedIntakePeriod =
                                                        'Spring';
                                                  });
                                                },
                                              ),
                                              FilterTile(
                                                title: 'Summer',
                                                isSelected:
                                                    selectedIntakePeriod ==
                                                        'Summer',
                                                onTap: () {
                                                  setState(() {
                                                    selectedIntakePeriod =
                                                        'Summer';
                                                  });
                                                },
                                              ),
                                              FilterTile(
                                                title: 'Winter',
                                                isSelected:
                                                    selectedIntakePeriod ==
                                                        'Winter',
                                                onTap: () {
                                                  setState(() {
                                                    selectedIntakePeriod =
                                                        'Winter';
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        UserFilterTypes.IntakeYear =>
                                          CustomTextField(
                                            controller: intakeYearController,
                                            hintText: 'Intake Year',
                                            labelText: '2025',
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Intake Year';
                                              }
                                              return null;
                                            },
                                            enabled: false,
                                            onTap: () async {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Select Year"),
                                                    content: SizedBox(
                                                      width: 300,
                                                      height: 300,
                                                      child: YearPicker(
                                                        firstDate: DateTime(
                                                            DateTime.now()
                                                                    .year -
                                                                100,
                                                            1),
                                                        lastDate: DateTime(
                                                            DateTime.now()
                                                                    .year +
                                                                100,
                                                            1),
                                                        selectedDate:
                                                            selectedYearDateTime,
                                                        onChanged: (DateTime
                                                            dateTime) {
                                                          Navigator.pop(
                                                              context);
                                                          intakeYearController
                                                                  .text =
                                                              dateTime.year
                                                                  .toString();
                                                          selectedYearDateTime =
                                                              dateTime;
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        UserFilterTypes.Gender => ListView(
                                            children: [
                                              FilterTile(
                                                title: 'Male',
                                                isSelected:
                                                    selectedGender == 'Male',
                                                onTap: () {
                                                  setState(() {
                                                    selectedGender = 'Male';
                                                  });
                                                },
                                              ),
                                              FilterTile(
                                                title: 'Female',
                                                isSelected:
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
                                                (e) => FilterTile(
                                                  title: e
                                                      .toUserFriendlyString()
                                                      .capitalize,
                                                  isSelected:
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
                                                (e) => FilterTile(
                                                  title:
                                                      e.toString().capitalize,
                                                  isSelected:
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
                                                (e) => FilterTile(
                                                  title:
                                                      e.toString().capitalize,
                                                  isSelected:
                                                      selectedDrinkingHabit ==
                                                          e,
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
                                                (e) => FilterTile(
                                                  title: e.toUI(),
                                                  isSelected:
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<HomeBloc>()
                                        .add(RemoveFilterProfileEvent());
                                    Navigator.of(ctx).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.error,
                                  ),
                                  child: Text(
                                    'Reset',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.onError,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final filter = UserFilter(
                                      universityName: selectedUniversity,
                                      branchName: selectedBranch,
                                      drinkingHabit: selectedDrinkingHabit,
                                      foodHabit: selectedEatingHabit,
                                      flatmateGenderPref: selectedGender,
                                      roomType: selectedRoomType,
                                      smokingHabit: selectedSmokingHabit,
                                      intakePeriod: selectedIntakePeriod,
                                      intakeYear:
                                          intakeYearController.text == ""
                                              ? null
                                              : int.parse(
                                                  intakeYearController.text,
                                                ),
                                    );
                                    context.read<HomeBloc>().add(
                                          AddFilterProfileEvent(
                                            filter,
                                          ),
                                        );
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text(
                                    'Apply',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppColor.white,
                                    ),
                                  ),
                                )
                              ],
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
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.error_outline_rounded,
                                color: AppTheme.error,
                                size: 16,
                              );
                            },
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
  IntakePeriod,
  IntakeYear,
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
      case UserFilterTypes.IntakePeriod:
        return 'Intake Period';
      case UserFilterTypes.IntakeYear:
        return 'Intake Year';
    }
  }
}
