import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:nesters/data/repository/database/object_box/models/chat/chat_entity.dart';
import 'package:nesters/data/repository/database/object_box/models/chat/message/message_entity.dart';
import 'package:nesters/data/repository/database/object_box/models/user/degree_entity.dart';
import 'package:nesters/data/repository/database/object_box/models/user/language_entity.dart';
import 'package:nesters/data/repository/database/object_box/models/user/marketplace_category_entity.dart';
import 'package:nesters/data/repository/database/object_box/models/user/university_entity.dart';
import 'package:nesters/data/repository/database/object_box/repository/error/obx_storage_error.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';

class ObjectBoxStorageRepository extends ObxStorageRepository {
  late Store store;
  late Box<UniversityEntity> universityEntityBox;
  late Box<DegreeEntity> degreeEntityBox;
  late Box<LanguageEntity> languageEntityBox;
  late Box<MarketplaceCategoryEntity> marketplaceCategoriesEntityBox;
  late Box<ChatEntity> chatEntityBox;
  late Box<MessageEntity> messageEntityBox;
  static String objectBoxDirectory = 'objectbox';

  @override
  Future<void> init() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    Directory objectBoxDir = Directory('${docsDir.path}/$objectBoxDirectory')
      ..create();
    store = await openStore(
      directory: objectBoxDir.path,
    );
    _initBox();
  }

  void _initBox() {
    chatEntityBox = store.box<ChatEntity>();
    messageEntityBox = store.box<MessageEntity>();
    universityEntityBox = store.box<UniversityEntity>();
    degreeEntityBox = store.box<DegreeEntity>();
    languageEntityBox = store.box<LanguageEntity>();
    marketplaceCategoriesEntityBox = store.box<MarketplaceCategoryEntity>();
  }

  @override
  List<QuickChatUser> getChatUserProfiles() {
    try {
      return chatEntityBox.getAll().map((e) => e.toQuickChatUser()).toList();
    } catch (e) {
      throw ObxStorageValueGetError('chatEntityBox');
    }
  }

  @override
  Stream<List<QuickChatUser>> getChatUsersStream() {
    try {
      return chatEntityBox.query().watch(triggerImmediately: true).map(
        (query) {
          return query.find().map((e) => e.toQuickChatUser()).toList();
        },
      );
    } on Exception {
      throw ObxStorageValueStreamError('chatEntityBox');
    }
  }

  @override
  Future<void> updateChatUser(List<QuickChatUser> users) async {
    try {
      chatEntityBox.removeAll();
      for (QuickChatUser user in users) {
        ChatEntity quickChat = ChatEntity(
          fullName: user.fullName as String,
          photoUrl: user.photoUrl as String,
          chatId: user.chatId as String,
          token: user.token as String,
          userId: user.userId as String,
        );
        await chatEntityBox.putAsync(quickChat);
      }
    } catch (e) {
      throw ObxStorageValueSaveError('chatEntityBox');
    }
  }

  @override
  Future<void> saveRecipientUser(QuickChatUser user) {
    try {
      ChatEntity quickChat = ChatEntity(
        fullName: user.fullName as String,
        photoUrl: user.photoUrl as String,
        chatId: user.chatId as String,
        token: user.token as String,
        userId: user.userId as String,
      );
      chatEntityBox.put(quickChat);
      return Future.value();
    } catch (e) {
      throw ObxStorageValueSaveError('chatEntityBox');
    }
  }

  @override
  void saveMessage(String chatId, Message message) {
    try {
      MessageEntity messageEntity = MessageEntity(
        messageId: message.id,
        content: message.content ?? '',
        messageType: message.messageType.toString(),
        senderId: message.senderId ?? '',
        sentAt: message.sentAt?.toDate() ?? DateTime.now(),
        epochTime: message.epochTime.millisecondsSinceEpoch,
      );
      final chatEntity = chatEntityBox
          .query(ChatEntity_.chatId.equals(chatId))
          .build()
          .findFirst();
      messageEntity.chat.target = chatEntity;
      messageEntityBox.put(messageEntity);
    } catch (e) {
      throw ObxStorageValueSaveError('messageEntityBox');
    }
  }

  Future<void> clearDatabase() async {
    try {
      Directory docsDir = await getApplicationDocumentsDirectory();
      Directory objectBoxDir = Directory('${docsDir.path}/$objectBoxDirectory');
      await objectBoxDir.delete(recursive: true);
    } catch (e) {
      throw ObxStorageClearError();
    }
  }

  @override
  void close() {
    unawaited(clearDatabase());
  }

  @override
  Future<void> reset() {
    try {
      store.close();
      return init();
    } catch (e) {
      throw ObxStorageResetError();
    }
  }

  @override
  Stream<List<Message>> getChatMessagesStream(String chatId) {
    try {
      return chatEntityBox.query(ChatEntity_.chatId.equals(chatId)).watch().map(
        (query) {
          final chatEntity = query.findFirst();
          if (chatEntity == null) {
            return [];
          }
          return chatEntity.messages.map((e) => e.toMessage()).toList();
        },
      );
    } catch (e) {
      throw ObxStorageValueStreamError('chatEntityBox');
    }
  }

  @override
  Subject<List<Message>> getChatMessagesSubject(String chatId) {
    try {
      Subject<List<Message>> subject = BehaviorSubject<List<Message>>();
      StreamSubscription streamSubscription =
          chatEntityBox.query(ChatEntity_.chatId.equals(chatId)).watch().listen(
        (query) {
          final chatEntity = query.findFirst();
          if (chatEntity == null) {
            subject.add([]);
            return;
          }
          subject.add(chatEntity.messages.map((e) => e.toMessage()).toList());
        },
      );
      subject.onCancel = () {
        streamSubscription.cancel();
      };
      return subject;
    } catch (e) {
      throw ObxStorageValueStreamError('chatEntityBox');
    }
  }

  @override
  List<Message> getChatMessages(String chatId) {
    try {
      final chatEntity = chatEntityBox
          .query(ChatEntity_.chatId.equals(chatId))
          .build()
          .findFirst();
      if (chatEntity == null) {
        log("No messages found for chatId: $chatId");
        return [];
      }
      return chatEntity.messages.reversed.map((e) => e.toMessage()).toList();
    } catch (e) {
      throw ObxStorageValueGetError('chatEntityBox');
    }
  }

  @override
  QuickChatUser? getQuickChatUser(String chatId) {
    try {
      final chatEntity = chatEntityBox
          .query(ChatEntity_.chatId.equals(chatId))
          .build()
          .findFirst();
      return chatEntity?.toQuickChatUser();
    } catch (e) {
      throw ObxStorageValueGetError('chatEntityBox');
    }
  }

  @override
  List<Degree> getDegrees() {
    try {
      return degreeEntityBox.getAll().map((e) => e.toModel()).toList();
    } catch (e) {
      log(e.toString());
      throw ObxStorageValueGetError('degreeEntityBox');
    }
  }

  @override
  List<Language> getLanguages() {
    try {
      return languageEntityBox.getAll().map((e) => e.toModel()).toList();
    } catch (e) {
      log(e.toString());
      throw ObxStorageValueGetError('languageEntityBox');
    }
  }

  @override
  List<MarketplaceCategoryModel> getMarketplaceCategories() {
    try {
      return marketplaceCategoriesEntityBox
          .getAll()
          .map((e) => e.toModel())
          .toList();
    } catch (e) {
      log(e.toString());
      throw ObxStorageValueGetError('marketplaceCategoriesEntityBox');
    }
  }

  @override
  List<University> getUniversities() {
    try {
      return universityEntityBox.getAll().map((e) => e.toModel()).toList();
    } catch (e) {
      throw ObxStorageValueGetError('universityEntityBox');
    }
  }

  @override
  Future<void> saveDegrees(List<Degree> degrees) {
    try {
      degreeEntityBox.removeAll();
      for (Degree degree in degrees) {
        DegreeEntity degreeEntity = DegreeEntity(title: degree.name);
        degreeEntityBox.put(degreeEntity);
      }
      return Future.value();
    } catch (e) {
      throw ObxStorageValueSaveError('degreeEntityBox');
    }
  }

  @override
  Future<void> saveLanguages(List<Language> languages) {
    try {
      languageEntityBox.removeAll();
      for (Language language in languages) {
        LanguageEntity languageEntity = LanguageEntity(name: language.name);
        languageEntityBox.put(languageEntity);
      }
      return Future.value();
    } catch (e) {
      throw ObxStorageValueSaveError('languageEntityBox');
    }
  }

  @override
  Future<void> saveMarketplaceCategories(
      List<MarketplaceCategoryModel> categories) {
    try {
      marketplaceCategoriesEntityBox.removeAll();
      for (MarketplaceCategoryModel category in categories) {
        MarketplaceCategoryEntity categoryEntity = MarketplaceCategoryEntity(
          modelId: category.id ?? 0,
          name: category.name ?? '',
        );
        marketplaceCategoriesEntityBox.put(categoryEntity);
      }
      return Future.value();
    } catch (e) {
      throw ObxStorageValueSaveError('marketplaceCategoriesEntityBox');
    }
  }

  @override
  Future<void> saveUniversities(List<University> universities) {
    try {
      universityEntityBox.removeAll();
      for (University university in universities) {
        UniversityEntity universityEntity = UniversityEntity(
          universityId: university.id,
          title: university.title ?? '',
          country: university.country ?? '',
          city: university.city ?? '',
          logo: university.logo ?? '',
          region: university.region ?? '',
        );
        universityEntityBox.put(universityEntity);
      }
      return Future.value();
    } catch (e) {
      throw ObxStorageValueSaveError('universityEntityBox');
    }
  }
}
