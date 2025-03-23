import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/apartment/apartment_repository.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/features/apartment/list/view/components/filter_apartment_location.dart';
import 'package:nesters/features/apartment/list/view/components/filter_page.dart';
import 'package:nesters/features/apartment/list/view/shimmer_apartment_list_page.dart';
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
          await _apartmentRepository.getNearbyApartments(
        userId: _authRepository.currentUser!.id,
        paginationKey: pageKey,
        locationRange: 100000000,
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
    return BlocConsumer<ApartmentBloc, ApartmentState>(
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
              if (state.singleApartmentFilter != null ||
                  state.apartmentFilter != null)
                _buildFilteredApartments()
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

  Widget _buildFilteredApartments() {
    return BlocBuilder<ApartmentBloc, ApartmentState>(
      builder: (context, state) {
        return state.filterState.isLoading
            ? const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : state.filterState.exception != null
                ? SliverToBoxAdapter(
                    child: ShowErrorWidget(
                      error: state.filterState.exception,
                    ),
                  )
                : state.filterState.isSuccess &&
                        state.filteredApartmentList != null &&
                        state.filteredApartmentList?.isNotEmpty == true
                    ? SliverList.builder(
                        itemCount: state.filteredApartmentList!.length,
                        itemBuilder: (context, index) {
                          return ApartmentModelWidget(
                            key: ValueKey(
                                state.filteredApartmentList![index].id),
                            onPressed: () {
                              GoRouter.of(context).go(
                                '${AppRouterService.homeScreen}/${AppRouterService.apartmentDetail}',
                                extra: state.filteredApartmentList![index],
                              );
                            },
                            actionOnFavourite: (isFavourite) {
                              return _apartmentRepository.updateLikeStatus(
                                userId: _authRepository.currentUser!.id,
                                apartmentId:
                                    state.filteredApartmentList![index].id,
                                isLiked: isFavourite,
                              );
                            },
                            apartment: state.filteredApartmentList![index],
                          );
                        },
                      )
                    : const SliverFillRemaining(
                        child: ShowNoInfoWidget(
                          title: "No Apartments Found",
                          subtitle:
                              "There are no apartment matching the filter criteria. Please try again later.",
                        ),
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
            key: ValueKey(apartment.id),
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
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                scrollDirection: Axis.horizontal,
                children: [
                  TopActionButton(
                    icon: Icons.filter,
                    title: 'Filter',
                    onTap: () {
                      showFilterDialog(context, apartmentState);
                    },
                    isActive: apartmentState.apartmentFilter != null,
                    closeIcon: false,
                  ),
                  if (apartmentState.singleApartmentFilter == null ||
                      apartmentState.singleApartmentFilter is LocationFilter)
                    TopActionButton(
                      icon: Icons.location_on,
                      title: "Location",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return Material(
                              color: Colors.transparent,
                              child: ApartmentLocationFilter(
                                apartments: _pagingController.itemList ?? [],
                                location: apartmentState.singleApartmentFilter
                                        is LocationFilter
                                    ? (apartmentState.singleApartmentFilter
                                            as LocationFilter)
                                        .location
                                    : null,
                              ),
                            );
                          },
                        ).then((value) {
                          if (value != null && value is Location) {
                            final filter = LocationFilter(
                              location: value,
                              radiusKm: 5,
                            );
                            context
                                .read<ApartmentBloc>()
                                .add(ApartmentEvent.addSingleFilter(filter));
                          }
                        });
                      },
                      onClose: () async {
                        if (apartmentState.singleApartmentFilter
                            is LocationFilter) {
                          context
                              .read<ApartmentBloc>()
                              .add(const ApartmentEvent.removeSingleFilter());
                        }
                      },
                      isActive: apartmentState.singleApartmentFilter
                          is LocationFilter,
                    ),
                  if (apartmentState.singleApartmentFilter == null ||
                      apartmentState.singleApartmentFilter is RentFilter)
                    TopActionButton(
                      icon: Icons.person,
                      title: apartmentState.singleApartmentFilter is RentFilter
                          ? "${(apartmentState.singleApartmentFilter as RentFilter).startRent} - ${(apartmentState.singleApartmentFilter as RentFilter).endRent}"
                          : "Rent",
                      isActive:
                          apartmentState.singleApartmentFilter is RentFilter,
                      onTap: () {
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
                                        padding: const EdgeInsets.symmetric(
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
                                                  style: AppTheme.bodyLarge,
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "Max: ${rentEnd.toInt()}",
                                                  style: AppTheme.bodyLarge,
                                                ),
                                              ],
                                            ),
                                            // to avoid the default padding of the slider
                                            Transform.scale(
                                              scale: 0.8,
                                              child: RangeSlider(
                                                values: RangeValues(
                                                    rentStart, rentEnd),
                                                onChanged:
                                                    (RangeValues values) {
                                                  setState(() {
                                                    rentStart = values.start;
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
                      },
                      onClose: () {
                        context
                            .read<ApartmentBloc>()
                            .add(const ApartmentEvent.removeSingleFilter());
                        if (apartmentState.singleApartmentFilter
                            is RentFilter) {
                        } else {}
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
                      onTap: () {
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
                                              value:
                                                  apartmentSizeBeds.toDouble(),
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
                                              value:
                                                  apartmentSizeBaths.toDouble(),
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
                                                    baths: apartmentSizeBaths,
                                                    beds: apartmentSizeBeds,
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
                      },
                      onClose: () {
                        context
                            .read<ApartmentBloc>()
                            .add(const ApartmentEvent.removeSingleFilter());
                      },
                      isActive: apartmentState.singleApartmentFilter
                          is ApartmentSizeFilter,
                    ),
                ],
              );
            },
          ),
        ));
  }

  void showFilterDialog(BuildContext context, ApartmentState state) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return BlocProvider.value(
              value: context.read<ApartmentBloc>(),
              child: ApartmentFilterDialogPage(filter: state.apartmentFilter),
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
