import 'package:equatable/equatable.dart';

class Channel extends Equatable {
  final String id;
  final String name;
  final String logo;
  final String country;
  final String category;
  final List<String> languages; // Nuevo campo

  const Channel({
    required this.id,
    required this.name,
    required this.logo,
    required this.country,
    required this.category,
    required this.languages,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    logo,
    country,
    category,
    languages,
  ];
}