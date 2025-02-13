import 'package:nesters/domain/models/college/degree.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class DegreeEntity {
  @Id()
  int id = 0;
  String title;

  DegreeEntity({
    this.id = 0,
    required this.title,
  });

  // to model
  Degree toModel() {
    return Degree(
      name: title,
    );
  }

  // from model
  static DegreeEntity fromModel(Degree model) {
    return DegreeEntity(
      title: model.name,
    );
  }
}
