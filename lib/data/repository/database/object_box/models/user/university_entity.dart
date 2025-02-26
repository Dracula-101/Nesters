import 'package:nesters/domain/models/college/university.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class UniversityEntity {
  @Id()
  int id = 0;
  int universityId;
  String title;
  String? country;
  String? city;
  String? logo;
  String? region;

  UniversityEntity({
    this.id = 0,
    required this.universityId,
    required this.title,
    required this.country,
    required this.city,
    required this.logo,
    required this.region,
  });

  //from model
  static UniversityEntity fromModel(University model) {
    return UniversityEntity(
      universityId: model.id,
      title: model.title ?? '',
      country: model.country,
      city: model.city,
      logo: model.logo,
      region: model.region,
    );
  }

  //to model
  University toModel() {
    return University(
      id: universityId,
      title: title,
      country: country,
      city: city,
      logo: logo,
      region: region,
    );
  }
}
