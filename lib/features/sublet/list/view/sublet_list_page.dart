import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/constants/app_assets.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/sublet/sublet_filter.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/home/bloc/home_bloc.dart';
import 'package:nesters/features/home/view/components/filter_tab.dart';
import 'package:nesters/features/home/view/components/filter_tile.dart';
import 'package:nesters/features/sublet/list/bloc/sublet_bloc.dart';
import 'package:nesters/features/sublet/list/view/components/sublet_list_widget.dart';
import 'package:nesters/features/sublet/list/view/shimmer_sublet_list_page.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/components/top_bar_action_button.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class SubletListPage extends StatelessWidget {
  const SubletListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).go(
            '${AppRouterService.homeScreen}/${AppRouterService.sublettingForm}',
          );
        },
        child: const Icon(Icons.add),
      ),
      body: const SafeArea(
        child: SubletListView(),
      ),
    );
  }
}

class SubletListView extends StatefulWidget {
  const SubletListView({super.key});

  @override
  State<SubletListView> createState() => _SubletListViewState();
}

class _SubletListViewState extends State<SubletListView> {
  final PagingController<int, SubletModel> _pagingController =
      PagingController(firstPageKey: 0);
  final SubletRepository _subletRepository = GetIt.I<SubletRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();
  final int _pageSize = 10;

