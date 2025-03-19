import 'dart:developer';

import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/location.dart';

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
  int id;
  String? userId;
  String? roomDescription;
  String? roommateDescription;
  String? roommateGenderPref;
  double? rent;
  List<String>? photos;
  LeasePeriod? leasePeriod;
  Amenities? amenitiesAvailable;
  ApartmentSize? apartmentSize;
  UserRoomType? roomType;
  String? address;
  Location? location;
  bool? isAvailable;
  bool? isFavouriteByUser;
  double? distanceFromUserInMetres;

  SubletModel({
    required this.id,
    this.userId,
    this.roomDescription,
    this.roommateDescription,
    this.roommateGenderPref,
    this.rent,
    this.photos,
    this.leasePeriod,
    this.amenitiesAvailable,
    this.apartmentSize,
    this.roomType,
    this.address,
    this.location,
    this.isAvailable = true,
    this.isFavouriteByUser = false,
    this.distanceFromUserInMetres,
  });

  bool isSubletActive() {
    return leasePeriod?.isLeaseActive() ?? false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId ?? '',
      'room_description': roomDescription ?? '',
      'roommate_description': roommateDescription ?? '',
      'roommate_gender_pref': roommateGenderPref ?? '',
      'rent': rent ?? 0.0,
      'photos': photos ?? [],
      'amenities_available': amenitiesAvailable?.toMap() ?? {},
      'room_type': (roomType ?? '').toString(),
      'address': address ?? '',
      'location': location?.toPoint() ?? "",
      'is_available': isAvailable ?? true,
      ...apartmentSize?.toMap() ?? {},
      ...leasePeriod?.toMap() ?? {},
    };
  }

  factory SubletModel.fromMap(Map<String, dynamic> map) {
    return SubletModel(
      id: map['id'] ?? map['sublet_id'] ?? 0,
      userId: map['user_id'] ?? '',
      roomDescription: map['room_description'] ?? '',
      roommateDescription: map['roommate_description'] ?? '',
      roommateGenderPref: map['roommate_gender_pref'] ?? '',
      rent: double.tryParse(map['rent'].toString()),
      photos: List<String>.from(map['photos'] ?? []),
      leasePeriod: LeasePeriod.fromMap(map),
      amenitiesAvailable: Amenities.fromMap(map['amenities_available'] ?? {}),
      apartmentSize: ApartmentSize.fromMap(map),
      roomType: UserRoomType.fromString(map['room_type'] ?? ''),
      address: map['address'] ?? '',
      location: Location.fromMap(map),
      isAvailable: map['is_available'] ?? true,
      isFavouriteByUser: map['sublet_likes'] == null
          ? false
          : (map['sublet_likes']['is_liked'] ?? false),
      distanceFromUserInMetres: map['distance_m'] ?? 0.0,
    );
  }

  SubletModel copyWith({
    int? id,
    String? userId,
    String? roomDescription,
    String? roommateDescription,
    String? roommateGenderPref,
    double? rent,
    List<String>? photos,
    LeasePeriod? leasePeriod,
    Amenities? amenitiesAvailable,
    ApartmentSize? apartmentSize,
    UserRoomType? roomType,
    String? address,
    Location? location,
    bool? isAvailable,
    double? distanceFromUserInMetres,
  }) {
    return SubletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roomDescription: roomDescription ?? this.roomDescription,
      roommateDescription: roommateDescription ?? this.roommateDescription,
      roommateGenderPref: roommateGenderPref ?? this.roommateGenderPref,
      rent: rent ?? this.rent,
      photos: photos ?? this.photos,
      leasePeriod: leasePeriod ?? this.leasePeriod,
      amenitiesAvailable: amenitiesAvailable ?? this.amenitiesAvailable,
      apartmentSize: apartmentSize ?? this.apartmentSize,
      roomType: roomType ?? this.roomType,
      address: address ?? this.address,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      distanceFromUserInMetres:
          distanceFromUserInMetres ?? this.distanceFromUserInMetres,
    );
  }
}
