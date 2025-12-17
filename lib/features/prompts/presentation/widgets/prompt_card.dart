import 'package:flutter/material.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_shadows.dart';
import 'package:incontext/core/widgets/animated_button.dart';
import 'package:incontext/features/prompts/domain/entities/prompt_entity.dart';

class PromptCard extends StatelessWidget {
  const PromptCard({
    super.key,
    required this.prompt,
    this.onTap,
    this.iconColor,
    this.icon,
  });

  final PromptEntity prompt;
  final VoidCallback? onTap;
  final Color? iconColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? AppColors.primary;

    return AnimatedButton(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppRadii.radiusXxl,
        border: Border.all(
          color: isDark
              ? AppColors.grey800.withValues(alpha: 0.5)
              : AppColors.grey200.withValues(alpha: 0.5),
        ),
        boxShadow: isDark ? [] : AppShadows.shadowSoft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.radiusXxl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: AppRadii.radiusXl,
                  ),
                  child: Icon(
                    icon ?? Icons.auto_awesome,
                    color: effectiveIconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prompt.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prompt.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.grey600 : AppColors.grey300,
                  size: 24,
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
