import 'package:equatable/equatable.dart';
import 'package:nesters/domain/models/user/location.dart';

// ignore: must_be_immutable
class University extends Equatable {
  final int id;
  String? country;
  String? city;
  String? title;
  String? logo;
  String? region;
  Location? location;

  University({
    required this.id,
    this.country,
    this.city,
    this.title,
    this.logo,
    this.region,
    this.location,
  });

  University.fromJson(
    this.id, {
    required Map<String, dynamic> json,
  }) {
    country = json['country'];
    city = json['city'];
    title = json['title'];
    logo = json['logo'];
    region = json['region'];
    location =
        json['location'] != null ? Location.fromPoint(json['location']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['country'] = country;
    data['city'] = city;
    data['title'] = title;
    data['logo'] = logo;
    data['region'] = region;
    data['location'] = location?.toPoint();
    return data;
  }

  @override
  List<Object?> get props => [country, city, title, logo, region, location];

  @override
  String toString() {
    return title ?? '';
  }
}
