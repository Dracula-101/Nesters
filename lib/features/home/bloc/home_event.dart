part of 'home_bloc.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class LoadProfileEvent extends HomeEvent {
  final UserInfo user;
  LoadProfileEvent(this.user);
}

class LoadProfileCompleteEvent extends HomeEvent {
  final List<UserQuickProfile> profiles;
  LoadProfileCompleteEvent(this.profiles);
}

class LoadProfileErrorEvent extends HomeEvent {
  final AppException error;
  LoadProfileErrorEvent(this.error);
}

class FetchNextPageEvent extends HomeEvent {}

// Filters for user profile
class SingleAddFilterProfileEvent extends HomeEvent {
  final SingleUserFilter filter;
  SingleAddFilterProfileEvent(this.filter);
}

class SingleRemoveFilterProfileEvent extends HomeEvent {
  SingleRemoveFilterProfileEvent();
}

class AddFilterProfileEvent extends HomeEvent {
  final UserFilter? filter;
  AddFilterProfileEvent(this.filter);
}

class RemoveFilterProfileEvent extends HomeEvent {
  RemoveFilterProfileEvent();
}
