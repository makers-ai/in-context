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

  // New: Primary button with icon (matches "New Note" button in HTML)
  Widget _buildPrimaryButton(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primary,
      borderRadius: AppRadii.radiusXl,
      elevation: 2,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppRadii.radiusXl,
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
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
