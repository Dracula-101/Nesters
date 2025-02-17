import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/location/city_info.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/user/address.dart';
import 'package:nesters/domain/models/user/form/user_advance_profile.dart';
import 'package:nesters/domain/models/user/form/user_basic_profile.dart';
import 'package:nesters/domain/models/user/profile/user_filter.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/features/home/bloc/home_bloc.dart';
import 'package:nesters/features/user/edit-profile/cubit/edit_profile_state.dart';
import 'package:nesters/features/user/profile-forms/forms/cubit/form_cubit.dart';

abstract class UserRepository {
  Future<void> setOnBoardingComplete();

  bool checkUserOnboardingStatus();

  bool checkUserTutorialComplete();

  Future<void> markUserTutorialComplete();

  Future<List<MarketplaceModel>> getMarketplaceData();

  Future<List<University>> getAllUniversities();

  Future<List<Degree>> getAllDegrees();

  Future<List<CityInfo>> searchCities({required String searchQuery});

  Future<bool?> checkUserCreated(String userId);

  Future<void> updateRoommateFoundStatus({
    required String id,
    required bool status,
  });

  Future<List<University>> getUniversities(String? searchString);

  Future<List<Degree>> getMastersDegree(String? searchString);

  Future<List<Language>> getLanguage(String? searchQuery);

  Future<List<Language>> getLanguages();

  Future<List<SearchAddress>> searchAddress(String? searchQuery);

  Future<bool> setBasicUserProfileData(UserBasicProfile userProfile);

  Future<bool> hasUserDeletedAccount({required String email});

  Future<List<UserQuickProfile>> getUserQuickProfiles(
      int offset, int limit, String userId);

  Future<List<UserQuickProfile>> getSingleFilteredQuickProfiles(
    SingleUserFilter filter,
  );

  Future<List<UserQuickProfile>> getMultipleFilteredQuickProfiles(
    UserFilter filters,
  );

  Future<UserProfile> getUserProfile(String userId);

  Future<void> completeProfileInfo(UserFormProfile profile);

  Future<void> editProfile(UserEditProfile profile, String userId);

  Future<UserAdvanceProfile> getUserFullProfile(String userId);

  Future<void> softDeleteAccount();

  Future<String> uploadProfileImage(
    String profileImagePath,
    String userId, {
    String? previousImageUrl,
  });
}
