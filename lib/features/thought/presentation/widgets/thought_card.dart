import 'package:flutter/material.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/features/thought/domain/entities/thought_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

class ThoughtCard extends StatefulWidget {
  const ThoughtCard({
    required this.thought,
    required this.onDelete,
    super.key,
  });

  final ThoughtEntity thought;
  final VoidCallback onDelete;

  @override
  State<ThoughtCard> createState() => _ThoughtCardState();
}

class _ThoughtCardState extends State<ThoughtCard> {
  bool isTextExpanded = false;
  bool isCollapsing = false;
  final int maxCaracters = 200;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isTextThought =
        widget.thought.type == ThoughtType.text || widget.thought.transcript != null;

    final textContentExceeds = widget.thought.rawContent.length > maxCaracters ||
        (widget.thought.transcript != null && widget.thought.transcript!.length > maxCaracters);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.thought.type == ThoughtType.text ? Icons.text_fields : Icons.mic,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  timeago.format(widget.thought.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onDelete,
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (widget.thought.type == ThoughtType.text)
              ClipRect(
                child: AnimatedSize(
                  onEnd: () {
                    setState(() {
                      isCollapsing = !isCollapsing;
                    });
                  },
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  duration: const Duration(milliseconds: 300),
                  child: Stack(
                    children: [
                      Align(
                        heightFactor: isTextExpanded ? 1 : 0,
                        alignment: Alignment.topLeft,
                        child: Text(widget.thought.rawContent),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: isCollapsing || isTextExpanded ? 0 : 1,
                        child: ColoredBox(
                          color: theme.colorScheme.surface,
                          child: Text(
                            widget.thought.rawContent.length > maxCaracters
                                ? '${widget.thought.rawContent.substring(0, maxCaracters)}...'
                                : widget.thought.rawContent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              if (widget.thought.transcriptionStatus == TranscriptionStatus.processing)
                const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text('Transcribing...'),
                  ],
                )
              else if (widget.thought.transcriptionStatus == TranscriptionStatus.failed)
                const Text(
                  'Transcription failed',
                  style: TextStyle(color: AppColors.error),
                )
              else if (widget.thought.transcript != null)
                ClipRect(
                  child: AnimatedSize(
                    onEnd: () {
                      setState(() {
                        isCollapsing = !isCollapsing;
                      });
                    },
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    duration: const Duration(milliseconds: 300),
                    child: Stack(
                      children: [
                        if (widget.thought.transcript!.isEmpty)
                          const Text(
                            'Nothing to transcribe',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        Align(
                          heightFactor: isTextExpanded ? 1 : 0,
                          alignment: Alignment.topLeft,
                          child: Text(widget.thought.transcript!),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 100),
                          opacity: isCollapsing || isTextExpanded ? 0 : 1,
                          child: ColoredBox(
                            color: theme.colorScheme.surface,
                            child: Text(
                              widget.thought.transcript!.length > maxCaracters
                                  ? '${widget.thought.transcript!.substring(0, maxCaracters)}...'
                                  : widget.thought.transcript!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Text('[Audio]', style: TextStyle(fontStyle: FontStyle.italic)),
            ],
            if (isTextThought && textContentExceeds)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    isTextExpanded = !isTextExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isTextExpanded ? 'Show less' : 'Show more',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Icon(
                          isTextExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
