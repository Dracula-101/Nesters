part of 'home_bloc.dart';

class HomeState extends Equatable {
  final List<UserQuickProfile>? profiles;
  final List<UserQuickProfile>? filteredProfiles;
  final Exception? error;
  final bool isLoading;
  final UserInfo? user;
  final UserFilter? userFilter;
  // Single category of user filtering
  final SingleUserFilter? singleUserFilter;

  const HomeState({
    this.user,
    this.profiles,
    this.filteredProfiles,
    this.error,
    this.isLoading = true,
    this.userFilter,
    this.singleUserFilter,
  });

  @override
  List<Object?> get props => [
        profiles,
        filteredProfiles,
        error,
        isLoading,
        user,
        userFilter,
        singleUserFilter,
      ];

  HomeState copyWith({
    List<UserQuickProfile>? profiles,
    List<UserQuickProfile>? filteredProfiles,
    Exception? error,
    bool? isLoading,
    UserInfo? user,
    UserFilter? userFilter,
    SingleUserFilter? singleUserFilter,
  }) {
    return HomeState(
      profiles: profiles ?? this.profiles,
      filteredProfiles: filteredProfiles,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      userFilter: userFilter,
      user: user ?? this.user,
      singleUserFilter: singleUserFilter,
    );
  }

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
    } else if (singleUserFilter != null) {
      return singleFilter(this);
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
