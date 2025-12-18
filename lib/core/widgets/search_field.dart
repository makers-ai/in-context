import 'package:flutter/material.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_shadows.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.hint = 'Search...',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppRadii.radiusSm,
        border: Border.all(
          color: Colors.transparent,
        ),
        boxShadow: isDark ? [] : AppShadows.shadowSm,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.search,
              size: 20,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
