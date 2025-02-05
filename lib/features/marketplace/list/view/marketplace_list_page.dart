import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/features/home/view/components/filter_tab.dart';
import 'package:nesters/features/marketplace/list/bloc/marketplace_bloc.dart';
import 'package:nesters/features/marketplace/list/view/components/marketplace_list_widget.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/components/top_bar_action_button.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          await _marketplaceRepository.getMarketplaces(
        userId: _authRepository.currentUser?.id ?? '',
        paginationKey: pageKey,
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
    } catch (error) {
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
    return BlocBuilder<MarketplaceBloc, MarketplaceState>(
      builder: (context, state) {
        return RefreshIndicator(
          child: CustomScrollView(
            slivers: [
              _buildFilterBar(),
              state.singleFilter != null || state.advancedFilter != null
                  ? state.marketplaceListFiltered?.isEmpty == true
                      ? _buildMarketplacePlaceholder()
                      : _buildFilteredMarketplaceList(
                          state.marketplaceListFiltered ?? [])
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

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorIndicator(Exception error) {
    return Center(
      child: Text('Error: $error'),
    );
  }

  Widget _buildMarketplacePlaceholder() {
    return SliverFillRemaining(
      child: Center(
        child: Text(
          "No marketplaces found",
          style: AppTheme.titleLarge,
        ),
      ),
    );
  }

  Widget _buildMarketplaceList(List<MarketplaceModel> marketplaces) {
    return PagedSliverList(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<MarketplaceModel>(
        firstPageProgressIndicatorBuilder: (context) =>
            _buildLoadingIndicator(),
        firstPageErrorIndicatorBuilder: (context) =>
            _buildErrorIndicator(_pagingController.error),
        itemBuilder: (context, marketplace, index) {
          return MarketplaceModelWidget(
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
                  isLiked: isFavourite);
            },
            marketplace: marketplace,
          );
        },
      ),
    );
  }

  Widget _buildFilteredMarketplaceList(List<MarketplaceModel> marketplaces) {
    return SliverList.builder(
      itemCount: marketplaces.length,
      itemBuilder: (context, index) {
        return MarketplaceModelWidget(
          onPressed: () {
            GoRouter.of(context).go(
              '${AppRouterService.homeScreen}/${AppRouterService.marketplaceDetail}',
              extra: marketplaces[index],
            );
          },
          marketplace: marketplaces[index],
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
                          showMultipleFilterDialog(marketplaceState);
                        },
                        isActive: marketplaceState.advancedFilter != null,
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
                          onPressed: () async {
                            if (marketplaceState.singleFilter
                                is MarketplaceCategoryFilter) {
                              context.read<MarketplaceBloc>().add(
                                  const MarketplaceEvent.removeSingleFilter());
                            } else {
                              // open a modal bottom sheet
                              if (userState.marketplaceCategory.isEmpty) {
                                context.read<UserBloc>().add(const UserEvent
                                    .loadMarketplaceCategories());
                              }
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
                                            if (userState
                                                .marketplaceCategory.isEmpty)
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            else
                                              ...userState.marketplaceCategory
                                                  .map((category) => ListTile(
                                                        title: Text(
                                                            category.name ??
                                                                ""),
                                                        onTap: () {
                                                          context
                                                              .read<
                                                                  MarketplaceBloc>()
                                                              .add(MarketplaceEvent
                                                                  .applySingleFilter(
                                                                      MarketplaceCategoryFilter(
                                                                          category)));
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ))
                                                  .toList(),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
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

  void showMultipleFilterDialog(MarketplaceState state) {
    MarketplaceFilterTypes selectedFilterType = MarketplaceFilterTypes.price;
    double? minPrice = state.advancedFilter?.minPrice ?? 0,
        maxPrice = state.advancedFilter?.maxPrice;
    MarketplaceCategoryModel? selectedCategory = state.advancedFilter?.category;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return BlocProvider.value(
              value: context.read<UserBloc>(),
              child: BlocBuilder<UserBloc, UserState>(
                builder: (ctx, userState) {
                  return BlocProvider.value(
                    value: context.read<MarketplaceBloc>(),
                    child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
                      builder: (context, marketplaceState) {
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: [
                                              ...MarketplaceFilterTypes.values
                                                  .map(
                                                (e) => FilterTab(
                                                  title: e.toString(),
                                                  isSelected:
                                                      e == selectedFilterType,
                                                  onTap: () {
                                                    setState(() {
                                                      selectedFilterType = e;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                                  selectedFilterType) {
                                                MarketplaceFilterTypes.price =>
                                                  Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 4),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Min Price",
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
                                                                        // 0 to 15000 with 50 increment
                                                                        values: List.generate(
                                                                            300,
                                                                            (index) =>
                                                                                (index * 50).toString()),
                                                                        title:
                                                                            "Select min price",
                                                                      );
                                                                    }).then((value) {
                                                                  if (value !=
                                                                      null) {
                                                                    setState(
                                                                        () {
                                                                      minPrice =
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
                                                                  border: Border
                                                                      .all(
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
                                                                  (minPrice ==
                                                                          null)
                                                                      ? "Select"
                                                                      : "\$$minPrice",
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
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 4),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Max Price",
                                                              style: AppTheme
                                                                  .titleSmall
                                                                  .copyWith(
                                                                color: minPrice ==
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
                                                                if (minPrice ==
                                                                    null) {
                                                                  return;
                                                                }
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (ctx) {
                                                                      return CustomValuePicker(
                                                                        // 100 to 10000 with 50 increment
                                                                        values: List.generate(
                                                                            200,
                                                                            (index) =>
                                                                                ((index + 1) * 50).toString()),
                                                                        title:
                                                                            "Select max price",
                                                                      );
                                                                    }).then((value) {
                                                                  if (value !=
                                                                      null) {
                                                                    setState(
                                                                        () {
                                                                      maxPrice =
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
                                                                  border: Border
                                                                      .all(
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
                                                                  (maxPrice !=
                                                                          null)
                                                                      ? "\$$maxPrice"
                                                                      : "Select",
                                                                  style: AppTheme
                                                                      .bodySmall
                                                                      .copyWith(
                                                                    color: minPrice ==
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
                                                MarketplaceFilterTypes
                                                      .category =>
                                                  (userState.marketplaceCategory
                                                          .isEmpty
                                                      ? const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        )
                                                      : ListView.builder(
                                                          itemCount: userState
                                                              .marketplaceCategory
                                                              .length,
                                                          itemBuilder:
                                                              (ctx, index) {
                                                            final category =
                                                                userState
                                                                        .marketplaceCategory[
                                                                    index];
                                                            return MarketplaceCategoryFilterTab(
                                                              category:
                                                                  category,
                                                              isSelected:
                                                                  category ==
                                                                      selectedCategory,
                                                              onTap: () {
                                                                setState(() {
                                                                  selectedCategory =
                                                                      category;
                                                                });
                                                              },
                                                            );
                                                          },
                                                        ))
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
                                          context.read<MarketplaceBloc>().add(
                                              const MarketplaceEvent
                                                  .removeMultipleFilter());
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
                                          MarketplaceAdvancedFilter filter =
                                              MarketplaceAdvancedFilter(
                                                  minPrice: minPrice,
                                                  maxPrice: maxPrice,
                                                  category: selectedCategory);
                                          context.read<MarketplaceBloc>().add(
                                              MarketplaceEvent
                                                  .addMultipleFilter(filter));
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
                  if (isSelected)
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
