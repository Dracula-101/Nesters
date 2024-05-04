import 'package:equatable/equatable.dart';

class University extends Equatable {
  final String name;
  final String? universityIcon;

  const University({
    required this.name,
    this.universityIcon,
  });

  @override
  List<Object?> get props => [name, universityIcon];
}
