import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../controllers/channel_controller.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String channelId;
  final String channelName;

  const PlayerScreen({
    super.key,
    required this.channelId,
    required this.channelName,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer(String url) async {
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final streamsAsync =
    ref.watch(streamsByChannelProvider(widget.channelId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
      ),
      body: streamsAsync.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(error.toString()),
        ),
        data: (streams) {
          if (streams.isEmpty) {
            return const Center(
              child: Text('No hay streams disponibles'),
            );
          }

          if (_chewieController == null) {
            _initializePlayer(streams.first.url);
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Chewie(controller: _chewieController!);
        },
      ),
    );
  }
}
