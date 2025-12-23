# Swipe-to-Delete with Undo for ThoughtCard Implementation Plan

## Overview

Implement swipe-to-delete functionality for thought cards using Flutter's Dismissible widget with a gradient background and trash icon. Replace the current delete icon button with a more intuitive swipe gesture (both left and right directions). Add an undo mechanism via SnackBar to prevent accidental deletions.

## Current State Analysis

### What exists now:
- **ThoughtCard** ([thought_card.dart:58-61](lib/features/thought/presentation/widgets/thought_card.dart)) has a delete icon button in the header row
- Delete operation triggers immediately without confirmation via `onDelete` callback
- ThoughtsSection ([thoughts_section.dart:50-55](lib/features/thought/presentation/widgets/components/thoughts_section.dart)) passes delete callback directly to controller
- ThoughtController ([thought_controller.dart:180-196](lib/features/thought/presentation/providers/thought_controller.dart)) handles deletion with loading state
- ListView.builder uses `ValueKey(thought.id)` for proper list management

### Key constraints discovered:
- Codebase doesn't currently use Dismissible widgets - this will be the first implementation
- SnackBar pattern exists ([output_card.dart:65-67](lib/features/output/presentation/widgets/output_card.dart)) using `ScaffoldMessenger.of(context).showSnackBar()`
- Theme system uses AppColors, AppSpacing, AppRadii for consistent styling
- Repository pattern with Result type for error handling

## Desired End State

After implementation:
- Users can swipe ThoughtCard left or right to delete
- Swiping reveals gradient background with trash icon
- Deletion happens immediately with SnackBar showing "Thought deleted" with Undo button
- If user taps Undo within ~4 seconds, thought is restored
- Delete icon button is removed from card header
- Card smoothly dismisses with animation when deleted

### Verification:
- Swipe a thought card left → card dismisses, SnackBar appears
- Swipe a thought card right → card dismisses, SnackBar appears
- Tap "Undo" in SnackBar → thought reappears in list
- Don't tap Undo → thought is permanently deleted after SnackBar disappears
- Card dismissal is smooth with gradient background visible during swipe

## What We're NOT Doing

- Not implementing multi-select deletion
- Not adding confirmation dialog (using SnackBar undo instead)
- Not changing the repository/controller delete logic
- Not modifying other card types (PromptCard, OutputCard, etc.) - only ThoughtCard
- Not implementing swipe actions other than delete (e.g., archive, edit)

## Implementation Approach

Use Flutter's Dismissible widget to wrap ThoughtCard with:
1. Gradient background (red to darker red) with centered trash icon
2. Bidirectional swipe (DismissDirection.horizontal)
3. `onDismissed` callback to handle deletion with undo logic
4. Optimistic deletion pattern: immediately remove from UI, restore if undone

The key insight is using a local state (`_pendingDeletions` Set) to track thoughts that have been swiped away but not yet deleted from Firebase. When the user swipes:
- Add thought ID to `_pendingDeletions` → thought is filtered out of the visible list (disappears immediately)
- Show SnackBar with Undo button
- If Undo pressed: Remove from `_pendingDeletions` → thought reappears in list
- If timeout (5 seconds): Delete from Firebase and remove from `_pendingDeletions`

## Phase 1: Update ThoughtCard Structure

### Overview
Modify ThoughtCard to remove the delete button and prepare the card for being wrapped in Dismissible widget by ThoughtsSection.

### Changes Required:

#### 1. Remove Delete Button from ThoughtCard Header
**File**: [lib/features/thought/presentation/widgets/thought_card.dart](lib/features/thought/presentation/widgets/thought_card.dart)

**Changes**:
- Remove `onDelete` callback parameter (line 10, 15)
- Remove IconButton with delete icon from Row (lines 57-61)
- Keep the card structure otherwise unchanged

