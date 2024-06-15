class Language {
  final String name;
  Language({required this.name});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  @override
  String toString() {
    return name;
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
