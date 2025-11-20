// Fichier: photo_detail_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/models/photo.dart';
// 🚀 Assurez-vous d'utiliser le bon chemin d'importation

class PhotoDetailPage extends StatefulWidget {
  // 🚀 Le type de la photo est maintenant le modèle Photo
  final Photo photo;
  const PhotoDetailPage({super.key, required this.photo});

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  int _currentIndex = 0;
  late PageController _pageController;
  late Timer _timer;
  bool isLiked = false;
  bool isDisliked = false;

  // Le chemin d'accès au stockage pour les images non complètes (si nécessaire)
  // final String storageBaseUrl = 'http://192.168.1.35:8000/storage/';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Vérification pour s'assurer qu'il y a plus d'une image pour le carrousel
    if (widget.photo.images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_currentIndex < widget.photo.images.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
        }

        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      });
    } else {
      // Annule le timer si une seule image est présente
      _timer = Timer(Duration.zero, () {});
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.photo.images;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.photo.titre,
          style: const TextStyle(color: Colors.brown),
        ),
        iconTheme: const IconThemeData(color: Colors.brown),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                // 🚀 CHANGEMENT: Utilisation de Image.network et de l'attribut .url
                return Image.network(
                  images[index].url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text("Erreur de chargement de l'image"),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index ? Colors.brown : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.photo.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
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
                    if (isLiked) isDisliked = false;
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
                    if (isDisliked) isLiked = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
