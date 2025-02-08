import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/room/room_type.dart';

// Change the filter function in [SubletRepository] and Amenities types to include the new fields
class SubletFilter {
  String? roommateGenderPref;
  double? startRent;
  double? endRent;
  LeasePeriod? leasePeriod;
  Amenities? amenitiesAvailable;
  ApartmentSize? apartmentSize;
  UserRoomType? roomType;

  SubletFilter({
    this.roommateGenderPref,
    this.startRent,
    this.endRent,
    this.leasePeriod,
    this.amenitiesAvailable,
    this.apartmentSize,
    this.roomType,
  });

  SubletFilter copyWith({
    String? roommateGenderPref,
    double? startRent,
    double? endRent,
    LeasePeriod? leasePeriod,
    Amenities? amenitiesAvailable,
    ApartmentSize? apartmentSize,
    UserRoomType? roomType,
  }) {
    return SubletFilter(
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
