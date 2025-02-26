import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class MarketplaceCategoryEntity {
  @Id()
  int id = 0;
  int modelId;
  String name;

  MarketplaceCategoryEntity({
    this.id = 0,
    required this.modelId,
    required this.name,
  });

  // from model
  static MarketplaceCategoryEntity fromModel(MarketplaceCategoryModel model) {
    return MarketplaceCategoryEntity(
      name: model.name ?? '',
      modelId: model.id ?? 0,
    );
  }

  // to model
  MarketplaceCategoryModel toModel() {
    return MarketplaceCategoryModel(
      id: modelId,
      name: name,
    );
  }
}
