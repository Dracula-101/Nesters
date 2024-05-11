class IndianState {
  final String id;
  final String name;

  IndianState({required this.name, required this.id});

  factory IndianState.fromJson(Map<String, dynamic> json) {
    return IndianState(
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
