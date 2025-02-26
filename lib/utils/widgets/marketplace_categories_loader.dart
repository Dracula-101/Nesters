part of 'widgets.dart';

class MarketplaceCategoriesLoader extends StatefulWidget {
  final Widget Function(
          BuildContext context, List<MarketplaceCategoryModel> universities)
      builder;
  const MarketplaceCategoriesLoader({super.key, required this.builder});

  @override
  State<MarketplaceCategoriesLoader> createState() =>
      _MarketplaceCategoriesLoaderState();
}

class _MarketplaceCategoriesLoaderState
    extends State<MarketplaceCategoriesLoader> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return state.marketplaceCategoryState.exception != null
            ? ShowErrorWidget(
                error: state.marketplaceCategoryState.exception,
                onRetry: () {
                  context
                      .read<AppBloc>()
                      .add(const AppEvent.loadMarketplaceCategories());
                },
              )
            : state.marketplaceCategoryState.isLoading
                ? Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () {
                            context
                                .read<AppBloc>()
                                .add(const AppEvent.loadUniversities());
                          },
                          child: const Text('Reload'),
                        ),
                      ],
                    ),
                  )
                : state.marketplaceCategory.isEmpty
                    ? const ShowNoInfoWidget(
                        title: 'No categories found',
                        subtitle:
                            'There are no categories available at the moment, please try again later',
                      )
                    : widget.builder(context, state.marketplaceCategory);
      },
    );
  }
}
