import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/constants/app_assets.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/apartment/apartment_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/apartment/apartment_filter.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/features/apartment/list/view/shimmer_apartment_list_page.dart';
import 'package:nesters/features/home/bloc/home_bloc.dart';
import 'package:nesters/features/home/view/components/filter_tab.dart';
import 'package:nesters/features/home/view/components/filter_tile.dart';
import 'package:nesters/features/apartment/list/bloc/apartment_bloc.dart';
import 'package:nesters/features/apartment/list/view/components/apartment_list_widget.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:nesters/features/home/view/components/top_bar_action_button.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class ApartmentListPage extends StatelessWidget {
  const ApartmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApartmentBloc(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            GoRouter.of(context).go(
              '${AppRouterService.homeScreen}/${AppRouterService.apartmentForm}',
            );
          },
          heroTag: "add_apartment",
          child: const Icon(Icons.add),
        ),
        body: const SafeArea(
          child: ApartmentListView(),
        ),
      ),
    );
  }
}

class ApartmentListView extends StatefulWidget {
  const ApartmentListView({super.key});

  @override
  State<ApartmentListView> createState() => _ApartmentListViewState();
}

class _ApartmentListViewState extends State<ApartmentListView> {
  final PagingController<int, ApartmentModel> _pagingController =
      PagingController(firstPageKey: 0);
  final ApartmentRepository _apartmentRepository =
      GetIt.I<ApartmentRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();
  final int _pageSize = 10;

