import 'dart:async';

import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:rxdart/rxdart.dart';

abstract class ObxStorageRepository {
  // Open and Closing the database
  Future<void> init();
  void close();
  Future<void> reset();

  // Universities
  List<University> getUniversities();
  Future<void> saveUniversities(List<University> universities);
  //Degree
  List<Degree> getDegrees();
  Future<void> saveDegrees(List<Degree> degrees);
  //Marketplace categories
  List<MarketplaceCategoryModel> getMarketplaceCategories();
  Future<void> saveMarketplaceCategories(
      List<MarketplaceCategoryModel> categories);

  List<String> getRecentSearchMarketplace();
  Future<void> addRecentSearchMarketplaceItem(String item);
  Future<void> removeRecentSearchMarketplaceItem(String item);

  //Language
  List<Language> getLanguages();
  Future<void> saveLanguages(List<Language> languages);

  Stream<List<QuickChatUser>> getChatUsersStream();
  List<QuickChatUser> getChatUserProfiles();
  QuickChatUser? getQuickChatUser(String chatId);
  Future<void> updateChatUser(List<QuickChatUser> users);
  Future<void> saveRecipientUser(QuickChatUser user);

  void saveMessage(String chatId, Message message);

  Stream<List<Message>> getChatMessagesStream(String chatId);
  Subject<List<Message>> getChatMessagesSubject(String chatId);
  List<Message> getChatMessages(String chatId);
}
