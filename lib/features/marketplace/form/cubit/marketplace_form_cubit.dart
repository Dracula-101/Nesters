import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_link_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_period_model.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'marketplace_form_state.dart';
part 'marketplace_form_cubit.freezed.dart';

class MarketplaceFormCubit extends Cubit<MarketplaceFormState> {
  MarketplaceFormCubit() : super(MarketplaceFormState.initial());

  final MarketplaceRepository _marketplaceRepository =
      GetIt.I<MarketplaceRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();
  int itemId = DateTime.now().millisecondsSinceEpoch;

  void validatePage() {
    emit(state.copyWith(isValidating: false));
    emit(state.copyWith(isValidating: true));
  }

  void onPageChange(int pageNumber) {
    emit(state.copyWith(pageNumber: pageNumber, isValidating: false));
  }

  void showPageValid(int page) {
    if (page == 1) {
      emit(state.copyWith(hasSecondPageAccess: true));
    }
  }

  void addFirstPageData({
    required String name,
    required String address,
    required DateTime startDate,
    required DateTime? endDate,
    required String description,
    required double itemPrice,
    required MarketplaceCategoryModel category,
    required MarketplaceLinkModel? link,
  }) {
    MarketplaceModel model = MarketplaceModel(
      id: itemId,
      name: name,
      location: Location(address: address),
      period: MarketplacePeriodModel(
        periodFrom: startDate,
        periodTill: endDate,
      ),
      category: category,
      createdAt: DateTime.now(),
      isAvailable: true,
      reference: link,
      description: description,
      price: itemPrice.toInt(),
    );
    emit(state.copyWith(item: model));
  }

  Future<void> createSublet(
    List<String> imagesPath,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      String? userId = _authRepository.currentUser?.id;
      if (userId == null) {
        emit(state.copyWith(submitError: Exception('User ID is null')));
        return;
      }
      Stream<MarketplaceImageUploadTask> uploadImageStream =
          _marketplaceRepository.uploadImages(
        userId: userId,
        itemId: itemId.toString(),
        imagePaths: imagesPath,
      );
      List<String> uploadedImagesUrl = [];
      await for (MarketplaceImageUploadTask value in uploadImageStream) {
        emit(state.copyWith(imageUploadTask: value));
        uploadedImagesUrl
          ..clear()
          ..addAll(value.urls?.toList() ?? []);
        _logger.info('Uploading: ${value.progress}');
      }
      if (uploadedImagesUrl.isEmpty) {
        emit(state.copyWith(submitError: Exception('No images uploaded')));
        return;
      }
      MarketplaceModel? model = state.item?.copyWith(photos: uploadedImagesUrl);
      await _marketplaceRepository.createMarketplace(
        userId: userId,
        item: model!,
      );
      emit(state.copyWith(
        submitError: null,
        imageUploadTask: null,
        isSubmitting: false,
        isSubmitComplete: true,
      ));
    } on Exception catch (e) {
      _logger.log('Error creating sublet: $e');
      emit(state.copyWith(
        submitError: e,
        isSubmitting: false,
        isSubmitComplete: false,
        imageUploadTask: null,
      ));
    }
  }

  Future<List<MarketplaceCategoryModel>> getCategories() {
    return _marketplaceRepository.getMarketplaceCategories();
  }
}
