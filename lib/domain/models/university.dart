import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class University extends Equatable {
  String? country;
  String? city;
  String? title;
  String? logo;
  String? score;
  String? rankDisplay;
  String? region;

  University(
      {this.country,
      this.city,
      this.title,
      this.logo,
      this.score,
      this.rankDisplay,
      this.region});

  University.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    city = json['city'];
    title = json['title'];
    logo = json['logo'];
    score = json['score'];
    rankDisplay = json['rank_display'];
    region = json['region'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country'] = country;
    data['city'] = city;
    data['title'] = title;
    data['logo'] = logo;
    data['score'] = score;
    data['rank_display'] = rankDisplay;
    data['region'] = region;
    return data;
  }

  @override
  List<Object?> get props =>
      [country, city, title, logo, score, rankDisplay, region];
}
