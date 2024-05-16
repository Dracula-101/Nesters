class IndianState {
  final String name;

  IndianState({required this.name});

  factory IndianState.fromJson(Map<String, dynamic> json) {
    return IndianState(
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
