part of 'home_bloc.dart';

class HomeState {
  final List<UserQuickProfile>? profiles;
  final List<UserQuickProfile>? filteredProfiles;
  final Exception? error;
  final bool isLoading;
  // Advanced filtering
  final UserFilter? userFilter;
  // Single category of user filtering
  final SingleUserFilter? singleUserFilter;

  const HomeState({
    this.profiles,
    this.filteredProfiles,
    this.error,
    this.isLoading = true,
    this.userFilter,
    this.singleUserFilter,
  });

  HomeState copyWith({
    List<UserQuickProfile>? profiles,
    List<UserQuickProfile>? filteredProfiles,
    Exception? error,
    bool? isLoading,
    UserFilter? userFilter,
    SingleUserFilter? singleUserFilter,
  }) {
    return HomeState(
      profiles: profiles ?? this.profiles,
      filteredProfiles: filteredProfiles,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      userFilter: userFilter,
      singleUserFilter: singleUserFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HomeState &&
        listEquals(other.profiles, profiles) &&
        other.error == error &&
        other.isLoading == isLoading &&
        other.userFilter == userFilter &&
        other.singleUserFilter == singleUserFilter;
  }

  @override
  int get hashCode => profiles.hashCode ^ error.hashCode ^ isLoading.hashCode;

  R when<R>({
    required R Function(
            List<UserQuickProfile>? profiles, Exception? error, bool isLoading)
        loaded,
    required R Function() initial,
    required R Function() loading,
    required R Function(List<UserQuickProfile>? profiles) fetchNextPage,
    required R Function(UserFilter? userFilter) filterUsers,
    required R Function(SingleUserFilter? userFilter) filterSingle,
  }) {
    if (isLoading) {
      return loading();
    } else if (profiles != null) {
      return loaded(profiles, error, isLoading);
    } else if (userFilter != null) {
      return filterUsers(userFilter);
    } else if (singleUserFilter != null) {
      return filterSingle(singleUserFilter);
    } else {
      return initial();
    }
  }

  R maybeWhen<R>({
    R Function(
            List<UserQuickProfile>? profiles, Exception? error, bool isLoading)?
        loaded,
    R Function()? initial,
    R Function()? loading,
    R Function(List<UserQuickProfile>? profiles)? fetchNextPage,
    R Function(UserFilter? userFilter)? filterUsers,
    R Function(SingleUserFilter? userFilter)? filterSingle,
    required R Function() orElse,
  }) {
    if (isLoading) {
      return loading?.call() ?? orElse.call();
    } else if (profiles != null) {
      return loaded?.call(profiles, error, isLoading) ?? orElse.call();
    } else if (userFilter != null) {
      return filterUsers?.call(userFilter) ?? orElse.call();
    } else if (singleUserFilter != null) {
      return filterSingle?.call(singleUserFilter) ?? orElse.call();
    } else {
      return initial?.call() ?? orElse.call();
    }
  }

  R map<R>({
    required R Function(HomeState) loaded,
    required R Function(HomeState) initial,
    required R Function(HomeState) loading,
    required R Function(HomeState) fetchNextPage,
    required R Function(HomeState) filterUsers,
    required R Function(HomeState) singleFilter,
  }) {
    if (isLoading) {
      return loading(this);
    } else if (profiles != null) {
      return loaded(this);
    } else if (userFilter != null) {
      return filterUsers(this);
    } else {
      return initial(this);
    }
  }

  R maybeMap<R>({
    R Function(HomeState)? loaded,
    R Function(HomeState)? initial,
    R Function(HomeState)? loading,
    R Function(HomeState)? fetchNextPage,
    R Function(HomeState)? filterUsers,
    R Function(HomeState)? singleFilter,
    required R Function(HomeState) orElse,
  }) {
    if (isLoading) {
      return loading?.call(this) ?? orElse.call(this);
    } else if (profiles != null) {
      return loaded?.call(this) ?? orElse.call(this);
    } else if (userFilter != null) {
      return filterUsers?.call(this) ?? orElse.call(this);
    } else if (singleUserFilter != null) {
      return singleFilter?.call(this) ?? orElse.call(this);
    } else {
      return initial?.call(this) ?? orElse.call(this);
    }
  }
}

abstract class SingleUserFilter {}

class UniversityFilter extends SingleUserFilter {
  final String university;

  UniversityFilter(this.university);
}

class BranchFilter extends SingleUserFilter {
  final String branch;

  BranchFilter(this.branch);
}

class GenderFilter extends SingleUserFilter {
  final String gender;

  GenderFilter(this.gender);
}
