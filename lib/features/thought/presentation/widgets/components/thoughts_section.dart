import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/widgets/error_body.dart';
import 'package:incontext/core/widgets/loading_body.dart';
import 'package:incontext/features/thought/domain/entities/thought_entity.dart';
import 'package:incontext/features/thought/presentation/providers/thought_providers.dart';
import 'package:incontext/features/thought/presentation/providers/thought_controller.dart';
import 'package:incontext/features/thought/presentation/widgets/components/add_thought_modal.dart';
import 'package:incontext/features/thought/presentation/widgets/thought_card.dart';

class ThoughtsSection extends ConsumerStatefulWidget {
  const ThoughtsSection({
    required this.projectId,
    required this.onChevronPressed,
    super.key,
  });

  final String projectId;
  final VoidCallback onChevronPressed;

  @override
  ConsumerState<ThoughtsSection> createState() => _ThoughtsSectionState();
}

class _ThoughtsSectionState extends ConsumerState<ThoughtsSection> {
  // Track thoughts that are pending deletion (dismissed but not yet deleted from Firebase)
  final Set<String> _pendingDeletions = {};

  @override
  Widget build(BuildContext context) {
    final thoughtsAsync = ref.watch(thoughtsStreamProvider(widget.projectId));

    return Column(
      children: [
        // Thoughts list
        thoughtsAsync.when(
          data: (thoughts) {
            // Clean up pending deletions for thoughts that no longer exist in Firebase
            final thoughtIds = thoughts.map((t) => t.id).toSet();
            _pendingDeletions.removeWhere((id) => !thoughtIds.contains(id));

            // Filter out thoughts that are pending deletion
            final visibleThoughts =
                thoughts.where((thought) => !_pendingDeletions.contains(thought.id)).toList();

            if (visibleThoughts.isEmpty) {
              return Expanded(
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'No thoughts yet. Click "Add Thought" above to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              );
            }

            return Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                itemCount: visibleThoughts.length,
                itemBuilder: (context, index) {
                  final thought = visibleThoughts[index];
                  return Dismissible(
                    key: ValueKey(thought.id),
                    direction: DismissDirection.horizontal,
                    background: _buildDismissBackground(context, isLeft: true),
                    secondaryBackground: _buildDismissBackground(context, isLeft: false),
                    onDismissed: (direction) {
                      _handleThoughtDismissed(thought);
                    },
                    child: ThoughtCard(thought: thought),
                  );
                },
              ),
            );
          },
          loading: () => const LoadingBody(loadingMessage: 'Loading thoughts...'),
          error: (error, _) => ErrorBody(description: 'Failed to load thoughts: $error'),
        ),

        // Add thought button
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddThoughtModal(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Thought'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.radiusMd,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton.outlined(
                onPressed: widget.onChevronPressed,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddThoughtModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (modalContext) => SafeArea(
        child: AddThoughtModal(
          projectId: widget.projectId,
          onDismiss: Navigator.of(modalContext).pop,
        ),
      ),
    );
  }

  Widget _buildDismissBackground(BuildContext context, {required bool isLeft}) {
    return Container(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade400,
            Colors.red.shade700,
          ],
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        ),
      ),
      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  void _handleThoughtDismissed(ThoughtEntity thought) {
    // Add to pending deletions to hide it from the list
    setState(() {
      _pendingDeletions.add(thought.id);
    });

    // Show SnackBar with Undo action
    final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 72.0),
        content: const Text('Thought deleted'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Remove from pending deletions to show it again
            setState(() {
              _pendingDeletions.remove(thought.id);
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    // Wait for the SnackBar to be closed and check the reason
    snackBarController.closed.then((reason) {
      // If the user didn't press Undo, proceed with deletion from Firebase
      if (reason != SnackBarClosedReason.action) {
        ref.read(thoughtControllerProvider.notifier).deleteThought(thought.id);
        // Don't remove from _pendingDeletions here - the Firebase stream will handle removing it
        // from the thoughts list, and we'll clean up _pendingDeletions when the widget rebuilds
      }
      // If they pressed Undo, the thought is already restored (removed from _pendingDeletions above)
    });
  }
}
