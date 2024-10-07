part of 'marketplace_bloc.dart';

abstract class MarketplaceEvent {
  const MarketplaceEvent();

  const factory MarketplaceEvent.initial() = _Initial;
  const factory MarketplaceEvent.saveMarketplaces(
      List<MarketplaceModel> marketplaces) = _SaveMarketplaces;

  R when<R>({
    required R Function() initial,
    required R Function(List<MarketplaceModel> marketplaces) saveMarketplaces,
  }) {
    if (this is _Initial) {
      return initial();
    } else if (this is _SaveMarketplaces) {
      return saveMarketplaces((this as _SaveMarketplaces).marketplaces);
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeWhen<R>({
    R Function()? initial,
    R Function(List<MarketplaceModel> marketplaces)? saveMarketplaces,
    required R Function() orElse,
  }) {
    if (this is _Initial) {
      return initial != null ? initial() : orElse();
    } else if (this is _SaveMarketplaces) {
      return saveMarketplaces != null
          ? saveMarketplaces((this as _SaveMarketplaces).marketplaces)
          : orElse();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R map<R>({
    required R Function() initial,
    required R Function(List<MarketplaceModel> marketPlace) saveMarketplaces,
  }) {
    if (this is _Initial) {
      return initial();
    } else if (this is _SaveMarketplaces) {
      return saveMarketplaces((this as _SaveMarketplaces).marketplaces);
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeMap<R>({
    R Function()? initial,
    R Function(List<MarketplaceModel> marketplaces)? saveMarketplaces,
    required R Function() orElse,
  }) {
    if (this is _Initial) {
      return initial != null ? initial() : orElse();
    } else if (this is _SaveMarketplaces) {
      return saveMarketplaces != null
          ? saveMarketplaces((this as _SaveMarketplaces).marketplaces)
          : orElse();
    } else {
      throw StateError('Unknown type $this');
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
