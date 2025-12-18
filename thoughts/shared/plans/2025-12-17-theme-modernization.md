# Theme Modernization Implementation Plan

## Overview

This plan outlines the transformation of the Flutter app's theme and reusable components to match a modern HTML design reference. The new design features a refined color palette, updated typography with Spline Sans font family, generous rounded corners, soft shadows, and smooth interactive animations.

## Current State Analysis

### Existing Theme Structure:
- **Primary Color**: Purple (`#6750A4`) - Material 3 default seed color
- **Typography**: Material 3 defaults without custom font family
- **Button Styles**: Standard Material 3 with small border radius (8px)
- **Cards**: Basic cards with outline borders
- **Spacing System**: Defined in `AppSpacing`
- **Border Radius**: Small values (4px-24px) defined in `AppRadii`
- **Shadows**: Basic shadows defined in `AppShadows`

### Current Widget Components:
- `AppButton` (lib/core/widgets/app_button.dart) - Elevated, Outlined, Text variants
- `AppTextField` (lib/core/widgets/app_text_field.dart) - Standard text input
- `AppDialog` (lib/core/widgets/app_dialog.dart) - Confirmation and info dialogs
- `ContextCard`, `PromptCard`, `ThoughtCard`, `OutputCard` - Feature-specific cards
- `AppText` - Text wrapper widgets

### Dependencies Required:
- Google Fonts package for Spline Sans font family
- Existing packages are sufficient for other features

## Desired End State

A Flutter app with:
- **Modern Color Palette**: Blue primary color (`#2a6aea`), custom background and surface colors
- **Custom Typography**: Spline Sans for display text, existing Material font for body
- **Rounded Design Language**: Larger border radius (12px-16px for cards, full rounded buttons)
- **Soft Shadows**: Multiple shadow layers with blur and glow effects
- **Interactive Animations**: Scale transforms on button press, smooth transitions
- **Consistent Card Designs**: Matching the HTML reference with hover states
- **Dark Mode Support**: Proper dark theme colors matching the design

### Success Verification:
- Visual comparison with HTML reference shows matching design elements
- Dark mode renders correctly with appropriate color contrast
- Buttons have proper rounded-full shape with icon+text combinations
- Cards display with correct shadows and border radius
- All interactive elements have smooth transitions
- Typography uses Spline Sans where appropriate

## What We're NOT Doing

- Not changing the app's architecture or state management
- Not modifying business logic or data layer
- Not adding new features beyond theme updates
- Not changing screen layouts significantly (only styling)
- Not removing existing functionality
- Not implementing web-specific features (blur effects may be simplified on mobile)

## Implementation Approach

This is primarily a visual and theming update. We'll update the design system tokens first (colors, typography, spacing, shadows), then update each reusable component to match the new design language. Finally, we'll verify that all screens properly reflect the new theme.

The work is organized into phases that build upon each other, allowing for incremental testing and validation.

## Phase 1: Update Design System Tokens

### Overview
Update all theme-related constants to match the new design reference.

### Changes Required:

#### 1. Update App Colors
**File**: `lib/core/theme/app_colors.dart`
**Changes**: Replace the existing color system with the new design tokens

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary color from design reference
  static const Color primary = Color(0xFF2a6aea);

  // Background colors
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color backgroundDark = Color(0xFF111621);

  // Surface colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1a202e);

  // Text colors
  static const Color textMainLight = Color(0xFF1F2937);  // gray-900
  static const Color textMainDark = Color(0xFFFFFFFF);
  static const Color textMutedLight = Color(0xFF6B7280);  // gray-500
  static const Color textMutedDark = Color(0xFF9CA3AF);   // gray-400

  // Semantic colors (keep existing, add some new ones)
  static const Color success = Color(0xFF10B981);   // emerald-500
  static const Color warning = Color(0xFFF59E0B);   // amber-500
  static const Color error = Color(0xFFEF4444);     // red-500
  static const Color info = Color(0xFF3B82F6);      // blue-500

  // Accent colors for prompt cards (from HTML examples)
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentOrange = Color(0xFFF97316);

  // Neutral colors (keep existing grays for compatibility)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
}
```

#### 2. Update Border Radius
**File**: `lib/core/theme/app_radii.dart`
**Changes**: Increase radius values to match the more rounded design

```dart
import 'package:flutter/material.dart';

class AppRadii {
  AppRadii._();

