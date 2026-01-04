import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../data/repositories/channel_repository.dart';
import '../../data/services/iptv_api_service.dart';
import '../../domain/entities/channel.dart';
import '../../data/models/stream_model.dart';

final channelRepositoryProvider = Provider<ChannelRepository>((ref) {
  return ChannelRepository(apiService: IptvApiService());
});

final channelsProvider = FutureProvider<List<Channel>>((ref) async {
  final repository = ref.read(channelRepositoryProvider);
  return repository.getChannels();
});

// Proveedor para obtener el mapa de Nombres de Países
final countryNamesProvider = FutureProvider<Map<String, String>>((ref) async {
  final repository = ref.read(channelRepositoryProvider);
  return repository.getCountryNames();
});

// Proveedor para obtener el mapa de Nombres de Idiomas
final languageNamesProvider = FutureProvider<Map<String, String>>((ref) async {
  final repository = ref.read(channelRepositoryProvider);
  return repository.getLanguageNames();
});

// Helper para convertir código de país a Bandera Emoji (ej: US -> 🇺🇸)
String _getCountryFlag(String countryCode) {
  try {
    return countryCode.toUpperCase().replaceAllMapped(
        RegExp(r'[A-Z]'),
            (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
  } catch (e) {
    return '';
  }
}

// Agrupado por IDIOMA (Con nombre completo)
final channelsByLanguageProvider = FutureProvider<Map<String, List<Channel>>>((ref) async {
  final channels = await ref.watch(channelsProvider.future);
  final languageNames = await ref.watch(languageNamesProvider.future);

  return groupBy(channels, (Channel c) {
    if (c.languages.isEmpty) return 'Desconocido';
    final code = c.languages.first.toLowerCase();
    // Devuelve el nombre real o el código en mayúsculas si no existe
    return languageNames[code] ?? code.toUpperCase();
  });
});

// Agrupado por PAÍS (Con bandera y nombre completo)
final channelsByCountryProvider = FutureProvider<Map<String, List<Channel>>>((ref) async {
  final channels = await ref.watch(channelsProvider.future);
  final countryNames = await ref.watch(countryNamesProvider.future);

  return groupBy(channels, (Channel c) {
    if (c.country.isEmpty) return 'Internacional';
    final code = c.country.toUpperCase();
    final name = countryNames[code] ?? code;
    final flag = _getCountryFlag(code);
    return '$flag  $name';
  });
});

final streamsByChannelProvider =
FutureProvider.family<List<StreamModel>, String>((ref, String channelId) async {
  final repository = ref.read(channelRepositoryProvider);
  return repository.getStreamsByChannel(channelId);
});