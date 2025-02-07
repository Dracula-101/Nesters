import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';

class UserPostState {
  final List<SubletModel> sublets;
  final List<MarketplaceModel> marketplaces;
  final List<ApartmentModel> apartments;
  final PostView postView;
  final bool isLoading;
  final Exception? error;

  UserPostState({
    required this.postView,
    this.sublets = const [],
    this.marketplaces = const [],
    this.apartments = const [],
    this.isLoading = false,
    this.error,
  });

  UserPostState copyWith({
    List<SubletModel>? sublets,
    List<MarketplaceModel>? marketplaces,
    List<ApartmentModel>? apartments,
    bool? isLoading,
    Exception? error,
  }) {
    return UserPostState(
      postView: postView,
      sublets: sublets ?? this.sublets,
      marketplaces: marketplaces ?? this.marketplaces,
      apartments: apartments ?? this.apartments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // when
  R when<R>({
    required R Function(
            List<SubletModel> sublets,
            List<MarketplaceModel> marketplaces,
            List<ApartmentModel> apartments,
            PostView view)
        data,
    required R Function() loading,
    required R Function(String message) showError,
  }) {
    if (isLoading) {
      return loading();
    } else if (error != null) {
      return showError(error.toString());
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