  // Radius values - updated for more rounded design
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;      // increased from 16
  static const double xl = 20;      // increased from 20
  static const double xxl = 28;     // increased from 24
  static const double full = 9999;  // for pill-shaped buttons

  // BorderRadius objects
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));
}
```

#### 3. Update Shadows
**File**: `lib/core/theme/app_shadows.dart`
**Changes**: Add softer, more subtle shadows with glow variants

```dart
import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // Soft shadows for light mode
  static const List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x0D000000),  // 5% opacity
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x19000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x19000000),
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
  ];

  // Glow effect for primary actions
  static const List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: Color(0x332a6aea),  // primary color with opacity
      offset: Offset(0, 0),
      blurRadius: 15,
      spreadRadius: -3,
    ),
  ];

  // Shadow variants for dark mode (more subtle)
  static const List<BoxShadow> shadowSoftDark = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];
}
```

#### 4. Update Typography
**File**: `lib/core/theme/app_typography.dart`
**Changes**: Integrate Spline Sans font family and adjust weights

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // Get Spline Sans font family
  static TextTheme get _splineSansTextTheme => GoogleFonts.splineSansTextTheme();

  // Material 3 Text Theme with Spline Sans
  static TextTheme textTheme = _splineSansTextTheme.copyWith(
    // Display - used for large hero text
    displayLarge: _splineSansTextTheme.displayLarge?.copyWith(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: _splineSansTextTheme.displayMedium?.copyWith(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.16,
    ),
    displaySmall: _splineSansTextTheme.displaySmall?.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.22,
    ),

    // Headline - used for page titles
    headlineLarge: _splineSansTextTheme.headlineLarge?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: _splineSansTextTheme.headlineMedium?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.29,
    ),
    headlineSmall: _splineSansTextTheme.headlineSmall?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.33,
    ),

    // Title - used for section headers and card titles
    titleLarge: _splineSansTextTheme.titleLarge?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: _splineSansTextTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.50,
    ),
    titleSmall: _splineSansTextTheme.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.43,
    ),

    // Body - primary content text
    bodyLarge: _splineSansTextTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.50,
    ),
    bodyMedium: _splineSansTextTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: _splineSansTextTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),

    // Label - buttons, chips, tags
    labelLarge: _splineSansTextTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelMedium: _splineSansTextTheme.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: _splineSansTextTheme.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.45,
    ),
  );
}
```

#### 5. Update App Theme
**File**: `lib/core/theme/app_theme.dart`
**Changes**: Update theme to use new color scheme and design tokens

```dart
import 'package:flutter/material.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_typography.dart';
import 'package:incontext/core/theme/app_shadows.dart';

class AppTheme {
  AppTheme._();

  // Light Theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.accentBlue,
      onSecondary: AppColors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textMainLight,
      error: AppColors.error,
      onError: AppColors.white,
      outline: AppColors.grey300,
      outlineVariant: AppColors.grey200,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight.withOpacity(0.9),
        foregroundColor: AppColors.textMainLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppColors.textMainLight,
          fontWeight: FontWeight.w700,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated Button - rounded full style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.radiusFull,
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: AppColors.grey300),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.radiusXl,
          ),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.radiusLg,
          ),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: AppRadii.radiusXl,
          borderSide: BorderSide(color: AppColors.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.radiusXl,
          borderSide: BorderSide(color: AppColors.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.radiusXl,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.radiusXl,
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.textMutedLight,
        ),
        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.textMutedLight,
        ),
      ),

      // Card - updated with soft shadows
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusXl,
          side: BorderSide(color: AppColors.grey200.withOpacity(0.5)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.radiusXxl,
        ),
        elevation: 8,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xxl),
          ),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.accentBlue,
      onSecondary: AppColors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textMainDark,
      error: AppColors.error,
      onError: AppColors.white,
      outline: AppColors.grey700,
      outlineVariant: AppColors.grey800,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark.withOpacity(0.9),
        foregroundColor: AppColors.textMainDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppColors.textMainDark,
          fontWeight: FontWeight.w700,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.radiusFull,
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: AppColors.grey700),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.radiusXl,
          ),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.radiusLg,
          ),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: AppRadii.radiusXl,
          borderSide: BorderSide(color: AppColors.grey800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.radiusXl,
          borderSide: BorderSide(color: AppColors.grey800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.radiusXl,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.radiusXl,
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.textMutedDark,
        ),
        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.textMutedDark,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusXl,
          side: BorderSide(color: AppColors.grey800.withOpacity(0.5)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.radiusXxl,
        ),
        elevation: 8,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xxl),
          ),
        ),
      ),
    );
  }
}
```

