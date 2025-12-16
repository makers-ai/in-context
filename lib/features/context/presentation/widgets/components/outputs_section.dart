import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/widgets/error_body.dart';
import 'package:incontext/core/widgets/loading_body.dart';
import 'package:incontext/features/context/domain/entities/context_entity.dart';
import 'package:incontext/features/context/presentation/providers/context_providers.dart';
import 'package:incontext/features/context/presentation/widgets/output_card.dart';
import 'package:incontext/features/prompts/domain/entities/prompt_entity.dart';
import 'package:incontext/features/prompts/presentation/providers/prompt_providers.dart';

class OutputsSection extends ConsumerWidget {
  const OutputsSection({
    required this.contextEntity,
    super.key,
  });

  final ContextEntity contextEntity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outputsAsync = ref.watch(outputsStreamProvider((projectId: contextEntity.projectId, contextId: contextEntity.id)));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Outputs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        Consumer(
          builder: (context, ref, _) {
            final promptsAsync = ref.watch(promptsStreamProvider);
            return outputsAsync.when(
              data: (outputs) {
                if (outputs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('No outputs yet. Apply a prompt above.'),
                  );
                }

                return promptsAsync.when(
                  data: (prompts) => Column(
                    children: [
                      for (final output in outputs)
                        OutputCard(
                          output: output,
                          promptName: prompts.firstWhere(
                                    (p) => p.id == output.promptId,
                                    orElse: () => PromptEntity(
                                      id: '',
                                      name: 'Unknown',
                                      description: '',
                                      version: '',
                                      promptTemplate: '',
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                    ),
                                  ).name,
                        ),
                    ],
                  ),
                  loading: () => const LoadingBody(),
                  error: (error, _) => Text('Failed to load prompts: $error'),
                );
              },
              loading: () => const LoadingBody(),
              error: (error, _) => ErrorBody(description: 'Failed to load outputs'),
            );
          },
        ),
      ],
    );
  }
}
