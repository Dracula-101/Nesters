import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/features/marketplace/list/bloc/marketplace_bloc.dart';
import 'package:nesters/features/marketplace/list/view/components/marketplace_list_widget.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/logger/logger.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Marketplace',
          style: AppTheme.titleLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'marketplace_fab',
        onPressed: () {
          GetIt.I<AppRouter>().navigateToMarketplaceForm();
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
              GetIt.I<AppRouter>().navigateToMarketplaceDetail(
                marketplace: marketplace,
              );
            },
            marketplace: marketplace,
          );
        },
      ),
    );
  }
}
