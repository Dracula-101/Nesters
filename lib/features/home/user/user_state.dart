part of 'user_bloc.dart';

class UserState {
  final User user;
  final List<University?> universities;
  final bool isLoadingUniversities;
  final List<Degree?> degrees;
  final bool isLoadingDegrees;
  final List<MarketplaceCategoryModel> marketplaceCategory;
  final bool isLoadingMarketplaceCategory;

  const UserState({
    required this.user,
    this.universities = const [],
    this.isLoadingUniversities = false,
    this.degrees = const [],
    this.isLoadingDegrees = false,
    this.marketplaceCategory = const [],
    this.isLoadingMarketplaceCategory = false,
  });

  UserState copyWith({
    User? user,
    List<University?>? universities,
    bool? isLoadingUniversities,
    List<Degree?>? degrees,
    bool? isLoadingDegrees,
    List<MarketplaceCategoryModel>? marketplaceCategory,
    bool? isLoadingMarketplaceCategory,
  }) {
    return UserState(
      user: user ?? this.user,
      universities: universities ?? this.universities,
      isLoadingUniversities:
          isLoadingUniversities ?? this.isLoadingUniversities,
      degrees: degrees ?? this.degrees,
      isLoadingDegrees: isLoadingDegrees ?? this.isLoadingDegrees,
      marketplaceCategory: marketplaceCategory ?? this.marketplaceCategory,
      isLoadingMarketplaceCategory:
          isLoadingMarketplaceCategory ?? this.isLoadingMarketplaceCategory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserState &&
        other.user == user &&
        listEquals(other.universities, universities) &&
        other.isLoadingUniversities == isLoadingUniversities &&
        listEquals(other.degrees, degrees) &&
        other.isLoadingDegrees == isLoadingDegrees &&
        listEquals(other.marketplaceCategory, marketplaceCategory) &&
        other.isLoadingMarketplaceCategory == isLoadingMarketplaceCategory;
  }

  @override
  int get hashCode =>
      user.hashCode ^
      universities.hashCode ^
      isLoadingUniversities.hashCode ^
      degrees.hashCode ^
      isLoadingDegrees.hashCode;
}
