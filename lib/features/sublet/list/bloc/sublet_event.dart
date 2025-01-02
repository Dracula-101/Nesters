part of 'sublet_bloc.dart';

abstract class SubletEvent {
  const SubletEvent();

  const factory SubletEvent.initial() = _Initial;
  const factory SubletEvent.saveSublets(List<SubletModel> sublets) =
      _SaveSublets;
  const factory SubletEvent.addSingleFilter(SingleSubletFilter filter) =
      _SingleAddFilterSubletEvent;

  const factory SubletEvent.removeSingleFilter() =
      _SingleRemoveFilterSubletEvent;

  R when<R>({
    required R Function() initial,
    required R Function(List<SubletModel> sublets) saveSublets,
    required R Function(SingleSubletFilter filter) singleAddFilter,
    required R Function() singleRemoveFilter,
  }) {
    if (this is _Initial) {
      return initial();
    } else if (this is _SaveSublets) {
      return saveSublets((this as _SaveSublets).sublets);
    } else if (this is _SingleAddFilterSubletEvent) {
      return singleAddFilter((this as _SingleAddFilterSubletEvent).filter);
    } else if (this is _SingleRemoveFilterSubletEvent) {
      return singleRemoveFilter();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeWhen<R>({
    R Function()? initial,
    R Function(List<SubletModel> sublets)? saveSublets,
    R Function(SingleSubletFilter filter)? singleAddFilter,
    R Function()? singleRemoveFilter,
    required R Function() orElse,
  }) {
    if (this is _Initial) {
      return initial != null ? initial() : orElse();
    } else if (this is _SaveSublets) {
      return saveSublets != null
          ? saveSublets((this as _SaveSublets).sublets)
          : orElse();
    } else if (this is _SingleAddFilterSubletEvent) {
      return singleAddFilter != null
          ? singleAddFilter((this as _SingleAddFilterSubletEvent).filter)
          : orElse();
    } else if (this is _SingleRemoveFilterSubletEvent) {
      return singleRemoveFilter != null ? singleRemoveFilter() : orElse();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R map<R>({
    required R Function() initial,
    required R Function(List<SubletModel> sublets) saveSublets,
    required R Function(SingleSubletFilter filter) singleAddFilter,
    required R Function() singleRemoveFilter,
  }) {
    if (this is _Initial) {
      return initial();
    } else if (this is _SaveSublets) {
      return saveSublets((this as _SaveSublets).sublets);
    } else if (this is _SingleAddFilterSubletEvent) {
      return singleAddFilter((this as _SingleAddFilterSubletEvent).filter);
    } else if (this is _SingleRemoveFilterSubletEvent) {
      return singleRemoveFilter();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeMap<R>({
    R Function()? initial,
    R Function(List<SubletModel> sublets)? saveSublets,
    R Function(SingleSubletFilter filter)? singleAddFilter,
    R Function()? singleRemoveFilter,
    required R Function(SubletEvent) orElse,
  }) {
    if (this is _Initial) {
      return initial != null ? initial() : orElse(this);
    } else if (this is _SaveSublets) {
      return saveSublets != null
          ? saveSublets((this as _SaveSublets).sublets)
          : orElse(this);
    } else if (this is _SingleAddFilterSubletEvent) {
      return singleAddFilter != null
          ? singleAddFilter((this as _SingleAddFilterSubletEvent).filter)
          : orElse(this);
    } else if (this is _SingleRemoveFilterSubletEvent) {
      return singleRemoveFilter != null ? singleRemoveFilter() : orElse(this);
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

abstract class SingleSubletFilter {}

class _SingleAddFilterSubletEvent extends SubletEvent {
  const _SingleAddFilterSubletEvent(this.filter);

  final SingleSubletFilter filter;
}

class _SingleRemoveFilterSubletEvent extends SubletEvent {
  const _SingleRemoveFilterSubletEvent();
}

class GenderPreferenceFilter extends SingleSubletFilter {
  final String preferredGender;

  GenderPreferenceFilter(this.preferredGender);
}

class RentFilter extends SingleSubletFilter {
  final int startRent;
  final int endRent;

  RentFilter(this.startRent, this.endRent);
}

class ApartmentSizeFilter extends SingleSubletFilter {
  final ApartmentSize apartmentSize;

  ApartmentSizeFilter(this.apartmentSize);
}

class ApartmentTypeFilter extends SingleSubletFilter {
  final UserRoomType apartmentType;

  ApartmentTypeFilter(this.apartmentType);
}