```dart
class ThoughtCard extends StatefulWidget {
  const ThoughtCard({
    required this.thought,
    // Remove: required this.onDelete,
    super.key,
  });

  final ThoughtEntity thought;
  // Remove: final VoidCallback onDelete;

  @override
  State<ThoughtCard> createState() => _ThoughtCardState();
}

class _ThoughtCardState extends State<ThoughtCard> {
  // ... existing state ...

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isTextThought =
        widget.thought.type == ThoughtType.text || widget.thought.transcript != null;

    final textContentExceeds = widget.thought.rawContent.length > maxCaracters ||
        (widget.thought.transcript != null && widget.thought.transcript!.length > maxCaracters);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.thought.type == ThoughtType.text ? Icons.text_fields : Icons.mic,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  timeago.format(widget.thought.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                // Remove the Spacer and IconButton here
              ],
            ),
            // ... rest of card content remains unchanged ...
          ],
        ),
      ),
    );
  }
}
```

### Success Criteria:

#### Automated Verification:
- [x] Code compiles without errors: `flutter analyze`
- [x] No type errors: `flutter analyze`
- [x] ThoughtCard no longer expects `onDelete` parameter

#### Manual Verification:
- [x] ThoughtsSection shows compile error (expected - will fix in Phase 2)
- [ ] Card header only shows icon and timestamp, no delete button
- [ ] Card layout looks clean without the trailing delete icon

---

## Phase 2: Implement Dismissible Wrapper in ThoughtsSection

### Overview
Wrap ThoughtCard with Dismissible widget in the ListView, implement the swipe-to-delete with undo functionality, and manage the optimistic deletion pattern.

### Changes Required:

#### 0. Convert ThoughtsSection to StatefulWidget
**File**: [lib/features/thought/presentation/widgets/components/thoughts_section.dart](lib/features/thought/presentation/widgets/components/thoughts_section.dart)

**Changes**:
- Convert from `ConsumerWidget` to `ConsumerStatefulWidget`
- Add `_pendingDeletions` Set to track thoughts pending deletion
- Filter thoughts to exclude pending deletions

```dart
class ThoughtsSection extends ConsumerStatefulWidget {
  const ThoughtsSection({
    required this.projectId,
    required this.onChevronPressed,
    super.key,
  });

  final String projectId;
  final VoidCallback onChevronPressed;

  @override
  ConsumerState<ThoughtsSection> createState() => _ThoughtsSectionState();
}

class _ThoughtsSectionState extends ConsumerState<ThoughtsSection> {
  final Set<String> _pendingDeletions = {};

  @override
  Widget build(BuildContext context) {
    final thoughtsAsync = ref.watch(thoughtsStreamProvider(widget.projectId));
    // ... rest of build method
  }
}
```

#### 1. Add Dismissible Wrapper with Gradient Background
**File**: [lib/features/thought/presentation/widgets/components/thoughts_section.dart](lib/features/thought/presentation/widgets/components/thoughts_section.dart)

**Changes**:
- Filter thoughts to exclude pending deletions
- Wrap ThoughtCard with Dismissible in ListView.builder
- Implement gradient background with trash icon
- Add `onDismissed` callback with SnackBar undo logic
- Remove `onDelete` parameter from ThoughtCard call

```dart
// Clean up pending deletions for thoughts that no longer exist in Firebase
final thoughtIds = thoughts.map((t) => t.id).toSet();
_pendingDeletions.removeWhere((id) => !thoughtIds.contains(id));

// Filter out thoughts that are pending deletion
final visibleThoughts = thoughts
    .where((thought) => !_pendingDeletions.contains(thought.id))
    .toList();

return Expanded(
  child: ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    itemCount: visibleThoughts.length,
    itemBuilder: (context, index) {
      final thought = visibleThoughts[index];
      return Dismissible(
        key: ValueKey(thought.id),
        direction: DismissDirection.horizontal,
        background: _buildDismissBackground(context, isLeft: true),
        secondaryBackground: _buildDismissBackground(context, isLeft: false),
        onDismissed: (direction) {
          _handleThoughtDismissed(thought);
        },
        child: ThoughtCard(
          thought: thought,
        ),
      );
    },
  ),
);
```

#### 2. Create Gradient Background Builder Method
**File**: [lib/features/thought/presentation/widgets/components/thoughts_section.dart](lib/features/thought/presentation/widgets/components/thoughts_section.dart)

**Changes**: Add new private method to build dismissible background

