import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_shadows.dart';
import 'package:incontext/core/widgets/app_button.dart';
import 'package:incontext/features/context/domain/entities/context_entity.dart';

class ContextCard extends StatelessWidget {
  const ContextCard({
    required this.context,
    required this.isOutdated,
    required this.onRefine,
    required this.onEdit,
    super.key,
    this.isRefining = false,
  });

  final ContextEntity? context;
  final bool isOutdated;
  final VoidCallback onRefine;
  final VoidCallback onEdit;
  final bool isRefining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppRadii.radiusXxl,
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? [] : AppShadows.shadowSoft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: AppRadii.radiusLg,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Contextual Refinement',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    borderRadius: AppRadii.radiusFull,
                  ),
                  child: Text(
                    'AI Enhanced',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (isOutdated)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: AppRadii.radiusXl,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Context is outdated. Thoughts have been added or removed.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (this.context != null) ...[
              MarkdownBody(
                data: this.context!.content,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: theme.textTheme.bodyMedium?.fontSize,
                    height: theme.textTheme.bodyMedium?.height,
                    color: theme.colorScheme.onSurface,
                  ),
                  strong: TextStyle(
                    fontSize: theme.textTheme.bodyMedium?.fontSize,
                    height: theme.textTheme.bodyMedium?.height,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  em: TextStyle(
                    fontSize: theme.textTheme.bodyMedium?.fontSize,
                    height: theme.textTheme.bodyMedium?.height,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppButton.outlined(
                      text: 'Edit',
                      onPressed: onEdit,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton.primary(
                      text: 'Refine',
                      icon: const Icon(Icons.auto_awesome, size: 20),
                      onPressed: onRefine,
                      isLoading: isRefining,
                    ),
                  ),
                ],
              ),
            ] else
              AppButton.primary(
                text: 'Refine Context',
                icon: const Icon(Icons.auto_awesome, size: 20),
                onPressed: onRefine,
                isLoading: isRefining,
              ),
          ],
        ),
      ),
    );
  }
}
