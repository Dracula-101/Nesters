import 'dart:developer';

import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/location.dart';

import 'sublet_model.dart';

class NearbySubletModel extends SubletModel {
  double? distanceInMetres;

  NearbySubletModel({
    required int id,
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
    bool? isFavouriteByUser,
    this.distanceInMetres,
  }) : super(
          id: id,
          userId: userId,
          roomDescription: roomDescription,
          roommateDescription: roommateDescription,
          roommateGenderPref: roommateGenderPref,
          rent: rent,
          photos: photos,
          leasePeriod: leasePeriod,
          amenitiesAvailable: amenitiesAvailable,
          apartmentSize: apartmentSize,
          roomType: roomType,
          address: address,
          location: location,
          isAvailable: isAvailable,
          isFavouriteByUser: isFavouriteByUser,
        );

  factory NearbySubletModel.fromMap(Map<String, dynamic> map) {
    return NearbySubletModel(
      id: map['sublet_id'] ?? 0,
      userId: map['user_id'] ?? '',
      roomDescription: map['room_description'] ?? '',
      roommateDescription: map['roommate_description'] ?? '',
      roommateGenderPref: map['roommate_gender_pref'] ?? '',
      rent: double.tryParse(map['rent'].toString()) ?? 0.0,
      photos: List<String>.from(map['photos'] ?? []),
      leasePeriod: LeasePeriod.fromMap(map),
      amenitiesAvailable: Amenities.fromMap(map['amenities_available'] ?? {}),
      apartmentSize: ApartmentSize.fromMap(map),
      roomType: UserRoomType.fromString(map['room_type'] ?? ''),
      address: map['address'] ?? '',
      location: Location.fromPoint(map['location']),
      isAvailable: map['is_available'] ?? true,
      isFavouriteByUser: map['sublet_likes'] == null
          ? false
          : (map['sublet_likes']['is_liked'] ?? false),
      distanceInMetres: map['distance_m']?.toDouble(),
    );
  }

  @override
  NearbySubletModel copyWith({
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
    double? distanceInMetres,
  }) {
    return NearbySubletModel(
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
      distanceInMetres: distanceInMetres ?? this.distanceInMetres,
    );
  }
}
