import '../../data/repositories/channel_repository.dart';
import '../entities/stream.dart';

class GetStreamsByChannelUseCase {
  final ChannelRepository repository;

  GetStreamsByChannelUseCase(this.repository);

  Future<List<Stream>> execute(String channelId) {
    return repository.getStreamsByChannel(channelId);
  }
}
