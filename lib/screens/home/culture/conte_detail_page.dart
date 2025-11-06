import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

class ConteDetailPage extends StatefulWidget {
  final Map<String, String> conte;
  const ConteDetailPage({super.key, required this.conte});

  @override
  State<ConteDetailPage> createState() => _ConteDetailPageState();
}

class _ConteDetailPageState extends State<ConteDetailPage> {
  bool isLiked = false;
  bool isDisliked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.conte['titre']!,
          style: const TextStyle(color: Colors.brown),
        ),
        iconTheme: const IconThemeData(color: Colors.brown),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conte['titre']!,
              style: const TextStyle(
                fontSize: 22,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.conte['origine']!,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.conte['contenu']!,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isLiked ? Colors.brown : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked;
                      if (isLiked)
                        isDisliked = false; // empêche les deux d’être actifs
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                    color: isDisliked ? Colors.brown : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isDisliked = !isDisliked;
                      if (isDisliked)
                        isLiked = false; // empêche les deux d’être actifs
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
