import 'package:nesters/domain/models/chat/message.dart';

class Chat {
  String? id;
  List<String>? participants;
  List<Message>? messages;

  Chat({
    this.id,
    this.participants,
    this.messages,
  });

  Chat copyWith({
    String? id,
    List<String>? participants,
    List<Message>? messages,
  }) {
    return Chat(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
    );
  }

  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    participants = json['participants'].cast<String>();
    if (json['messages'] != null) {
      messages = <Message>[];
      json['messages'].forEach((v) {
        messages!.add(Message.fromMap(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['participants'] = participants;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toMap()).toList();
    }
    return data;
  }
}
