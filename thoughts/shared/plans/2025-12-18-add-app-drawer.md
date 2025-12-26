# App Drawer Implementation Plan

## Overview

Add a custom-styled drawer to the home screen (ProjectsListScreen) that displays user information and provides a sign-out option. The drawer will feature a modern, clean design that matches the app's existing theme while avoiding standard Material Design 3 patterns.

## Current State Analysis

**Existing Implementation:**
- [ProjectsListScreen](lib/features/project/presentation/screens/projects_list_screen.dart:13) uses a standard `Scaffold` with `AppBar`
- No drawer currently exists in the app
- Sign-out functionality exists via [SignOut use case](lib/features/auth/domain/usecases/sign_out.dart:4)
- Auth state managed via Riverpod [auth_providers.dart](lib/features/auth/presentation/providers/auth_providers.dart)
- User entity has: `id`, `email`, `displayName`, `photoUrl` ([user_entity.dart](lib/features/auth/domain/entities/user_entity.dart:3))

**Design System:**
- Font: Spline Sans via Google Fonts ([app_typography.dart](lib/core/theme/app_typography.dart:8))
- Primary color: #2a6aea ([app_colors.dart](lib/core/theme/app_colors.dart:7))
- Surface colors: Light (#FFFFFF), Dark (#1a202e) ([app_colors.dart](lib/core/theme/app_colors.dart:14-15))
- Border radius scale: 4-28px ([app_radii.dart](lib/core/theme/app_radii.dart))
- Spacing: 8pt grid system ([app_spacing.dart](lib/core/theme/app_spacing.dart))

### Key Discoveries:
- User data accessible via `currentUserProvider` ([auth_providers.dart:25](lib/features/auth/presentation/providers/auth_providers.dart#L25))
- App uses clean, rounded design with subtle shadows
- No existing drawer patterns to conflict with

## Desired End State

After implementation:
- ProjectsListScreen will have a drawer accessible via hamburger menu icon in the AppBar
- Drawer will display:
  - **Header section**: User avatar (circular with fallback to initials), display name, email
  - **Body section**: One placeholder navigation item (no actual navigation, for future use)
  - **Bottom section**: Sign-out button with icon
- Custom styling that matches app theme (not standard Material 3)
- Sign-out will show confirmation dialog before logging out
- Smooth animations when opening/closing drawer

**Verification:**
- Run app and tap hamburger icon to open drawer
- Verify user info displays correctly with avatar/initials
- Verify placeholder navigation item is visible
- Tap sign-out and confirm dialog appears
- Confirm sign-out and verify user is logged out and redirected to login screen

## What We're NOT Doing

- Not adding functional navigation items (only placeholder)
- Not adding settings, about, or other features to the drawer
- Not implementing drawer on other screens (only home screen)
- Not creating a persistent drawer that's always visible
- Not adding theme switching or language selection
- Not implementing drawer gestures beyond the standard swipe-to-open

## Implementation Approach

Create a reusable custom drawer widget with three main sections (header, body, footer), then integrate it into ProjectsListScreen. Use Riverpod to access user data and handle sign-out logic. Style the drawer with custom design matching the app's aesthetic.

## Phase 1: Create Custom Drawer Widget

### Overview
Build the drawer widget with custom styling, user header, placeholder navigation, and sign-out button.

### Changes Required:

#### 1. Create App Drawer Widget
**File**: `lib/core/widgets/app_drawer.dart` (new file)
**Changes**: Create new custom drawer widget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/theme/app_typography.dart';
import 'package:incontext/features/auth/presentation/providers/auth_providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: SafeArea(
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
          ],
        ),
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
            AppColors.primary.withOpacity(0.8),
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
              color: Colors.white.withOpacity(0.9),
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
          color: Colors.white.withOpacity(0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
      color: AppColors.primary.withOpacity(0.1),
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
          icon: Icons.home_outlined,
          label: 'Placeholder Item',
          onTap: () {
            // TODO: Add navigation when needed
            Navigator.pop(context);
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
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
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
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
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
              ? AppColors.grey800.withOpacity(0.5)
              : AppColors.grey200.withOpacity(0.5),
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
                    color: AppColors.error.withOpacity(0.3),
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
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
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
```

### Success Criteria:

#### Automated Verification:
- [x] Code compiles without errors: `flutter analyze`
- [x] No linting issues: `flutter analyze`
- [ ] App builds successfully: `flutter build apk --debug` or `flutter build ios --debug`

#### Manual Verification:
- [ ] Drawer widget renders correctly with all three sections
- [ ] User avatar shows photo if available, otherwise shows initials
- [ ] User display name and email display correctly
- [ ] Placeholder navigation item is visible and clickable
- [ ] Sign-out button appears at the bottom with proper styling
- [ ] Theme-aware colors work in both light and dark mode

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation that the drawer widget looks good and all sections render correctly before proceeding to Phase 2.

---

## Phase 2: Integrate Drawer into ProjectsListScreen

### Overview
Add the drawer to the home screen and update the AppBar to include a hamburger menu icon.

### Changes Required:

#### 1. Update ProjectsListScreen
**File**: `lib/features/project/presentation/screens/projects_list_screen.dart`
**Changes**: Add drawer to Scaffold

```dart
// Add import at the top
import 'package:incontext/core/widgets/app_drawer.dart';

// In the build method, update the Scaffold:
return Scaffold(
  appBar: AppBar(
    title: const Text('My Projects'),
    leading: Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
        tooltip: 'Open menu',
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () => context.push(AppRoutes.prompts),
        tooltip: 'Manage Prompts',
      ),
    ],
  ),
  drawer: const AppDrawer(), // Add this line
  body: projectsAsync.when(
    // ... rest of the code remains the same
  ),
  floatingActionButton: FloatingActionButton(
    // ... rest remains the same
  ),
);
```

### Success Criteria:

#### Automated Verification:
- [x] Code compiles without errors: `flutter analyze`
- [x] No linting issues: `flutter analyze`
- [ ] App builds successfully: `flutter build apk --debug` or `flutter build ios --debug`
- [ ] Hot reload works without errors

#### Manual Verification:
- [ ] Hamburger menu icon appears in the AppBar on home screen
- [ ] Tapping hamburger icon opens the drawer with smooth animation
- [ ] Drawer displays user information correctly
- [ ] Swipe from left edge opens drawer
- [ ] Tapping outside drawer closes it
- [ ] Placeholder navigation item closes drawer when tapped
- [ ] Sign-out confirmation dialog appears when tapping sign-out
- [ ] After confirming sign-out, user is logged out and redirected to login screen
- [ ] Drawer styling matches app theme in both light and dark mode
- [ ] No visual glitches or layout issues

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation that the drawer integration works correctly and all functionality is working as expected.

---

## Testing Strategy

### Unit Tests:
- Not required for this feature (UI-heavy component)
- Could add widget tests if desired, but manual testing is sufficient for a drawer

### Integration Tests:
- Not required for this simple feature

### Manual Testing Steps:
1. **Open the app** and log in (or ensure you're already logged in)
2. **Navigate to home screen** (ProjectsListScreen)
3. **Verify hamburger icon** appears in the AppBar
4. **Tap hamburger icon** to open drawer
5. **Verify drawer appearance**:
   - User avatar displays (photo or initials)
   - Display name shows correctly
   - Email shows correctly
   - Header has gradient background
   - Placeholder navigation item is visible
   - Sign-out button is at the bottom
6. **Test interactions**:
   - Tap placeholder item → drawer closes
   - Tap sign-out → confirmation dialog appears
   - Cancel dialog → drawer stays open
   - Confirm sign-out → drawer closes, user logs out, redirects to login
7. **Test swipe gesture**: Swipe from left edge to open drawer
8. **Test close behavior**: Tap outside drawer to close it
9. **Test dark mode**: Switch to dark mode and verify all colors adapt correctly
10. **Test edge cases**:
    - User with no display name (should show email prefix)
    - User with no photo (should show initials)
    - Very long email/name (should truncate with ellipsis)

## Performance Considerations

- User avatar image should use `cached_network_image` if loading is slow (optional enhancement)
- Drawer animation is handled by Flutter's built-in Drawer widget (smooth 60fps)
- No heavy computations or async operations in drawer widget
- Sign-out operation is async but handled properly with loading states via auth providers

## Migration Notes

Not applicable - this is a new feature with no data migration required.

## References

- Material Design Drawer: https://m3.material.io/components/navigation-drawer/overview
- Flutter Drawer: https://api.flutter.dev/flutter/material/Drawer-class.html
- Current implementation files:
  - [ProjectsListScreen](lib/features/project/presentation/screens/projects_list_screen.dart)
  - [Auth Providers](lib/features/auth/presentation/providers/auth_providers.dart)
  - [User Entity](lib/features/auth/domain/entities/user_entity.dart)
  - [Sign Out Use Case](lib/features/auth/domain/usecases/sign_out.dart)
  - [App Theme](lib/core/theme/app_theme.dart)
  - [App Colors](lib/core/theme/app_colors.dart)
