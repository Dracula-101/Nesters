import 'dart:io';

import 'package:nesters/domain/models/chat/message.dart';

abstract class RemoteChatRepository {
  String generateChatId(String senderId, String receiverId);
  Future<List<Message>> fetchChatMessages(String chatId);
  Stream<List<Message>> getChatMessages(String chatId);
  Future<void> sendMessage(String chatId, Message message);
  Future<bool> doesChatExist(String chatId);
  Future<void> createChat(String chatId,
      {required String senderId, required String receiverId});
  Stream<DocumentUploadTask> uploadDocument(
      {required File file, required String chatID});
  Future<String?> downloadDocument(String url);
}

class DocumentUploadTask {
  final double progress;
  final String? url;
  final bool isComplete;

  DocumentUploadTask({
    required this.progress,
    required this.url,
    required this.isComplete,
  });

  DocumentUploadTask copyWith({
    double? progress,
    String? url,
    bool? isComplete,
  }) {
    return DocumentUploadTask(
      progress: progress ?? this.progress,
      url: url ?? this.url,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  static DocumentUploadTask success(String url) {
    return DocumentUploadTask(
      progress: 100,
      url: url,
      isComplete: true,
    );
  }

  static DocumentUploadTask inProgress(double progress) {
    return DocumentUploadTask(
      progress: progress,
      url: null,
      isComplete: false,
    );
  }

  @override
  String toString() =>
      'DocumentUploadTask(progress: $progress, url: $url, isComplete: $isComplete)';
}