```dart
Widget _buildDismissBackground(BuildContext context, {required bool isLeft}) {
  return Container(
    alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.red.shade400,
          Colors.red.shade700,
        ],
        begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      ),
    ),
    child: const Icon(
      Icons.delete,
      color: Colors.white,
      size: 32,
    ),
  );
}
```

#### 3. Implement Optimistic Deletion with Undo Logic
**File**: [lib/features/thought/presentation/widgets/components/thoughts_section.dart](lib/features/thought/presentation/widgets/components/thoughts_section.dart)

**Changes**: Add method to handle optimistic deletion with undo capability

```dart
void _handleThoughtDismissed(ThoughtEntity thought) {
  // Add to pending deletions to hide it from the list
  setState(() {
    _pendingDeletions.add(thought.id);
  });

  // Show SnackBar with Undo action
  final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Thought deleted'),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Remove from pending deletions to show it again
          setState(() {
            _pendingDeletions.remove(thought.id);
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );

  // Wait for the SnackBar to be closed and check the reason
  snackBarController.closed.then((reason) {
    // If the user didn't press Undo, proceed with deletion from Firebase
    if (reason != SnackBarClosedReason.action) {
      ref.read(thoughtControllerProvider.notifier).deleteThought(thought.id);
      // Don't remove from _pendingDeletions here - the Firebase stream will handle removing it
      // from the thoughts list, and we'll clean up _pendingDeletions when the widget rebuilds
    }
    // If they pressed Undo, the thought is already restored (removed from _pendingDeletions above)
  });
}
```

### Success Criteria:

#### Automated Verification:
- [x] Code compiles successfully: `flutter analyze`
- [x] No linting errors: `flutter analyze`
- [x] Type checking passes for all Dismissible parameters
- [x] WidgetRef is properly imported from flutter_riverpod

#### Manual Verification:
- [x] Swipe thought card left → gradient background appears with trash icon on left side
- [x] Swipe thought card right → gradient background appears with trash icon on right side
- [x] Complete swipe → card disappears immediately from list, SnackBar shows "Thought deleted" with "Undo" button
- [x] Tap "Undo" within 5 seconds → card reappears in the list, thought is NOT deleted from Firebase
- [x] Don't tap "Undo" → after 5 seconds, thought is permanently deleted from Firebase (card stays gone)
- [x] Dismissal animation is smooth
- [x] No visual glitches during swipe
- [x] Multiple rapid swipes don't cause crashes
- [x] Undo restores thought to correct position in list

**Implementation Note**: After completing Phase 2 and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to Phase 3 (if needed).

---

## Phase 3: Refinement and Edge Case Handling (Optional)

### Overview
Address potential edge cases and improve the UX based on testing feedback.

### Potential Issues to Address:

1. **Rapid Swipe Issue**: If user swipes multiple cards quickly, multiple SnackBars might stack
   - **Solution**: Use `ScaffoldMessenger.of(context).clearSnackBars()` before showing new one

2. **Screen Navigation**: If user navigates away while SnackBar is showing, deletion might not complete
   - **Solution**: Track pending deletions and clean up in `dispose()`

3. **Network Errors**: If deletion fails, user has no feedback
   - **Solution**: Listen to controller error state and show error SnackBar

### Changes Required (if needed):

#### 1. Improve SnackBar Handling
**File**: [lib/features/thought/presentation/widgets/components/thoughts_section.dart](lib/features/thought/presentation/widgets/components/thoughts_section.dart)

**Changes**: Clear previous SnackBars before showing new one

```dart
Future<bool> _showUndoSnackBar(
  BuildContext context,
  WidgetRef ref,
  ThoughtEntity thought,
) async {
  bool shouldDelete = true;

  // Clear any existing SnackBars to prevent stacking
  ScaffoldMessenger.of(context).clearSnackBars();

  final snackBar = SnackBar(
    content: const Text('Thought deleted'),
    duration: const Duration(seconds: 4),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        shouldDelete = false;
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  await Future.delayed(const Duration(seconds: 4));

  if (shouldDelete) {
    ref.read(thoughtControllerProvider.notifier).deleteThought(thought.id);
  }

  return true;
}
```

