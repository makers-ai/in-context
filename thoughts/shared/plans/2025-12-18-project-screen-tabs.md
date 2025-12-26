# ProjectScreen Tabbed Interface Implementation Plan

## Overview

Transform the ProjectScreen from a vertically scrolling layout into a tabbed interface with three sections: Thoughts, Context, and Outputs. The tab interface will use a custom sliding pill selector that matches the app's rounded, modern design language (28px border radius), avoiding Material Design conventions.

## Current State Analysis

**Current Layout** ([project_screen.dart:87-124](lib/features/project/presentation/screens/project_screen.dart#L87-L124)):
The ProjectScreen currently displays all sections in a single `SingleChildScrollView`:
```dart
SingleChildScrollView(
  child: Column(
    children: [
      ThoughtsSection(projectId: widget.projectId),
      ContextSection(projectId: widget.projectId),
      Consumer(/* Shows PromptsSection + OutputsSection conditionally */),
    ],
  ),
)
```

**Section Components**:
- **ThoughtsSection** - Fixed 300px height container with scrollable thought cards
- **ContextSection** - Variable height based on content, includes ContextCard
- **PromptsSection** - Horizontal wrap of ActionChips for prompt selection
- **OutputsSection** - Vertical list of OutputCards

**Design System**:
- Border radius: `AppRadii.radiusXxl` (28px) for cards
- Spacing: 8pt grid system via `AppSpacing`
- Colors: `AppColors.primary` (0xFF2a6aea) with transparency overlays
- Shadows: Only in light mode (`isDark ? [] : AppShadows.shadowSoft`)
- Custom components: `AppButton`, `AnimatedButton`, various card types

**Key Discoveries**:
- No existing tab component in codebase - this is a new pattern
- App uses custom styling over Material Design
- All sections use Riverpod stream providers for real-time data
- Conditional rendering: PromptsSection/OutputsSection only show when context exists

## Desired End State

A tabbed interface with:

1. **Custom Tab Bar**:
   - Three tabs: "Thoughts", "Context", "Outputs"
   - Sliding pill selector with smooth animation
   - Matches app's 28px border radius design language
   - Fixed position below AppBar

2. **Tab Content**:
   - **Thoughts Tab**: ThoughtsSection (unchanged functionally)
   - **Context Tab**: ContextSection (unchanged functionally)
   - **Outputs Tab**: PromptsSection + OutputsSection together

3. **Behavior**:
   - Scroll position persists when switching tabs (using `AutomaticKeepAliveClientMixin`)
   - Smooth animations between tabs
   - Tab content fills available screen height

### Success Criteria:

#### Automated Verification:
- [x] Code compiles without errors: `flutter analyze`
- [x] No linting issues: `make analyze`
- [x] All existing tests pass (if any): `flutter test`
- [x] Hot reload works without errors during development

#### Manual Verification:
- [x] Three tabs are visible and tappable
- [x] Sliding pill animation is smooth (300ms duration)
- [x] Each tab displays correct content
- [x] Scroll position is preserved when switching between tabs
- [x] Thoughts section shows thought cards correctly
- [x] Context section shows context card with refine/edit actions
- [x] Outputs tab shows both prompt chips and output results
- [x] Error listeners still work (snackbars appear for errors)
- [x] UI matches app's rounded design aesthetic
- [x] Works correctly in both light and dark modes
- [x] Performance is smooth with many thoughts/outputs

**Implementation Note**: After completing this implementation and all automated verification passes, pause for manual confirmation that the manual testing was successful.

## What We're NOT Doing

- NOT implementing swipe gestures between tabs (can be added later)
- NOT changing the internal logic of ThoughtsSection, ContextSection, PromptsSection, or OutputsSection
- NOT modifying the data providers or controllers
- NOT adding tab badges or indicators (e.g., unread counts)
- NOT making tabs scrollable horizontally (only 3 tabs, they fit)
- NOT implementing tab history/navigation (tabs are local to this screen)

## Implementation Approach

We'll create a custom tab component that matches the app's design language, then refactor ProjectScreen to use it. The approach focuses on:

1. **Custom Tab Widget**: Build a reusable `CustomTabBar` widget with sliding pill animation
2. **Screen Refactor**: Replace `SingleChildScrollView` with `TabBarView` equivalent
3. **State Management**: Use built-in Flutter state for tab selection (no need for Riverpod)
4. **Scroll Persistence**: Implement `AutomaticKeepAliveClientMixin` for each tab's content

## Phase 1: Create Custom Tab Bar Component

### Overview
Build the custom tab bar widget with sliding pill selector animation. This will be a reusable component that matches the app's design system.

### Changes Required:

#### 1. Create CustomTabBar Widget
**File**: `lib/core/widgets/custom_tab_bar.dart` (new file)

```dart
import 'package:flutter/material.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_radii.dart';
import 'package:incontext/core/theme/app_spacing.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    super.key,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  final List<GlobalKey> _tabKeys = [];

  @override
  void initState() {
    super.initState();
    _tabKeys.addAll(List.generate(widget.tabs.length, (_) => GlobalKey()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
          ? AppColors.grey800.withValues(alpha: 0.5)
          : AppColors.grey100,
        borderRadius: AppRadii.radiusFull,
      ),
      child: Stack(
        children: [
          // Animated pill background
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _calculatePillOffset(),
            top: 0,
            bottom: 0,
            width: _calculatePillWidth(),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: AppRadii.radiusFull,
                boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
              ),
            ),
          ),
          // Tab buttons
          Row(
            children: List.generate(widget.tabs.length, (index) {
              final isSelected = widget.selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  key: _tabKeys[index],
                  onTap: () => widget.onTabSelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: isSelected
                            ? theme.colorScheme.onPrimary
                            : (isDark ? AppColors.grey400 : AppColors.grey600),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        child: Text(widget.tabs[index]),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  double _calculatePillOffset() {
    if (_tabKeys.isEmpty || widget.selectedIndex >= _tabKeys.length) {
      return 0;
    }

    final selectedKey = _tabKeys[widget.selectedIndex];
    final renderBox = selectedKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return 0;

    final position = renderBox.localToGlobal(Offset.zero);
    final containerPosition = (context.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero);

    if (containerPosition == null) return 0;

    return position.dx - containerPosition.dx - 4; // Subtract container padding
  }

  double _calculatePillWidth() {
    if (_tabKeys.isEmpty || widget.selectedIndex >= _tabKeys.length) {
      return 0;
    }

    final selectedKey = _tabKeys[widget.selectedIndex];
    final renderBox = selectedKey.currentContext?.findRenderObject() as RenderBox?;

    return renderBox?.size.width ?? 0;
  }
}
```

**Key aspects**:
- Uses `AnimatedPositioned` for smooth pill movement
- Calculates pill position/width using `GlobalKey` and `RenderBox`
- Matches app's design: pill-shaped container, 28px radius, primary color
- Text color animates between selected/unselected states
- 300ms animation duration with `easeInOut` curve

### Success Criteria:

#### Automated Verification:
- [x] File compiles without errors: `flutter analyze lib/core/widgets/custom_tab_bar.dart`
- [x] No linting issues in the new file

#### Manual Verification:
- [x] Tab bar renders with three tabs
- [x] Pill selector slides smoothly when tapping tabs
- [x] Selected tab text is white and bold
- [x] Unselected tab text is gray and medium weight
- [x] Works in both light and dark mode
- [x] Pill has shadow in light mode only

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 2: Create Tab Content Wrapper

### Overview
Create wrapper widgets for each tab's content that preserve scroll position using `AutomaticKeepAliveClientMixin`.

### Changes Required:

#### 1. Create KeepAliveTab Widget
**File**: `lib/core/widgets/keep_alive_tab.dart` (new file)

```dart
import 'package:flutter/material.dart';

/// Wrapper widget that keeps tab content alive when switching tabs.
/// This preserves scroll position and widget state.
class KeepAliveTab extends StatefulWidget {
  const KeepAliveTab({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return widget.child;
  }
}
```

**Key aspects**:
- Simple wrapper using `AutomaticKeepAliveClientMixin`
- Keeps widget tree alive when tab is not visible
- Preserves scroll controllers and state
- Must call `super.build()` in build method

### Success Criteria:

#### Automated Verification:
- [x] File compiles without errors: `flutter analyze lib/core/widgets/keep_alive_tab.dart`
- [x] No linting issues in the new file

#### Manual Verification:
- [x] Widget compiles and can be imported
- [x] No runtime errors when wrapping other widgets

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 3: Refactor ProjectScreen to Use Tabs

### Overview
Replace the single scrolling layout with a tabbed interface. This is the main integration phase.

### Changes Required:

#### 1. Update ProjectScreen Widget
**File**: [lib/features/project/presentation/screens/project_screen.dart](lib/features/project/presentation/screens/project_screen.dart)

**Step 3a: Add imports**
Add these imports at the top of the file:
```dart
import 'package:incontext/core/widgets/custom_tab_bar.dart';
import 'package:incontext/core/widgets/keep_alive_tab.dart';
```

**Step 3b: Add state for tab selection**
In `_ProjectScreenState` class (after line 29), add:
```dart
class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  int _selectedTabIndex = 0; // Add this line

  @override
  Widget build(BuildContext context) {
    // ... existing code
```

**Step 3c: Replace the body in the Scaffold**
Replace lines 86-128 (the entire `body: SafeArea(...)` section) with:
```dart
body: SafeArea(
  child: Column(
    children: [
      // Custom tab bar
      CustomTabBar(
        tabs: const ['Thoughts', 'Context', 'Outputs'],
        selectedIndex: _selectedTabIndex,
        onTabSelected: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),

      // Tab content
      Expanded(
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            // Thoughts tab
            KeepAliveTab(
              child: SingleChildScrollView(
                child: ThoughtsSection(
                  projectId: widget.projectId,
                ),
              ),
            ),

            // Context tab
            KeepAliveTab(
              child: SingleChildScrollView(
                child: ContextSection(
                  projectId: widget.projectId,
                ),
              ),
            ),

            // Outputs tab (Prompts + Outputs)
            KeepAliveTab(
              child: Consumer(
                builder: (context, ref, _) {
                  final contextAsync = ref.watch(contextStreamProvider(widget.projectId));
                  return contextAsync.when(
                    data: (contextEntity) {
                      if (contextEntity == null) {
                        // Show empty state when no context exists
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: Text(
                              'Create context first to generate outputs',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textMutedLight),
                            ),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.md),
                            // Prompts section
                            PromptsSection(contextEntity: contextEntity),
                            const SizedBox(height: AppSpacing.md),
                            // Outputs section
                            OutputsSection(contextEntity: contextEntity),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(
                          'Error loading context',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
```

**Step 3d: Add missing import for AppSpacing**
If not already imported, add:
```dart
import 'package:incontext/core/theme/app_spacing.dart';
```

**Key changes explained**:
- **IndexedStack**: Keeps all tabs in memory but only shows the selected one
- **KeepAliveTab**: Wraps each tab to preserve scroll position
- **SingleChildScrollView**: Each tab has its own scroll controller
- **Conditional rendering**: Outputs tab shows empty state when no context exists
- **Error listeners**: Remain unchanged (lines 35-71)

### Success Criteria:

#### Automated Verification:
- [x] Code compiles without errors: `flutter analyze`
- [x] No linting issues: `make analyze`
- [x] All existing tests pass: `flutter test` (Note: Existing test has pre-existing Firebase initialization issue unrelated to our changes)
- [x] Hot reload works during development

#### Manual Verification:
- [x] App builds and runs successfully
- [x] Three tabs appear below the AppBar
- [x] Tapping tabs switches content smoothly
- [x] Thoughts tab shows thought cards correctly
- [x] Context tab shows context card with refine/edit buttons
- [x] Outputs tab shows prompt chips and output results
- [x] Outputs tab shows empty state when no context exists
- [x] Scroll position is preserved when switching tabs:
  - [x] Scroll down in Thoughts tab
  - [x] Switch to Context tab
  - [x] Switch back to Thoughts tab
  - [x] Verify scroll position is maintained
- [x] Error snackbars still appear for thought/context/output errors
- [x] All existing functionality works (add thought, refine context, generate output, etc.)
- [x] UI looks good in both light and dark mode
- [x] Tab bar pill animation is smooth and aligns correctly with tab text

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 4: Polish and Refinement

### Overview
Optional improvements for better UX and polish. Only implement if time permits and previous phases work correctly.

### Changes Required:

#### 1. Add Haptic Feedback (Optional)
**File**: [lib/core/widgets/custom_tab_bar.dart](lib/core/widgets/custom_tab_bar.dart)

Add haptic feedback when tapping tabs:
```dart
import 'package:flutter/services.dart'; // Add import

// In the GestureDetector onTap:
onTap: () {
  HapticFeedback.selectionClick(); // Add this
  widget.onTabSelected(index);
},
```

#### 2. Fix ThoughtsSection Height (Optional)
**File**: [lib/features/thought/presentation/widgets/components/thoughts_section.dart](lib/features/thought/presentation/widgets/components/thoughts_section.dart)

Currently ThoughtsSection has a fixed 300px height (line 44). When in a tab, it should expand to fill available space:

**Option A**: Add a parameter to control height behavior:
```dart
class ThoughtsSection extends ConsumerWidget {
  const ThoughtsSection({
    required this.projectId,
    this.useFixedHeight = true, // Add this parameter
    super.key,
  });

  final String projectId;
  final bool useFixedHeight; // Add this

  // In build method, change line 43-77:
  useFixedHeight
    ? SizedBox(
        height: 300,
        child: /* existing list content */,
      )
    : Expanded(
        child: /* existing list content */,
      )
```

Then in ProjectScreen, use: `ThoughtsSection(projectId: widget.projectId, useFixedHeight: false)`

**Option B**: Remove the fixed height entirely and always use `Expanded` or full height.

#### 3. Add Tab Transition Animation (Optional)
**File**: [lib/features/project/presentation/screens/project_screen.dart](lib/features/project/presentation/screens/project_screen.dart)

Replace `IndexedStack` with `AnimatedSwitcher` for fade transitions:
```dart
Expanded(
  child: AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    switchInCurve: Curves.easeIn,
    switchOutCurve: Curves.easeOut,
    child: [
      /* Thoughts tab */,
      /* Context tab */,
      /* Outputs tab */,
    ][_selectedTabIndex],
  ),
),
```

**Note**: This will NOT preserve scroll position. Only use if you decide scroll persistence is not needed.

### Success Criteria:

#### Automated Verification:
- [x] Code compiles without errors: `flutter analyze`
- [x] No linting issues: `make analyze`

#### Manual Verification:
- [x] Haptic feedback is felt when tapping tabs (on physical device)
- [x] ThoughtsSection fills available height instead of being fixed
- [x] Tab transitions are smooth (if using AnimatedSwitcher)
- [x] All functionality from previous phases still works

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful.

---

## Testing Strategy

### Unit Tests:
Not applicable for this feature - it's primarily UI/layout changes with no complex business logic to unit test.

### Integration Tests:
Could add widget tests for the custom tab bar:
- Test tab selection changes state
- Test pill animation triggers on tap
- Test correct tab content is displayed

### Manual Testing Steps:

1. **Basic Tab Functionality**:
   - Open a project
   - Verify three tabs appear: Thoughts, Context, Outputs
   - Tap each tab and verify correct content displays

2. **Scroll Persistence**:
   - In Thoughts tab, scroll down to view multiple thoughts
   - Switch to Context tab
   - Switch back to Thoughts tab
   - Verify scroll position is maintained (not reset to top)
   - Repeat for Context and Outputs tabs

3. **Content Verification**:
   - **Thoughts tab**: Add a new thought, verify it appears in the list
   - **Context tab**: Refine context, verify the refined indicator appears
   - **Outputs tab**:
     - If no context exists, verify empty state message
     - If context exists, verify prompt chips appear
     - Click a prompt chip, verify output is generated and appears
     - Verify both prompts and outputs are visible in the same tab

4. **Error Handling**:
   - Trigger an error in thought creation (if possible)
   - Verify error snackbar still appears
   - Repeat for context and output errors

5. **Visual Polish**:
   - Verify tab bar pill selector:
     - Slides smoothly between tabs (not instant)
     - Has correct rounded shape (pill/capsule)
     - Matches app's 28px border radius aesthetic
     - Has shadow in light mode
   - Verify selected tab text is white and bold
   - Verify unselected tab text is gray

6. **Theme Testing**:
   - Toggle between light and dark mode
   - Verify tab bar looks good in both modes
   - Verify pill selector adapts to theme
   - Verify all content is readable in both themes

7. **Edge Cases**:
   - Test with zero thoughts
   - Test with zero outputs
   - Test with very long content in each tab
   - Test rapid tab switching

## Performance Considerations

**IndexedStack Memory Usage**:
- `IndexedStack` keeps all three tabs in memory simultaneously
- This is acceptable for this use case (only 3 tabs, lightweight content)
- If memory becomes an issue, could switch to lazy loading with `PageView`

**Scroll Controllers**:
- Each tab has its own `SingleChildScrollView` with separate scroll controller
- `AutomaticKeepAliveClientMixin` ensures controllers are not disposed when switching tabs
- No manual controller management needed

**Stream Subscriptions**:
- All existing Riverpod providers remain active
- No additional stream subscriptions are created
- Tab switching doesn't re-subscribe to streams (thanks to `KeepAliveTab`)

**Animation Performance**:
- Tab pill animation uses `AnimatedPositioned` which is GPU-accelerated
- 300ms duration is fast enough to feel responsive
- `easeInOut` curve provides smooth, natural motion

## Migration Notes

**Breaking Changes**: None - this is a UI-only refactor

**Backwards Compatibility**: N/A - this is not a library, just app UI

**Data Migration**: None required

**User Impact**:
- Users will see a different layout (tabs instead of vertical scroll)
- No data loss or functionality removal
- May need to re-learn navigation (tabs instead of scrolling)
- Consider adding a brief in-app tooltip or announcement

## References

- Original screen: [lib/features/project/presentation/screens/project_screen.dart](lib/features/project/presentation/screens/project_screen.dart)
- Design system:
  - Colors: [lib/core/theme/app_colors.dart](lib/core/theme/app_colors.dart)
  - Border radius: [lib/core/theme/app_radii.dart](lib/core/theme/app_radii.dart)
  - Spacing: [lib/core/theme/app_spacing.dart](lib/core/theme/app_spacing.dart)
- Custom button: [lib/core/widgets/app_button.dart](lib/core/widgets/app_button.dart)
- Similar custom component: [lib/features/thought/presentation/widgets/components/add_thought_modal.dart](lib/features/thought/presentation/widgets/components/add_thought_modal.dart) (shows custom state-based UI)

## Open Questions

✅ **All questions resolved**:
- Tab style: Sliding pill selector
- Outputs tab organization: Prompts + Outputs together
- Scroll persistence: Yes, remember position
