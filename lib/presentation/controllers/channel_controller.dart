import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart'; // Necesario para groupBy

import '../../data/repositories/channel_repository.dart';
import '../../data/services/iptv_api_service.dart';
import '../../domain/entities/channel.dart';
import '../../data/models/stream_model.dart';

// Repositorio
final channelRepositoryProvider = Provider<ChannelRepository>((ref) {
  return ChannelRepository(
    apiService: IptvApiService(),
  );
});

// Proveedor base de todos los canales
final channelsProvider = FutureProvider<List<Channel>>((ref) async {
  final repository = ref.read(channelRepositoryProvider);
  return repository.getChannels();
});

// Proveedor agrupado por IDIOMA
final channelsByLanguageProvider = FutureProvider<Map<String, List<Channel>>>((ref) async {
  final channels = await ref.watch(channelsProvider.future);

  return groupBy(channels, (Channel c) {
    if (c.languages.isEmpty) return 'Otros';
    // Tomamos el primer idioma y lo ponemos en mayúsculas (ej: spa -> SPA)
    return c.languages.first.toUpperCase();
  });
});

// Proveedor agrupado por PAÍS
final channelsByCountryProvider = FutureProvider<Map<String, List<Channel>>>((ref) async {
  final channels = await ref.watch(channelsProvider.future);

  return groupBy(channels, (Channel c) {
    return c.country.isEmpty ? 'Internacional' : c.country;
  });
});

// Proveedor de Streams por Canal
final streamsByChannelProvider =
FutureProvider.family<List<StreamModel>, String>((ref, String channelId) async {
  final repository = ref.read(channelRepositoryProvider);
  return repository.getStreamsByChannel(channelId);
});