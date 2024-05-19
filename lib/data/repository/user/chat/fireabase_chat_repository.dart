import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:path/path.dart' as path_provider;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'user_chat_repository.dart';
// import 'package:image_downloader/image_downloader.dart';

class FirebaseChatRepository extends RemoteChatRepository {
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final HttpClient httpClient = HttpClient();

  @override
  String generateChatId(String senderId, String receiverId) {
    final sortedIds = [receiverId, senderId]..sort();
    return sortedIds.join('_');
  }

  @override
  Future<List<Message>> fetchChatMessages(String chatId) {
    try {
      return _store
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get()
          .then((value) => value.docs
              .map((e) => Message.fromMap(e['messages'].data()))
              .toList());
    } on Exception {
      rethrow;
    }
  }

  @override
  Stream<List<Message>> getChatMessages(String chatId) {
    try {
      return _store.collection('chats').doc(chatId).snapshots().map(
            (event) => event['messages']
                .map<Message>((e) => Message.fromMap(e))
                .toList()
                .reversed
                .toList(),
          );
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(String chatId, Message message) {
    try {
      DocumentReference docRef = _store.collection('chats').doc(chatId);
      return docRef.update({
        'messages': FieldValue.arrayUnion([message.toMap()])
      });
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<bool> doesChatExist(String chatId) {
    try {
      return _store.collection('chats').doc(chatId).get().then((value) {
        return value.exists;
      });
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> createChat(
    String chatId, {
    required String senderId,
    required String receiverId,
  }) {
    try {
      //get user details and store in local object box
      return _store.collection('chats').doc(chatId).set(
        {
          'id': chatId,
          'participants': [senderId, receiverId],
          'created_at': DateTime.now().toIso8601String(),
          'messages': []
        },
      );
    } on Exception {
      rethrow;
    }
  }

  @override
  Stream<DocumentUploadTask> uploadDocument(
      {required File file, required String chatID}) {
    Reference fileRef = _firebaseStorage
        .ref(
          'chats/$chatID',
        )
        .child(
          '${DateTime.now().toIso8601String()}${path_provider.extension(file.path)}',
        );
    UploadTask uploadTask = fileRef.putFile(
      file,
    );
    return uploadTask.snapshotEvents.asyncMap(
      (event) async {
        return event.state == TaskState.success
            ? DocumentUploadTask.success(
                await fileRef.getDownloadURL(),
              )
            : DocumentUploadTask.inProgress(
                event.bytesTransferred.toDouble() / event.totalBytes.toDouble(),
              );
      },
    );
  }

  @override
  Future<String?> downloadDocument(String url) async {
    String? message;
    Random random = Random();
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
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        message = 'Image saved successfully.';
      }
      return message;
    } on Exception {
      rethrow;
    }
  }
}
