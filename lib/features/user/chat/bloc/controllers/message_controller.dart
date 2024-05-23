import 'dart:async';

import 'package:nesters/domain/models/chat/message.dart';
import 'package:rxdart/rxdart.dart';

class MessageController {
  final BehaviorSubject<List<Message>> _liveChatStreamController =
      BehaviorSubject.seeded([]);
  Stream<List<Message>> get liveChatStream => _liveChatStreamController.stream;
  int _lastSyncedEpochTime = 0;

  StreamSubscription<List<Message>>? _remoteStreamSubscription;
  final BehaviorSubject<List<Message>> _newMessagesStream = BehaviorSubject();
  Stream<List<Message>> get newMessageStream =>
      _newMessagesStream.stream.asBroadcastStream();
  Stream<Message?> get latestMessageStream =>
      liveChatStream.map((event) => event.lastOrNull);
  static const Duration _syncInterval = Duration(minutes: 30);
  Timer? _timer;

  MessageController({
    required List<Message> intialMessages,
    required this.getRemoteStream,
  }) {
    _initalizeController(intialMessages, getRemoteStream);
  }

  Subject<List<Message>> Function(String? epochTime) getRemoteStream;

  void _initalizeController(
    List<Message> messages,
    Subject<List<Message>> Function(String? epochTime) remoteChatStream,
  ) {
    _remoteStreamSubscription = remoteChatStream(
      _lastSyncedEpochTime == 0 ? null : _lastSyncedEpochTime.toString(),
    ).listen(null);
    messages.sort((a, b) => a.epochTime.compareTo(b.epochTime));
    _lastSyncedEpochTime = messages.isEmpty
        ? _lastSyncedEpochTime
        : messages.last.epochTime.microsecondsSinceEpoch;
    _liveChatStreamController.add(messages);
    _listenRemoteStream();
    _intializeResetTimer();
  }

  void _intializeResetTimer() {
    _timer = Timer.periodic(_syncInterval, (timer) {
      unawaited(_resetRemoteStream());
    });
  }

  Future<void> _resetRemoteStream() async {
    await _remoteStreamSubscription?.cancel();
    _remoteStreamSubscription =
        getRemoteStream.call(_lastSyncedEpochTime.toString()).listen(null);
    _listenRemoteStream();
  }

  void _listenRemoteStream() {
    _remoteStreamSubscription?.onData(addMessages);
  }

  void addMessage(Message message) {
    final List<Message> currentMessages =
        _liveChatStreamController.valueOrNull ?? [];
    final List<Message> updatedMessages =
        _filterMessages(currentMessages, [message]);
    updatedMessages.sort((a, b) => a.epochTime.compareTo(b.epochTime));
    _liveChatStreamController.add(updatedMessages);
    _newMessagesStream.add([message]);
  }

  void addMessages(List<Message> messages) {
    final List<Message> currentMessages = _liveChatStreamController.value;
    final List<Message> newMessages = messages
        .where((element) => !currentMessages.contains(element))
        .toList();
    final List<Message> updatedMessages =
        _filterMessages(currentMessages, newMessages);
    updatedMessages.sort((a, b) => a.epochTime.compareTo(b.epochTime));
    _liveChatStreamController.add(updatedMessages);
    _newMessagesStream.add(newMessages);
  }

  List<Message> _filterMessages(
      List<Message> currentMessages, List<Message> newMessages) {
    final List<Message> updatedMessages = [...currentMessages, ...newMessages];
    updatedMessages.sort((a, b) => a.epochTime.compareTo(b.epochTime));
    final List<Message> filteredMessages = [];
    // remove all messages with same epoch time
    for (int i = 0; i < updatedMessages.length; i++) {
      if (i == 0) {
        filteredMessages.add(updatedMessages[i]);
      } else if (updatedMessages[i].epochTime !=
          updatedMessages[i - 1].epochTime) {
        filteredMessages.add(updatedMessages[i]);
      }
    }
    filteredMessages.sort((a, b) => a.epochTime.compareTo(b.epochTime));
    _lastSyncedEpochTime = filteredMessages.isEmpty
        ? _lastSyncedEpochTime
        : filteredMessages.last.epochTime.microsecondsSinceEpoch;
    return filteredMessages;
  }

  Future<void> close() async {
    await _liveChatStreamController.close();
    await _remoteStreamSubscription?.cancel();
    _timer?.cancel();
  }
}
