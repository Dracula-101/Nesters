import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/marketplace/error/marketplace_error.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/features/home/view/components/filter_tab.dart';
import 'package:nesters/features/marketplace/list/bloc/marketplace_bloc.dart';
import 'package:nesters/features/marketplace/list/view/components/filter_marketplace_location.dart';
import 'package:nesters/features/marketplace/list/view/components/filter_page.dart';
import 'package:nesters/features/marketplace/list/view/components/marketplace_list_widget.dart';
import 'package:nesters/features/marketplace/list/view/shimmer_marketplace_list_page.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/context.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:nesters/features/home/view/components/top_bar_action_button.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarketplaceBloc(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: 'marketplace_fab',
          onPressed: () {
            GoRouter.of(context).go(
              '${AppRouterService.homeScreen}/${AppRouterService.marketplaceForm}',
            );
          },
          child: const Icon(Icons.post_add),
        ),
        body: const SafeArea(
          child: MarketplaceListView(),
        ),
      ),
    );
  }
}

class MarketplaceListView extends StatefulWidget {
  const MarketplaceListView({super.key});

  @override
  State<MarketplaceListView> createState() => _MarketplaceListViewState();
}

class _MarketplaceListViewState extends State<MarketplaceListView> {
  final PagingController<int, MarketplaceModel> _pagingController =
      PagingController(firstPageKey: 0);
  final MarketplaceRepository _marketplaceRepository =
      GetIt.I<MarketplaceRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();
  final int _pageSize = 10;

