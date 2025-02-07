import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';

// Change the filter function in [ApartmentRepository] and Amenities types to include the new fields
class ApartmentFilter {
  String? roommateGenderPref;
  double? startRent;
  double? endRent;
  LeasePeriod? leasePeriod;
  Amenities? amenitiesAvailable;
  ApartmentSize? apartmentSize;
  UserRoomType? roomType;

  ApartmentFilter({
    this.roommateGenderPref,
    this.startRent,
    this.endRent,
    this.leasePeriod,
    this.amenitiesAvailable,
    this.apartmentSize,
    this.roomType,
  });

  ApartmentFilter copyWith({
    String? roommateGenderPref,
    double? startRent,
    double? endRent,
    LeasePeriod? leasePeriod,
    Amenities? amenitiesAvailable,
    ApartmentSize? apartmentSize,
    UserRoomType? roomType,
  }) {
    return ApartmentFilter(
      roommateGenderPref: roommateGenderPref ?? this.roommateGenderPref,
      startRent: startRent ?? this.startRent,
      endRent: endRent ?? this.endRent,
      leasePeriod: leasePeriod ?? this.leasePeriod,
      amenitiesAvailable: amenitiesAvailable ?? this.amenitiesAvailable,
      apartmentSize: apartmentSize ?? this.apartmentSize,
      roomType: roomType ?? this.roomType,
    );
  }
}
