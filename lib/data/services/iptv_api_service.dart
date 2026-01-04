import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/channel_model.dart';
import '../models/stream_model.dart';

class IptvApiService {
  final http.Client client;

  IptvApiService({http.Client? client})
      : client = client ?? http.Client();

  /// Obtiene streams IPTV válidos (HLS)
  /// Nota: muchas APIs IPTV NO relacionan bien channelId ↔ stream
  Future<List<StreamModel>> fetchStreamsByChannel(String channelId) async {
    final response = await client.get(
      Uri.parse(ApiConstants.streams),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final streams = data
          .where((json) {
        final url = json['url']?.toString() ?? '';
        return url.startsWith('http') &&
            url.contains('.m3u8'); // SOLO HLS
      })
          .map((json) => StreamModel.fromJson(json))
          .toList();

      print('Streams HLS válidos encontrados: ${streams.length}');

      return streams;
    } else {
      throw Exception('Error al cargar streams IPTV');
    }
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
