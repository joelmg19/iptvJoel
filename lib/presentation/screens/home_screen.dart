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
    final channelsAsync = ref.watch(channelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IPTV Channels'),
      ),
      body: channelsAsync.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        data: (List<Channel> channels) {
          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];

              return ListTile(
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

                leading: channel.logo.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: channel.logo,
                  width: 40,
                  height: 40,
                  errorWidget: (_, __, ___) =>
                  const Icon(Icons.tv),
                )
                    : const Icon(Icons.tv),
                title: Text(channel.name),
                subtitle: Text(
                  '${channel.country} • ${channel.category}',

                ),
              );
            },
          );
        },
      ),
    );
  }
}
