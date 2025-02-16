import 'package:nesters/utils/extensions/extensions.dart';

class Language {
  final String name;
  final String? nativeName;
  Language({
    required this.name,
    this.nativeName,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'] ?? '',
      nativeName: json['native_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'native_name': nativeName,
    };
  }

  @override
  String toString() {
    return name.toTitleCase;
  }
}

class Comment {
  String userId;
  String name;
  String comment;
  List<Comment>? replies;

  Comment(
      {required this.userId,
      required this.name,
      required this.comment,
      this.replies});
}
