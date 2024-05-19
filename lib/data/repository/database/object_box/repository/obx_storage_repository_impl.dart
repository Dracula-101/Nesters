import 'dart:developer';
import 'dart:io';

import 'package:nesters/data/repository/database/object_box/models/chat/chat.dart';
import 'package:nesters/data/repository/database/object_box/models/chat/message/message.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

class ObjectBoxStorageRepository extends ObxStorageRepository {
  late Store store;
  late Box<ChatEntity> chatEntityBox;
  late Box<MessageEntity> messageEntityBox;
  static String objectBoxDirectory = 'objectbox';

  Future<void> close() async {
    store.close();
  }

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
      rethrow;
    }
  }

  @override
  Future<void> saveReceipentUser(QuickChatUser user) {
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
      rethrow;
    }
  }
}
