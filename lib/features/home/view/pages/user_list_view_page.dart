import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/home.dart';
import 'package:nesters/features/home/view/components/filter_page.dart';
import 'package:nesters/features/home/view/components/top_bar_action_button.dart';
import 'package:nesters/features/home/view/components/user_quick_profile_widget.dart';
import 'package:nesters/features/home/view/shimmer_home_view.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/features/user/request/bloc/request_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';
import 'package:nesters/constants/app_assets.dart';
import 'package:flutter_svg/svg.dart';

class UserListPage extends StatelessWidget {
  final GlobalKey chatIconKey;
  final GlobalKey requestIconKey;
  final GlobalKey settingsIconKey;
  const UserListPage(
      {super.key,
      required this.chatIconKey,
      required this.requestIconKey,
      required this.settingsIconKey});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        authRepository: GetIt.I<AuthRepository>(),
      ),
      child: Scaffold(
        body: SafeArea(
          child: UserListView(
            requestIconKey: requestIconKey,
            chatIconKey: chatIconKey,
            settingsIconKey: settingsIconKey,
          ),
        ),
      ),
    );
  }
}

class UserListView extends StatefulWidget {
  final GlobalKey chatIconKey;
  final GlobalKey requestIconKey;
  final GlobalKey settingsIconKey;
  const UserListView(
      {super.key,
      required this.chatIconKey,
      required this.requestIconKey,
      required this.settingsIconKey});
  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  final UserRepository userRepository = GetIt.I<UserRepository>();
  final PagingController<int, UserQuickProfile> _pagingController =
      PagingController(firstPageKey: 0);
  final int _pageSize = 20;
  final GlobalKey _tooltip = GlobalKey();

