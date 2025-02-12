import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/features/home/view/components/filter_tab.dart';
import 'package:nesters/features/marketplace/list/bloc/marketplace_bloc.dart';
import 'package:nesters/features/marketplace/list/view/marketplace_list_page.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class MarketplaceFilterDialogPage extends StatefulWidget {
  const MarketplaceFilterDialogPage({super.key});

  @override
  State<MarketplaceFilterDialogPage> createState() =>
      _MarketplaceFilterDialogPageState();
}

class _MarketplaceFilterDialogPageState
    extends State<MarketplaceFilterDialogPage> {
  MarketplaceFilterTypes selectedFilterType = MarketplaceFilterTypes.price;
  double? minPrice, maxPrice;
  MarketplaceCategoryModel? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Material(
        color: AppTheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Navigator.of(context).pop();
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ...MarketplaceFilterTypes.values.map(
                            (e) => FilterTab(
                              title: e.toString(),
                              isSelected: e == selectedFilterType,
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
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppTheme.greyShades.shade300,
                            ),
                          ),
                        ),
                        child: Container(
                          child: switch (selectedFilterType) {
                            MarketplaceFilterTypes.price =>
                              _buildMarketplacePriceFilter(),
                            MarketplaceFilterTypes.category =>
                              _buildMarketplaceCategoryFilter(),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<MarketplaceBloc>()
                          .add(const MarketplaceEvent.removeMultipleFilter());
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                    ),
                    child: Text(
                      'Reset All',
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
                      context
                          .read<MarketplaceBloc>()
                          .add(MarketplaceEvent.addMultipleFilter(filter));
                      Navigator.of(context).pop();
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
  }

  Widget _buildMarketplacePriceFilter() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                "Min Price",
                style: AppTheme.titleSmall,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        return CustomValuePicker(
                          values: List.generate(
                              300, (index) => (index * 50).toString()),
                          title: "Select min price",
                        );
                      }).then((value) {
                    if (value != null) {
                      setState(() {
                        minPrice = double.parse(value);
                      });
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.greyShades.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (minPrice == null) ? "Select" : "\$${minPrice?.toInt()}",
                    style: AppTheme.bodySmall,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                "Max Price",
                style: AppTheme.titleSmall.copyWith(
                  color: minPrice == null
                      ? AppTheme.greyShades.shade400
                      : AppTheme.onSurface,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (minPrice == null) {
                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        return CustomValuePicker(
                          values: List.generate(
                              200, (index) => ((index + 1) * 50).toString()),
                          title: "Select max price",
                        );
                      }).then((value) {
                    if (value != null) {
                      setState(() {
                        maxPrice = double.parse(value);
                      });
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.greyShades.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (maxPrice != null) ? "\$${maxPrice?.toInt()}" : "Select",
                    style: AppTheme.bodySmall.copyWith(
                      color: minPrice == null
                          ? AppTheme.greyShades.shade400
                          : AppTheme.onSurface,
                    ),
                  ),
                ),
              ),
              if (minPrice != null || maxPrice != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomFlatButton(
                    text: "Reset",
                    onPressed: () {
                      setState(() {
                        minPrice = null;
                        maxPrice = null;
                      });
                    },
                  ),
                )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMarketplaceCategoryFilter() {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return appState.marketplaceCategory.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: appState.marketplaceCategory.length,
                      itemBuilder: (ctx, index) {
                        final category = appState.marketplaceCategory[index];
                        return MarketplaceCategoryFilterTab(
                          category: category,
                          isSelected: category == selectedCategory,
                          onTap: () {
                            // reset logic
                            if (category == selectedCategory) {
                              setState(() {
                                selectedCategory = null;
                              });
                              return;
                            }
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
      },
    );
  }
}
