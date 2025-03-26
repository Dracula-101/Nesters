import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/user/location.dart';

// Change the filter function in [ApartmentRepository] and Amenities types to include the new fields
class ApartmentFilter {
  Location? location;
  String? address;
  double? startRent;
  double? endRent;
  LeasePeriod? leasePeriod;
  Amenities? amenitiesAvailable;
  ApartmentSize? apartmentSize;

  ApartmentFilter({
    this.location,
    this.address,
    this.startRent,
    this.endRent,
    this.leasePeriod,
    this.amenitiesAvailable,
    this.apartmentSize,
  });

  ApartmentFilter copyWith({
    Location? location,
    String? address,
    double? startRent,
    double? endRent,
    LeasePeriod? leasePeriod,
    Amenities? amenitiesAvailable,
    ApartmentSize? apartmentSize,
  }) {
    return ApartmentFilter(
      location: location ?? this.location,
      address: address ?? this.address,
      startRent: startRent ?? this.startRent,
      endRent: endRent ?? this.endRent,
      leasePeriod: leasePeriod ?? this.leasePeriod,
      amenitiesAvailable: amenitiesAvailable ?? this.amenitiesAvailable,
      apartmentSize: apartmentSize ?? this.apartmentSize,
    );
  }

  ApartmentFilter resetLocation() {
    return ApartmentFilter(
      location: null,
      address: null,
      startRent: startRent,
      endRent: endRent,
      leasePeriod: leasePeriod,
      amenitiesAvailable: amenitiesAvailable,
      apartmentSize: apartmentSize,
    );
  }

  ApartmentFilter resetStartRent() {
    return ApartmentFilter(
      location: location,
      address: address,
      startRent: null,
      endRent: endRent,
      leasePeriod: leasePeriod,
      amenitiesAvailable: amenitiesAvailable,
      apartmentSize: apartmentSize,
    );
  }

  ApartmentFilter resetEndRent() {
    return ApartmentFilter(
      location: location,
      address: address,
      startRent: startRent,
      endRent: null,
      leasePeriod: leasePeriod,
      amenitiesAvailable: amenitiesAvailable,
      apartmentSize: apartmentSize,
    );
  }

  ApartmentFilter resetRent() {
    return ApartmentFilter(
      location: location,
      address: address,
      startRent: null,
      endRent: null,
      leasePeriod: leasePeriod,
      amenitiesAvailable: amenitiesAvailable,
      apartmentSize: apartmentSize,
    );
  }

  ApartmentFilter resetLeasePeriod() {
    return ApartmentFilter(
      location: location,
      address: address,
      startRent: startRent,
      endRent: endRent,
      leasePeriod: null,
      amenitiesAvailable: amenitiesAvailable,
      apartmentSize: apartmentSize,
    );
  }

  ApartmentFilter resetAmenities() {
    return ApartmentFilter(
      location: location,
      address: address,
      startRent: startRent,
      endRent: endRent,
      leasePeriod: leasePeriod,
      amenitiesAvailable: null,
      apartmentSize: apartmentSize,
    );
  }

  ApartmentFilter resetApartmentSize() {
    return ApartmentFilter(
      location: location,
      address: address,
      startRent: startRent,
      endRent: endRent,
      leasePeriod: leasePeriod,
      amenitiesAvailable: amenitiesAvailable,
      apartmentSize: null,
    );
  }
}
