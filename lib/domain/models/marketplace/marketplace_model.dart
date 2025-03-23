import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_link_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_period_model.dart';
import 'package:nesters/domain/models/user/location.dart';

class MarketplaceModel {
  // photos - 4
  // name
  // category - take from amazon
  // description
  // price
  // link
  // address
  // period - piskcup available from till
  // is_available,
  // created_at
  // id

  int id;
  String? name;
  String? description;
  int? price;
  MarketplaceCategoryModel? category;
  List<String>? photos;
  MarketplaceLinkModel? reference;
  String? address;
  Location? location;
  MarketplacePeriodModel? period;
  bool? isAvailable;
  DateTime? createdAt;
  String? userId;
  bool? isFavouriteByUser;
  double? distanceFromUserInMeters;

  MarketplaceModel({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.category,
    this.photos,
    this.reference,
    this.address,
    this.location,
    this.period,
    this.isAvailable,
    this.createdAt,
    this.userId,
    this.isFavouriteByUser,
    this.distanceFromUserInMeters,
  });

  factory MarketplaceModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString())?.toInt(),
      photos: List<String>.from(json['photos'] ?? []),
      category: MarketplaceCategoryModel.fromJson(json['category']),
      reference: MarketplaceLinkModel.fromJson(json['link'] ?? {}),
      address: json['address'] ?? '',
      location: Location.fromMap(json),
      period: MarketplacePeriodModel.fromJson(json['period'] ?? {}),
      isAvailable: json['is_available'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      userId: json['user_id'],
      isFavouriteByUser: (json['marketplaces_likes'] != null
          ? json['marketplaces_likes']['is_liked']
          : false),
      distanceFromUserInMeters: json['distance_m'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name ?? '',
      'description': description ?? '',
      'price': price ?? 0,
      'category': category?.toJson() ?? {},
      'photos': photos ?? [],
      'link': reference?.toJson() ?? {},
      'address': address ?? '',
      'location': location?.toPoint() ?? "",
      'period': period?.toJson() ?? {},
      'is_available': isAvailable ?? false,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'user_id': userId,
    };
  }

  // copywith
  MarketplaceModel copyWith({
    int? id,
    String? name,
    String? description,
    int? price,
    MarketplaceCategoryModel? category,
    List<String>? photos,
    MarketplaceLinkModel? reference,
    String? address,
    Location? location,
    MarketplacePeriodModel? period,
    bool? isAvailable,
    DateTime? createdAt,
    String? userId,
    bool? isFavouriteByUser,
    double? distanceFromUserInMeters,
  }) {
    return MarketplaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      photos: photos ?? this.photos,
      reference: reference ?? this.reference,
      address: address ?? this.address,
      location: location ?? this.location,
      period: period ?? this.period,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      isFavouriteByUser: isFavouriteByUser ?? this.isFavouriteByUser,
      distanceFromUserInMeters:
          distanceFromUserInMeters ?? this.distanceFromUserInMeters,
    );
  }
}