  Future<void> loadApartments(int pageKey) async {
    try {
      _logger.info('Loading apartments for page $pageKey');
      final List<ApartmentModel> apartments =
          await _apartmentRepository.getApartments(
        userId: _authRepository.currentUser!.id,
        paginationKey: pageKey,
      );
      final isLastPage = apartments.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(apartments);
      } else {
        _pagingController.appendPage(apartments, pageKey + _pageSize);
      }
      // ignore: use_build_context_synchronously
      context
          .read<ApartmentBloc>()
          .add(ApartmentEvent.saveApartments(_pagingController.itemList ?? []));
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      loadApartments(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApartmentBloc, ApartmentState>(
      builder: (context, state) {
        return RefreshIndicator(
          child: CustomScrollView(
            slivers: [
              _buildFilterBar(),
              if (state.singleApartmentFilter != null ||
                  state.apartmentFilter != null)
                if (state.filteredApartmentList?.isNotEmpty ?? false)
                  _buildFilteredApartments(state.filteredApartmentList!)
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
                _buildApartmentList(state.apartmentList ?? []),
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

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildFilteredApartments(List<ApartmentModel> apartments) {
    return SliverList.builder(
      itemCount: apartments.length,
      itemBuilder: (context, index) {
        return ApartmentModelWidget(
          onPressed: () {
            GoRouter.of(context).go(
              '${AppRouterService.homeScreen}/${AppRouterService.apartmentDetail}',
              extra: apartments[index],
            );
          },
          actionOnFavourite: (isFavourite) {
            return _apartmentRepository.updateLikeStatus(
              userId: _authRepository.currentUser!.id,
              apartmentId: apartments[index].id,
              isLiked: isFavourite,
            );
          },
          apartment: apartments[index],
        );
      },
    );
  }

  Widget _buildApartmentList(List<ApartmentModel> apartments) {
    return PagedSliverList(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<ApartmentModel>(
        firstPageProgressIndicatorBuilder: (context) =>
            const ShimmerApartmentPage(),
        itemBuilder: (context, apartment, index) {
          return ApartmentModelWidget(
            onPressed: () {
              GoRouter.of(context).go(
                '${AppRouterService.homeScreen}/${AppRouterService.apartmentDetail}',
                extra: apartment,
              );
            },
            actionOnFavourite: (isFavourite) {
              return _apartmentRepository.updateLikeStatus(
                userId: _authRepository.currentUser!.id,
                apartmentId: apartment.id,
                isLiked: isFavourite,
              );
            },
            apartment: apartment,
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
          title: "No Apartments Found",
          subtitle:
              "There are no apartments at the moment, Please try again later",
        ),
        noMoreItemsIndicatorBuilder: (context) => const SizedBox(height: 100),
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
          child: BlocBuilder<ApartmentBloc, ApartmentState>(
            builder: (context, apartmentState) {
              return BlocBuilder<AppBloc, AppState>(
                builder: (context, userState) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    scrollDirection: Axis.horizontal,
                    children: [
                      TopActionButton(
                        icon: Icons.filter,
                        title: 'Filter',
                        onPressed: () {
                          showFilterDialog(context, apartmentState);
                        },
                        isActive: apartmentState.apartmentFilter != null,
                        closeIcon: false,
                      ),
                      if (apartmentState.singleApartmentFilter == null ||
                          apartmentState.singleApartmentFilter is RentFilter)
                        TopActionButton(
                          icon: Icons.person,
                          title: apartmentState.singleApartmentFilter
                                  is RentFilter
                              ? "${(apartmentState.singleApartmentFilter as RentFilter).startRent} - ${(apartmentState.singleApartmentFilter as RentFilter).endRent}"
                              : "Rent",
                          isActive: apartmentState.singleApartmentFilter
                              is RentFilter,
                          onPressed: () async {
                            if (apartmentState.singleApartmentFilter
                                is RentFilter) {
                              context.read<ApartmentBloc>().add(
                                  const ApartmentEvent.removeSingleFilter());
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
                                                          .read<ApartmentBloc>()
                                                          .add(ApartmentEvent
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
                      if (apartmentState.singleApartmentFilter == null ||
                          apartmentState.singleApartmentFilter
                              is ApartmentSizeFilter)
                        TopActionButton(
                          icon: Icons.bed,
                          title: apartmentState.singleApartmentFilter
                                  is ApartmentSizeFilter
                              ? (apartmentState.singleApartmentFilter
                                      as ApartmentSizeFilter)
                                  .apartmentSize
                                  .toFormattedString()
                              : "Size",
                          onPressed: () async {
                            if (apartmentState.singleApartmentFilter
                                is ApartmentSizeFilter) {
                              context.read<ApartmentBloc>().add(
                                  const ApartmentEvent.removeSingleFilter());
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
                                                        .read<ApartmentBloc>()
                                                        .add(ApartmentEvent
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
                          isActive: apartmentState.singleApartmentFilter
                              is ApartmentSizeFilter,
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ));
  }

  void showFilterDialog(BuildContext context, ApartmentState state) {
    ApartmentFilterTypes apartmentFilterTypeSelected =
        ApartmentFilterTypes.Rent;
    double? rentStart = state.apartmentFilter?.startRent?.toDouble();
    double? rentEnd = state.apartmentFilter?.endRent?.toDouble();
    LeasePeriod? selectedLeasePeriod = state.apartmentFilter?.leasePeriod;
    Map<AmenitiesType, bool> selectedAmenities =
        state.apartmentFilter?.amenitiesAvailable?.toMapAmenitiesTypes() ?? {};
    ApartmentSize? selectedApartmentSize = state.apartmentFilter?.apartmentSize;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return BlocProvider.value(
              value: context.read<ApartmentBloc>(),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Material(
                  color: AppTheme.surface,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 4, left: 16, right: 16),
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
                                width: MediaQuery.of(context).size.width * 0.35,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    ...ApartmentFilterTypes.values.map(
                                      (e) => FilterTab(
                                        title: e.toString(),
                                        isSelected:
                                            e == apartmentFilterTypeSelected,
                                        onTap: () {
                                          setState(() {
                                            apartmentFilterTypeSelected = e;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.65,
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
                                        apartmentFilterTypeSelected) {
                                      ApartmentFilterTypes.Rent => Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Start Rent",
                                                    style: AppTheme.titleSmall,
                                                  ),
                                                  const Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (ctx) {
                                                            return CustomValuePicker(
                                                              // 100 to 10000 with 100 increment
                                                              values: List.generate(
                                                                  100,
                                                                  (index) => (100 +
                                                                          (index *
                                                                              100))
                                                                      .toInt()
                                                                      .toString()),
                                                              title:
                                                                  "Select Start Rent",
                                                            );
                                                          }).then((value) {
                                                        if (value != null) {
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
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: AppTheme
                                                              .greyShades
                                                              .shade300,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        (rentStart == null)
                                                            ? "Select"
                                                            : "\$$rentStart",
                                                        style:
                                                            AppTheme.bodySmall,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "End Rent",
                                                    style: AppTheme.titleSmall
                                                        .copyWith(
                                                      color: rentStart == null
                                                          ? AppTheme.greyShades
                                                              .shade400
                                                          : AppTheme.onSurface,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (rentStart == null) {
                                                        return;
                                                      }
                                                      showDialog(
                                                          context: context,
                                                          builder: (ctx) {
                                                            return CustomValuePicker(
                                                              // 100 to 10000 with 100 increment
                                                              values: List.generate(
                                                                  rentStart !=
                                                                          null
                                                                      ? rentStart!
                                                                          .toInt()
                                                                      : 100,
                                                                  (index) => ((rentStart ??
                                                                              100) +
                                                                          (index *
                                                                              100))
                                                                      .toInt()
                                                                      .toString()),
                                                              title:
                                                                  "Select End Rent",
                                                            );
                                                          }).then((value) {
                                                        if (value != null) {
                                                          setState(() {
                                                            rentEnd =
                                                                double.parse(
                                                                    value);
                                                          });
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: AppTheme
                                                              .greyShades
                                                              .shade300,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        (rentEnd != null)
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
                                      ApartmentFilterTypes.ApartmentSize =>
                                        ListView(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              child: Text(
                                                "No of Beds: ${selectedApartmentSize?.beds ?? "1"}",
                                                style: AppTheme.titleMedium,
                                              ),
                                            ),
                                            Slider(
                                              value: selectedApartmentSize?.beds
                                                      ?.toDouble() ??
                                                  1,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedApartmentSize =
                                                      ApartmentSize(
                                                    beds: value.toInt(),
                                                    baths: selectedApartmentSize
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              child: Text(
                                                "No of Baths: ${selectedApartmentSize?.baths ?? "1"}",
                                                style: AppTheme.titleMedium,
                                              ),
                                            ),
                                            Slider(
                                              value: selectedApartmentSize
                                                      ?.baths
                                                      ?.toDouble() ??
                                                  1,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedApartmentSize =
                                                      ApartmentSize(
                                                    baths: value.toInt(),
                                                    beds: selectedApartmentSize
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
                                      ApartmentFilterTypes.LeasePeriods =>
                                        ListView(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Start Date",
                                                    style: AppTheme.titleSmall,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        lastDate: selectedLeasePeriod
                                                                ?.endDate ??
                                                            DateTime.now().add(
                                                                const Duration(
                                                                    days: 365)),
                                                        firstDate:
                                                            DateTime.now(),
                                                      ).then((value) {
                                                        if (value != null) {
                                                          setState(() {
                                                            selectedLeasePeriod =
                                                                LeasePeriod(
                                                              startDate: value,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "End Date",
                                                    style: AppTheme.titleSmall,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            selectedLeasePeriod
                                                                    ?.startDate ??
                                                                DateTime.now(),
                                                        lastDate: DateTime.now()
                                                            .add(const Duration(
                                                                days: 365)),
                                                        firstDate:
                                                            selectedLeasePeriod
                                                                    ?.startDate ??
                                                                DateTime.now(),
                                                      ).then((value) {
                                                        if (value != null) {
                                                          setState(() {
                                                            selectedLeasePeriod =
                                                                LeasePeriod(
                                                              startDate:
                                                                  selectedLeasePeriod
                                                                      ?.startDate,
                                                              endDate: value,
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
                                      ApartmentFilterTypes.Ameneties =>
                                        ListView(
                                          children: [
                                            ...AmenitiesType.values.map(
                                              (e) => FilterTile(
                                                title: e.toUi(),
                                                isSelected: selectedAmenities
                                                    .containsKey(e),
                                                onTap: () {
                                                  setState(() {
                                                    if (selectedAmenities
                                                        .containsKey(e)) {
                                                      selectedAmenities
                                                          .remove(e);
                                                    } else {
                                                      selectedAmenities[e] =
                                                          true;
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.read<ApartmentBloc>().add(
                                    const ApartmentEvent.removeFilterEvent());
                                Navigator.of(ctx).pop();
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
                                final apartmentFilter = ApartmentFilter(
                                  startRent: rentStart,
                                  endRent: rentEnd,
                                  leasePeriod: selectedLeasePeriod,
                                  apartmentSize: selectedApartmentSize,
                                  amenitiesAvailable:
                                      Amenities.fromAmenitiesTypes(
                                          selectedAmenities.keys.toList()),
                                );
                                context.read<ApartmentBloc>().add(
                                    ApartmentEvent.addFilterEvent(
                                        apartmentFilter));
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
              ),
            );
          },
        );
      },
    );
  }
}

enum ApartmentFilterTypes {
  Rent,
  LeasePeriods,
  Ameneties,
  ApartmentSize;

  @override
  String toString() {
    switch (this) {
      case Rent:
        return "Rent";
      case LeasePeriods:
        return "Lease Period";
      case Ameneties:
        return "Ameneties";
      case ApartmentSize:
        return "Apartment Size";
    }
  }
}
