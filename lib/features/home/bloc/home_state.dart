part of 'home_bloc.dart';

class HomeState {
  final List<UserQuickProfile>? profiles;
  final Exception? error;
  final bool isLoading;

  const HomeState({
    this.profiles,
    this.error,
    this.isLoading = true,
  });

  HomeState copyWith({
    List<UserQuickProfile>? profiles,
    Exception? error,
    bool? isLoading,
  }) {
    return HomeState(
      profiles: profiles ?? this.profiles,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HomeState &&
        listEquals(other.profiles, profiles) &&
        other.error == error &&
        other.isLoading == isLoading;
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
  }) {
    if (isLoading) {
      return loading();
    } else if (profiles != null) {
      return loaded(profiles, error, isLoading);
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
    required R Function() orElse,
  }) {
    if (isLoading) {
      return loading?.call() ?? orElse.call();
    } else if (profiles != null) {
      return loaded?.call(profiles, error, isLoading) ?? orElse.call();
    } else {
      return initial?.call() ?? orElse.call();
    }
  }

  R map<R>({
    required R Function(HomeState) loaded,
    required R Function(HomeState) initial,
    required R Function(HomeState) loading,
    required R Function(HomeState) fetchNextPage,
  }) {
    if (isLoading) {
      return loading(this);
    } else if (profiles != null) {
      return loaded(this);
    } else {
      return initial(this);
    }
  }

  R maybeMap<R>({
    R Function(HomeState)? loaded,
    R Function(HomeState)? initial,
    R Function(HomeState)? loading,
    R Function(HomeState)? fetchNextPage,
    required R Function(HomeState) orElse,
  }) {
    if (isLoading) {
      return loading?.call(this) ?? orElse.call(this);
    } else if (profiles != null) {
      return loaded?.call(this) ?? orElse.call(this);
    } else {
      return initial?.call(this) ?? orElse.call(this);
    }
  }
}
