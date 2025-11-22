import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'glass_container.dart';

class MediaCard extends StatelessWidget {
  const MediaCard({super.key, required this.imageUrl, required this.title, this.rating, this.onTap});
  final String imageUrl;
  final String title;
  final double? rating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        borderRadius: 16,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 2/3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (c, _) => Container(color: Colors.white10),
                  errorWidget: (c, _, __) => const Center(child: Icon(Icons.image_not_supported, color: Colors.white54)),
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
              ),
            ),
            if (rating != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(rating!.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
