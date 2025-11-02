import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

class MusicPlayerScreen extends StatefulWidget {
  final List<Map<String, String>> tracks;
  final int index;

  const MusicPlayerScreen({
    super.key,
    required this.tracks,
    required this.index,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late AudioPlayer player;
  late int index;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    index = widget.index;
    player = AudioPlayer();
    play();

    player.onPositionChanged.listen((p) {
      setState(() => position = p);
    });

    player.onDurationChanged.listen((d) {
      setState(() => duration = d);
    });

    player.onPlayerStateChanged.listen((s) {
      setState(() => isPlaying = s == PlayerState.playing);
    });
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes);
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> play() async {
    final path = widget.tracks[index]['path']!.replaceFirst("assets/", "");
    await player.play(AssetSource(path));
  }

  Future<void> next() async {
    if (index < widget.tracks.length - 1) {
      index++;
      await play();
    }
  }

  Future<void> previous() async {
    if (index > 0) {
      index--;
      await play();
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.tracks[index];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background, //const Color(0xFFD2B48C),
        title: Text(
          track['title']!,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 120, backgroundImage: AssetImage(track['img']!)),

          const SizedBox(height: 25),

          Text(
            track['title']!,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            track["artist"] ?? "Artiste inconnu",
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),

          const SizedBox(height: 20),

          // ✅ Slider + Durées
          Column(
            children: [
              Slider(
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds.toDouble() + 1,
                activeColor: Colors.brown,
                onChanged: (value) {
                  player.seek(Duration(seconds: value.toInt()));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(position),
                      style: const TextStyle(color: Colors.black),
                    ),
                    Text(
                      formatTime(duration),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ✅ Boutons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: previous,
                icon: const Icon(Icons.skip_previous, size: 45),
              ),
              IconButton(
                onPressed: () => isPlaying ? player.pause() : play(),
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 75,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: next,
                icon: const Icon(Icons.skip_next, size: 45),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
