import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/user/user.dart';

part 'user_state.dart';
part 'user_event.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(
    User user,
  ) : super(UserState(user: user)) {
    on<UserEvent>(
      (event, emit) async => await event.when(
        loadUser: (user) => emit(state.copyWith(user: user)),
        loadUniversities: () async => await _loadUniversities(event, emit),
        loadDegrees: () async => await _loadDegrees(event, emit),
        loadMarketplaceCategories: () async =>
            await _loadMarketplaceCategories(event, emit),
      ),
    );
    add(UserEvent.loadUser(user: user));
    add(const UserEvent.loadUniversities());
    add(const UserEvent.loadDegrees());
    add(const UserEvent.loadMarketplaceCategories());
  }

  final UserRepository _userRepository = GetIt.I<UserRepository>();
  final LocalStorageRepository _localStorageRepository =
      GetIt.I<LocalStorageRepository>();
  final MarketplaceRepository _marketplaceRepository =
      GetIt.I<MarketplaceRepository>();

  Future<void> _loadUniversities(
      UserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoadingUniversities: true));
    final cachedUniversities = _localStorageRepository.getListClass(
        LocalStorageKeys.universityList, (p0) => University.fromJson(p0));
    if (cachedUniversities?.isNotEmpty ?? false) {
      emit(state.copyWith(
          universities: cachedUniversities, isLoadingUniversities: false));
    }
    try {
      final universities = await _userRepository.getAllUniversities();
      if (universities.isNotEmpty) {
        _localStorageRepository.saveListClass(LocalStorageKeys.universityList,
            universities, (p0) => p0?.toJson() ?? {});
        emit(state.copyWith(
            universities: universities, isLoadingUniversities: false));
      } else {
        emit(state.copyWith(isLoadingUniversities: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingUniversities: false));
    }
  }

  Future<void> _loadDegrees(UserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoadingDegrees: true));
    final cachedDegrees = _localStorageRepository.getListClass(
        LocalStorageKeys.degreeList, (p0) => Degree.fromJson(p0));
    if (cachedDegrees?.isNotEmpty ?? false) {
      emit(state.copyWith(degrees: cachedDegrees, isLoadingDegrees: false));
    }
    try {
      final degrees = await _userRepository.getAllDegrees();
      if (degrees.isNotEmpty) {
        _localStorageRepository.saveListClass(
            LocalStorageKeys.degreeList, degrees, (p0) => p0?.toJson() ?? {});
        emit(state.copyWith(degrees: degrees, isLoadingDegrees: false));
      } else {
        emit(state.copyWith(isLoadingDegrees: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingDegrees: false));
    }
  }

  Future<void> _loadMarketplaceCategories(
      UserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoadingMarketplaceCategory: true));
    final cachedMarketplaceCategories = _localStorageRepository.getListClass(
        LocalStorageKeys.marketplaceCategoryList,
        (p0) => MarketplaceCategoryModel.fromJson(p0));
    if (cachedMarketplaceCategories?.isNotEmpty ?? false) {
      emit(state.copyWith(
          marketplaceCategory: cachedMarketplaceCategories,
          isLoadingMarketplaceCategory: false));
    }
    try {
      final marketplaceCategories =
          await _marketplaceRepository.getMarketplaceCategories();
      if (marketplaceCategories.isNotEmpty) {
        _localStorageRepository.saveListClass(
            LocalStorageKeys.marketplaceCategoryList,
            marketplaceCategories,
            (p0) => p0.toJson());
        emit(state.copyWith(
            marketplaceCategory: marketplaceCategories,
            isLoadingMarketplaceCategory: false));
      } else {
        emit(state.copyWith(isLoadingMarketplaceCategory: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingMarketplaceCategory: false));
    }
  }
}
