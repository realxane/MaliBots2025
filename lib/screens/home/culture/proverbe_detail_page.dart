import 'package:flutter/material.dart';

class ProverbeDetailPage extends StatefulWidget {
  final Map<String, String> proverbe;
  const ProverbeDetailPage({super.key, required this.proverbe});

  @override
  State<ProverbeDetailPage> createState() => _ProverbeDetailPageState();
}

class _ProverbeDetailPageState extends State<ProverbeDetailPage> {
  bool isLiked = false;
  bool isDisliked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détail du Proverbe',
          style: TextStyle(color: Colors.brown),
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
              widget.proverbe['texte']!,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.proverbe['origine']!,
              style: const TextStyle(color: Colors.grey),
            ),
            const Spacer(),
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