  Future<void> loadSublets(int pageKey) async {
    try {
      _logger.info('Loading sublets for page $pageKey');
      final List<SubletModel> sublets = await _subletRepository.getSublets(
        userId: _authRepository.currentUser!.id,
        paginationKey: pageKey,
      );
      final isLastPage = sublets.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(sublets);
      } else {
        _pagingController.appendPage(sublets, pageKey + _pageSize);
      }
      // ignore: use_build_context_synchronously
      context
          .read<SubletBloc>()
          .add(SubletEvent.saveSublets(_pagingController.itemList ?? []));
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      loadSublets(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubletBloc, SubletState>(
      builder: (context, state) {
        return RefreshIndicator(
          child: CustomScrollView(
            slivers: [
              _buildFilterBar(),
              if (state.singleSubletFilter != null ||
                  state.subletFilter != null)
                if (state.filteredSubletList?.isNotEmpty ?? false)
                  _buildFilteredSublets(state.filteredSubletList!)
                else
                  SliverFillRemaining(
                    child: Center(
                      child: Image.asset(
                        AppRasterImages.emptyIcon,
                        width: 100.0,
                        height: 100.0,
                      ),
                    ),
                  )
              else
                _buildSubletList(state.subletList ?? []),
            ],
          ),
          onRefresh: () {
            _pagingController.refresh();
            return Future<void>.value();
          },
        );
      },
    );
  }

  Widget _buildErrorIndicator(Exception error) {
    return Center(
      child: Text('Error: $error'),
    );
  }

  Widget _buildFilteredSublets(List<SubletModel> sublets) {
    return SliverList.builder(
      itemCount: sublets.length + 1,
      itemBuilder: (context, index) {
        if (index < sublets.length) {
          return SubletModelWidget(
            onPressed: () {
              GoRouter.of(context).go(
                '${AppRouterService.homeScreen}/${AppRouterService.subletDetail}',
                extra: sublets[index],
              );
            },
            actionOnFavourite: (isFavourite) {
              return _subletRepository.updateLikeStatus(
                userId: _authRepository.currentUser!.id,
                subletId: sublets[index].id,
                isLiked: isFavourite,
              );
            },
            sublet: sublets[index],
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Image.asset(
            AppRasterImages.endIcon,
            width: 50.0,
            height: 50.0,
          ),
        );
      },
    );
  }

  Widget _buildSubletList(List<SubletModel> sublets) {
    return PagedSliverList(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<SubletModel>(
        firstPageProgressIndicatorBuilder: (context) =>
            const ShimmerSubletPage(),
        firstPageErrorIndicatorBuilder: (context) =>
            _buildErrorIndicator(_pagingController.error),
        newPageProgressIndicatorBuilder: (_) => const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        newPageErrorIndicatorBuilder: (_) => SizedBox(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Image.asset(
                AppRasterImages.emptyIcon,
                width: 50.0,
                height: 50.0,
              ),
            ),
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
        itemBuilder: (context, sublet, index) {
          return SubletModelWidget(
            onPressed: () {
              GoRouter.of(context).go(
                '${AppRouterService.homeScreen}/${AppRouterService.subletDetail}',
                extra: sublet,
              );
            },
            actionOnFavourite: (isFavourite) {
              return _subletRepository.updateLikeStatus(
                userId: _authRepository.currentUser!.id,
                subletId: sublet.id,
                isLiked: isFavourite,
              );
            },
            sublet: sublet,
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    // rent, gender pref, apartment size,
    double rentStart = 0;
    double rentEnd = 10000;
    int apartmentSizeBeds = 1;
    int apartmentSizeBaths = 1;
    return SliverAppBar(
        pinned: true,
        collapsedHeight: kToolbarHeight,
        titleSpacing: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
          ),
        ),
        title: SizedBox(
          height: 50,
          child: BlocBuilder<SubletBloc, SubletState>(
            builder: (context, subletState) {
              return BlocBuilder<UserBloc, UserState>(
                builder: (context, userState) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    scrollDirection: Axis.horizontal,
                    children: [
                      TopActionButton(
                        icon: Icons.filter,
                        title: 'Filter',
                        onPressed: () {
                          showFilterDialog(context, subletState);
                        },
                        isActive: subletState.subletFilter != null,
                        closeIcon: false,
                      ),
                      if (subletState.singleSubletFilter == null ||
                          subletState.singleSubletFilter is RentFilter)
                        TopActionButton(
                          icon: Icons.person,
                          title: subletState.singleSubletFilter is RentFilter
                              ? "${(subletState.singleSubletFilter as RentFilter).startRent} - ${(subletState.singleSubletFilter as RentFilter).endRent}"
                              : "Rent",
                          isActive:
                              subletState.singleSubletFilter is RentFilter,
                          onPressed: () async {
                            if (subletState.singleSubletFilter is RentFilter) {
                              context
                                  .read<SubletBloc>()
                                  .add(const SubletEvent.removeSingleFilter());
                            } else {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                showDragHandle: true,
                                enableDrag: true,
                                isDismissible: true,
                                scrollControlDisabledMaxHeightRatio: 0.3,
                                useSafeArea: true,
                                builder: (ctx) {
                                  return DraggableScrollableSheet(
                                    expand: false,
                                    minChildSize: 0.15,
                                    initialChildSize: 0.2,
                                    maxChildSize: 0.2,
                                    builder: (ctx, scrollController) {
                                      return StatefulBuilder(
                                        builder: (ctx, setState) {
                                          return SingleChildScrollView(
                                            controller: scrollController,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Min: ${rentStart.toInt()}",
                                                        style:
                                                            AppTheme.bodyLarge,
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "Max: ${rentEnd.toInt()}",
                                                        style:
                                                            AppTheme.bodyLarge,
                                                      ),
                                                    ],
                                                  ),
                                                  // to avoid the default padding of the slider
                                                  Transform.scale(
                                                    scale: 1.1,
                                                    child: RangeSlider(
                                                      values: RangeValues(
                                                          rentStart, rentEnd),
                                                      onChanged:
                                                          (RangeValues values) {
                                                        setState(() {
                                                          rentStart =
                                                              values.start;
                                                          rentEnd = values.end;
                                                        });
                                                      },
                                                      min: 0,
                                                      max: 10000,
                                                      divisions: 100,
                                                    ),
                                                  ),
                                                  CustomFlatButton(
                                                    onPressed: () {
                                                      context
                                                          .read<SubletBloc>()
                                                          .add(SubletEvent
                                                              .addSingleFilter(
                                                                  RentFilter(
                                                                      rentStart
                                                                          .toInt(),
                                                                      rentEnd
                                                                          .toInt())));
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    text: "Apply",
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                        ),
                      if (subletState.singleSubletFilter == null ||
                          subletState.singleSubletFilter is ApartmentSizeFilter)
                        TopActionButton(
                          icon: Icons.bed,
                          title: subletState.singleSubletFilter
                                  is ApartmentSizeFilter
                              ? (subletState.singleSubletFilter
                                      as ApartmentSizeFilter)
                                  .apartmentSize
                                  .toFormattedString()
                              : "Size",
                          onPressed: () async {
                            if (subletState.singleSubletFilter
                                is ApartmentSizeFilter) {
                              context
                                  .read<SubletBloc>()
                                  .add(const SubletEvent.removeSingleFilter());
                            } else {
                              // open a modal bottom sheet
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
                                    initialChildSize: 0.35,
                                    maxChildSize: 0.35,
                                    builder: (ctx, scrollController) {
                                      return StatefulBuilder(
                                          builder: (ctx, setState) {
                                        return SingleChildScrollView(
                                          controller: scrollController,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Apartment Size",
                                                  style: AppTheme.titleLarge,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  "Beds: $apartmentSizeBeds",
                                                  style: AppTheme.bodyLarge,
                                                ),
                                                Transform.scale(
                                                  scale: 1.1,
                                                  child: Slider(
                                                    value: apartmentSizeBeds
                                                        .toDouble(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        apartmentSizeBeds =
                                                            value.toInt();
                                                      });
                                                    },
                                                    min: 1,
                                                    max: 6,
                                                  ),
                                                ),
                                                Text(
                                                  "Baths: $apartmentSizeBaths",
                                                  style: AppTheme.bodyLarge,
                                                ),
                                                Transform.scale(
                                                  scale: 1.1,
                                                  child: Slider(
                                                    value: apartmentSizeBaths
                                                        .toDouble(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        apartmentSizeBaths =
                                                            value.toInt();
                                                      });
                                                    },
                                                    min: 1,
                                                    max: 6,
                                                  ),
                                                ),
                                                CustomFlatButton(
                                                  text: "Apply",
                                                  onPressed: () {
                                                    context
                                                        .read<SubletBloc>()
                                                        .add(SubletEvent
                                                            .addSingleFilter(
                                                                ApartmentSizeFilter(
                                                                    ApartmentSize(
                                                          baths:
                                                              apartmentSizeBaths,
                                                          beds:
                                                              apartmentSizeBeds,
                                                        ))));
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                  );
                                },
                              );
                            }
                          },
                          isActive: subletState.singleSubletFilter
                              is ApartmentSizeFilter,
                        ),
                      if (subletState.singleSubletFilter == null ||
                          subletState.singleSubletFilter is ApartmentTypeFilter)
                        TopActionButton(
                          icon: Icons.apartment,
                          title: subletState.singleSubletFilter
                                  is ApartmentTypeFilter
                              ? (subletState.singleSubletFilter
                                      as ApartmentTypeFilter)
                                  .apartmentType
                                  .toUI()
                              : "Type",
                          onPressed: () async {
                            if (subletState.singleSubletFilter
                                is ApartmentTypeFilter) {
                              context
                                  .read<SubletBloc>()
                                  .add(const SubletEvent.removeSingleFilter());
                            } else {
                              // open a modal bottom sheet
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
                                    initialChildSize: 0.35,
                                    maxChildSize: 0.35,
                                    builder: (ctx, scrollController) {
                                      return StatefulBuilder(
                                          builder: (ctx, setState) {
                                        return SingleChildScrollView(
                                          controller: scrollController,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Apartment Type",
                                                  style: AppTheme.titleLarge,
                                                ),
                                                const SizedBox(height: 16),
                                                ListTile(
                                                  title: const Text('Private'),
                                                  onTap: () {
                                                    context.read<SubletBloc>().add(
                                                        SubletEvent.addSingleFilter(
                                                            ApartmentTypeFilter(
                                                                UserRoomType
                                                                    .PRIVATE)));
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                ListTile(
                                                  title: const Text('Shared'),
                                                  onTap: () {
                                                    context.read<SubletBloc>().add(
                                                        SubletEvent.addSingleFilter(
                                                            ApartmentTypeFilter(
                                                                UserRoomType
                                                                    .SHARED)));
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                ListTile(
                                                  title: const Text('Flex'),
                                                  onTap: () {
                                                    context
                                                        .read<SubletBloc>()
                                                        .add(SubletEvent
                                                            .addSingleFilter(
                                                                ApartmentTypeFilter(
                                                                    UserRoomType
                                                                        .FLEX)));
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                  );
                                },
                              );
                            }
                          },
                          isActive: subletState.singleSubletFilter
                              is ApartmentTypeFilter,
                        ),
                      if (subletState.singleSubletFilter == null ||
                          subletState.singleSubletFilter
                              is GenderPreferenceFilter)
                        TopActionButton(
                          icon: Icons.person,
                          title: subletState.singleSubletFilter
                                  is GenderPreferenceFilter
                              ? (subletState.singleSubletFilter
                                      as GenderPreferenceFilter)
                                  .preferredGender
                              : "Gender Pref",
                          isActive: subletState.singleSubletFilter
                              is GenderPreferenceFilter,
                          onPressed: () async {
                            if (subletState.singleSubletFilter
                                is GenderPreferenceFilter) {
                              context
                                  .read<SubletBloc>()
                                  .add(const SubletEvent.removeSingleFilter());
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
                                    initialChildSize: 0.25,
                                    maxChildSize: 0.25,
                                    minChildSize: 0.25,
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
                                                "Gender Preference for Sublet",
                                                style: AppTheme.titleLarge,
                                              ),
                                            ),
                                            // male
                                            ListTile(
                                              title: const Text('Male'),
                                              leading: Icon(
                                                Icons.male,
                                                color: AppTheme
                                                    .greyShades.shade800,
                                              ),
                                              onTap: () {
                                                Navigator.of(context)
                                                    .pop('Male');
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
                                                color: AppTheme
                                                    .greyShades.shade800,
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
                                  context.read<SubletBloc>().add(
                                      SubletEvent.addSingleFilter(
                                          GenderPreferenceFilter(value)));
                                }
                              });
                            }
                          },
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ));
  }

  void showFilterDialog(BuildContext context, SubletState state) {
    SubletFilterTypes subletFilterTypeSelected =
        SubletFilterTypes.RoomateGenderPref;
    String? selectedGender = state.subletFilter?.roommateGenderPref ?? '';
    double? rentStart = state.subletFilter?.startRent?.toDouble();
    double? rentEnd = state.subletFilter?.endRent?.toDouble();
    LeasePeriod? selectedLeasePeriod = state.subletFilter?.leasePeriod;
    Map<AmenitiesType, bool> selectedAmenities =
        state.subletFilter?.amenitiesAvailable?.toMapAmenitiesTypes() ?? {};
    ApartmentSize? selectedApartmentSize = state.subletFilter?.apartmentSize;
    UserRoomType? selectedRoomType = state.subletFilter?.roomType;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return BlocProvider.value(
              value: context.read<HomeBloc>(),
              child: BlocProvider.value(
                  value: context.read<SubletBloc>(),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                            ...SubletFilterTypes.values.map(
                                              (e) => FilterTab(
                                                title: e.toString(),
                                                isSelected: e ==
                                                    subletFilterTypeSelected,
                                                onTap: () {
                                                  setState(() {
                                                    subletFilterTypeSelected =
                                                        e;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.65,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: AppTheme
                                                    .greyShades.shade300,
                                              ),
                                            ),
                                          ),
                                          child: Container(
                                            child: switch (
                                                subletFilterTypeSelected) {
                                              SubletFilterTypes
                                                    .RoomateGenderPref =>
                                                ListView(
                                                  children: [
                                                    FilterTile(
                                                      title: "Male",
                                                      isSelected:
                                                          selectedGender ==
                                                              'Male',
                                                      onTap: () {
                                                        setState(() {
                                                          selectedGender =
                                                              "Male";
                                                        });
                                                      },
                                                    ),
                                                    FilterTile(
                                                      title: "Female",
                                                      isSelected:
                                                          selectedGender ==
                                                              'Female',
                                                      onTap: () {
                                                        setState(() {
                                                          selectedGender =
                                                              "Female";
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              SubletFilterTypes.Rent => Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Start Rent",
                                                            style: AppTheme
                                                                .titleSmall,
                                                          ),
                                                          const Spacer(),
                                                          GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (ctx) {
                                                                    return CustomValuePicker(
                                                                      // 100 to 10000 with 100 increment
                                                                      values: List.generate(
                                                                          100,
                                                                          (index) => (100 + (index * 100))
                                                                              .toInt()
                                                                              .toString()),
                                                                      title:
                                                                          "Select Start Rent",
                                                                    );
                                                                  }).then((value) {
                                                                if (value !=
                                                                    null) {
                                                                  setState(() {
                                                                    rentStart =
                                                                        double.parse(
                                                                            value);
                                                                  });
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: AppTheme
                                                                      .greyShades
                                                                      .shade300,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: Text(
                                                                (rentStart ==
                                                                        null)
                                                                    ? "Select"
                                                                    : "\$$rentStart",
                                                                style: AppTheme
                                                                    .bodySmall,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "End Rent",
                                                            style: AppTheme
                                                                .titleSmall
                                                                .copyWith(
                                                              color: rentStart ==
                                                                      null
                                                                  ? AppTheme
                                                                      .greyShades
                                                                      .shade400
                                                                  : AppTheme
                                                                      .onSurface,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          GestureDetector(
                                                            onTap: () {
                                                              if (rentStart ==
                                                                  null) {
                                                                return;
                                                              }
                                                              showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (ctx) {
                                                                        return CustomValuePicker(
                                                                          // 100 to 10000 with 100 increment
                                                                          values: List.generate(
                                                                              rentStart != null ? rentStart!.toInt() : 100,
                                                                              (index) => ((rentStart ?? 100) + (index * 100)).toInt().toString()),
                                                                          title:
                                                                              "Select End Rent",
                                                                        );
                                                                      })
                                                                  .then(
                                                                      (value) {
                                                                if (value !=
                                                                    null) {
                                                                  setState(() {
                                                                    rentEnd = double
                                                                        .parse(
                                                                            value);
                                                                  });
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: AppTheme
                                                                      .greyShades
                                                                      .shade300,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: Text(
                                                                (rentEnd !=
                                                                        null)
                                                                    ? "\$$rentEnd"
                                                                    : "Select",
                                                                style: AppTheme
                                                                    .bodySmall
                                                                    .copyWith(
                                                                  color: rentStart ==
                                                                          null
                                                                      ? AppTheme
                                                                          .greyShades
                                                                          .shade400
                                                                      : AppTheme
                                                                          .onSurface,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              SubletFilterTypes.ApartmentSize =>
                                                ListView(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 4),
                                                      child: Text(
                                                        "No of Beds: ${selectedApartmentSize?.beds ?? "1"}",
                                                        style: AppTheme
                                                            .titleMedium,
                                                      ),
                                                    ),
                                                    Slider(
                                                      value:
                                                          selectedApartmentSize
                                                                  ?.beds
                                                                  ?.toDouble() ??
                                                              1,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedApartmentSize =
                                                              ApartmentSize(
                                                            beds: value.toInt(),
                                                            baths:
                                                                selectedApartmentSize
                                                                        ?.baths ??
                                                                    1,
                                                          );
                                                        });
                                                      },
                                                      min: 1,
                                                      max: 5,
                                                      divisions: 100,
                                                    ),
                                                    const Divider(
                                                      height: 1,
                                                      thickness: 1,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 4),
                                                      child: Text(
                                                        "No of Baths: ${selectedApartmentSize?.baths ?? "1"}",
                                                        style: AppTheme
                                                            .titleMedium,
                                                      ),
                                                    ),
                                                    Slider(
                                                      value:
                                                          selectedApartmentSize
                                                                  ?.baths
                                                                  ?.toDouble() ??
                                                              1,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedApartmentSize =
                                                              ApartmentSize(
                                                            baths:
                                                                value.toInt(),
                                                            beds:
                                                                selectedApartmentSize
                                                                        ?.beds ??
                                                                    1,
                                                          );
                                                        });
                                                      },
                                                      min: 1,
                                                      max: 5,
                                                      divisions: 100,
                                                    )
                                                  ],
                                                ),
                                              SubletFilterTypes.RoomType =>
                                                ListView(
                                                  children: [
                                                    ...UserRoomType.toList()
                                                        .map(
                                                      (e) => FilterTile(
                                                        title: e.toUI(),
                                                        isSelected:
                                                            selectedRoomType ==
                                                                e,
                                                        onTap: () {
                                                          setState(() {
                                                            selectedRoomType =
                                                                e;
                                                          });
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              SubletFilterTypes.LeasePeriods =>
                                                ListView(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 4),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Start Date",
                                                            style: AppTheme
                                                                .titleSmall,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              showDatePicker(
                                                                context:
                                                                    context,
                                                                initialDate:
                                                                    DateTime
                                                                        .now(),
                                                                lastDate: selectedLeasePeriod
                                                                        ?.endDate ??
                                                                    DateTime.now().add(
                                                                        const Duration(
                                                                            days:
                                                                                365)),
                                                                firstDate:
                                                                    DateTime
                                                                        .now(),
                                                              ).then((value) {
                                                                if (value !=
                                                                    null) {
                                                                  setState(() {
                                                                    selectedLeasePeriod =
                                                                        LeasePeriod(
                                                                      startDate:
                                                                          value,
                                                                      endDate:
                                                                          selectedLeasePeriod
                                                                              ?.endDate,
                                                                    );
                                                                  });
                                                                }
                                                              });
                                                            },
                                                            child: selectedLeasePeriod
                                                                        ?.startDate !=
                                                                    null
                                                                ? Text(
                                                                    "${selectedLeasePeriod?.startDate!.day}, ${selectedLeasePeriod?.startDate!.monthName(true)}, ${selectedLeasePeriod?.startDate!.year}",
                                                                    style: AppTheme
                                                                        .bodySmall,
                                                                  )
                                                                : Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: AppTheme
                                                                            .greyShades
                                                                            .shade300,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    child: Text(
                                                                      "Select",
                                                                      style: AppTheme
                                                                          .bodySmall,
                                                                    ),
                                                                  ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 4),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "End Date",
                                                            style: AppTheme
                                                                .titleSmall,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              showDatePicker(
                                                                context:
                                                                    context,
                                                                initialDate:
                                                                    selectedLeasePeriod
                                                                            ?.startDate ??
                                                                        DateTime
                                                                            .now(),
                                                                lastDate: DateTime
                                                                        .now()
                                                                    .add(const Duration(
                                                                        days:
                                                                            365)),
                                                                firstDate: selectedLeasePeriod
                                                                        ?.startDate ??
                                                                    DateTime
                                                                        .now(),
                                                              ).then((value) {
                                                                if (value !=
                                                                    null) {
                                                                  setState(() {
                                                                    selectedLeasePeriod =
                                                                        LeasePeriod(
                                                                      startDate:
                                                                          selectedLeasePeriod
                                                                              ?.startDate,
                                                                      endDate:
                                                                          value,
                                                                    );
                                                                  });
                                                                }
                                                              });
                                                            },
                                                            child: selectedLeasePeriod
                                                                        ?.endDate !=
                                                                    null
                                                                ? Text(
                                                                    "${selectedLeasePeriod?.endDate!.day}, ${selectedLeasePeriod?.endDate!.monthName(true)}, ${selectedLeasePeriod?.endDate!.year}",
                                                                    style: AppTheme
                                                                        .bodySmall,
                                                                  )
                                                                : Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: AppTheme
                                                                            .greyShades
                                                                            .shade300,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    child: Text(
                                                                      "Select",
                                                                      style: AppTheme
                                                                          .bodySmall,
                                                                    ),
                                                                  ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              SubletFilterTypes.Ameneties =>
                                                ListView(
                                                  children: [
                                                    ...AmenitiesType.values.map(
                                                      (e) => FilterTile(
                                                        title: e.toUi(),
                                                        isSelected:
                                                            selectedAmenities
                                                                .containsKey(e),
                                                        onTap: () {
                                                          setState(() {
                                                            if (selectedAmenities
                                                                .containsKey(
                                                                    e)) {
                                                              selectedAmenities
                                                                  .remove(e);
                                                            } else {
                                                              selectedAmenities[
                                                                  e] = true;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                            },
                                          ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        context.read<SubletBloc>().add(
                                            const SubletEvent
                                                .removeFilterEvent());
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.errorColor,
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
                                        final subletFilter = SubletFilter(
                                          roommateGenderPref: selectedGender,
                                          startRent: rentStart,
                                          endRent: rentEnd,
                                          leasePeriod: selectedLeasePeriod,
                                          apartmentSize: selectedApartmentSize,
                                          roomType: selectedRoomType,
                                          amenitiesAvailable:
                                              Amenities.fromAmenitiesTypes(
                                                  selectedAmenities.keys
                                                      .toList()),
                                        );
                                        context.read<SubletBloc>().add(
                                            SubletEvent.addFilterEvent(
                                                subletFilter));
                                        Navigator.of(context).pop();
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
                  )),
            );
          },
        );
      },
    );
  }
}

enum SubletFilterTypes {
  RoomateGenderPref,
  Rent,
  LeasePeriods,
  Ameneties,
  ApartmentSize,
  RoomType;

  @override
  String toString() {
    switch (this) {
      case RoomateGenderPref:
        return "Roomate Gender";
      case Rent:
        return "Rent";
      case LeasePeriods:
        return "Lease Period";
      case Ameneties:
        return "Ameneties";
      case ApartmentSize:
        return "Apartment Size";
      case RoomType:
        return "Room Type";
    }
  }
}
