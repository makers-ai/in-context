import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incontext/core/routing/app_routes.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/theme/app_typography.dart';
import 'package:incontext/core/widgets/app_button.dart';
import 'package:incontext/features/auth/presentation/providers/auth_providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Column(
        children: [
          // Header Section
          _DrawerHeader(
            displayName: currentUser?.displayName,
            email: currentUser?.email ?? '',
            photoUrl: currentUser?.photoUrl,
            isDark: isDark,
          ),

          // Body Section with placeholder navigation
          Expanded(
            child: _DrawerBody(isDark: isDark),
          ),

          // Footer Section with sign out
          _DrawerFooter(isDark: isDark),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}

// Header with user info
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.isDark,
  });

  final String? displayName;
  final String email;
  final String? photoUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadii.xxl),
          bottomRight: Radius.circular(AppRadii.xxl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top),
          // Avatar
          _UserAvatar(
            photoUrl: photoUrl,
            displayName: displayName,
            email: email,
          ),
          const SizedBox(height: AppSpacing.md),

          // Display name
          Text(
            displayName ?? email.split('@').first,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Email
          Text(
            email,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// User avatar with fallback to initials
class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.photoUrl,
    required this.displayName,
    required this.email,
  });

  final String? photoUrl;
  final String? displayName;
  final String email;

  String _getInitials() {
    final name = displayName ?? email;
    if (name.isEmpty) return '?';

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _InitialsAvatar(initials: _getInitials());
                },
              )
            : _InitialsAvatar(initials: _getInitials()),
      ),
    );
  }
}

// Initials avatar fallback
class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          initials,
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// Drawer body with placeholder navigation
class _DrawerBody extends StatelessWidget {
  const _DrawerBody({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      children: [
        _DrawerItem(
          icon: Icons.menu_book_sharp,
          label: 'Prompts',
          onTap: () {
            Navigator.pop(context);
            context.push(AppRoutes.prompts);
          },
          isDark: isDark,
        ),
      ],
    );
  }
}

// Reusable drawer item
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.radiusLg,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadii.radiusLg,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Drawer footer with sign out
class _DrawerFooter extends ConsumerWidget {
  const _DrawerFooter({required this.isDark});

  final bool isDark;

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          AppButton.elevated(
            onPressed: () => Navigator.pop(context, true),
            text: 'Sign Out',
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Close drawer first
      Navigator.pop(context);

      // Sign out
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 1,
          color: isDark
              ? AppColors.grey800.withValues(alpha: 0.5)
              : AppColors.grey200.withValues(alpha: 0.5),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleSignOut(context, ref),
              borderRadius: AppRadii.radiusLg,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  borderRadius: AppRadii.radiusLg,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 24,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Sign Out',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
