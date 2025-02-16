part of 'home_bloc.dart';

class HomeState extends Equatable {
  final List<UserQuickProfile>? profiles;
  final List<UserQuickProfile>? filteredProfiles;
  final BlocState filterState;
  final UserInfo? user;
  final UserFilter? userFilter;
  // Single category of user filtering
  final SingleUserFilter? singleUserFilter;

  const HomeState({
    this.user,
    this.profiles,
    this.filteredProfiles,
    this.filterState = const BlocState(),
    this.userFilter,
    this.singleUserFilter,
  });

  @override
  List<Object?> get props => [
        profiles,
        filteredProfiles,
        filterState,
        user,
        userFilter,
        singleUserFilter,
      ];

  HomeState copyWith({
    List<UserQuickProfile>? profiles,
    List<UserQuickProfile>? filteredProfiles,
    BlocState? filterState,
    UserInfo? user,
    UserFilter? userFilter,
    SingleUserFilter? singleUserFilter,
  }) {
    return HomeState(
      profiles: profiles ?? this.profiles,
      filteredProfiles: filteredProfiles,
      filterState: filterState ?? this.filterState,
      userFilter: userFilter,
      user: user ?? this.user,
      singleUserFilter: singleUserFilter,
    );
  }

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(AppException) error,
    required R Function(List<UserQuickProfile>? profiles) loaded,
    required R Function(List<UserQuickProfile>? profiles) fetchNextPage,
    required R Function(UserFilter? userFilter) filterUsers,
    required R Function(SingleUserFilter? userFilter) filterSingle,
  }) {
    if (filterState.isLoading) {
      return loading();
    } else if (filterState.exception != null) {
      return error(filterState.exception!);
    } else if (profiles != null) {
      return loaded(
        profiles,
      );
    } else if (userFilter != null) {
      return filterUsers(userFilter);
    } else {
      return initial();
    }
  }

  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(AppException)? error,
    R Function(List<UserQuickProfile>? profiles)? loaded,
    R Function(List<UserQuickProfile>? profiles)? fetchNextPage,
    R Function(UserFilter? userFilter)? filterUsers,
    R Function(SingleUserFilter? userFilter)? filterSingle,
    required R Function() orElse,
  }) {
    if (filterState.isLoading) {
      return loading?.call() ?? orElse.call();
    } else if (filterState.exception != null) {
      return error?.call(filterState.exception!) ?? orElse.call();
    } else if (profiles != null) {
      return loaded?.call(profiles) ?? orElse.call();
    } else if (userFilter != null) {
      return filterUsers?.call(userFilter) ?? orElse.call();
    } else if (singleUserFilter != null) {
      return filterSingle?.call(singleUserFilter) ?? orElse.call();
    } else {
      return initial?.call() ?? orElse.call();
    }
  }

  R map<R>({
    required R Function(HomeState) initial,
    required R Function(HomeState) loading,
    required R Function(HomeState) error,
    required R Function(HomeState) loaded,
    required R Function(HomeState) fetchNextPage,
    required R Function(HomeState) filterUsers,
    required R Function(HomeState) singleFilter,
  }) {
    if (filterState.isLoading) {
      return loading(this);
    } else if (filterState.exception != null) {
      return error(this);
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
    R Function(HomeState)? initial,
    R Function(HomeState)? loading,
    R Function(HomeState)? error,
    R Function(HomeState)? loaded,
    R Function(HomeState)? fetchNextPage,
    R Function(HomeState)? filterUsers,
    R Function(HomeState)? singleFilter,
    required R Function(HomeState) orElse,
  }) {
    if (filterState.isLoading) {
      return loading?.call(this) ?? orElse.call(this);
    } else if (filterState.exception != null) {
      return error?.call(this) ?? orElse.call(this);
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
  final University university;

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