#### 2. Add Error Handling Listener
**File**: [lib/features/thought/presentation/widgets/components/thoughts_section.dart](lib/features/thought/presentation/widgets/components/thoughts_section.dart)

**Changes**: Add listener to show error messages

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final thoughtsAsync = ref.watch(thoughtsStreamProvider(projectId));

  // Listen to controller state for errors
  ref.listen<ThoughtState>(
    thoughtControllerProvider,
    (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
  );

  return Column(
    children: [
      // ... existing widget tree ...
    ],
  );
}
```

### Success Criteria:

#### Automated Verification:
- [ ] Code compiles successfully: `flutter analyze`
- [ ] No new linting errors introduced

#### Manual Verification:
- [ ] Swipe multiple cards rapidly → only one SnackBar shows at a time
- [ ] If deletion fails (e.g., network error) → error SnackBar appears
- [ ] Navigate away during undo countdown → no errors in console
- [ ] App remains stable during edge case scenarios

---

## Testing Strategy

### Unit Tests:
This feature is primarily UI-based, so unit tests are minimal:
- Test that ThoughtCard builds without `onDelete` parameter
- Verify ThoughtController.deleteThought() is called with correct ID

### Widget Tests:
- Test Dismissible widget renders correctly
- Test background gradient appears during swipe
- Test ThoughtCard dismisses when swiped
- Mock SnackBar and verify it shows after dismissal

### Manual Testing Steps:

1. **Basic Swipe Left:**
   - Open project with multiple thoughts
   - Swipe a thought card left
   - Verify gradient background with trash icon appears
   - Complete swipe and verify card dismisses smoothly
   - Verify SnackBar shows "Thought deleted" with "Undo" button

2. **Basic Swipe Right:**
   - Swipe a thought card right
   - Verify gradient background with trash icon appears (mirrored)
   - Complete swipe and verify card dismisses
   - Verify SnackBar appears

3. **Undo Action:**
   - Swipe to delete a thought
   - Immediately tap "Undo" in SnackBar
   - Verify thought reappears in the list
   - Check Firebase console → thought should still exist

4. **Confirmed Deletion:**
   - Swipe to delete a thought
   - Wait 4+ seconds without tapping Undo
   - Verify SnackBar disappears
   - Check Firebase console → thought should be deleted

5. **Multiple Rapid Swipes:**
   - Swipe 3-4 thoughts quickly
   - Verify only one SnackBar shows at a time
   - Verify all thoughts are deleted (or restored if Undo tapped)

6. **Edge Cases:**
   - Swipe while list is loading → verify no crashes
   - Swipe the last thought in list → verify empty state appears
   - Swipe while offline → verify error handling

7. **Visual Polish:**
   - Verify gradient is smooth and visually appealing
   - Trash icon is properly centered
   - Swipe threshold feels natural (not too sensitive or too hard)
   - Animation is smooth at 60fps

## Performance Considerations

- **ListView performance**: Using `ValueKey(thought.id)` ensures efficient list updates
- **Dismissible animations**: Flutter handles these natively with hardware acceleration
- **SnackBar cleanup**: Using `clearSnackBars()` prevents memory leaks from stacked SnackBars
- **Optimistic updates**: The thought stream from Firebase will automatically update the UI

## Migration Notes

Not applicable - this is a UI enhancement with no data migration required.

## References

- Current ThoughtCard: [lib/features/thought/presentation/widgets/thought_card.dart](lib/features/thought/presentation/widgets/thought_card.dart)
- ThoughtsSection ListView: [lib/features/thought/presentation/widgets/components/thoughts_section.dart:44-58](lib/features/thought/presentation/widgets/components/thoughts_section.dart#L44-L58)
- ThoughtController delete method: [lib/features/thought/presentation/providers/thought_controller.dart:180-196](lib/features/thought/presentation/providers/thought_controller.dart#L180-L196)
- SnackBar pattern example: [lib/features/output/presentation/widgets/output_card.dart:65-67](lib/features/output/presentation/widgets/output_card.dart#L65-L67)
- Flutter Dismissible docs: https://api.flutter.dev/flutter/widgets/Dismissible-class.html
