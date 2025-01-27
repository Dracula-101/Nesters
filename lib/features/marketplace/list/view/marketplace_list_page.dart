import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/features/marketplace/list/bloc/marketplace_bloc.dart';
import 'package:nesters/features/marketplace/list/view/components/marketplace_list_widget.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/components/top_bar_action_button.dart';

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
              state.singleFilter != null
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
                        onPressed: () {},
                        isActive: false,
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
}
