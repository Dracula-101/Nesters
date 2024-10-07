part of 'sublet_bloc.dart';

abstract class SubletEvent {
  const SubletEvent();

  const factory SubletEvent.initial() = _Initial;
  const factory SubletEvent.saveSublets(List<SubletModel> sublets) =
      _SaveSublets;

  R when<R>({
    required R Function() initial,
    required R Function(List<SubletModel> sublets) saveSublets,
  }) {
    if (this is _Initial) {
      return initial();
    } else if (this is _SaveSublets) {
      return saveSublets((this as _SaveSublets).sublets);
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeWhen<R>({
    R Function()? initial,
    R Function(List<SubletModel> sublets)? saveSublets,
    required R Function() orElse,
  }) {
    if (this is _Initial) {
      return initial != null ? initial() : orElse();
    } else if (this is _SaveSublets) {
      return saveSublets != null
          ? saveSublets((this as _SaveSublets).sublets)
          : orElse();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R map<R>({
    required R Function() initial,
    required R Function(List<SubletModel> sublets) saveSublets,
  }) {
    if (this is _Initial) {
      return initial();
    } else if (this is _SaveSublets) {
      return saveSublets((this as _SaveSublets).sublets);
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeMap<R>({
    R Function()? initial,
    R Function(List<SubletModel> sublets)? saveSublets,
    required R Function(SubletEvent) orElse,
  }) {
    if (this is _Initial) {
      return initial != null ? initial() : orElse(this);
    } else if (this is _SaveSublets) {
      return saveSublets != null
          ? saveSublets((this as _SaveSublets).sublets)
          : orElse(this);
    } else {
      throw StateError('Unknown type $this');
    }
  }
}

class _Initial extends SubletEvent {
  const _Initial();
}

class _SaveSublets extends SubletEvent {
  const _SaveSublets(this.sublets);

  final List<SubletModel> sublets;
}
