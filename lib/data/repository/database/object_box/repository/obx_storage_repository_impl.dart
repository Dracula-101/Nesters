import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:nesters/data/repository/database/object_box/models/chat/chat_entity.dart';
import 'package:nesters/data/repository/database/object_box/models/chat/message/message_entity.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:nesters/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';

class ObjectBoxStorageRepository extends ObxStorageRepository {
  late Store store;
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
  }

  @override
  List<QuickChatUser> getChatUserProfiles() {
    try {
      return chatEntityBox.getAll().map((e) => e.toQuickChatUser()).toList();
    } catch (e) {
      rethrow;
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
      rethrow;
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
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  }

  Future<void> clearDatabase() async {
    try {
      Directory docsDir = await getApplicationDocumentsDirectory();
      Directory objectBoxDir = Directory('${docsDir.path}/$objectBoxDirectory');
      await objectBoxDir.delete(recursive: true);
    } catch (e) {
      rethrow;
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
      rethrow;
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
      rethrow;
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
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  }
}
