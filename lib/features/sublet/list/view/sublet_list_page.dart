import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/sublet/apartment_size.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/home/view/pages/user_list_view_page.dart';
import 'package:nesters/features/sublet/list/bloc/sublet_bloc.dart';
import 'package:nesters/features/sublet/list/view/components/sublet_list_widget.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/components/top_bar_action_button.dart';
import 'package:nesters/utils/widgets/custom_flat_button.dart';

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
  final AppLogger _logger = GetIt.I<AppLogger>();
  final int _pageSize = 10;

  Future<void> loadSublets(int pageKey) async {
    try {
      _logger.info('Loading sublets for page $pageKey');
      final List<SubletModel> sublets = await _subletRepository.getSublets(
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
              if (state.singleSubletFilter != null)
                if (state.filteredSubletList?.isNotEmpty ?? false)
                  _buildFilteredSublets(state.filteredSubletList!)
                else
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No sublets found',
                        style: AppTheme.titleLarge,
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

  Widget _buildFilteredSublets(List<SubletModel> sublets) {
    return SliverList.builder(
      itemBuilder: (context, index) {
        return SubletModelWidget(
          onPressed: () {
            GoRouter.of(context).go(
              '${AppRouterService.homeScreen}/${AppRouterService.subletDetail}',
              extra: sublets[index],
            );
          },
          sublet: sublets[index],
        );
      },
    );
  }

  Widget _buildSubletList(List<SubletModel> sublets) {
    return PagedSliverList(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<SubletModel>(
        firstPageProgressIndicatorBuilder: (context) =>
            _buildLoadingIndicator(),
        firstPageErrorIndicatorBuilder: (context) =>
            _buildErrorIndicator(_pagingController.error),
        itemBuilder: (context, sublet, index) {
          return SubletModelWidget(
            onPressed: () {
              GoRouter.of(context).go(
                '${AppRouterService.homeScreen}/${AppRouterService.subletDetail}',
                extra: sublet,
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
    double _rentStart = 0;
    double _rentEnd = 10000;
    int _apartmentSizeBeds = 1;
    int _apartmentSizeBaths = 1;
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
                        onPressed: () {},
                        isActive: false,
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
                                                        "Min: ${_rentStart.toInt()}",
                                                        style:
                                                            AppTheme.bodyLarge,
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "Max: ${_rentEnd.toInt()}",
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
                                                          _rentStart, _rentEnd),
                                                      onChanged:
                                                          (RangeValues values) {
                                                        setState(() {
                                                          _rentStart =
                                                              values.start;
                                                          _rentEnd = values.end;
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
                                                                      _rentStart
                                                                          .toInt(),
                                                                      _rentEnd
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
                                                  "Beds: $_apartmentSizeBeds",
                                                  style: AppTheme.bodyLarge,
                                                ),
                                                Transform.scale(
                                                  scale: 1.1,
                                                  child: Slider(
                                                    value: _apartmentSizeBeds
                                                        .toDouble(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _apartmentSizeBeds =
                                                            value.toInt();
                                                      });
                                                    },
                                                    min: 1,
                                                    max: 6,
                                                  ),
                                                ),
                                                Text(
                                                  "Baths: $_apartmentSizeBaths",
                                                  style: AppTheme.bodyLarge,
                                                ),
                                                Transform.scale(
                                                  scale: 1.1,
                                                  child: Slider(
                                                    value: _apartmentSizeBaths
                                                        .toDouble(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _apartmentSizeBaths =
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
                                                              _apartmentSizeBaths,
                                                          beds:
                                                              _apartmentSizeBeds,
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
}
