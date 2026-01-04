import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/channel_model.dart';
import '../models/stream_model.dart';

class IptvApiService {
  final http.Client client;

  // Cache para guardar los streams y no descargarlos cada vez
  List<StreamModel>? _cachedStreams;

  IptvApiService({http.Client? client}) : client = client ?? http.Client();

  /// Obtiene streams, usando caché y filtrando por ID de canal
  Future<List<StreamModel>> fetchStreamsByChannel(String channelId) async {
    // 1. Si no tenemos los streams en memoria, los descargamos (solo la primera vez)
    if (_cachedStreams == null) {
      print('Descargando lista maestra de streams... esto puede tardar un poco.');
      final response = await client.get(
        Uri.parse(ApiConstants.streams),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Guardamos todos los streams en memoria
        _cachedStreams = data
            .map((json) => StreamModel.fromJson(json))
            .toList();
        print('Total de streams descargados: ${_cachedStreams!.length}');
      } else {
        throw Exception('Error al cargar streams IPTV');
      }
    }

    // 2. Filtramos la lista maestra buscando coincidencias con el channelId
    // y asegurando que sean enlaces .m3u8 (HLS)
    final matchingStreams = _cachedStreams!.where((stream) {
      final isValidUrl = stream.url.startsWith('http') && stream.url.contains('.m3u8');
      return stream.channelId == channelId && isValidUrl;
    }).toList();

    print('Streams encontrados para el canal $channelId: ${matchingStreams.length}');
    return matchingStreams;
  }

  /// Obtiene la lista de canales
  Future<List<ChannelModel>> fetchChannels() async {
    final response = await client.get(
      Uri.parse(ApiConstants.channels),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data
          .map((json) => ChannelModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar canales IPTV');
    }
  }
}