#### 6. Add Google Fonts Dependency
**File**: `pubspec.yaml`
**Changes**: Add google_fonts package

```yaml
dependencies:
  # ... existing dependencies ...
  google_fonts: ^6.2.1
```

### Success Criteria:

#### Automated Verification:
- [x] App builds successfully: `flutter build apk --debug`
- [x] No compile errors: `flutter analyze`
- [x] Dependencies downloaded: `flutter pub get`

#### Manual Verification:
- [ ] Theme colors match the HTML reference in both light and dark modes
- [ ] Typography uses Spline Sans font family
- [ ] Border radius values are visibly more rounded
- [ ] Shadows are softer and more subtle

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the theme changes look correct before proceeding to the next phase.

---

## Phase 2: Update Button Components

### Overview
Modernize the AppButton widget to support rounded-full design, icon+text combinations with proper styling, and interactive animations.

### Changes Required:

#### 1. Update AppButton Widget
**File**: `lib/core/widgets/app_button.dart`
**Changes**: Add new button variants and improve styling

```dart
import 'package:flutter/material.dart';
import 'package:incontext/core/theme/app_radii.dart';

enum AppButtonType {
  elevated,
  outlined,
  text,
  primary,  // new: rounded-full primary button with icon
  icon,     // new: icon-only button
}

class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = AppButtonType.elevated,
    this.icon,
    this.fullWidth = false,
    super.key,
  });

  const AppButton.elevated({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    super.key,
  }) : type = AppButtonType.elevated;

  const AppButton.outlined({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    super.key,
  }) : type = AppButtonType.outlined;

  const AppButton.text({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    super.key,
  }) : type = AppButtonType.text;

  // New: Primary rounded-full button with icon
  const AppButton.primary({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    super.key,
  }) : type = AppButtonType.primary;

  // New: Icon-only button
  const AppButton.icon({
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    super.key,
  })  : text = '',
        type = AppButtonType.icon,
        fullWidth = false;

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonType type;
  final Widget? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final button = switch (type) {
      AppButtonType.elevated => _buildElevatedButton(context),
      AppButtonType.outlined => _buildOutlinedButton(context),
      AppButtonType.text => _buildTextButton(context),
      AppButtonType.primary => _buildPrimaryButton(context),
      AppButtonType.icon => _buildIconButton(context),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildElevatedButton(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? _buildLoader(context) : icon!,
        label: Text(text),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 48),
        ),
      );
    }
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 48),
      ),
      child: isLoading ? _buildLoader(context) : Text(text),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? _buildLoader(context) : icon!,
        label: Text(text),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
        ),
      );
    }
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
      ),
      child: isLoading ? _buildLoader(context) : Text(text),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    if (icon != null) {
      return TextButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? _buildLoader(context) : icon!,
        label: Text(text),
      );
    }
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading ? _buildLoader(context) : Text(text),
    );
  }

  // New: Primary rounded-full button (matches "New Note" button in HTML)
  Widget _buildPrimaryButton(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primary,
      borderRadius: AppRadii.radiusFull,
      elevation: 2,
      shadowColor: theme.colorScheme.primary.withOpacity(0.3),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppRadii.radiusFull,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: icon != null ? 16 : 20,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                _buildLoader(context)
              else if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              if (!isLoading || icon == null)
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // New: Icon-only button (matches header icons in HTML)
  Widget _buildIconButton(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppRadii.radiusFull,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            borderRadius: AppRadii.radiusFull,
          ),
          child: Center(
            child: isLoading ? _buildLoader(context) : icon,
          ),
        ),
      ),
    );
  }

  Widget _buildLoader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(
          type == AppButtonType.elevated || type == AppButtonType.primary
              ? colors.onPrimary
              : colors.primary,
        ),
      ),
    );
  }
}
```

### Success Criteria:

#### Automated Verification:
- [x] App builds successfully: `flutter build apk --debug`
- [x] No compile errors: `flutter analyze`
- [x] All button types render without errors

#### Manual Verification:
- [ ] Primary buttons have rounded-full shape
- [ ] Icon buttons display correctly with circular backgrounds
- [ ] Button press states feel responsive
- [ ] Loading states work correctly for all button types
- [ ] Icon+text combinations are properly spaced

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the buttons look correct before proceeding to the next phase.

