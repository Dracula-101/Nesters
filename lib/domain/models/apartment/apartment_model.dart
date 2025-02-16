import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/user/location.dart';

class ApartmentModel {
  // 1]address -String
  // 2]google map - GmapObject
  // 3]apartment description - String
  // 4]rent - Fixed number
  // 5]photos - List of String
  // 6]start - Object
  // 7]amenities available - Object (dryer, washing machine, extra options)
  // 8]apartment size beds and baths - Object ( bed,  bath )
  int id;
  String? userId;
  String? apartmentDescription;
  double? rent;
  List<String>? photos;
  LeasePeriod? leasePeriod;
  Amenities? amenitiesAvailable;
  ApartmentSize? apartmentSize;
  Location? location;
  String? address;
  bool? isAvailable;
  bool? isFavouriteByUser;

  ApartmentModel({
    required this.id,
    this.userId,
    this.apartmentDescription,
    this.rent,
    this.photos,
    this.leasePeriod,
    this.amenitiesAvailable,
    this.apartmentSize,
    this.address,
    this.location,
    this.isAvailable = true,
    this.isFavouriteByUser = false,
  });

  bool isApartmentActive() {
    return leasePeriod?.isLeaseActive() ?? false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId ?? '',
      'apartment_description': apartmentDescription ?? '',
      'rent': rent ?? 0.0,
      'photos': photos ?? [],
      'amenities_available': amenitiesAvailable?.toMap() ?? {},
      'address': address ?? '',
      'location': location?.toPoint() ?? {},
      'is_available': isAvailable ?? true,
      ...apartmentSize?.toMap() ?? {},
      ...leasePeriod?.toMap() ?? {},
    };
  }

  factory ApartmentModel.fromMap(Map<String, dynamic> map) {
    return ApartmentModel(
      id: map['id'] ?? 0,
      userId: map['user_id'] ?? '',
      apartmentDescription: map['apartment_description'] ?? '',
      rent: double.tryParse(map['rent'].toString()),
      photos: List<String>.from(map['photos'] ?? []),
      leasePeriod: LeasePeriod.fromMap(map),
      amenitiesAvailable: Amenities.fromMap(map['amenities_available'] ?? {}),
      apartmentSize: ApartmentSize.fromMap(map),
      location: Location.fromPoint(map['location']),
      isAvailable: map['is_available'] ?? true,
      isFavouriteByUser: map['apartment_likes'] == null
          ? false
          : (map['apartment_likes']['is_liked'] ?? false),
    );
  }

  ApartmentModel copyWith({
    int? id,
    String? userId,
    String? apartmentDescription,
    double? rent,
    List<String>? photos,
    LeasePeriod? leasePeriod,
    Amenities? amenitiesAvailable,
    ApartmentSize? apartmentSize,
    String? address,
    Location? location,
    bool? isAvailable,
  }) {
    return ApartmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      apartmentDescription: apartmentDescription ?? this.apartmentDescription,
      rent: rent ?? this.rent,
      photos: photos ?? this.photos,
      leasePeriod: leasePeriod ?? this.leasePeriod,
      amenitiesAvailable: amenitiesAvailable ?? this.amenitiesAvailable,
      apartmentSize: apartmentSize ?? this.apartmentSize,
      address: address ?? this.address,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