  Future<void> loadMarketplaces(int pageKey) async {
    try {
      _logger.info('Loading marketplaces for page $pageKey');
      final List<MarketplaceModel> marketplaces =
          await _marketplaceRepository.getNearbyMarketplaces(
        userId: _authRepository.currentUser?.id ?? '',
        paginationKey: pageKey,
        locationRange: 100000000,
      );

      final isLastPage = marketplaces.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(marketplaces);
      } else {
        _pagingController.appendPage(marketplaces, pageKey + _pageSize);
      }
      // ignore: use_build_context_synchronously
      context.read<MarketplaceBloc>().add(
          MarketplaceEvent.saveMarketplaces(_pagingController.itemList ?? []));
    } on AppException catch (error) {
      // ignore: use_build_context_synchronously
      context.logger.error(
          'Error loading marketplaces: ${(error as MarketplaceError).hint}');
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      loadMarketplaces(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarketplaceBloc, MarketplaceState>(
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
              state.singleFilter != null || state.advancedFilter != null
                  ? _buildFilteredMarketplaceList()
                  : _buildMarketplaceList(state.marketplaceList ?? []),
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

  Widget _buildMarketplaceList(List<MarketplaceModel> marketplaces) {
    return PagedSliverList(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<MarketplaceModel>(
        itemBuilder: (context, marketplace, index) {
          return MarketplaceModelWidget(
            key: ValueKey(marketplace.id),
            onPressed: () {
              GoRouter.of(context).go(
                '${AppRouterService.homeScreen}/${AppRouterService.marketplaceDetail}',
                extra: marketplace,
              );
            },
            onFavourite: (isFavourite) {
              final userId = _authRepository.currentUser?.id;
              return _marketplaceRepository.updateLikeStatus(
                userId: userId!,
                itemId: marketplace.id,
                isLiked: isFavourite,
              );
            },
            marketplace: marketplace,
          );
        },
        firstPageProgressIndicatorBuilder: (context) =>
            const ShimmerMarketplacePage(),
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
          title: 'No Items Found',
          subtitle: 'There are no items at the moment. Please try again later.',
        ),
        noMoreItemsIndicatorBuilder: (_) => const SizedBox(height: 100),
      ),
    );
  }

  Widget _buildFilteredMarketplaceList() {
    return BlocBuilder<MarketplaceBloc, MarketplaceState>(
      builder: (context, state) {
        return state.filterState.isLoading
            ? const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : state.filterState.exception != null
                ? SliverFillRemaining(
                    child: ShowErrorWidget(error: state.filterState.exception),
                  )
                : state.marketplaceListFiltered != null &&
                        state.marketplaceListFiltered!.isNotEmpty
                    ? SliverList.builder(
                        itemCount: state.marketplaceListFiltered!.length,
                        itemBuilder: (context, index) {
                          return MarketplaceModelWidget(
                            onPressed: () {
                              GoRouter.of(context).go(
                                '${AppRouterService.homeScreen}/${AppRouterService.marketplaceDetail}',
                                extra: state.marketplaceListFiltered![index],
                              );
                            },
                            marketplace: state.marketplaceListFiltered![index],
                          );
                        },
                      )
                    : const SliverFillRemaining(
                        child: ShowNoInfoWidget(
                          title: 'No Items Found',
                          subtitle:
                              'No marketplace items found matching the filter criteria. Please try again later.',
                        ),
                      );
      },
    );
  }

  Widget _buildFilterBar() {
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
          child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
            builder: (context, marketplaceState) {
              return BlocBuilder<AppBloc, AppState>(
                builder: (context, appState) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    scrollDirection: Axis.horizontal,
                    children: [
                      TopActionButton(
                        icon: Icons.search,
                        title: 'Search',
                        onTap: () {
                          GoRouter.of(context).go(
                            '${AppRouterService.homeScreen}/${AppRouterService.marketplaceSearch}',
                          );
                        },
                        isActive: marketplaceState.advancedFilter != null,
                      ),
                      TopActionButton(
                        icon: Icons.filter,
                        title: 'Filter',
                        onTap: () {
                          showMultipleFilterDialog(marketplaceState);
                        },
                        isActive: marketplaceState.advancedFilter != null,
                      ),
                      if (marketplaceState.singleFilter == null ||
                          marketplaceState.singleFilter is LocationFilter)
                        TopActionButton(
                          icon: Icons.location_on,
                          title: "Location",
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return Material(
                                  color: Colors.transparent,
                                  child: MarketplaceLocationFilter(
                                    marketplaces:
                                        _pagingController.itemList ?? [],
                                    location: marketplaceState.singleFilter
                                            is LocationFilter
                                        ? (marketplaceState.singleFilter
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
                                context.read<MarketplaceBloc>().add(
                                    MarketplaceEvent.applySingleFilter(filter));
                              }
                            });
                          },
                          onClose: () async {
                            if (marketplaceState.singleFilter
                                is LocationFilter) {
                              context.read<MarketplaceBloc>().add(
                                  const MarketplaceEvent.removeSingleFilter());
                            }
                          },
                          isActive:
                              marketplaceState.singleFilter is LocationFilter,
                        ),
                      if (marketplaceState.singleFilter == null ||
                          marketplaceState.singleFilter
                              is MarketplaceCategoryFilter)
                        TopActionButton(
                          icon: Icons.category,
                          title: marketplaceState.singleFilter
                                  is MarketplaceCategoryFilter
                              ? (marketplaceState.singleFilter
                                          as MarketplaceCategoryFilter)
                                      .category
                                      .name ??
                                  ''
                              : "Category",
                          isActive: marketplaceState.singleFilter
                              is MarketplaceCategoryFilter,
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
                                  builder: (ctx, scrollController) {
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
                                                "Categories",
                                                style: AppTheme.titleLarge,
                                              )),
                                          if (appState
                                              .marketplaceCategory.isEmpty)
                                            const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          else
                                            ...appState.marketplaceCategory
                                                .map(
                                                  (category) => GestureDetector(
                                                    onTap: () {
                                                      context
                                                          .read<
                                                              MarketplaceBloc>()
                                                          .add(MarketplaceEvent
                                                              .applySingleFilter(
                                                                  MarketplaceCategoryFilter(
                                                                      category)));
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            color: AppTheme
                                                                .greyShades
                                                                .shade300,
                                                            width: 1,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        category.name ?? "",
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          onClose: () {
                            context.read<MarketplaceBloc>().add(
                                const MarketplaceEvent.removeSingleFilter());
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

  void showMultipleFilterDialog(MarketplaceState state) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return BlocProvider.value(
              value: context.read<AppBloc>(),
              child: BlocBuilder<AppBloc, AppState>(
                builder: (ctx, appState) {
                  return BlocProvider.value(
                    value: context.read<MarketplaceBloc>(),
                    child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
                      builder: (context, marketplaceState) {
                        return MarketplaceFilterDialogPage(
                          filter: marketplaceState.advancedFilter,
                        );
                      },
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

class MarketplaceCategoryFilterTab extends StatelessWidget {
  final MarketplaceCategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;
  const MarketplaceCategoryFilterTab(
      {super.key,
      required this.category,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Icon(
                      Icons.check,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      category.name ?? '',
                      style: AppTheme.bodySmall.copyWith(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.bodyMedium.color,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
