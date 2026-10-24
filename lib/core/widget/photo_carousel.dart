import 'package:flutter/material.dart';
import 'package:kumo/core/widget/photo_placeholder.dart';

class PhotoCarousel extends StatefulWidget {
  const new({required this.images, super.key});

  final List<ImageProvider> images;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.images;
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
                child: Image(
                  image: photos[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const PhotoPlaceholder(),
                ),
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

class _PhotoCounter extends StatelessWidget {
  const new({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colors.inverseSurface,
      ),
      child: Text(
        '$current / $total fotos',
        style: TextStyle(color: colors.onInverseSurface, fontSize: 13),
      ),
    );
  }
}
