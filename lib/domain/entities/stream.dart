import 'package:equatable/equatable.dart';

class Stream extends Equatable {
  final String channelId;
  final String url;
  final String status;

  const Stream({
    required this.channelId,
    required this.url,
    required this.status,
  });

  @override
  List<Object?> get props => [
    channelId,
    url,
    status,
  ];
}
