import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/apartment/apartment_repository.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/marketplace/error/marketplace_error.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/user/posts/cubit/user_post_state.dart';

class UserPostCubit extends Cubit<UserPostState> {
  UserPostCubit({
    required PostView postView,
  }) : super(UserPostState(postView: postView)) {
    if (state.postView == PostView.sublet) {
      fetchSubletUserPosts();
    } else if (state.postView == PostView.apartment) {
      fetchApartmentUserPosts();
    } else {
      fetchMarketplaceUserPosts();
    }
  }

  final MarketplaceRepository _marketplaceRepository =
      GetIt.I<MarketplaceRepository>();
  final SubletRepository _subletRepository = GetIt.I<SubletRepository>();
  final ApartmentRepository _apartmentRepository =
      GetIt.I<ApartmentRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  Future<void> fetchSubletUserPosts() async {
    emit(state.copyWith(loadingState: state.loadingState.loading()));
    try {
      final userId = _authRepository.currentUser!.id;
      final posts = await _subletRepository.getUserSublets(userId: userId);
      emit(state.copyWith(
          sublets: posts, loadingState: state.loadingState.success()));
    } on AppException catch (e) {
      emit(state.copyWith(loadingState: state.loadingState.failure(e)));
    }
  }

  Future<void> fetchApartmentUserPosts() async {
    emit(state.copyWith(loadingState: state.loadingState.loading()));
    try {
      final userId = _authRepository.currentUser!.id;
      final posts =
          await _apartmentRepository.getUserApartments(userId: userId);
      emit(state.copyWith(
          apartments: posts, loadingState: state.loadingState.success()));
    } on AppException catch (e) {
      emit(state.copyWith(loadingState: state.loadingState.failure(e)));
    }
  }

  Future<void> fetchMarketplaceUserPosts() async {
    emit(state.copyWith(loadingState: state.loadingState.loading()));
    try {
      final userId = _authRepository.currentUser!.id;
      final posts =
          await _marketplaceRepository.getUserMarketplaces(userId: userId);
      emit(state.copyWith(
          marketplaces: posts, loadingState: state.loadingState.success()));
    } on AppException catch (e) {
      emit(state.copyWith(loadingState: state.loadingState.failure(e)));
    }
  }

  Future<void> changeSubletVisibility({
    required String subletId,
    required bool isVisible,
  }) async {
    emit(state.copyWith(loadingState: state.loadingState.loading()));
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
      emit(state.copyWith(
          sublets: updatedSublets, loadingState: state.loadingState.success()));
    } on AppException catch (e) {
      emit(state.copyWith(loadingState: state.loadingState.failure(e)));
    }
  }

  Future<void> changeApartmentVisibility({
    required String apartmentId,
    required bool isVisible,
  }) async {
    emit(state.copyWith(loadingState: state.loadingState.loading()));
    try {
      final userId = _authRepository.currentUser!.id;
      await _apartmentRepository.changeApartmentAvailabilityStatus(
          apartmentId: apartmentId, userId: userId, isAvailable: isVisible);
      final updatedApartments = List<ApartmentModel>.empty(growable: true);
      for (var apartment in state.apartments) {
        if (apartment.id == int.tryParse(apartmentId)) {
          updatedApartments.add(apartment.copyWith(isAvailable: isVisible));
        } else {
          updatedApartments.add(apartment);
        }
      }
      emit(state.copyWith(
          apartments: updatedApartments,
          loadingState: state.loadingState.success()));
    } on AppException catch (e) {
      emit(state.copyWith(loadingState: state.loadingState.failure(e)));
    }
  }

  Future<void> changeMarketplaceVisibility({
    required int itemId,
    required bool isVisible,
  }) async {
    emit(state.copyWith(loadingState: state.loadingState.loading()));
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
      emit(state.copyWith(
          marketplaces: updatedMarketplaces,
          loadingState: state.loadingState.success()));
    } on AppException catch (e) {
      emit(state.copyWith(loadingState: state.loadingState.failure(e)));
    }
  }

  Future<void> deleteSublet({required String subletId}) async {
    emit(state.copyWith(loadingState: state.loadingState.loading()));
    try {
      final userId = _authRepository.currentUser!.id;
      await _subletRepository.deleteUserSublet(
          subletId: subletId, userId: userId);
      final updatedSublets = state.sublets
          .where((sublet) => sublet.id != int.tryParse(subletId))
          .toList();
      emit(state.copyWith(
          sublets: updatedSublets, loadingState: state.loadingState.success()));
    } on AppException catch (e) {
      log("Error deleting apartment: $e");
      emit(state.copyWith(loadingState: state.loadingState.failure(e)));
    }
  }

  Future<void> deleteApartment({required String apartmentId}) async {
    emit(state.copyWith(loadingState: state.loadingState.loading()));
    try {
      final userId = _authRepository.currentUser!.id;
      await _apartmentRepository.deleteUserApartment(
          apartmentId: apartmentId, userId: userId);
      final updatedApartments = state.apartments
          .where((apartment) => apartment.id != int.tryParse(apartmentId))
          .toList();
      emit(state.copyWith(
          apartments: updatedApartments,
          loadingState: state.loadingState.success()));
    } on AppException catch (e) {
      log("Error deleting apartment: $e");
      emit(state.copyWith(loadingState: state.loadingState.failure(e)));
    }
  }

  Future<void> deleteMarketplace({required int itemId}) async {
    emit(state.copyWith(loadingState: state.loadingState.loading()));
    try {
      final userId = _authRepository.currentUser!.id;
      await _marketplaceRepository.deleteUserMarketplace(
          itemId: itemId, userId: userId);
      final updatedMarketplaces = state.marketplaces
          .where((marketplace) => marketplace.id != itemId)
          .toList();
      emit(state.copyWith(
          marketplaces: updatedMarketplaces,
          loadingState: state.loadingState.success()));
    } on AppException catch (e) {
      log("Error deleting marketplace: ${(e as MarketplaceError).hint}");
      emit(state.copyWith(loadingState: state.loadingState.failure(e)));
    }
  }
}
