part of 'sublet_bloc.dart';

@freezed
class SubletEvent with _$SubletEvent {
  const factory SubletEvent.initial() = _Initial;
  const factory SubletEvent.loadSublet() = _LoadSublet;
  const factory SubletEvent.reloadSublet() = _ReloadSublet;
}
