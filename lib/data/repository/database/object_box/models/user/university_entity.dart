import 'package:nesters/domain/models/college/university.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class UniversityEntity {
  @Id()
  int id = 0;
  String title;
  String? country;
  String? city;
  String? logo;
  String? score;
  String? rankDisplay;
  String? region;

  UniversityEntity({
    this.id = 0,
    required this.title,
    required this.country,
    required this.city,
    required this.logo,
    required this.score,
    required this.rankDisplay,
    required this.region,
  });

  //from model
  static UniversityEntity fromModel(University model) {
    return UniversityEntity(
      title: model.title ?? '',
      country: model.country,
      city: model.city,
      logo: model.logo,
      score: model.score,
      rankDisplay: model.rankDisplay,
      region: model.region,
    );
  }

  //to model
  University toModel() {
    return University(
      title: title,
      country: country,
      city: city,
      logo: logo,
      score: score,
      rankDisplay: rankDisplay,
      region: region,
    );
  }
}