---

## Phase 3: Update Card Components

### Overview
Modernize card widgets to match the HTML design with proper shadows, rounded corners, and interactive states.

### Changes Required:

#### 1. Update PromptCard
**File**: `lib/features/prompts/presentation/widgets/prompt_card.dart`
**Changes**: Update to match the HTML list item design with colored icon backgrounds

```dart
import 'package:flutter/material.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_shadows.dart';
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppRadii.radiusXxl,
        border: Border.all(
          color: isDark
              ? AppColors.grey800.withOpacity(0.5)
              : AppColors.grey200.withOpacity(0.5),
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
                    color: effectiveIconColor.withOpacity(isDark ? 0.2 : 0.1),
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
    );
  }
}
```

#### 2. Update ContextCard
**File**: `lib/features/context/presentation/widgets/context_card.dart`
**Changes**: Update styling to match new design system

```dart
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
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.1),
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
                    color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
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
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
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
                  p: theme.textTheme.bodyMedium,
                  strong: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  em: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
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
```

#### 3. Create a New ListItemCard Widget
**File**: `lib/core/widgets/list_item_card.dart` (new file)
**Changes**: Create a reusable list item card matching the HTML notes list design

```dart
import 'package:flutter/material.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/theme/app_radii.dart';
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
                          fontWeight: showRefinedBadge
                              ? FontWeight.w600
                              : FontWeight.w500,
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
                                  : (isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight),
                              fontWeight: showRefinedBadge
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.grey600
                                    : AppColors.grey300,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
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
                      color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
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
```

### Success Criteria:

#### Automated Verification:
- [x] App builds successfully: `flutter build apk --debug`
- [x] No compile errors: `flutter analyze`
- [x] All card components render without errors

#### Manual Verification:
- [ ] Cards have proper rounded corners and soft shadows
- [ ] Icon backgrounds are colored and rounded correctly
- [ ] List items match the HTML reference design
- [ ] Tap feedback is responsive and smooth
- [ ] Dark mode renders correctly

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the cards look correct before proceeding to the next phase.

---

## Phase 4: Update Input Fields and Search Components

### Overview
Update text input fields to match the new design with rounded corners and proper styling.

### Changes Required:

#### 1. Update AppTextField
**File**: `lib/core/widgets/app_text_field.dart`
**Changes**: Update styling to match new design

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_shadows.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.onEditingComplete,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadii.radiusXl,
        boxShadow: isDark ? [] : AppShadows.shadowSm,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        validator: validator,
        onTap: onTap,
        readOnly: readOnly,
        enabled: enabled,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        focusNode: focusNode,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          helperText: helperText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
```

#### 2. Create SearchField Widget
**File**: `lib/core/widgets/search_field.dart` (new file)
**Changes**: Create a dedicated search field matching the HTML design

```dart
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
        borderRadius: AppRadii.radiusXl,
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
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
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
```

### Success Criteria:

#### Automated Verification:
- [x] App builds successfully: `flutter build apk --debug`
- [x] No compile errors: `flutter analyze`

#### Manual Verification:
- [ ] Text fields have proper rounded corners
- [ ] Search field matches HTML reference design
- [ ] Focus states work correctly with ring effect
- [ ] Placeholder text is properly styled
- [ ] Dark mode renders correctly

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the input fields look correct before proceeding to the next phase.

---

## Phase 5: Visual Polish and Animations

### Overview
Add subtle animations and transitions to match the HTML reference's interactive feel.

### Changes Required:

#### 1. Add Animation Constants
**File**: `lib/core/theme/app_durations.dart`
**Changes**: Add standard animation durations (file already exists, update if needed)

```dart
class AppDurations {
  AppDurations._();

  // Animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration verySlow = Duration(milliseconds: 500);
}
```

#### 2. Create AnimatedButton Widget
**File**: `lib/core/widgets/animated_button.dart` (new file)
**Changes**: Create a button wrapper with scale animation on press

```dart
import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleAmount = 0.95,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleAmount;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleAmount : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
```

#### 3. Update PromptCard with Hover Effect
**File**: `lib/features/prompts/presentation/widgets/prompt_card.dart`
**Changes**: Wrap in AnimatedButton for scale effect on tap

```dart
// At the top of the file
import 'package:incontext/core/widgets/animated_button.dart';