  @override
  void initState() {
    _addPageListener();
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void _addPageListener() {
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
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
        if (_tooltip.currentState is TooltipState &&
            !userRepository.checkSettingInfoComplete() &&
            userRepository.checkUserTutorialComplete()) {
          (_tooltip.currentState as TooltipState).ensureTooltipVisible();
          userRepository.updateSettingInfoStatus();
        }
      }
    } catch (error) {
      log(error.toString());
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
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.filterState.exception != null) {
            context.showErrorSnackBar(state.filterState.exception!.message);
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              state.userFilter != null || state.singleUserFilter != null
                  ? _buildFilteredUserList(
                      isAllowed: state.user?.isUserProfileComplete() ?? false,
                    )
                  : _buildUserList(
                      isAllowed: state.user?.isUserProfileComplete() ?? false,
                    )
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return BlocBuilder<HomeBloc, HomeState>(
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
                  Tooltip(
                    key: _tooltip,
                    richMessage: WidgetSpan(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: SvgPicture.asset(
                              AppVectorImages.arrowTooltip,
                              height: 6,
                              width: 6,
                              colorFilter: ColorFilter.mode(
                                AppTheme.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.onSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Click here to view settings',
                              style: AppTheme.bodySmall
                                  .copyWith(color: AppTheme.surface),
                            ),
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    preferBelow: true,
                    triggerMode: TooltipTriggerMode.manual,
                    child: CircleAvatar(
                      key: widget.settingsIconKey,
                      radius: 20,
                      backgroundColor: AppColor.white,
                      backgroundImage: const AssetImage(
                        'assets/images/user/user_placeholder.png',
                      ),
                      foregroundImage:
                          NetworkImage(state.user?.profileImage ?? ""),
                      child: state.user?.profileImage.isEmpty == true
                          ? const Icon(
                              Icons.person,
                              size: 20,
                            )
                          : null,
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
                        state.user?.fullName.toTitleCase ?? '',
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
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              children: [
                TopActionButton(
                  icon: Icons.filter,
                  title: 'Filter',
                  onPressed: () {
                    showFilterDialog(context, homeState, appState);
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
                                .title ??
                            ''
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
                          builder: (ctx) {
                            return BlocProvider.value(
                              value: context.read<AppBloc>(),
                              child: DraggableScrollableSheet(
                                expand: false,
                                builder: (ctx, scrollController) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 12, bottom: 16),
                                        child: Text(
                                          "Universities",
                                          style: AppTheme.titleLarge,
                                        ),
                                      ),
                                      UniversitiesLoader(
                                        builder: (BuildContext context,
                                            List<University> universities) {
                                          return Expanded(
                                            child: ListView.builder(
                                              controller: scrollController,
                                              itemCount: universities.length,
                                              itemBuilder: (context, index) {
                                                return UniversityFilterTile(
                                                  isSelected: false,
                                                  onTap: () {
                                                    Navigator.of(context).pop(
                                                        universities[index]);
                                                  },
                                                  university:
                                                      universities[index],
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                        ).then((value) {
                          if (value != null && value is University) {
                            context.read<HomeBloc>().add(
                                SingleAddFilterProfileEvent(
                                    UniversityFilter(value)));
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
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          enableDrag: true,
                          isDismissible: true,
                          scrollControlDisabledMaxHeightRatio: 0.5,
                          useSafeArea: true,
                          builder: (ctx) {
                            return DraggableScrollableSheet(
                              expand: false,
                              builder: (ctx, scrollController) {
                                return BlocProvider.value(
                                  value: context.read<AppBloc>(),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                      DegreesLoader(
                                        builder: (BuildContext context,
                                            List<Degree> degrees) {
                                          return Expanded(
                                            child: ListView.builder(
                                              controller: scrollController,
                                              itemCount: degrees.length,
                                              itemBuilder: (context, index) {
                                                return DegreeFilterTile(
                                                  isSelected: false,
                                                  onTap: () {
                                                    Navigator.of(context).pop(
                                                      degrees[index],
                                                    );
                                                  },
                                                  degree: degrees[index],
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
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

  Widget _buildUserList({
    required bool isAllowed,
  }) {
    return PagedSliverList<int, UserQuickProfile>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<UserQuickProfile>(
        animateTransitions: true,
        transitionDuration: const Duration(
          milliseconds: 500,
        ),
        itemBuilder: (context, item, index) => UserQuickProfileWidget(
          key: ValueKey(item.id),
          userQuickProfile: item,
          canNavigate: isAllowed,
        ),
        firstPageProgressIndicatorBuilder: (_) => const ShimmerHomePage(),
        firstPageErrorIndicatorBuilder: (_) => ShowErrorWidget(
          error: _pagingController.error,
        ),
        newPageErrorIndicatorBuilder: (_) => ShowErrorWidget(
          error: _pagingController.error,
        ),
        newPageProgressIndicatorBuilder: (_) => ShowErrorWidget(
          error: _pagingController.error,
          height: 300,
        ),
        noItemsFoundIndicatorBuilder: (_) => const ShowNoInfoWidget(
          title: 'No Profiles Found',
          subtitle:
              'There are no profiles at the moment, Please try again later.',
        ),
        noMoreItemsIndicatorBuilder: (_) => const SizedBox(height: 100),
      ),
    );
  }

  Widget _buildFilteredUserList({
    required bool isAllowed,
  }) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return state.filterState.isLoading
            ? const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : state.filterState.exception != null
                ? SliverFillRemaining(
                    child: ShowErrorWidget(
                      error: state.filterState.exception,
                    ),
                  )
                : state.filterState.isSuccess &&
                        state.filteredProfiles != null &&
                        (state.filteredProfiles?.isNotEmpty == true)
                    ? SliverList.builder(
                        itemCount: state.filteredProfiles!.length,
                        itemBuilder: (context, index) {
                          return UserQuickProfileWidget(
                            key: ValueKey(state.filteredProfiles![index].id),
                            userQuickProfile: state.filteredProfiles![index],
                            canNavigate: isAllowed,
                          );
                        },
                      )
                    : const SliverFillRemaining(
                        child: ShowNoInfoWidget(
                          title: 'No Profiles Found',
                          subtitle:
                              'There are no profiles matching the filter criteria. Please try again later.',
                        ),
                      );
      },
    );
  }

  void showFilterDialog(
      BuildContext context, HomeState state, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, updateState) {
            return BlocProvider.value(
              value: context.read<HomeBloc>(),
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, homeState) {
                  return UserFilterPage(
                    initialFilter: homeState.userFilter,
                    universities: appState.universities,
                    onApply: (filter) {
                      context
                          .read<HomeBloc>()
                          .add(AddFilterProfileEvent(filter));
                    },
                    onReset: () {
                      context.read<HomeBloc>().add(RemoveFilterProfileEvent());
                    },
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
