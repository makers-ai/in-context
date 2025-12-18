import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/features/context/domain/entities/context_entity.dart';
import 'package:incontext/features/thought/domain/entities/thought_entity.dart';
import 'package:incontext/features/context/presentation/providers/context_controller.dart';
import 'package:incontext/features/context/presentation/providers/context_providers.dart';
import 'package:incontext/features/context/presentation/screens/context_editor_screen.dart';
import 'package:incontext/features/context/presentation/widgets/context_card.dart';
import 'package:incontext/features/thought/presentation/providers/thought_providers.dart';

class ContextSection extends ConsumerWidget {
  const ContextSection({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(contextStreamProvider(projectId));
    final thoughtsAsync = ref.watch(thoughtsStreamProvider(projectId));
    final contextState = ref.watch(contextControllerProvider);

    return contextAsync.when(
      data: (contextEntity) {
        final thoughts = thoughtsAsync.valueOrNull ?? [];
        final isOutdated =
            contextEntity != null ? _isContextOutdated(contextEntity, thoughts) : false;

        return ContextCard(
          context: contextEntity,
          isOutdated: isOutdated,
          onRefine: () => _refineContext(ref, thoughts),
          onEdit: () => _editContext(context, contextEntity),
          isRefining: contextState.isEnhancing,
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Failed to load context: $error'),
      ),
    );
  }

  bool _isContextOutdated(ContextEntity context, List<ThoughtEntity> thoughts) {
    // Context is outdated if:
    // 1. Any thought was created after context.updatedAt
    // 2. Any thought in sourceThoughtIds is missing (deleted)
    return thoughts.any((t) => t.createdAt.isAfter(context.updatedAt)) ||
        !context.sourceThoughtIds.every((id) => thoughts.any((t) => t.id == id));
  }

  void _refineContext(WidgetRef ref, List<ThoughtEntity> thoughts) {
    ref.read(contextControllerProvider.notifier).enhanceContext(
          projectId: projectId,
          thoughts: thoughts,
        );
  }

  void _editContext(BuildContext context, ContextEntity? contextEntity) {
    if (contextEntity != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ContextEditorScreen(context: contextEntity),
        ),
      );
    }
  }
}