// In the build method, wrap the Container with AnimatedButton:
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
        // ... rest of the decoration
      ),
      child: Padding(
        // ... rest of the content
      ),
    ),
  );
}
```

### Success Criteria:

#### Automated Verification:
- [x] App builds successfully: `flutter build apk --debug`
- [x] No compile errors: `flutter analyze`

#### Manual Verification:
- [ ] Buttons have smooth scale animation on press
- [ ] Cards respond to touch with subtle animations
- [ ] Transitions feel smooth and not jarring
- [ ] Performance is acceptable (no jank)

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that animations feel smooth before proceeding to the next phase.

---

## Phase 6: Final Integration and Testing

### Overview
Ensure all screens properly use the updated components and verify the complete theme transformation.

### Changes Required:

#### 1. Audit and Update Screen Files
**Files**: All screen files in `lib/features/**/presentation/screens/`
**Changes**: Review each screen to ensure:
- Using updated AppButton variants where appropriate
- Cards are properly styled
- Search fields use the new SearchField widget
- Spacing and layout match the design

#### 2. Test Dark Mode
**Action**: Manually test all screens in dark mode
**Verify**:
- Colors are appropriate for dark theme
- Contrast is sufficient for readability
- Shadows are visible but subtle
- Cards stand out from background

#### 3. Update Example Screens (if any)
**Action**: Update any example or demo screens to showcase new design

### Success Criteria:

#### Automated Verification:
- [x] App builds successfully: `flutter build apk --release`
- [x] No compile errors: `flutter analyze`
- [x] No warnings from flutter analyze (only unrelated info messages)
- [ ] All tests pass: `flutter test`

#### Manual Verification:
- [ ] All screens render correctly in light mode
- [ ] All screens render correctly in dark mode
- [ ] Navigation between screens is smooth
- [ ] Interactive elements respond appropriately
- [ ] Typography is consistent throughout
- [ ] Colors match the HTML reference
- [ ] Buttons have proper styling (rounded-full, shadows, colors)
- [ ] Cards have soft shadows and proper border radius
- [ ] Search fields match the design
- [ ] Overall app feels modern and polished
- [ ] No visual regressions on existing functionality

**Implementation Note**: This is the final phase. After all verification passes and manual testing confirms the app matches the HTML reference design, the theme modernization is complete.

---

## Testing Strategy

### Unit Tests
- Test color value conversions are correct
- Test theme switching between light and dark modes
- Test button variants render correctly
- Test card components with different states

### Integration Tests
- Test navigation between screens with new theme
- Test user interactions (button presses, card taps)
- Test form inputs with new text field styling

### Manual Testing Steps
1. **Theme Comparison**:
   - Open HTML reference in browser
   - Open Flutter app side-by-side
   - Compare colors, spacing, shadows, typography

2. **Light Mode Testing**:
   - Navigate through all major screens
   - Verify colors match design
   - Test all interactive elements
   - Check button states (normal, pressed, loading)

3. **Dark Mode Testing**:
   - Switch to dark mode
   - Repeat navigation and interaction tests
   - Verify appropriate contrast
   - Check that elements are distinguishable

4. **Responsive Behavior**:
   - Test on different screen sizes
   - Verify layouts adapt properly
   - Check that text remains readable

5. **Edge Cases**:
   - Very long text in cards
   - Empty states
   - Error states
   - Loading states

## Performance Considerations

- **Shadows**: Use boxShadow sparingly; consider removing on scrolling lists for better performance
- **Animations**: Keep durations short (100-300ms) to feel snappy
- **Google Fonts**: Consider bundling fonts locally for offline access and faster load times
- **Material Widgets**: Continue using Material widgets when possible for platform consistency

## Migration Notes

### For Developers
- Import new color constants from AppColors
- Use new button variants: AppButton.primary() for main actions
- Use SearchField for search functionality
- Wrap interactive cards with AnimatedButton for touch feedback
- Reference new shadow constants for custom containers

### Breaking Changes
- None - all changes are additive or visual only
- Existing code will continue to work with updated theme

## References

- HTML Design Reference: Provided by user (3 HTML files with Refine theme)
- Current Flutter App: `/Users/yohanangulo/Documents/dev/flutter_projects/in-context/`
- Material Design 3: https://m3.material.io/
- Google Fonts Package: https://pub.dev/packages/google_fonts
