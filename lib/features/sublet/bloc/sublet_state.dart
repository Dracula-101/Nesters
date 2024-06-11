part of 'sublet_bloc.dart';

@freezed
class SubletState with _$SubletState {
  const factory SubletState.initial() = _Initial;
  const factory SubletState.loading() = _Loading;
  const factory SubletState.loaded(List<SubletModel> sublets) = _Loaded;
  const factory SubletState.error(Exception error) = _Error;
}
