import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/sublet/amenities.dart';
import 'package:nesters/domain/models/sublet/apartment_size.dart';
import 'package:nesters/domain/models/sublet/lease_period.dart';
import 'package:nesters/domain/models/sublet/sublet_location.dart';

class SubletModel {
  // 1]address -String
  // 2]google map - GmapObject
  // 3]room description - String
  // 4]roommate descriptio - String
  // 5]roommate gender pref - List of Options
  // 6]rent - Fixed number
  // 7]photos - List of String
  // 8]start and end date - Object
  // 9]amenities available - Object (dryer, washing machine, extra options)
  // 10]room size beds and baths - Object ( bed,  bath )
  // 11]shared/private/flex -Options

  String? roomDescription;
  String? roommateDescription;
  String? roommateGenderPref;
  double? rent;
  List<String>? photos;
  LeasePeriod? leaseTime;
  Amenities? amenitiesAvailable;
  ApartmentSize? apartmentSize;
  UserRoomType? roomType;
  Location? location;
  bool? isAvailable;

  SubletModel({
    required this.roomDescription,
    required this.roommateDescription,
    required this.roommateGenderPref,
    required this.rent,
    required this.photos,
    required this.leaseTime,
    required this.amenitiesAvailable,
    required this.apartmentSize,
    required this.roomType,
    required this.location,
    this.isAvailable = true,
  });

  bool isSubletActive() {
    return leaseTime?.isLeaseActive() ?? false;
  }

  Map<String, dynamic> toMap() {
    return {
      'roomDescription': roomDescription ?? '',
      'roommateDescription': roommateDescription ?? '',
      'roommateGenderPref': roommateGenderPref ?? '',
      'rent': rent ?? 0.0,
      'photos': photos ?? [],
      'leaseTime': leaseTime?.toMap() ?? {},
      'amenitiesAvailable': amenitiesAvailable?.toMap() ?? {},
      'apartmentSize': apartmentSize?.toMap() ?? {},
      'roomType': roomType ?? '',
      'location': location?.toMap() ?? {},
      'isAvailable': isAvailable ?? true,
    };
  }

  factory SubletModel.fromMap(Map<String, dynamic> map) {
    return SubletModel(
      roomDescription: map['roomDescription'] ?? '',
      roommateDescription: map['roommateDescription'] ?? '',
      roommateGenderPref: map['roommateGenderPref'] ?? '',
      rent: map['rent'] ?? 0.0,
      photos: List<String>.from(map['photos'] ?? []),
      leaseTime: LeasePeriod.fromMap(map['leaseTime'] ?? {}),
      amenitiesAvailable: Amenities.fromMap(map['amenitiesAvailable'] ?? {}),
      apartmentSize: ApartmentSize.fromMap(map['apartmentSize'] ?? {}),
      roomType: map['roomType'] ?? '',
      location: Location.fromMap(map['location'] ?? {}),
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  SubletModel copyWith({
    String? roomDescription,
    String? roommateDescription,
    String? roommateGenderPref,
    double? rent,
    List<String>? photos,
    LeasePeriod? leaseTime,
    Amenities? amenitiesAvailable,
    ApartmentSize? apartmentSize,
    UserRoomType? roomType,
    Location? location,
    bool? isAvailable,
  }) {
    return SubletModel(
      roomDescription: roomDescription ?? this.roomDescription,
      roommateDescription: roommateDescription ?? this.roommateDescription,
      roommateGenderPref: roommateGenderPref ?? this.roommateGenderPref,
      rent: rent ?? this.rent,
      photos: photos ?? this.photos,
      leaseTime: leaseTime ?? this.leaseTime,
      amenitiesAvailable: amenitiesAvailable ?? this.amenitiesAvailable,
      apartmentSize: apartmentSize ?? this.apartmentSize,
      roomType: roomType ?? this.roomType,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
