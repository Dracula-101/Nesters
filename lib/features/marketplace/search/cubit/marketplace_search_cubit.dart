import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/marketplace/searched_marketplace_model.dart';
import 'package:nesters/features/auth/bloc/auth_error.dart';
import 'package:nesters/utils/bloc_state.dart';

part 'marketplace_search_state.dart';

class MarketplaceSearchCubit extends Cubit<MarketplaceSearchState> {
  MarketplaceSearchCubit() : super(const MarketplaceSearchState());

  final MarketplaceRepository marketplaceRepository =
      GetIt.I<MarketplaceRepository>();
  final AuthRepository authRepository = GetIt.I<AuthRepository>();

  void search(String query) async {
    emit(MarketplaceSearchState.loading());
    try {
      String? userId = authRepository.currentUser?.id;
      if (userId == null) {
        throw UserNotAuthError();
      }
      final result = await marketplaceRepository.searchMarketplaces(
        query: query,
        userId: userId,
      );
      emit(MarketplaceSearchState.loaded(
          searchResults: result, searchQuery: query));
    } on AppException catch (e) {
      emit(MarketplaceSearchState.error(error: e));
    }
  }
}
