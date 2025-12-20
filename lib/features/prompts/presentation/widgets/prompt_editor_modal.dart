import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/widgets/app_button.dart';
import 'package:incontext/features/prompts/domain/entities/prompt_entity.dart';
import 'package:incontext/features/prompts/presentation/providers/prompt_controller.dart';

class PromptEditorModal extends ConsumerStatefulWidget {
  const PromptEditorModal({
    super.key,
    this.prompt,
  });

  final PromptEntity? prompt;

  @override
  ConsumerState<PromptEditorModal> createState() => _PromptEditorModalState();
}

class _PromptEditorModalState extends ConsumerState<PromptEditorModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _templateController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prompt != null) {
      _nameController.text = widget.prompt!.name;
      _descriptionController.text = widget.prompt!.description;
      _templateController.text = widget.prompt!.promptTemplate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _templateController.dispose();
    super.dispose();
  }

  Future<void> _savePrompt() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final controller = ref.read(promptControllerProvider.notifier);

    if (widget.prompt != null) {
      await controller.updatePrompt(
        id: widget.prompt!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        promptTemplate: _templateController.text,
      );
    } else {
      await controller.createPrompt(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        promptTemplate: _templateController.text,
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _deletePrompt() {
    if (widget.prompt == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: const Text('Are you sure you want to delete this prompt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _performDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete() async {
    await ref.read(promptControllerProvider.notifier).deletePrompt(widget.prompt!.id);
    if (mounted) {
      Navigator.of(context).pop(); // Close modal
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promptControllerProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.prompt != null ? 'Edit Prompt' : 'Create Prompt',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (widget.prompt != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _deletePrompt,
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Prompt Name',
                            hintText: 'e.g., Email Generator',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Brief description of what this prompt does',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _templateController,
                          decoration: InputDecoration(
                            labelText: 'Prompt Template',
                            hintText: 'Your AI prompt template. Use {{CONTEXT}} to insert context.',
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          maxLines: 8,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a prompt template';
                            }
                            if (!value.contains('{{CONTEXT}}')) {
                              return 'Template must include {{CONTEXT}} placeholder';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (state.error != null)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              state.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton.elevated(
                      isLoading: _isLoading,
                      onPressed: _savePrompt,
                      text: widget.prompt != null ? 'Update' : 'Create',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
