import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kumo/features/moments/domain/entities/moment_photo.dart';

class MomentPhotoCarousel extends StatefulWidget {
  const new({required this.photos, super.key});

  final List<MomentPhoto> photos;

  @override
  State<MomentPhotoCarousel> createState() => _MomentPhotoCarouselState();
}

class _MomentPhotoCarouselState extends State<MomentPhotoCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    if (photos.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: _pageController,
            itemCount: photos.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  var value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                  }
                  final scale = Curves.easeOut.transform(value);
                  return Center(
                    child: SizedBox(
                      height: scale * 250,
                      width: scale * screenWidth,
                      child: child,
                    ),
                  );
                },
                child: _MomentPhotoImage(photo: photos[index]),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 12,
            child: _PhotoCounter(
              current: _currentPage + 1,
              total: photos.length,
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra la foto remota si ya se subió, o la local si todavía no.
class _MomentPhotoImage extends StatelessWidget {
  const new({required this.photo});

  final MomentPhoto photo;

  @override
  Widget build(BuildContext context) {
    final remoteUrl = photo.remoteUrl;
    final localPath = photo.localPath;

    if (remoteUrl != null) {
      return Image.network(
        remoteUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
      );
    }
    if (localPath != null) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
      );
    }
    return const _PhotoPlaceholder();
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF1B1C24),
      child: Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white54),
      ),
    );
  }
}

class _PhotoCounter extends StatelessWidget {
  const new({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1B1C24),
      ),
      child: Text(
        '$current / $total fotos',
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
