import '../models/channel_model.dart';
import '../services/iptv_api_service.dart';
import '../models/stream_model.dart';

class ChannelRepository {
  final IptvApiService apiService;

  ChannelRepository({required this.apiService});

  Future<List<StreamModel>> getStreamsByChannel(String channelId) {
    return apiService.fetchStreamsByChannel(channelId);
  }

  Future<List<ChannelModel>> getChannels() {
    return apiService.fetchChannels();
  }

  Future<Map<String, String>> getCountryNames() {
    return apiService.fetchCountryNames();
  }

  Future<Map<String, String>> getLanguageNames() {
    return apiService.fetchLanguageNames();
  }
}