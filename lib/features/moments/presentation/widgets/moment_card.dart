import 'package:flutter/material.dart';
import 'package:kumo/core/extensions/date_time_extensions.dart';
import 'package:kumo/core/widget/photo_placeholder.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/presentation/extensions/moment_photo_image.dart';
import 'package:kumo/features/moments/presentation/widgets/emotion_chip.dart';

class MomentCard extends StatelessWidget {
  const new({required this.moment, this.onTap, super.key});

  final Moment moment;
  final VoidCallback? onTap;

  static const double _thumbnailSize = 88;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstPhoto = moment.photos.firstOrNull;
    final emotion = moment.sentiment?.emotion;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: _thumbnailSize,
                height: _thumbnailSize,
                child: firstPhoto == null
                    ? const PhotoPlaceholder()
                    : Image(
                        image: firstPhoto.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const PhotoPlaceholder(),
                      ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Flexible(
                        child: Text(
                          moment.placeName,
                          style: textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (emotion != null) EmotionChip(emotion: emotion),
                    ],
                  ),
                  Text(
                    moment.note,
                    style: textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    moment.createdAt.toHumanReadable(),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
