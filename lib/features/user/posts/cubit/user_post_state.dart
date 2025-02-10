import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/utils/bloc_state.dart';

class UserPostLoadingState extends BlocState {
  UserPostLoadingState({
    required bool isLoading,
    required AppException? exception,
    required bool isSuccess,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          isSuccess: isSuccess,
        );

  @override
  UserPostLoadingState copyWith(
      {bool? isLoading, AppException? error, bool? isSuccess}) {
    return UserPostLoadingState(
      isLoading: isLoading ?? this.isLoading,
      exception: error ?? exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  UserPostLoadingState failure(AppException error) {
    return UserPostLoadingState(
      isLoading: false,
      exception: error,
      isSuccess: false,
    );
  }

  @override
  UserPostLoadingState loading() {
    return UserPostLoadingState(
      isLoading: true,
      exception: null,
      isSuccess: false,
    );
  }

  @override
  UserPostLoadingState resetLoading() {
    return copyWith(isLoading: false);
  }

  @override
  UserPostLoadingState success() {
    return UserPostLoadingState(
      isLoading: false,
      exception: null,
      isSuccess: true,
    );
  }
}

class UserPostState {
  final List<SubletModel> sublets;
  final List<MarketplaceModel> marketplaces;
  final List<ApartmentModel> apartments;
  final PostView postView;
  final UserPostLoadingState? loadingState;

  UserPostState({
    required this.postView,
    this.sublets = const [],
    this.marketplaces = const [],
    this.apartments = const [],
    this.loadingState,
  });

  UserPostState copyWith({
    List<SubletModel>? sublets,
    List<MarketplaceModel>? marketplaces,
    List<ApartmentModel>? apartments,
    UserPostLoadingState? loadingState,
  }) {
    return UserPostState(
      postView: postView,
      sublets: sublets ?? this.sublets,
      marketplaces: marketplaces ?? this.marketplaces,
      apartments: apartments ?? this.apartments,
      loadingState: loadingState ?? this.loadingState,
    );
  }

  //when
  R when<R>({
    required R Function() loading,
    required R Function(AppException error) error,
    required R Function(
            List<SubletModel> sublets,
            List<MarketplaceModel> marketplaces,
            List<ApartmentModel> apartments,
            PostView postView)
        data,
  }) {
    if (loadingState?.isLoading == true) {
      return loading();
    } else if (loadingState?.exception != null) {
      return error(loadingState!.exception!);
    } else {
      return data(sublets, marketplaces, apartments, postView);
    }
  }
}

enum PostView {
  sublet,
  marketplace,
  apartment,
}
