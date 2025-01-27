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
  Location? location;
  MarketplacePeriodModel? period;
  bool? isAvailable;
  DateTime? createdAt;
  String? userId;
  bool? isFavouriteByUser;

  MarketplaceModel({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.category,
    this.photos,
    this.reference,
    this.location,
    this.period,
    this.isAvailable,
    this.createdAt,
    this.userId,
    this.isFavouriteByUser,
  });

  factory MarketplaceModel.fromJson(Map<String, dynamic> json) {
    try {
      return MarketplaceModel(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        price: double.tryParse(json['price'].toString())?.toInt(),
        photos: List<String>.from(json['photos'] ?? []),
        category: MarketplaceCategoryModel.fromJson(json['category']),
        reference: MarketplaceLinkModel.fromJson(json['link'] ?? {}),
        location: Location.fromJson(json['location'] ?? {}),
        period: MarketplacePeriodModel.fromJson(json['period'] ?? {}),
        isAvailable: json['is_available'] ?? false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
        userId: json['user_id'],
        isFavouriteByUser: (json['marketplaces_likes'] != null
            ? json['marketplaces_likes']['is_liked']
            : false),
      );
    } catch (e, stacktrace) {
      print('Error: $e, Stacktrace: $stacktrace');
      return MarketplaceModel(id: 0);
    }
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
      'location': location?.toJson() ?? {},
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
    Location? location,
    MarketplacePeriodModel? period,
    bool? isAvailable,
    DateTime? createdAt,
    String? userId,
  }) {
    return MarketplaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      photos: photos ?? this.photos,
      reference: reference ?? this.reference,
      location: location ?? this.location,
      period: period ?? this.period,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
