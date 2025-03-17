import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/sublet/list/bloc/sublet_bloc.dart';
import 'package:nesters/features/sublet/list/view/components/filter_page.dart';
import 'package:nesters/features/sublet/list/view/components/sublet_list_widget.dart';
import 'package:nesters/features/sublet/list/view/shimmer_sublet_list_page.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:nesters/features/home/view/components/top_bar_action_button.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class SubletListPage extends StatelessWidget {
  const SubletListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubletBloc(),
      child: Scaffold(
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
      final List<SubletModel> sublets =
          await _subletRepository.getNearbySublets(
        userId: _authRepository.currentUser!.id,
        paginationKey: pageKey,
        rangeKm: 50000000,
      );
      final isLastPage = sublets.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(sublets);
      } else {
        _pagingController.appendPage(sublets, pageKey + _pageSize);
      }
      // ignore: use_build_context_synchronously
    } on AppException catch (error) {
      log(error.toString());
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
    return BlocConsumer<SubletBloc, SubletState>(
      listener: (context, state) {
        if (state.filterState.exception != null) {
          context.showErrorSnackBar(state.filterState.exception!.message);
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          child: CustomScrollView(
            slivers: [
              _buildFilterBar(),
              if (state.singleSubletFilter != null ||
                  state.subletFilter != null)
                _buildFilteredSublets()
              else
                _buildSubletList(),
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

  Widget _buildFilteredSublets() {
    return BlocBuilder<SubletBloc, SubletState>(
      builder: (context, state) {
        return state.filterState.exception != null
            ? SliverFillRemaining(
                child: ShowErrorWidget(
                  error: state.filterState.exception,
                ),
              )
            : state.filterState.isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : state.filterState.isSuccess &&
                        state.filteredSubletList != null &&
                        state.filteredSubletList!.isNotEmpty
                    ? _buildFilteredSubletList(state.filteredSubletList!)
                    : const SliverFillRemaining(
                        child: ShowNoInfoWidget(
                          title: "No Sublets Found",
                          subtitle:
                              "There are no sublets matching the filter criteria. Please try again later.",
                        ),
                      );
      },
    );
  }

  Widget _buildSubletList() {
    return PagedSliverList(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<SubletModel>(
        firstPageProgressIndicatorBuilder: (context) =>
            const ShimmerSubletPage(),
        itemBuilder: (context, sublet, index) {
          return SubletModelWidget(
            key: ValueKey(sublet.id),
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
        animateTransitions: true,
        transitionDuration: const Duration(
          milliseconds: 500,
        ),
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
          title: "No Sublets Found",
          subtitle:
              "There are no sublets at the moment. Please try again later.",
        ),
        noMoreItemsIndicatorBuilder: (context) => const SizedBox(height: 100),
      ),
    );
  }

  Widget _buildFilteredSubletList(List<SubletModel> sublets) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final sublet = sublets[index];
          return SubletModelWidget(
            key: ValueKey(sublet.id),
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
        childCount: sublets.length,
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
              return BlocBuilder<AppBloc, AppState>(
                builder: (context, appState) {
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
                                                      Navigator.of(ctx).pop();
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
                                                    Navigator.of(ctx).pop();
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
                                  .toString()
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
                                    initialChildSize: 0.20,
                                    maxChildSize: 0.20,
                                    minChildSize: 0.20,
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
                                                  left: 12, bottom: 12),
                                              child: Text(
                                                "Gender Preference for Sublet",
                                                style: AppTheme.titleLarge,
                                              ),
                                            ),
                                            // male
                                            ListTile(
                                              title: const Text('Male'),
                                              dense: true,
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
                                              dense: true,
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
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return BlocProvider.value(
              value: context.read<SubletBloc>(),
              child: SubletFilterPage(
                initialFilter: state.subletFilter,
                onApply: (filter) {
                  context
                      .read<SubletBloc>()
                      .add(SubletEvent.addFilterEvent(filter));
                },
                onReset: () {
                  context
                      .read<SubletBloc>()
                      .add(const SubletEvent.removeFilterEvent());
                },
              ),
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
