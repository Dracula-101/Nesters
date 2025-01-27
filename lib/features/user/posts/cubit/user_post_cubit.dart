import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/user/posts/cubit/user_post_state.dart';

class UserPostCubit extends Cubit<UserPostState> {
  UserPostCubit({
    required PostView postView,
  }) : super(UserPostState(postView: postView)) {
    if (state.postView == PostView.sublet) {
      fetchSubletUserPosts();
    } else {
      fetchMarketplaceUserPosts();
    }
  }

  final MarketplaceRepository _marketplaceRepository =
      GetIt.I<MarketplaceRepository>();
  final SubletRepository _subletRepository = GetIt.I<SubletRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  Future<void> fetchSubletUserPosts() async {
    emit(state.copyWith(isLoading: true));
    try {
      final userId = _authRepository.currentUser!.id;
      final posts = await _subletRepository.getUserSublets(userId: userId);
      emit(state.copyWith(sublets: posts, isLoading: false));
    } on Exception catch (e) {
      emit(state.copyWith(error: e, isLoading: false));
    }
  }

  Future<void> fetchMarketplaceUserPosts() async {
    emit(state.copyWith(isLoading: true));
    try {
      final userId = _authRepository.currentUser!.id;
      final posts =
          await _marketplaceRepository.getUserMarketplaces(userId: userId);
      emit(state.copyWith(marketplaces: posts, isLoading: false));
    } on Exception catch (e) {
      emit(state.copyWith(error: e, isLoading: false));
    }
  }

  Future<void> changeSubletVisibility({
    required String subletId,
    required bool isVisible,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userId = _authRepository.currentUser!.id;
      await _subletRepository.changeSubletAvailabilityStatus(
          subletId: subletId, userId: userId, isAvailable: isVisible);
      final updatedSublets = List<SubletModel>.empty(growable: true);
      for (var sublet in state.sublets) {
        if (sublet.id == int.tryParse(subletId)) {
          updatedSublets.add(sublet.copyWith(isAvailable: isVisible));
        } else {
          updatedSublets.add(sublet);
        }
      }
      emit(state.copyWith(sublets: updatedSublets, isLoading: false));
    } on Exception catch (e) {
      emit(state.copyWith(error: e, isLoading: false));
    }
  }

  Future<void> changeMarketplaceVisibility({
    required int itemId,
    required bool isVisible,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userId = _authRepository.currentUser!.id;
      await _marketplaceRepository.changeAvailabilityStatus(
          itemId: itemId, userId: userId, isAvailable: isVisible);
      // change the visibility of the item in the list
      final updatedMarketplaces = List<MarketplaceModel>.empty(growable: true);
      for (var marketplace in state.marketplaces) {
        if (marketplace.id == itemId) {
          updatedMarketplaces.add(marketplace.copyWith(isAvailable: isVisible));
        } else {
          updatedMarketplaces.add(marketplace);
        }
      }
      emit(state.copyWith(marketplaces: updatedMarketplaces, isLoading: false));
    } on Exception catch (e) {
      emit(state.copyWith(error: e, isLoading: false));
    }
  }

  Future<void> deleteSublet({required String subletId}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userId = _authRepository.currentUser!.id;
      await _subletRepository.deleteUserSublet(
          subletId: subletId, userId: userId);
      final updatedSublets = state.sublets
          .where((sublet) => sublet.id != int.tryParse(subletId))
          .toList();
      emit(state.copyWith(sublets: updatedSublets, isLoading: false));
    } on Exception catch (e) {
      emit(state.copyWith(error: e, isLoading: false));
    }
  }

  Future<void> deleteMarketplace({required int itemId}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userId = _authRepository.currentUser!.id;
      await _marketplaceRepository.deleteUserMarketplace(
          itemId: itemId, userId: userId);
      final updatedMarketplaces = state.marketplaces
          .where((marketplace) => marketplace.id != itemId)
          .toList();
      emit(state.copyWith(marketplaces: updatedMarketplaces, isLoading: false));
    } on Exception catch (e) {
      emit(state.copyWith(error: e, isLoading: false));
    }
  }
}
