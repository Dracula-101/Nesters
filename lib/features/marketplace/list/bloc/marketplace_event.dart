part of 'marketplace_bloc.dart';

abstract class MarketplaceEvent {
  const MarketplaceEvent();

  const factory MarketplaceEvent.initial() = _Initial;
  const factory MarketplaceEvent.saveMarketplaces(
      List<MarketplaceModel> marketplaces) = _SaveMarketplaces;
  const factory MarketplaceEvent.applySingleFilter(
      MarketplaceSingleFilter filter) = _ApplySingleFilter;
  const factory MarketplaceEvent.removeSingleFilter() = _RemoveSingleFilter;
  const factory MarketplaceEvent.addMultipleFilter(
      MarketplaceAdvancedFilter filter) = _AddMultipleFilter;
  const factory MarketplaceEvent.removeMultipleFilter() = _RemoveMultipleFilter;

  R when<R>({
    required R Function() initial,
    required R Function(List<MarketplaceModel> marketplaces) saveMarketplaces,
    required R Function(MarketplaceSingleFilter filter) applySingleFilter,
    required R Function() removeSingleFilter,
    required R Function(MarketplaceAdvancedFilter) addMultipleFilter,
    required R Function() removeMultipleFilter,
  }) {
    if (this is _Initial) {
      return initial();
    } else if (this is _SaveMarketplaces) {
      return saveMarketplaces((this as _SaveMarketplaces).marketplaces);
    } else if (this is _ApplySingleFilter) {
      return applySingleFilter((this as _ApplySingleFilter).filter);
    } else if (this is _RemoveSingleFilter) {
      return removeSingleFilter();
    } else if (this is _AddMultipleFilter) {
      return addMultipleFilter((this as _AddMultipleFilter).filter);
    } else if (this is _RemoveMultipleFilter) {
      return removeMultipleFilter();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeWhen<R>({
    R Function()? initial,
    R Function(List<MarketplaceModel> marketplaces)? saveMarketplaces,
    R Function(MarketplaceSingleFilter filter)? applySingleFilter,
    R Function()? removeSingleFilter,
    R Function(MarketplaceAdvancedFilter)? addMultipleFilter,
    R Function()? removeMultipleFilter,
    required R Function() orElse,
  }) {
    if (this is _Initial) {
      return initial != null ? initial() : orElse();
    } else if (this is _SaveMarketplaces) {
      return saveMarketplaces != null
          ? saveMarketplaces((this as _SaveMarketplaces).marketplaces)
          : orElse();
    } else if (this is _ApplySingleFilter) {
      return applySingleFilter != null
          ? applySingleFilter((this as _ApplySingleFilter).filter)
          : orElse();
    } else if (this is _RemoveSingleFilter) {
      return removeSingleFilter != null ? removeSingleFilter() : orElse();
    } else if (this is _AddMultipleFilter) {
      return addMultipleFilter != null
          ? addMultipleFilter((this as _AddMultipleFilter).filter)
          : orElse();
    } else if (this is _RemoveMultipleFilter) {
      return removeMultipleFilter != null ? removeMultipleFilter() : orElse();
    } else {
      return orElse();
    }
  }

  R map<R>({
    required R Function() initial,
    required R Function(List<MarketplaceModel> marketPlace) saveMarketplaces,
    required R Function(MarketplaceSingleFilter filter) applySingleFilter,
    required R Function() removeSingleFilter,
    required R Function(MarketplaceAdvancedFilter) addMultipleFilter,
    required R Function() removeMultipleFilter,
  }) {
    if (this is _Initial) {
      return initial();
    } else if (this is _SaveMarketplaces) {
      return saveMarketplaces((this as _SaveMarketplaces).marketplaces);
    } else if (this is _ApplySingleFilter) {
      return applySingleFilter((this as _ApplySingleFilter).filter);
    } else if (this is _RemoveSingleFilter) {
      return removeSingleFilter();
    } else if (this is _AddMultipleFilter) {
      return addMultipleFilter((this as _AddMultipleFilter).filter);
    } else if (this is _RemoveMultipleFilter) {
      return removeMultipleFilter();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeMap<R>({
    R Function()? initial,
    R Function(List<MarketplaceModel> marketplaces)? saveMarketplaces,
    R Function(MarketplaceSingleFilter filter)? applySingleFilter,
    R Function()? removeSingleFilter,
    R Function(MarketplaceAdvancedFilter)? addMultipleFilter,
    R Function()? removeMultipleFilter,
    required R Function() orElse,
  }) {
    if (this is _Initial) {
      return initial != null ? initial() : orElse();
    } else if (this is _SaveMarketplaces) {
      return saveMarketplaces != null
          ? saveMarketplaces((this as _SaveMarketplaces).marketplaces)
          : orElse();
    } else if (this is _ApplySingleFilter) {
      return applySingleFilter != null
          ? applySingleFilter((this as _ApplySingleFilter).filter)
          : orElse();
    } else if (this is _RemoveSingleFilter) {
      return removeSingleFilter != null ? removeSingleFilter() : orElse();
    } else if (this is _AddMultipleFilter) {
      return addMultipleFilter != null
          ? addMultipleFilter((this as _AddMultipleFilter).filter)
          : orElse();
    } else if (this is _RemoveMultipleFilter) {
      return removeMultipleFilter != null ? removeMultipleFilter() : orElse();
    } else {
      return orElse();
    }
  }
}

class _Initial extends MarketplaceEvent {
  const _Initial();
}

class _SaveMarketplaces extends MarketplaceEvent {
  final List<MarketplaceModel> marketplaces;

  const _SaveMarketplaces(this.marketplaces);
}

abstract class MarketplaceSingleFilter {}

class MarketplaceCategoryFilter extends MarketplaceSingleFilter {
  final MarketplaceCategoryModel category;

  MarketplaceCategoryFilter(this.category);
}

class _ApplySingleFilter extends MarketplaceEvent {
  final MarketplaceSingleFilter filter;

  const _ApplySingleFilter(this.filter);
}

class _RemoveSingleFilter extends MarketplaceEvent {
  const _RemoveSingleFilter();
}

class _AddMultipleFilter extends MarketplaceEvent {
  final MarketplaceAdvancedFilter filter;

  const _AddMultipleFilter(this.filter);
}

class _RemoveMultipleFilter extends MarketplaceEvent {
  const _RemoveMultipleFilter();
}

class MarketplaceAdvancedFilter {
  final double? minPrice;
  final double? maxPrice;
  final String? keyword;
  final MarketplaceCategoryModel? category;

  MarketplaceAdvancedFilter({
    this.minPrice,
    this.maxPrice,
    this.keyword,
    this.category,
  });
}
