import 'package:flutter/material.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/theme/app_colors.dart';

class ListItemCard extends StatelessWidget {
  const ListItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.metadata,
    this.trailing,
    this.onTap,
    this.showRefinedBadge = false,
  });

  final String title;
  final String? subtitle;
  final String? metadata;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showRefinedBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: showRefinedBadge ? FontWeight.w600 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            metadata ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: showRefinedBadge
                                  ? AppColors.primary
                                  : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                              fontWeight: showRefinedBadge ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.grey600 : AppColors.grey300,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (trailing != null)
                  trailing!
                else if (showRefinedBadge)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isDark ? AppColors.grey600 : AppColors.grey300,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
