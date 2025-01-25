import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
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
      final posts = await _subletRepository.getSubletsByUserId(userId: userId);
      emit(state.copyWith(sublets: posts, isLoading: false));
    } on Exception catch (e) {
      emit(state.copyWith(error: e));
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
      emit(state.copyWith(error: e));
    }
  }
}
