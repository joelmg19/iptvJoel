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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IPTV Player'),
          actions: [
            // BOTÓN DE BÚSQUEDA
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                final channelsAsync = ref.read(channelsProvider);
                channelsAsync.whenData((channels) {
                  showSearch(
                    context: context,
                    delegate: ChannelSearchDelegate(channels),
                  );
                });
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
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

// --- VISTAS (Idiomas, Países, Todos) ---

class LanguagesView extends ConsumerWidget {
  const LanguagesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagesAsync = ref.watch(channelsByLanguageProvider);
    return languagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (grouped) {
        final keys = grouped.keys.toList()..sort();
        return ListView.builder(
          itemCount: keys.length,
          itemBuilder: (context, index) {
            final key = keys[index];
            final channels = grouped[key]!;
            return SectionHorizontalList(title: key, channels: channels);
          },
        );
      },
    );
  }
}

class CountriesView extends ConsumerWidget {
  const CountriesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(channelsByCountryProvider);
    return countriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (grouped) {
        final keys = grouped.keys.toList()..sort();
        return ListView.builder(
          itemCount: keys.length,
          itemBuilder: (context, index) {
            final key = keys[index];
            final channels = grouped[key]!;
            return ExpansionTile(
              title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: channels.length,
                  itemBuilder: (_, i) => ChannelCard(channel: channels[i]),
                )
              ],
            );
          },
        );
      },
    );
  }
}

class AllChannelsView extends ConsumerWidget {
  const AllChannelsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelsProvider);
    return channelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (channels) => GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: channels.length,
        itemBuilder: (_, i) => ChannelCard(channel: channels[i]),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class SectionHorizontalList extends StatelessWidget {
  final String title;
  final List<Channel> channels;

  const SectionHorizontalList({super.key, required this.title, required this.channels});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: channels.length,
            itemBuilder: (_, i) => SizedBox(
              width: 110,
              child: ChannelCard(channel: channels[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class ChannelCard extends StatelessWidget {
  final Channel channel;

  const ChannelCard({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => PlayerScreen(channelId: channel.id, channelName: channel.name),
        ));
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white10,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                // LÓGICA DE LOGO MEJORADA
                child: channel.logo.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: channel.logo,
                  fit: BoxFit.contain,
                  // Si falla la imagen, muestra el icono por defecto
                  errorWidget: (context, url, error) => _buildFallbackLogo(),
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
                    : _buildFallbackLogo(),
              ),
            ),
            Container(
              color: Colors.black87,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Text(
                channel.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.tv_off, color: Colors.white24, size: 30),
        const SizedBox(height: 4),
        Text(
          channel.name.characters.take(3).toString().toUpperCase(),
          style: const TextStyle(color: Colors.white24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// --- DELEGADO DE BÚSQUEDA ---

class ChannelSearchDelegate extends SearchDelegate {
  final List<Channel> allChannels;

  ChannelSearchDelegate(this.allChannels);

  @override
  String get searchFieldLabel => 'Buscar canal...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark(); // Mantiene el tema oscuro en el buscador
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allChannels.where((channel) {
      return channel.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final channel = suggestions[index];
        return ListTile(
          leading: SizedBox(
            width: 40,
            height: 40,
            child: channel.logo.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: channel.logo,
              errorWidget: (_, __, ___) => const Icon(Icons.tv),
            )
                : const Icon(Icons.tv),
          ),
          title: Text(channel.name),
          subtitle: Text(channel.country.toUpperCase()),
          onTap: () {
            close(context, null); // Cierra el buscador
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => PlayerScreen(channelId: channel.id, channelName: channel.name),
            ));
          },
        );
      },
    );
  }
}