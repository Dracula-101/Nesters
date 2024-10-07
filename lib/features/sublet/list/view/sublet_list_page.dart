import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/sublet/list/bloc/sublet_bloc.dart';
import 'package:nesters/features/sublet/list/view/components/sublet_list_widget.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/logger/logger.dart';

class SubletListPage extends StatelessWidget {
  const SubletListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sublets',
          style: AppTheme.titleLarge,
        ),
      ),
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
}
