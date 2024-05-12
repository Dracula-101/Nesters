class Language {
  final String name;
  final String id;

  Language({required this.name, required this.id});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'],
      id: json['id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}
