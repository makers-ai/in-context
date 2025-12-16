import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/features/context/domain/entities/context_entity.dart';
import 'package:incontext/features/context/presentation/providers/output_controller.dart';
import 'package:incontext/features/prompts/presentation/providers/prompt_providers.dart';
import 'package:incontext/features/prompts/presentation/widgets/prompt_editor_modal.dart';

class PromptsSection extends ConsumerWidget {
  const PromptsSection({
    required this.contextEntity,
    super.key,
  });

  final ContextEntity contextEntity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (ctx, ref, _) {
        final promptsAsync = ref.watch(promptsStreamProvider);
        return promptsAsync.when(
          data: (prompts) => Wrap(
            spacing: AppSpacing.sm,
            children: [
              ...prompts.map((prompt) {
                return ActionChip(
                  label: Text(prompt.name),
                  onPressed: () {
                    ref.read(outputControllerProvider.notifier).generateOutput(
                          context: contextEntity,
                          prompt: prompt,
                        );
                  },
                );
              }),
              ActionChip(
                label: const Text('Create Prompt'),
                avatar: const Icon(Icons.add, size: 18),
                onPressed: () => _showCreatePromptModal(ctx),
              ),
            ],
          ),
          loading: () => const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text('Failed to load prompts: $error'),
        );
      },
    );
  }

  void _showCreatePromptModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PromptEditorModal(),
    );
  }
}
