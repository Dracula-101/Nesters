part of 'home_bloc.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class LoadProfileEvent extends HomeEvent {}

class LoadProfileCompleteEvent extends HomeEvent {
  final List<UserQuickProfile> profiles;
  LoadProfileCompleteEvent(this.profiles);
}

class LoadProfileErrorEvent extends HomeEvent {
  final Exception error;
  LoadProfileErrorEvent(this.error);
}

class FetchNextPageEvent extends HomeEvent {}
