import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/status_chip.dart';
import 'record_image.dart';

/// Swipeable, pinch-to-zoom pages with a "2 / 5" counter. Reports the
/// visible page so the screen can delete it.
class RecordPageViewer extends StatefulWidget {
  const RecordPageViewer({
    super.key,
    required this.pages,
    required this.onPageChanged,
  });

  final List<RecordAttachment> pages;
  final ValueChanged<int> onPageChanged;

  @override
  State<RecordPageViewer> createState() => _RecordPageViewerState();
}

class _RecordPageViewerState extends State<RecordPageViewer> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final count = widget.pages.length;
    final index = _index.clamp(0, count == 0 ? 0 : count - 1);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: ColoredBox(
        color: AppColors.moss,
        child: AspectRatio(
          aspectRatio: AppSpacing.recordThumbAspect,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: count,
                onPageChanged: (i) {
                  setState(() => _index = i);
                  widget.onPageChanged(i);
                },
                itemBuilder: (_, i) => InteractiveViewer(
                  maxScale: AppSpacing.maxZoom,
                  child: RecordImage(
                    relativePath: widget.pages[i].relativePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (count > 1)
                Positioned(
                  bottom: AppSpacing.md,
                  right: AppSpacing.md,
                  child: StatusChip(
                    label: '${index + 1} / $count',
                    background: AppColors.scrim,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
