import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_spacing.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({
    required this.tabs,
    required this.controller,
    super.key,
  });

  final List<String> tabs;
  final TabController controller;

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (widget.controller.indexIsChanging) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800.withValues(alpha: 0.5) : AppColors.grey100,
        borderRadius: AppRadii.radiusFull,
      ),
      child: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: TabBar(
          controller: widget.controller,
          tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
          indicator: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: AppRadii.radiusFull,
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Color(0x33000000), // 20%
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: isDark ? AppColors.grey400 : AppColors.grey600,
          labelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }
}
