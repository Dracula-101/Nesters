import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/marketplace/searched_marketplace_model.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/features/auth/bloc/auth_error.dart';
import 'package:nesters/utils/bloc_state.dart';

part 'marketplace_search_state.dart';

class MarketplaceSearchCubit extends Cubit<MarketplaceSearchState> {
  MarketplaceSearchCubit() : super(MarketplaceSearchState.initial()) {
    _loadRecentSearches();
  }

  final MarketplaceRepository marketplaceRepository =
      GetIt.I<MarketplaceRepository>();
  final AuthRepository authRepository = GetIt.I<AuthRepository>();
  final ObxStorageRepository obxStorageRepository =
      GetIt.I<ObxStorageRepository>();
  final LocalStorageRepository localStorageRepository =
      GetIt.I<LocalStorageRepository>();

  void _loadRecentSearches() {
    final recentSearches = obxStorageRepository.getRecentSearchMarketplace();
    emit(state.copyWith(recentSearches: recentSearches));
  }

  void search(String query) async {
    emit(state.copyWith(searchState: const BlocState(isLoading: true)));
    try {
      String? userId = authRepository.currentUser?.id;
      if (userId == null) {
        throw UserNotAuthError();
      }
      double? lat =
          localStorageRepository.getDouble(LocalStorageKeys.locationLatitude) ??
              0.0;
      double? lng = localStorageRepository
              .getDouble(LocalStorageKeys.locationLongitude) ??
          0.0;
      Location? location;
      if (lat != 0.0 && lng != 0.0) {
        location = Location(
          latitude: lat,
          longitude: lng,
        );
      }
      final result = await marketplaceRepository.searchMarketplaces(
        query: query,
        userId: userId,
        location: location,
      );
      emit(state.copyWith(
        searchResults: result,
        searchQuery: query,
      ));
      unawaited(obxStorageRepository.addRecentSearchMarketplaceItem(query));
      emit(state.copyWith(
          searchState: state.searchState.copyWith(isSuccess: true)));
    } on AppException catch (e) {
      emit(state.copyWith(
          searchState: state.searchState.copyWith(exception: e)));
    } finally {
      emit(state.copyWith(
          searchState: state.searchState.copyWith(isLoading: false)));
    }
  }

  void removeSearch(String query) {
    final recentSearches =
        state.recentSearches.where((e) => e != query).toList();
    obxStorageRepository.removeRecentSearchMarketplaceItem(query).then((_) {
      emit(state.copyWith(recentSearches: recentSearches));
    });
  }
}
