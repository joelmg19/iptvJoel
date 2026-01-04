import '../../domain/entities/stream.dart';

class StreamModel extends Stream {
  const StreamModel({
    required super.channelId,
    required super.url,
    required super.status,
  });

  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(
      channelId: json['channel'] ?? '',
      url: json['url'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
