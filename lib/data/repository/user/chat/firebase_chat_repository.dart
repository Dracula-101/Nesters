import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:cloudinary/cloudinary.dart';
import 'package:mime/mime.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nesters/data/repository/config/app_secrets_repository.dart';
import 'package:nesters/data/repository/user/error/user_chat_error.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:path/path.dart' as path_provider;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'remote_chat_repository.dart';
// import 'package:image_downloader/image_downloader.dart';

class FirebaseChatRepository extends RemoteChatRepository {
  FirebaseChatRepository({
    required AppSecretsRepository appSecretsRepository,
  }) : _appSecretsRepository = appSecretsRepository;

  final AppSecretsRepository _appSecretsRepository;
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  late final Cloudinary _cloudinaryClient = Cloudinary.signedConfig(
    apiKey: _appSecretsRepository.getSecret(AppSecretsKeys.CLOUDINARY_API_KEY),
    apiSecret:
        _appSecretsRepository.getSecret(AppSecretsKeys.CLOUDINARY_API_SECRET),
    cloudName:
        _appSecretsRepository.getSecret(AppSecretsKeys.CLOUDINARY_CLOUD_NAME),
  );
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final HttpClient httpClient = HttpClient();

  @override
  String generateChatId(String senderId, String receiverId) {
    final sortedIds = [receiverId, senderId]..sort();
    return sortedIds.join('_');
  }

  @override
  Future<void> tokenChangeListener() async {
    try {
      _firebaseMessaging.onTokenRefresh.listen(
        (token) async {
          log('Token Refreshed $token');
          await _store.collection('users').doc('token').set({'token': token});
        },
      );
    } on Exception {
      throw UserChatErrorFactory.create(
        UserChatErrorCode.TOKEN_CHANGE_LISTENER_ERR,
        'Token Change Listener Error',
      );
    }
  }

  @override
  Future<List<Message>> fetchChatMessages(String chatId) {
    try {
      return _store
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('epochTime', descending: true)
          .get()
          .then(
            (value) => value.docs
                .map<Message>(
                  (e) => Message.fromMap(
                    {
                      ...e.data(),
                      'id': e.id,
                    },
                  ),
                )
                .toList(),
          );
    } on Exception {
      throw UserChatErrorFactory.create(
        UserChatErrorCode.CHAT_GET_MSG_ERR,
        'Fetch Chat Messages Error',
      );
    }
  }

  @override
  Stream<List<Message>> getChatMessages(String chatId) {
    try {
      return _store
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('epochTime', descending: true)
          .snapshots()
          .map((event) {
        return event.docs
            .map((e) => Message.fromMap({
                  ...e.data(),
                  'id': e.id,
                }))
            .toList();
      });
    } on Exception {
      throw UserChatErrorFactory.create(
        UserChatErrorCode.CHAT_GET_MSG_ERR,
        'Get Chat Messages Error',
      );
    }
  }

  @override
  Subject<List<Message>> getChatMessagesSubject(String chatId) {
    try {
      Subject<List<Message>> subject = BehaviorSubject<List<Message>>();
      StreamSubscription subscription = _store
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('epochTime', descending: true)
          .snapshots()
          .map((event) {
        return event.docs
            .map((e) => Message.fromMap({
                  ...e.data(),
                  'id': e.id,
                }))
            .toList();
      }).listen((event) {
        subject.add(event);
      });
      subject.doOnCancel(() {
        subscription.cancel();
      });
      return subject;
    } on Exception {
      throw UserChatErrorFactory.create(
        UserChatErrorCode.CHAT_GET_MSG_ERR,
        'Get Chat Messages Subject Error',
      );
    }
  }

  @override
  Future<String> sendMessage(String chatId, Message message) {
    try {
      return _store
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap())
          .then((value) => value.id);
    } on Exception {
      throw UserChatErrorFactory.create(
        UserChatErrorCode.CHAT_ADD_MSG_ERR,
        'Send Message Error',
      );
    }
  }

  @override
  Future<bool> doesChatExist(String chatId) {
    try {
      return _store.collection('chats').doc(chatId).get().then(
            (value) => value.exists,
          );
    } on Exception {
      throw UserChatErrorFactory.create(
        UserChatErrorCode.CHAT_ROOM_EXIST_ERR,
        'Chat Room Exist Error',
      );
    }
  }

  @override
  Future<void> createChat(
    String chatId, {
    required String senderId,
    required String receiverId,
  }) async {
    try {
      //get user details and store in local object box
      return _store.collection('chats').doc(chatId).set(
        {
          'id': chatId,
          'participants': [senderId, receiverId],
          'created_at': DateTime.now().toIso8601String(),
        },
      );
    } on Exception {
      throw UserChatErrorFactory.create(
        UserChatErrorCode.CHAT_ROOM_CREATE_ERR,
        'Create Chat Room Error',
      );
    }
  }

  @override
  Stream<DocumentUploadTask> uploadDocument({
    required File file,
    required String chatID,
  }) async* {
    final String fileName = path_provider.basename(file.path);
    try {
      final uploadFuture = _cloudinaryClient.upload(
        file: file.path,
        folder: 'nesters_chat_images/$chatID',
        resourceType: CloudinaryResourceType.image,
        fileName: fileName,
      );
      final response = await uploadFuture;
      yield DocumentUploadTask(
        progress: 1.0,
        isComplete: true,
        url: response.secureUrl,
      );
    } catch (e) {
      throw UserChatErrorFactory.create(
        UserChatErrorCode.CHAT_UPLOAD_DOC_ERR,
        'Upload Document Error: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> downloadDocument(String url) async {
    String? message;
    math.Random random = math.Random();
    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(url));

      // Get temporary directory
      final dir = await getTemporaryDirectory();
      final fileType = url.split('.').last.split('?').first;
      // Create an image name
      String filename =
          '${dir.path}/SaveImage${random.nextInt(1000)}.$fileType';

      // Save to filesystem
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);

      // Ask the user to save it
      // TODO: Implement this
      // final params = SaveFileDialogParams(sourceFilePath: file.path);
      // final finalPath = await FlutterFileDialog.saveFile(params: params);

      // if (finalPath != null) {
      //   message = 'Image saved successfully.';
      // }
      return message;
    } on Exception {
      throw UserChatErrorFactory.create(
        UserChatErrorCode.CHAT_DOWNLOAD_DOC_ERR,
        'Download Document Error',
      );
    }
  }
}
