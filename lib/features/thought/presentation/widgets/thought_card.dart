import 'package:flutter/material.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/features/thought/domain/entities/thought_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

class ThoughtCard extends StatefulWidget {
  const ThoughtCard({
    required this.thought,
    super.key,
  });

  final ThoughtEntity thought;

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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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
                        child: Text(
                          widget.thought.rawContent,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: isCollapsing || isTextExpanded ? 0 : 1,
                        child: Text(
                          widget.thought.rawContent.length > maxCaracters
                              ? '${widget.thought.rawContent.substring(0, maxCaracters)}...'
                              : widget.thought.rawContent,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              if (widget.thought.transcriptionStatus == TranscriptionStatus.processing)
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Transcribing...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
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
                          Text(
                            'Nothing to transcribe',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        Align(
                          heightFactor: isTextExpanded ? 1 : 0,
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.thought.transcript!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 100),
                          opacity: isCollapsing || isTextExpanded ? 0 : 1,
                          child: Text(
                            widget.thought.transcript!.length > maxCaracters
                                ? '${widget.thought.transcript!.substring(0, maxCaracters)}...'
                                : widget.thought.transcript!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  '[Audio]',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
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
