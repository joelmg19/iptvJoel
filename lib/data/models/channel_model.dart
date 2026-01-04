import '../../domain/entities/channel.dart';

class ChannelModel extends Channel {
  const ChannelModel({
    required super.id,
    required super.name,
    required super.logo,
    required super.country,
    required super.category,
    required super.languages,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      country: json['country'] ?? '',
      category: json['category'] ?? '',
      // Mapeo seguro de la lista de idiomas
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}