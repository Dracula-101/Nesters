import 'package:nesters/domain/models/language.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class LanguageEntity {
  @Id()
  int id = 0;
  String name;
  String? nativeName;

  LanguageEntity({
    this.id = 0,
    required this.name,
    this.nativeName,
  });

  // to model
  Language toModel() {
    return Language(
      name: name,
      nativeName: nativeName,
    );
  }

  // from model
  static LanguageEntity fromModel(LanguageEntity model) {
    return LanguageEntity(
      name: model.name,
      nativeName: model.nativeName,
    );
  }
}
