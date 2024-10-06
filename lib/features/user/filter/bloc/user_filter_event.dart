part of 'user_filter_bloc.dart';

abstract class UserFilterEvent {
  const factory UserFilterEvent.started() = _Started;
}

class _Started implements UserFilterEvent {
  const _Started();
}
