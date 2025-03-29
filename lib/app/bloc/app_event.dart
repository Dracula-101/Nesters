part of 'app_bloc.dart';

class AppEvent {
  const AppEvent();
  const factory AppEvent.load() = _Load;
  const factory AppEvent.loaded({
    required bool isSuccessful,
    required bool isOnboaringComplete,
    required AppThemeMode themeMode,
  }) = _Loaded;
  const factory AppEvent.changeThemeMode({
    required AppThemeMode themeMode,
  }) = _ChangeThemeMode;
  const factory AppEvent.networkChange({
    required NetworkData data,
    required bool isOnline,
  }) = _NetworkChange;
  const factory AppEvent.loadUniversities() = _LoadUniversities;
  const factory AppEvent.loadDegrees() = _LoadDegrees;
  const factory AppEvent.loadMarketplaceCategories() =
      _LoadMarketplaceCategories;
  const factory AppEvent.loadLanguages() = _LoadLanguages;

  Future<void> when<R>({
    required Future<void> Function() load,
    required void Function(bool isSuccessful, bool isOnboaringComplete) loaded,
    required void Function(AppThemeMode themeMode) changeThemeMode,
    required void Function(NetworkData data, bool isOnline) networkChange,
    required Future<void> Function() loadUniversities,
    required Future<void> Function() loadDegrees,
    required Future<void> Function() loadMarketplaceCategories,
    required Future<void> Function() loadLanguages,
  }) {
    if (this is _Load) {
      return load();
    } else if (this is _Loaded) {
      loaded((this as _Loaded).isSuccessful,
          (this as _Loaded).isOnboaringComplete);
      return Future.value();
    } else if (this is _ChangeThemeMode) {
      changeThemeMode((this as _ChangeThemeMode).themeMode);
      return Future.value();
    } else if (this is _NetworkChange) {
      networkChange(
          (this as _NetworkChange).data, (this as _NetworkChange).isOnline);
      return Future.value();
    } else if (this is _LoadUniversities) {
      return loadUniversities();
    } else if (this is _LoadDegrees) {
      return loadDegrees();
    } else if (this is _LoadMarketplaceCategories) {
      return loadMarketplaceCategories();
    } else if (this is _LoadLanguages) {
      return loadLanguages();
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R maybeWhen<R>({
    R Function()? load,
    R Function(bool isSuccessful, bool isOnboaringComplete)? loaded,
    R Function(AppThemeMode themeMode)? changeThemeMode,
    R Function(NetworkData data, bool isOnline)? networkChange,
    R Function()? loadUniversities,
    R Function()? loadDegrees,
    R Function()? loadMarketplaceCategories,
    R Function()? loadLanguages,
    required R Function() orElse,
  }) {
    if (this is _Load) {
      return load != null ? load() : orElse();
    } else if (this is _Loaded) {
      return loaded != null
          ? loaded((this as _Loaded).isSuccessful,
              (this as _Loaded).isOnboaringComplete)
          : orElse();
    }  else if (this is _ChangeThemeMode) {
      return changeThemeMode != null
          ? changeThemeMode((this as _ChangeThemeMode).themeMode)
          : orElse();
    } else if (this is _NetworkChange) {
      return networkChange != null
          ? networkChange(
              (this as _NetworkChange).data, (this as _NetworkChange).isOnline)
          : orElse();
    } else if (this is _LoadUniversities) {
      return loadUniversities != null ? loadUniversities() : orElse();
    } else if (this is _LoadDegrees) {
      return loadDegrees != null ? loadDegrees() : orElse();
    } else if (this is _LoadMarketplaceCategories) {
      return loadMarketplaceCategories != null
          ? loadMarketplaceCategories()
          : orElse();
    } else if (this is _LoadLanguages) {
      return loadLanguages != null ? loadLanguages() : orElse();
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R whenOrNull<R>({
    R Function()? load,
    R Function(bool isSuccessful, bool isOnboaringComplete)? loaded,
    R Function(AppThemeMode themeMode)? changeThemeMode,
    R Function(NetworkData data, bool isOnline)? networkChange,
    R Function()? loadUniversities,
    R Function()? loadDegrees,
    R Function()? loadMarketplaceCategories,
    R Function()? loadLanguages,
    required R Function() orElse,
  }) {
    if (this is _Load) {
      return load != null ? load() : orElse();
    } else if (this is _Loaded) {
      return loaded != null
          ? loaded((this as _Loaded).isSuccessful,
              (this as _Loaded).isOnboaringComplete)
          : orElse();
    }  else if (this is _ChangeThemeMode) {
      return changeThemeMode != null
          ? changeThemeMode((this as _ChangeThemeMode).themeMode)
          : orElse();
    } else if (this is _NetworkChange) {
      return networkChange != null
          ? networkChange(
              (this as _NetworkChange).data, (this as _NetworkChange).isOnline)
          : orElse();
    } else if (this is _LoadUniversities) {
      return loadUniversities != null ? loadUniversities() : orElse();
    } else if (this is _LoadDegrees) {
      return loadDegrees != null ? loadDegrees() : orElse();
    } else if (this is _LoadMarketplaceCategories) {
      return loadMarketplaceCategories != null
          ? loadMarketplaceCategories()
          : orElse();
    } else if (this is _LoadLanguages) {
      return loadLanguages != null ? loadLanguages() : orElse();
    } else {
      throw Exception('Unknown event: $this');
    }
  }
}

class _Load extends AppEvent {
  const _Load() : super();
}

class _Loaded extends AppEvent {
  final bool isSuccessful;
  final bool isOnboaringComplete;
  final AppThemeMode themeMode;

  const _Loaded({
    required this.isSuccessful,
    required this.isOnboaringComplete,
    required this.themeMode,
  }) : super();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _Loaded &&
        other.isSuccessful == isSuccessful &&
        other.isOnboaringComplete == isOnboaringComplete &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode => isSuccessful.hashCode ^ isOnboaringComplete.hashCode ^
      themeMode.hashCode;
}

class _ChangeThemeMode extends AppEvent {
  final AppThemeMode themeMode;

  const _ChangeThemeMode({
    required this.themeMode,
  }) : super();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _ChangeThemeMode && other.themeMode == themeMode;
  }

  @override
  int get hashCode => themeMode.hashCode;
}

class _NetworkChange extends AppEvent {
  final NetworkData data;
  final bool isOnline;

  const _NetworkChange({
    required this.data,
    required this.isOnline,
  }) : super();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _NetworkChange &&
        other.data == data &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode => data.hashCode ^ isOnline.hashCode;
}

class _LoadUniversities extends AppEvent {
  const _LoadUniversities();
}

class _LoadDegrees extends AppEvent {
  const _LoadDegrees();
}

class _LoadMarketplaceCategories extends AppEvent {
  const _LoadMarketplaceCategories();
}

class _LoadLanguages extends AppEvent {
  const _LoadLanguages();
}
