part of 'app_bloc.dart';

// @freezed
// class AppEvent with _$AppEvent {
//   const factory AppEvent() = _AppEvent;

//   const factory AppEvent.load() = _Load;
//   const factory AppEvent.loaded({
//     required bool isSuccessful,
//     required bool isOnboaringComplete,
//   }) = _Loaded;

//   const factory AppEvent.networkChange({
//     required NetworkData data,
//     required bool isOnline,
//   }) = _NetworkChange;
// }

class AppEvent {
  const AppEvent();
  const factory AppEvent.load() = _Load;
  const factory AppEvent.loaded({
    required bool isSuccessful,
    required bool isOnboaringComplete,
  }) = _Loaded;
  const factory AppEvent.networkChange({
    required NetworkData data,
    required bool isOnline,
  }) = _NetworkChange;

  R when<R>({
    required R Function() load,
    required R Function(bool isSuccessful, bool isOnboaringComplete) loaded,
    required R Function(NetworkData data, bool isOnline) networkChange,
  }) {
    if (this is _Load) {
      return load();
    } else if (this is _Loaded) {
      return loaded((this as _Loaded).isSuccessful,
          (this as _Loaded).isOnboaringComplete);
    } else if (this is _NetworkChange) {
      return networkChange(
          (this as _NetworkChange).data, (this as _NetworkChange).isOnline);
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R maybeWhen<R>({
    R Function()? load,
    R Function(bool isSuccessful, bool isOnboaringComplete)? loaded,
    R Function(NetworkData data, bool isOnline)? networkChange,
    required R Function() orElse,
  }) {
    if (this is _Load) {
      return load != null ? load() : orElse();
    } else if (this is _Loaded) {
      return loaded != null
          ? loaded((this as _Loaded).isSuccessful,
              (this as _Loaded).isOnboaringComplete)
          : orElse();
    } else if (this is _NetworkChange) {
      return networkChange != null
          ? networkChange(
              (this as _NetworkChange).data, (this as _NetworkChange).isOnline)
          : orElse();
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R whenOrNull<R>({
    R Function()? load,
    R Function(bool isSuccessful, bool isOnboaringComplete)? loaded,
    R Function(NetworkData data, bool isOnline)? networkChange,
    required R Function() orElse,
  }) {
    if (this is _Load) {
      return load != null ? load() : orElse();
    } else if (this is _Loaded) {
      return loaded != null
          ? loaded((this as _Loaded).isSuccessful,
              (this as _Loaded).isOnboaringComplete)
          : orElse();
    } else if (this is _NetworkChange) {
      return networkChange != null
          ? networkChange(
              (this as _NetworkChange).data, (this as _NetworkChange).isOnline)
          : orElse();
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

  const _Loaded({
    required this.isSuccessful,
    required this.isOnboaringComplete,
  }) : super();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _Loaded &&
        other.isSuccessful == isSuccessful &&
        other.isOnboaringComplete == isOnboaringComplete;
  }

  @override
  int get hashCode => isSuccessful.hashCode ^ isOnboaringComplete.hashCode;
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
