import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/channel_model.dart';
import '../models/stream_model.dart';

class IptvApiService {
  final http.Client client;
  List<StreamModel>? _cachedStreams;

  IptvApiService({http.Client? client}) : client = client ?? http.Client();

  /// Obtiene streams, usando caché y filtrando por ID de canal
  Future<List<StreamModel>> fetchStreamsByChannel(String channelId) async {
    if (_cachedStreams == null) {
      print('Descargando lista maestra de streams...');
      final response = await client.get(Uri.parse(ApiConstants.streams));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedStreams = data.map((json) => StreamModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar streams IPTV');
      }
    }

    final matchingStreams = _cachedStreams!.where((stream) {
      final isValidUrl = stream.url.startsWith('http') && stream.url.contains('.m3u8');
      return stream.channelId == channelId && isValidUrl;
    }).toList();

    return matchingStreams;
  }

  /// Obtiene la lista de canales
  Future<List<ChannelModel>> fetchChannels() async {
    final response = await client.get(Uri.parse(ApiConstants.channels));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChannelModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar canales IPTV');
    }
  }

  /// Obtiene mapa de códigos de país a nombres reales (ej: "CL" -> "Chile")
  Future<Map<String, String>> fetchCountryNames() async {
    try {
      final response = await client.get(Uri.parse(ApiConstants.countries));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, String> map = {};
        for (var item in data) {
          map[item['code'].toString().toUpperCase()] = item['name'].toString();
        }
        return map;
      }
    } catch (e) {
      print('Error cargando países: $e');
    }
    return {};
  }

  /// Obtiene mapa de códigos de idioma a nombres reales (ej: "spa" -> "Spanish")
  Future<Map<String, String>> fetchLanguageNames() async {
    try {
      final response = await client.get(Uri.parse(ApiConstants.languages));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, String> map = {};
        for (var item in data) {
          map[item['code'].toString().toLowerCase()] = item['name'].toString();
        }
        return map;
      }
    } catch (e) {
      print('Error cargando idiomas: $e');
    }
    return {};
  }
}