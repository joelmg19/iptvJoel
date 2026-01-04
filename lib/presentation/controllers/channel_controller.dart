import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/channel_repository.dart';
import '../../data/services/iptv_api_service.dart';
import '../../domain/entities/channel.dart';

final channelRepositoryProvider = Provider<ChannelRepository>((ref) {
  return ChannelRepository(
    apiService: IptvApiService(),
  );
});

final channelsProvider =
FutureProvider<List<Channel>>((ref) async {
  final repository = ref.read(channelRepositoryProvider);
  return repository.getChannels();
});

final streamsByChannelProvider =
FutureProvider.family((ref, String channelId) async {
  final repository = ref.read(channelRepositoryProvider);
  return repository.getStreamsByChannel(channelId);
});
