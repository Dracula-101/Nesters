part of 'chat_bloc.dart';

// @freezed
// class ChatEvent with _$ChatEvent {
//   const factory ChatEvent.loadChats(String chatId) = _LoadChats;
//   const factory ChatEvent.checkChat(String senderId, String receiverId) =
//       _CheckChat;
//   const factory ChatEvent.closeChat() = _CancelChatSubscription;
//   const factory ChatEvent.sendMessage(Message message) = _SendMessage;
//   const factory ChatEvent.sendDocument(DocumentSource source, String senderId) =
//       _SendDocument;
//   const factory ChatEvent.downloadDocument(
//       String url, VoidCallback onComplete) = _DownloadDocument;
// }

abstract class ChatEvent {
  const ChatEvent();

  const factory ChatEvent.loadChats(String chatId) = _LoadChats;
  const factory ChatEvent.checkChat(String senderId, String receiverId) =
      _CheckChat;
  const factory ChatEvent.closeChat() = _CancelChatSubscription;
  const factory ChatEvent.sendMessage(Message message) = _SendMessage;
  const factory ChatEvent.sendDocument(DocumentSource source, String senderId) =
      _SendDocument;
  const factory ChatEvent.downloadDocument(
      String url, VoidCallback onComplete) = _DownloadDocument;

  R when<R>({
    required R Function(String chatId) loadChats,
    required R Function(String senderId, String receiverId) checkChat,
    required R Function() closeChat,
    required R Function(Message message) sendMessage,
    required R Function(DocumentSource source, String senderId) sendDocument,
    required R Function(String url, VoidCallback onComplete) downloadDocument,
  }) {
    if (this is _LoadChats) {
      return loadChats((this as _LoadChats).chatId);
    } else if (this is _CheckChat) {
      return checkChat(
          (this as _CheckChat).senderId, (this as _CheckChat).receiverId);
    } else if (this is _CancelChatSubscription) {
      return closeChat();
    } else if (this is _SendMessage) {
      return sendMessage((this as _SendMessage).message);
    } else if (this is _SendDocument) {
      return sendDocument(
          (this as _SendDocument).source, (this as _SendDocument).senderId);
    } else if (this is _DownloadDocument) {
      return downloadDocument((this as _DownloadDocument).url,
          (this as _DownloadDocument).onComplete);
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeWhen<R>({
    R Function(String chatId)? loadChats,
    R Function(String senderId, String receiverId)? checkChat,
    R Function()? closeChat,
    R Function(Message message)? sendMessage,
    R Function(DocumentSource source, String senderId)? sendDocument,
    R Function(String url, VoidCallback onComplete)? downloadDocument,
    required R Function() orElse,
  }) {
    if (this is _LoadChats) {
      return loadChats != null
          ? loadChats((this as _LoadChats).chatId)
          : orElse();
    } else if (this is _CheckChat) {
      return checkChat != null
          ? checkChat(
              (this as _CheckChat).senderId, (this as _CheckChat).receiverId)
          : orElse();
    } else if (this is _CancelChatSubscription) {
      return closeChat != null ? closeChat() : orElse();
    } else if (this is _SendMessage) {
      return sendMessage != null
          ? sendMessage((this as _SendMessage).message)
          : orElse();
    } else if (this is _SendDocument) {
      return sendDocument != null
          ? sendDocument(
              (this as _SendDocument).source, (this as _SendDocument).senderId)
          : orElse();
    } else if (this is _DownloadDocument) {
      return downloadDocument != null
          ? downloadDocument((this as _DownloadDocument).url,
              (this as _DownloadDocument).onComplete)
          : orElse();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R map<R>({
    required R Function(_LoadChats) loadChats,
    required R Function(_CheckChat) checkChat,
    required R Function(_CancelChatSubscription) closeChat,
    required R Function(_SendMessage) sendMessage,
    required R Function(_SendDocument) sendDocument,
    required R Function(_DownloadDocument) downloadDocument,
  }) {
    if (this is _LoadChats) {
      return loadChats(this as _LoadChats);
    } else if (this is _CheckChat) {
      return checkChat(this as _CheckChat);
    } else if (this is _CancelChatSubscription) {
      return closeChat(this as _CancelChatSubscription);
    } else if (this is _SendMessage) {
      return sendMessage(this as _SendMessage);
    } else if (this is _SendDocument) {
      return sendDocument(this as _SendDocument);
    } else if (this is _DownloadDocument) {
      return downloadDocument(this as _DownloadDocument);
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeMap<R>({
    R Function(_LoadChats)? loadChats,
    R Function(_CheckChat)? checkChat,
    R Function(_CancelChatSubscription)? closeChat,
    R Function(_SendMessage)? sendMessage,
    R Function(_SendDocument)? sendDocument,
    R Function(_DownloadDocument)? downloadDocument,
    required R Function(ChatEvent) orElse,
  }) {
    if (this is _LoadChats) {
      return loadChats != null ? loadChats(this as _LoadChats) : orElse(this);
    } else if (this is _CheckChat) {
      return checkChat != null ? checkChat(this as _CheckChat) : orElse(this);
    } else if (this is _CancelChatSubscription) {
      return closeChat != null
          ? closeChat(this as _CancelChatSubscription)
          : orElse(this);
    } else if (this is _SendMessage) {
      return sendMessage != null
          ? sendMessage(this as _SendMessage)
          : orElse(this);
    } else if (this is _SendDocument) {
      return sendDocument != null
          ? sendDocument(this as _SendDocument)
          : orElse(this);
    } else if (this is _DownloadDocument) {
      return downloadDocument != null
          ? downloadDocument(this as _DownloadDocument)
          : orElse(this);
    } else {
      throw StateError('Unknown type $this');
    }
  }
}

class _LoadChats extends ChatEvent {
  const _LoadChats(this.chatId);

  final String chatId;
}

class _CheckChat extends ChatEvent {
  const _CheckChat(this.senderId, this.receiverId);

  final String senderId;
  final String receiverId;
}

class _CancelChatSubscription extends ChatEvent {
  const _CancelChatSubscription();
}

class _SendMessage extends ChatEvent {
  const _SendMessage(this.message);

  final Message message;
}

class _SendDocument extends ChatEvent {
  const _SendDocument(this.source, this.senderId);

  final DocumentSource source;
  final String senderId;
}

class _DownloadDocument extends ChatEvent {
  const _DownloadDocument(this.url, this.onComplete);

  final String url;
  final VoidCallback onComplete;
}
