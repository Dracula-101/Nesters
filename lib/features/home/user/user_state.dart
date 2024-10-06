part of 'user_bloc.dart';

// @freezed
// class UserState with _$UserState {
//   factory UserState({
//     required User user,
//     @Default([]) List<University?> universities,
//     @Default(false) bool isLoadingUniversities,
//     @Default([]) List<Degree?> degrees,
//     @Default(false) bool isLoadingDegrees,
//   }) = _UserState;

//   factory UserState.initial() {
//     return UserState(
//       user: User.empty(),
//       universities: [],
//       degrees: [],
//     );
//   }
// }

class UserState {
  final User user;
  final List<University?> universities;
  final bool isLoadingUniversities;
  final List<Degree?> degrees;
  final bool isLoadingDegrees;

  const UserState({
    required this.user,
    this.universities = const [],
    this.isLoadingUniversities = false,
    this.degrees = const [],
    this.isLoadingDegrees = false,
  });

  UserState copyWith({
    User? user,
    List<University?>? universities,
    bool? isLoadingUniversities,
    List<Degree?>? degrees,
    bool? isLoadingDegrees,
  }) {
    return UserState(
      user: user ?? this.user,
      universities: universities ?? this.universities,
      isLoadingUniversities:
          isLoadingUniversities ?? this.isLoadingUniversities,
      degrees: degrees ?? this.degrees,
      isLoadingDegrees: isLoadingDegrees ?? this.isLoadingDegrees,
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
        other.isLoadingDegrees == isLoadingDegrees;
  }

  @override
  int get hashCode =>
      user.hashCode ^
      universities.hashCode ^
      isLoadingUniversities.hashCode ^
      degrees.hashCode ^
      isLoadingDegrees.hashCode;
}
