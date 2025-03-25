import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/domain/models/marketplace/searched_marketplace_model.dart';
import 'package:nesters/features/marketplace/search/cubit/marketplace_search_cubit.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class MarketplaceSearchPage extends StatelessWidget {
  const MarketplaceSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MarketplaceSearchCubit(),
      child: const MarketplaceSearchView(),
    );
  }
}

class MarketplaceSearchView extends StatefulWidget {
  const MarketplaceSearchView({super.key});

  @override
  State<MarketplaceSearchView> createState() => _MarketplaceSearchViewState();
}

class _MarketplaceSearchViewState extends State<MarketplaceSearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketplaceSearchCubit, MarketplaceSearchState>(
      builder: (context, state) {
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CustomTextField(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) {},
                  onFieldSubmitted: (value) {
                    context.read<MarketplaceSearchCubit>().search(value);
                  },
                  autofocus: true,
                  controller: _searchController,
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
              ),
              if (_searchController.text.isEmpty) ...[
                if (state.recentSearches.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Recent Searches',
                      style: AppTheme.titleMedium,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: state.recentSearches.length,
                      itemBuilder: (context, index) {
                        final item =
                            state.recentSearches.reversed.toList()[index];
                        return ListTile(
                          title: Text(item),
                          dense: true,
                          onTap: () {
                            _searchController.text = item;
                            context.read<MarketplaceSearchCubit>().search(item);
                          },
                          trailing: GestureDetector(
                            onTap: () {
                              context
                                  .read<MarketplaceSearchCubit>()
                                  .removeSearch(item);
                            },
                            child: const Icon(Icons.close),
                          ),
                        );
                      },
                    ),
                  ),
                ] else
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 32.0),
                        child: ShowInfoWidget(
                          icon: Icons.search,
                          message: 'Search for items',
                          subtitle: 'Marketplace items will appear here',
                        ),
                      ),
                    ),
                  )
              ] else ...[
                _buildSearchResults()
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<MarketplaceSearchCubit, MarketplaceSearchState>(
      builder: (context, state) {
        if (state.searchState.isLoading) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state.searchState.exception != null) {
          return Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: ShowErrorWidget(
                  error: state.searchState.exception,
                ),
              ),
            ),
          );
        } else if (state.searchState.isSuccess) {
          if (state.searchResults.isEmpty) {
            return const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 32.0),
                  child: ShowWarningWidget(
                    message: 'No items found',
                    subtitle: 'Try searching for something else',
                  ),
                ),
              ),
            );
          } else {
            return Expanded(
              child: ListView.builder(
                itemCount: state.searchResults.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final item = state.searchResults[index];
                  return marketplaceItem(item, state.searchQuery);
                },
              ),
            );
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget marketplaceItem(SearchedMarketplaceModel item, String query) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).go(
          '${AppRouterService.homeScreen}/${AppRouterService.marketplaceSearch}/${AppRouterService.marketplaceDetail}',
          extra: item.toMarketplaceItem(),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.greyShades.shade400,
                  width: 1,
                ),
                image: DecorationImage(
                  image: NetworkImage(item.photos![0]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.searchCategory == SearchCategory.NAME)
                    _buildRichText(item.name!, query, AppTheme.titleSmall)
                  else
                    Text(
                      item.name!,
                      style: AppTheme.titleSmall,
                    ),
                  if (item.searchCategory == SearchCategory.DESCRIPTION)
                    _buildRichText(
                      item.description!,
                      query,
                      AppTheme.labelSmallLightVariant,
                    )
                  else if (item.searchCategory == SearchCategory.CATEGORY)
                    _buildRichText(
                      'Category: ${item.category!.name}',
                      'Category:',
                      AppTheme.labelSmallLightVariant,
                    )
                  else if (item.searchCategory == SearchCategory.LOCATION)
                    _buildRichText(
                      'Location: ${item.address}',
                      'Location:',
                      AppTheme.labelSmallLightVariant,
                    )
                  else
                    Text(
                      item.description!,
                      style: AppTheme.labelSmallLightVariant,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildSubtitle(
                        item.price.toString(),
                        Icons.attach_money,
                      ),
                      Text(
                        '  •  ',
                        style: AppTheme.labelLargeLightVariant.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildSubtitle(
                        " ${_buildTimePost(item.createdAt!)}",
                        Icons.access_time,
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _buildTimePost(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inSeconds}s ago';
    }
  }

  Widget _buildSubtitle(String? subtitle, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.greyShades.shade700,
        ),
        Text(
          subtitle ?? 'N/A',
          style: AppTheme.labelLargeLightVariant.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRichText(String text, String query, TextStyle style) {
    final queryIndex = text.toLowerCase().indexOf(query.toLowerCase());
    final queryLength = query.length;
    bool isQuery = queryIndex != -1;
    return isQuery
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: text.substring(0, queryIndex),
                  style: style,
                ),
                TextSpan(
                  text: text.substring(queryIndex, queryIndex + queryLength),
                  style: style.copyWith(
                      fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                TextSpan(
                  text: text.substring(queryIndex + queryLength),
                  style: style,
                ),
              ],
            ),
          )
        : Text(
            text,
            style: style,
          );
  }
}
