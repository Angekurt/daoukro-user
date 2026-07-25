import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_colors.dart';

/// Galerie photo pour une fiche détail (pharmacie, hébergement, artisan...).
/// Combine la photo de couverture + les photos de galerie, affichées en
/// carrousel plein écran avec un aperçu plein écran au tap.
class PhotoGallery extends StatefulWidget {
  final String? photoCouverture;
  final List<String> photos;
  final double height;

  const PhotoGallery({
    super.key,
    required this.photoCouverture,
    required this.photos,
    this.height = 240,
  });

  List<String> get _toutes => [
        if (photoCouverture != null) photoCouverture!,
        ...photos.where((p) => p != photoCouverture),
      ];

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final _controller = PageController();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget._toutes;
    if (images.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: widget.height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? AppColors.white12 : AppColors.border, width: 1),
        ),
        child: Stack(
          children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: images.length,
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => _ouvrirPleinEcran(context, images, i),
              child: CachedNetworkImage(
                imageUrl: images[i],
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: isDark ? AppColors.cardDark : AppColors.shimmerBase,
                  highlightColor: isDark ? AppColors.white12 : AppColors.shimmerHigh,
                  child: Container(color: isDark ? AppColors.cardDark : AppColors.white),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceAlt,
                  child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted, size: 32),
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: images.length,
                  effect: const WormEffect(
                    dotHeight: 6,
                    dotWidth: 6,
                    activeDotColor: AppColors.white,
                    dotColor: Color(0x80FFFFFF),
                  ),
                ),
              ),
            ),
          if (images.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${_page + 1}/${images.length}',
                    style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ouvrirPleinEcran(BuildContext context, List<String> images, int index) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _VisionneusePleinEcran(images: images, indexInitial: index),
      fullscreenDialog: true,
    ));
  }
}

class _VisionneusePleinEcran extends StatelessWidget {
  final List<String> images;
  final int indexInitial;
  const _VisionneusePleinEcran({required this.images, required this.indexInitial});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: indexInitial),
        itemCount: images.length,
        itemBuilder: (context, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: CachedNetworkImage(imageUrl: images[i], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
