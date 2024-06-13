part of 'sublet_bloc.dart';

@freezed
class SubletEvent with _$SubletEvent {
  const factory SubletEvent.initial() = _Initial;
  const factory SubletEvent.saveSublets(List<SubletModel> sublets) =
      _SaveSublets;
}
