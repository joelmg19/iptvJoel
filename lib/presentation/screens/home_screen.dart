import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/channel_controller.dart';
import '../../domain/entities/channel.dart';
import 'player_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3, // Idiomas, Países, Todos
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IPTV Player Pro'),
          centerTitle: true,
          elevation: 2,
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.translate), text: 'Idiomas'),
              Tab(icon: Icon(Icons.public), text: 'Países'),
              Tab(icon: Icon(Icons.grid_view), text: 'Todos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LanguagesView(),
            CountriesView(),
            AllChannelsView(),
          ],
        ),
      ),
    );
  }
}

// --- VISTA 1: IDIOMAS (Carruseles Horizontales) ---
class LanguagesView extends ConsumerWidget {
  const LanguagesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagesAsync = ref.watch(channelsByLanguageProvider);

    return languagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (groupedChannels) {
        // Ordenamos los idiomas alfabéticamente
        final languages = groupedChannels.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final languageCode = languages[index];
            final channels = groupedChannels[languageCode]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          languageCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${channels.length} canales',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 150, // Altura del carrusel
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: channels.length,
                    itemBuilder: (context, i) => SizedBox(
                      width: 120, // Ancho de cada tarjeta
                      child: ChannelCard(channel: channels[i]),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// --- VISTA 2: PAÍSES (Lista Expandible) ---
class CountriesView extends ConsumerWidget {
  const CountriesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(channelsByCountryProvider);

    return countriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (groupedChannels) {
        final countries = groupedChannels.keys.toList()..sort();

        return ListView.builder(
          itemCount: countries.length,
          itemBuilder: (context, index) {
            final country = countries[index];
            final channels = groupedChannels[country]!;

            return ExpansionTile(
              leading: const Icon(Icons.flag),
              title: Text('$country (${channels.length})'),
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: channels.length,
                  itemBuilder: (context, i) => ChannelCard(channel: channels[i]),
                )
              ],
            );
          },
        );
      },
    );
  }
}

// --- VISTA 3: TODOS (Grid Infinito) ---
class AllChannelsView extends ConsumerWidget {
  const AllChannelsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelsProvider);

    return channelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (channels) {
        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 columnas
            childAspectRatio: 0.75, // Proporción alto/ancho
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: channels.length,
          itemBuilder: (context, index) => ChannelCard(channel: channels[index]),
        );
      },
    );
  }
}

// --- WIDGET TARJETA DE CANAL (Reutilizable) ---
class ChannelCard extends StatelessWidget {
  final Channel channel;

  const ChannelCard({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(
              channelId: channel.id,
              channelName: channel.name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: channel.logo.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: channel.logo,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                      child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)
                      )
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.tv, size: 40, color: Colors.white24),
                )
                    : const Icon(Icons.tv, size: 40, color: Colors.white24),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                channel.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}