part of 'marketplace_bloc.dart';

@freezed
class MarketplaceEvent with _$MarketplaceEvent {
  const factory MarketplaceEvent.initial() = _Initial;
  const factory MarketplaceEvent.saveMarketplaces(
      List<MarketplaceModel> marketplaces) = _SaveMarketplaces;
}
