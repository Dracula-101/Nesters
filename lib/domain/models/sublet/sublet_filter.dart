import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/location.dart';

// Change the filter function in [SubletRepository] and Amenities types to include the new fields
class SubletFilter {
  Location? location;
  String? address;
  String? roommateGenderPref;
  double? startRent;
  double? endRent;
  LeasePeriod? leasePeriod;
  Amenities? amenitiesAvailable;
  ApartmentSize? apartmentSize;
  UserRoomType? roomType;

  SubletFilter({
    this.location,
    this.address,
    this.roommateGenderPref,
    this.startRent,
    this.endRent,
    this.leasePeriod,
    this.amenitiesAvailable,
    this.apartmentSize,
    this.roomType,
  });

  SubletFilter copyWith({
    Location? location,
    String? address,
    String? roommateGenderPref,
    double? startRent,
    double? endRent,
    LeasePeriod? leasePeriod,
    Amenities? amenitiesAvailable,
    ApartmentSize? apartmentSize,
    UserRoomType? roomType,
  }) {
    return SubletFilter(
      location: location,
      address: address,
      roommateGenderPref: roommateGenderPref ?? this.roommateGenderPref,
      startRent: startRent,
      endRent: endRent,
      leasePeriod: leasePeriod ?? this.leasePeriod,
      amenitiesAvailable: amenitiesAvailable ?? this.amenitiesAvailable,
      apartmentSize: apartmentSize,
      roomType: roomType ?? this.roomType,
    );
  }
}
