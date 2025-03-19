part of 'apartment_bloc.dart';

abstract class ApartmentEvent {
  const ApartmentEvent();

  const factory ApartmentEvent.initial() = _Initial;
  const factory ApartmentEvent.saveApartments(List<ApartmentModel> apartments) =
      _SaveApartments;
  const factory ApartmentEvent.addSingleFilter(SingleApartmentFilter filter) =
      _SingleAddFilterApartmentEvent;

  const factory ApartmentEvent.removeSingleFilter() =
      _SingleRemoveFilterApartmentEvent;

  const factory ApartmentEvent.addFilterEvent(ApartmentFilter filter) =
      _FilterAddEvent;

  const factory ApartmentEvent.removeFilterEvent() = _FilterRemoveEvent;

  R when<R>({
    required R Function() initial,
    required R Function(List<ApartmentModel> apartments) saveApartments,
    required R Function(SingleApartmentFilter filter) singleAddFilter,
    required R Function() singleRemoveFilter,
    required R Function(ApartmentFilter filter) addFilter,
    required R Function() removeFilter,
  }) {
    if (this is _Initial) {
      return initial();
    } else if (this is _SaveApartments) {
      return saveApartments((this as _SaveApartments).apartments);
    } else if (this is _SingleAddFilterApartmentEvent) {
      return singleAddFilter((this as _SingleAddFilterApartmentEvent).filter);
    } else if (this is _SingleRemoveFilterApartmentEvent) {
      return singleRemoveFilter();
    } else if (this is _FilterAddEvent) {
      return addFilter((this as _FilterAddEvent).filter);
    } else if (this is _FilterRemoveEvent) {
      return removeFilter();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeWhen<R>({
    R Function()? initial,
    R Function(List<ApartmentModel> apartments)? saveApartments,
    R Function(SingleApartmentFilter filter)? singleAddFilter,
    R Function()? singleRemoveFilter,
    R Function(ApartmentFilter filter)? addFilter,
    R Function()? removeFilter,
    required R Function() orElse,
  }) {
    if (this is _Initial) {
      return initial != null ? initial() : orElse();
    } else if (this is _SaveApartments) {
      return saveApartments != null
          ? saveApartments((this as _SaveApartments).apartments)
          : orElse();
    } else if (this is _SingleAddFilterApartmentEvent) {
      return singleAddFilter != null
          ? singleAddFilter((this as _SingleAddFilterApartmentEvent).filter)
          : orElse();
    } else if (this is _SingleRemoveFilterApartmentEvent) {
      return singleRemoveFilter != null ? singleRemoveFilter() : orElse();
    } else if (this is _FilterAddEvent) {
      return addFilter != null
          ? addFilter((this as _FilterAddEvent).filter)
          : orElse();
    } else if (this is _FilterRemoveEvent) {
      return removeFilter != null ? removeFilter() : orElse();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R map<R>({
    required R Function() initial,
    required R Function(List<ApartmentModel> apartments) saveApartments,
    required R Function(SingleApartmentFilter filter) singleAddFilter,
    required R Function() singleRemoveFilter,
    required R Function(ApartmentFilter filter) addFilter,
    required R Function() removeFilter,
  }) {
    if (this is _Initial) {
      return initial();
    } else if (this is _SaveApartments) {
      return saveApartments((this as _SaveApartments).apartments);
    } else if (this is _SingleAddFilterApartmentEvent) {
      return singleAddFilter((this as _SingleAddFilterApartmentEvent).filter);
    } else if (this is _SingleRemoveFilterApartmentEvent) {
      return singleRemoveFilter();
    } else if (this is _FilterAddEvent) {
      return addFilter((this as _FilterAddEvent).filter);
    } else if (this is _FilterRemoveEvent) {
      return removeFilter();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeMap<R>({
    R Function()? initial,
    R Function(List<ApartmentModel> apartments)? saveApartments,
    R Function(SingleApartmentFilter filter)? singleAddFilter,
    R Function()? singleRemoveFilter,
    R Function(ApartmentFilter filter)? addFilter,
    R Function()? removeFilter,
    required R Function(ApartmentEvent) orElse,
  }) {
    if (this is _Initial) {
      return initial != null ? initial() : orElse(this);
    } else if (this is _SaveApartments) {
      return saveApartments != null
          ? saveApartments((this as _SaveApartments).apartments)
          : orElse(this);
    } else if (this is _SingleAddFilterApartmentEvent) {
      return singleAddFilter != null
          ? singleAddFilter((this as _SingleAddFilterApartmentEvent).filter)
          : orElse(this);
    } else if (this is _SingleRemoveFilterApartmentEvent) {
      return singleRemoveFilter != null ? singleRemoveFilter() : orElse(this);
    } else if (this is _FilterAddEvent) {
      return addFilter != null
          ? addFilter((this as _FilterAddEvent).filter)
          : orElse(this);
    } else if (this is _FilterRemoveEvent) {
      return removeFilter != null ? removeFilter() : orElse(this);
    } else {
      throw StateError('Unknown type $this');
    }
  }
}

class _Initial extends ApartmentEvent {
  const _Initial();
}

class _SaveApartments extends ApartmentEvent {
  const _SaveApartments(this.apartments);

  final List<ApartmentModel> apartments;
}

abstract class SingleApartmentFilter {}

class LocationFilter extends SingleApartmentFilter {
  final Location location;
  final double radiusKm;

  LocationFilter({required this.location, required this.radiusKm});
}

class _SingleAddFilterApartmentEvent extends ApartmentEvent {
  const _SingleAddFilterApartmentEvent(this.filter);

  final SingleApartmentFilter filter;
}

class _SingleRemoveFilterApartmentEvent extends ApartmentEvent {
  const _SingleRemoveFilterApartmentEvent();
}

class GenderPreferenceFilter extends SingleApartmentFilter {
  final String preferredGender;

  GenderPreferenceFilter(this.preferredGender);
}

class RentFilter extends SingleApartmentFilter {
  final int startRent;
  final int endRent;

  RentFilter(this.startRent, this.endRent);
}

class ApartmentSizeFilter extends SingleApartmentFilter {
  final ApartmentSize apartmentSize;

  ApartmentSizeFilter(this.apartmentSize);
}

class ApartmentTypeFilter extends SingleApartmentFilter {
  final UserRoomType apartmentType;

  ApartmentTypeFilter(this.apartmentType);
}

class _FilterAddEvent extends ApartmentEvent {
  final ApartmentFilter filter;
  const _FilterAddEvent(this.filter);
}

class _FilterRemoveEvent extends ApartmentEvent {
  const _FilterRemoveEvent();
}
