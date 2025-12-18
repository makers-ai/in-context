import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/features/thought/presentation/providers/thought_controller.dart';

/// Three modal states:
/// 1. Selection - Choose between voice or text
/// 2. Recording - Voice recording UI
/// 3. TextInput - Text editing UI
enum _ModalState { selection, recording, textInput }

class AddThoughtModal extends ConsumerStatefulWidget {
  const AddThoughtModal({
    required this.projectId,
    required this.onDismiss,
    super.key,
  });

  final String projectId;
  final VoidCallback onDismiss;

  @override
  ConsumerState<AddThoughtModal> createState() => _AddThoughtModalState();
}

class _AddThoughtModalState extends ConsumerState<AddThoughtModal>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  _ModalState _state = _ModalState.selection;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _submitText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref.read(thoughtControllerProvider.notifier).createTextThought(
          projectId: widget.projectId,
          text: text,
        );
    _controller.clear();
    widget.onDismiss();
  }

  void _startRecording() {
    ref.read(thoughtControllerProvider.notifier).startRecording();
    setState(() => _state = _ModalState.recording);
  }

  void _stopRecording() {
    ref.read(thoughtControllerProvider.notifier).stopRecordingAndCreateThought(widget.projectId);
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thoughtState = ref.watch(thoughtControllerProvider);

    return AnimatedSize(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 350),
      child: _buildModalContent(context, isDark, thoughtState),
    );
  }

  Widget _buildModalContent(
    BuildContext context,
    bool isDark,
    dynamic thoughtState,
  ) {
    switch (_state) {
      case _ModalState.selection:
        return _buildSelectionState(context, isDark);
      case _ModalState.recording:
        return _buildRecordingState(context, isDark, thoughtState);
      case _ModalState.textInput:
        return _buildTextInputState(context, isDark);
    }
  }

  /// State 1: Selection - Choose between Record Voice or Write Text
  Widget _buildSelectionState(BuildContext context, bool isDark) {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('selection'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child!,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: AppSpacing.xl + AppSpacing.spacing32 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'Capture Thought',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose how you want to capture your thought.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Options Grid
            Row(
              children: [
                // Voice Option
                Expanded(
                  child: _OptionCard(
                    icon: Icons.mic,
                    label: 'Record Voice',
                    isDark: isDark,
                    onTap: _startRecording,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Text Option
                Expanded(
                  child: _OptionCard(
                    icon: Icons.edit_note,
                    label: 'Write Text',
                    isDark: isDark,
                    onTap: () => setState(() => _state = _ModalState.textInput),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// State 2: Recording - Voice recording UI with animation
  Widget _buildRecordingState(
    BuildContext context,
    bool isDark,
    dynamic thoughtState,
  ) {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('recording'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child!,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Recording UI
            Column(
              children: [
                // "Recording..." text
                Text(
                  'RECORDING...',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Pulsing mic button
                _buildPulsingMicButton(),
                const SizedBox(height: AppSpacing.xl),

                // Waveform visualization
                _buildWaveform(),
                const SizedBox(height: AppSpacing.xl),

                // Stop button
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: thoughtState.isRecording ? _stopRecording : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.grey800 : AppColors.grey100,
                      foregroundColor: isDark ? AppColors.white : AppColors.grey900,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                        horizontal: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.stop_circle,
                      color: AppColors.error,
                    ),
                    label: const Text('Stop Recording'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// State 3: Text Input - Full-screen text editor
  Widget _buildTextInputState(BuildContext context, bool isDark) {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('text-input'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child!,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: widget.onDismiss,
                  icon: const Icon(Icons.close),
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                Text(
                  'NEW NOTE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: isDark ? AppColors.grey400 : AppColors.grey500,
                      ),
                ),
                const SizedBox(width: 48), // Spacer for centering
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Input Area
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                autofocus: true,
                textAlignVertical: TextAlignVertical.top,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      height: 1.6,
                    ),
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            // Toolbar / Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.grey800 : AppColors.grey100,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left actions (optional image/mic buttons)
                  IconButton(
                    onPressed: () {
                      setState(() => _state = _ModalState.recording);
                      _startRecording();
                    },
                    icon: const Icon(Icons.mic),
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                  // Right actions (char count + save button)
                  Row(
                    children: [
                      Text(
                        '${_controller.text.length} chars',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _controller.text.trim().isEmpty ? null : _submitText,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.full),
                          ),
                          elevation: 0,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pulsing mic button with animated rings
  Widget _buildPulsingMicButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing ring
            Transform.scale(
              scale: 1 + (_pulseController.value * 0.6),
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(
                    alpha: 0.1 * (1 - _pulseController.value),
                  ),
                ),
              ),
            ),
            // Inner pulsing ring
            Transform.scale(
              scale: 1 + (_pulseController.value * 0.3),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(
                    alpha: 0.2 * (1 - _pulseController.value),
                  ),
                ),
              ),
            ),
            // Main mic button
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 36,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Animated waveform visualization
  Widget _buildWaveform() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (index) {
          final heights = [12.0, 24.0, 40.0, 28.0, 16.0, 8.0];
          final delays = [0.0, 0.2, 0.8, 1.1, 0.9, 1.3];
          final opacities = [0.4, 0.6, 1.0, 1.0, 0.6, 0.4];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final animValue = (_pulseController.value + delays[index]) % 1.0;
                final animatedHeight = heights[index] + (20 * (0.5 - (animValue - 0.5).abs()));

                return Container(
                  width: 6,
                  height: animatedHeight,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: opacities[index]),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

/// Reusable option card for selection state
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800.withValues(alpha: 0.5) : AppColors.grey50,
            border: Border.all(
              color: isDark ? AppColors.grey700 : AppColors.grey100,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing20),
              // Label
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textMainDark : AppColors.grey700,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
