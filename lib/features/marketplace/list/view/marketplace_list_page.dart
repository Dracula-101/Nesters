import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/features/marketplace/list/bloc/marketplace_bloc.dart';
import 'package:nesters/features/marketplace/list/view/components/marketplace_list_widget.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:nesters/features/home/view/pages/user_list_view_page.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/features/home/home.dart';
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
  final AppLogger _logger = GetIt.I<AppLogger>();
  final int _pageSize = 10;

  Future<void> loadMarketplaces(int pageKey) async {
    try {
      _logger.info('Loading marketplaces for page $pageKey');
      final List<MarketplaceModel> marketplaces =
          await _marketplaceRepository.getMarketplaces(
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
              _buildMarketplaceList(state.marketplaceList ?? []),
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
            marketplace: marketplace,
          );
        },
      ),
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
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, homeState) {
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
                      if (homeState.singleUserFilter == null ||
                          homeState.singleUserFilter is UniversityFilter)
                        TopActionButton(
                          icon: Icons.school,
                          title: homeState.singleUserFilter is UniversityFilter
                              ? (homeState.singleUserFilter as UniversityFilter)
                                  .university
                              : "University",
                          isActive:
                              homeState.singleUserFilter is UniversityFilter,
                          onPressed: () async {
                            if (homeState.singleUserFilter
                                is UniversityFilter) {
                              context
                                  .read<HomeBloc>()
                                  .add(SingleRemoveFilterProfileEvent());
                            } else {
                              // open a modal bottom sheet
                              if (userState.universities.isEmpty) {
                                context
                                    .read<UserBloc>()
                                    .add(const UserEvent.loadUniversities());
                              }
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
                                                  "Universities",
                                                  style: AppTheme.titleLarge,
                                                )),
                                            if (userState.universities.isEmpty)
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            else
                                              ...userState.universities
                                                  .map((university) =>
                                                      UniversityFilterTile(
                                                        isSelected: false,
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .pop(university);
                                                        },
                                                        university: university!,
                                                      ))
                                                  .toList(),
                                          ],
                                        ),
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
                              ? (homeState.singleUserFilter as BranchFilter)
                                  .branch
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
                                                "Branches",
                                                style: AppTheme.titleLarge,
                                              ),
                                            ),
                                            if (userState.degrees.isEmpty)
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            else
                                              ...userState.degrees
                                                  .map((degree) =>
                                                      DegreeFilterTile(
                                                        isSelected: false,
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .pop(degree);
                                                        },
                                                        degree: degree!,
                                                      ))
                                                  .toList()
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
                              ? (homeState.singleUserFilter as GenderFilter)
                                  .gender
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
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
                                            ListTile(
                                              title: const Text('Other'),
                                              onTap: () {
                                                Navigator.of(context)
                                                    .pop('Other');
                                              },
                                              leading: Icon(
                                                Icons.transgender,
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
          ),
        ));
  }
}
