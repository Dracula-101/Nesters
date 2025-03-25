import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_link_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_period_model.dart';
import 'package:nesters/domain/models/user/location.dart';

class SearchedMarketplaceModel {
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
  SearchCategory? searchCategory;

  SearchedMarketplaceModel({
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
    this.searchCategory,
  });

  factory SearchedMarketplaceModel.fromJson(Map<String, dynamic> json) {
    return SearchedMarketplaceModel(
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
      searchCategory: json['match_by'] != null
          ? SearchCategory.fromString(json['match_by'])
          : null,
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

  MarketplaceModel toMarketplaceItem() {
    return MarketplaceModel(
      id: id,
      name: name ?? '',
      description: description ?? '',
      price: price ?? 0,
      category: category ?? MarketplaceCategoryModel(),
      photos: photos ?? [],
      reference: reference ?? MarketplaceLinkModel(),
      address: address ?? '',
      location: location ?? Location(),
      period: period ?? MarketplacePeriodModel(),
      isAvailable: isAvailable ?? false,
      createdAt: createdAt ?? DateTime.now(),
      userId: userId,
    );
  }
}

enum SearchCategory {
  NAME,
  CATEGORY,
  DESCRIPTION,
  LOCATION;

  static SearchCategory fromString(String value) {
    switch (value) {
      case 'name':
        return NAME;
      case 'category':
        return CATEGORY;
      case 'description':
        return DESCRIPTION;
      case 'location':
        return LOCATION;
      default:
        return NAME;
    }
  }
}
