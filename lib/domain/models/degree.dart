class Degree {
  final String name;

  Degree({
    required this.name,
  });

  factory Degree.fromJson(Map<String, dynamic> json) {
    return Degree(
      name: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': name,
    };
  }
}
