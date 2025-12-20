import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/features/prompts/domain/entities/prompt_entity.dart';
import 'package:incontext/features/prompts/presentation/providers/prompt_providers.dart';
import 'package:incontext/features/prompts/presentation/widgets/prompt_card.dart';
import 'package:incontext/features/prompts/presentation/widgets/prompt_editor_modal.dart';

class PromptsListScreen extends ConsumerWidget {
  const PromptsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptsAsync = ref.watch(promptsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prompts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePromptModal(context),
          ),
        ],
      ),
      body: promptsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
        data: (prompts) =>
            prompts.isEmpty ? _buildEmptyState(context) : _buildPromptsList(context, prompts),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePromptModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No prompts yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create your first prompt to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => _showCreatePromptModal(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Prompt'),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptsList(BuildContext context, List<PromptEntity> prompts) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: prompts.length,
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        return PromptCard(
          prompt: prompt,
          onTap: () => _showEditPromptModal(context, prompt),
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

  void _showEditPromptModal(BuildContext context, PromptEntity prompt) {
    showDialog(
      context: context,
      builder: (context) => PromptEditorModal(prompt: prompt),
    );
  }
}
