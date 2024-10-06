part of 'profile_bloc.dart';

// @freezed
// class ProfileEvent with _$ProfileEvent {
//   const factory ProfileEvent.load(String userId) = _Load;
// }

abstract class ProfileEvent {
  const ProfileEvent();

  const factory ProfileEvent.load(String userId) = _Load;

  Future<void> when({
    required Future<void> Function(String userId) load,
  }) async {
    if (this is _Load) {
      return load((this as _Load).userId);
    }
  }

  R maybeWhen<R>({
    R Function(String userId)? load,
    required R Function() orElse,
  }) {
    if (this is _Load) {
      return load?.call((this as _Load).userId) ?? orElse.call();
    } else {
      return orElse.call();
    }
  }

  R map<R>({
    required R Function() load,
  }) {
    if (this is _Load) {
      return load();
    } else {
      throw Exception();
    }
  }

  R maybeMap<R>({
    R Function()? load,
    required R Function(ProfileEvent) orElse,
  }) {
    if (this is _Load) {
      return load?.call() ?? orElse.call(this);
    } else {
      return orElse.call(this);
    }
  }
}

class _Load extends ProfileEvent {
  final String userId;

  const _Load(this.userId);
}
