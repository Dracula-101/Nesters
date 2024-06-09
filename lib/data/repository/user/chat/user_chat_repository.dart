import 'dart:io';

import 'package:nesters/domain/models/chat/message.dart';
import 'package:rxdart/rxdart.dart';

abstract class RemoteChatRepository {
  String generateChatId(String senderId, String receiverId);
  Future<bool> doesChatExist(String chatId);
  Future<void> tokenChangeListener();
  Future<void> createChat(
    String chatId, {
    required String senderId,
    required String receiverId,
  });
  Future<List<Message>> fetchChatMessages(String chatId);
  Stream<List<Message>> getChatMessages(String chatId);
  Subject<List<Message>> getChatMessagesSubject(String chatId);
  Future<String> sendMessage(String chatId, Message message);

  Stream<DocumentUploadTask> uploadDocument({
    required File file,
    required String chatID,
  });
  Future<String?> downloadDocument(String url);
}

class DocumentUploadTask {
  final bool isPreLoading;
  final double progress;
  final String? url;
  final bool isComplete;

  DocumentUploadTask({
    this.progress = 0.0,
    this.url = "",
    this.isComplete = false,
    this.isPreLoading = false,
  });

  DocumentUploadTask copyWith({
    double? progress,
    String? url,
    bool? isComplete,
    bool? isPreLoading,
  }) {
    return DocumentUploadTask(
      progress: progress ?? this.progress,
      url: url ?? this.url,
      isComplete: isComplete ?? this.isComplete,
      isPreLoading: isPreLoading ?? this.isPreLoading,
    );
  }

  static DocumentUploadTask success(String url) {
    return DocumentUploadTask(
      progress: 100,
      url: url,
      isComplete: true,
      isPreLoading: false,
    );
  }

  static DocumentUploadTask inProgress(double progress) {
    return DocumentUploadTask(
      progress: progress,
      url: null,
      isComplete: false,
      isPreLoading: false,
    );
  }

  @override
  String toString() =>
      'DocumentUploadTask(progress: $progress, url: $url, isComplete: $isComplete)';
}
