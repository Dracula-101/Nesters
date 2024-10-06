part of 'user_bloc.dart';

// @freezed
// class UserEvent with _$UserEvent {

//   const factory UserEvent.loadUser({
//     required User user,
//   }) = _LoadUser;
//   const factory UserEvent.loadUniversities() = _LoadUniversities;
//   const factory UserEvent.loadDegrees() = _LoadDegrees;
// }

class UserEvent {
  const UserEvent();
  const factory UserEvent.loadUser({
    required User user,
  }) = _LoadUser;
  const factory UserEvent.loadUniversities() = _LoadUniversities;
  const factory UserEvent.loadDegrees() = _LoadDegrees;

  R when<R>({
    required R Function(User user) loadUser,
    required R Function() loadUniversities,
    required R Function() loadDegrees,
  }) {
    if (this is _LoadUser) {
      return loadUser((this as _LoadUser).user);
    } else if (this is _LoadUniversities) {
      return loadUniversities();
    } else if (this is _LoadDegrees) {
      return loadDegrees();
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R maybeWhen<R>({
    R Function(User user)? loadUser,
    R Function()? loadUniversities,
    R Function()? loadDegrees,
    required R Function() orElse,
  }) {
    if (this is _LoadUser) {
      return loadUser != null ? loadUser((this as _LoadUser).user) : orElse();
    } else if (this is _LoadUniversities) {
      return loadUniversities != null ? loadUniversities() : orElse();
    } else if (this is _LoadDegrees) {
      return loadDegrees != null ? loadDegrees() : orElse();
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R whenOrNull<R>({
    R Function(User user)? loadUser,
    R Function()? loadUniversities,
    R Function()? loadDegrees,
    required R Function() orElse,
  }) {
    if (this is _LoadUser) {
      return loadUser != null ? loadUser((this as _LoadUser).user) : orElse();
    } else if (this is _LoadUniversities) {
      return loadUniversities != null ? loadUniversities() : orElse();
    } else if (this is _LoadDegrees) {
      return loadDegrees != null ? loadDegrees() : orElse();
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R maybeWhenOrNull<R>({
    R Function(User user)? loadUser,
    R Function()? loadUniversities,
    R Function()? loadDegrees,
    required R Function() orElse,
  }) {
    if (this is _LoadUser) {
      return loadUser != null ? loadUser((this as _LoadUser).user) : orElse();
    } else if (this is _LoadUniversities) {
      return loadUniversities != null ? loadUniversities() : orElse();
    } else if (this is _LoadDegrees) {
      return loadDegrees != null ? loadDegrees() : orElse();
    } else {
      return orElse();
    }
  }
}

class _LoadUser extends UserEvent {
  final User user;
  const _LoadUser({required this.user});
}

class _LoadUniversities extends UserEvent {
  const _LoadUniversities();
}

class _LoadDegrees extends UserEvent {
  const _LoadDegrees();
}
