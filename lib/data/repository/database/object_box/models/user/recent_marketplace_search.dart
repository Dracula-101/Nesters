import 'package:objectbox/objectbox.dart';

@Entity()
class RecentSearchMarketplaceItemEntity {
  @Id()
  int? id;
  String searchQuery;
  @Property(type: PropertyType.date)
  DateTime searchedAt;

  RecentSearchMarketplaceItemEntity({
    this.id = 0,
    required this.searchQuery,
    required this.searchedAt,
  });
}
