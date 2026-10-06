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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.creamLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
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
                      child: Center(
                        child: RecordImage(
                          relativePath: widget.pages[i].relativePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  if (count > 1)
                    Positioned(
                      bottom: AppSpacing.md,
                      right: AppSpacing.md,
                      child: StatusChip(
                        label: '${index + 1} / $count',
                        background: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
