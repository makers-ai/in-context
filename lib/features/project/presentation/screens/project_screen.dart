import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incontext/core/routing/app_routes.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/widgets/error_body.dart';
import 'package:incontext/core/widgets/keep_alive_tab.dart';
import 'package:incontext/core/widgets/loading_body.dart';
import 'package:incontext/features/context/presentation/providers/context_controller.dart';
import 'package:incontext/features/context/presentation/providers/context_providers.dart';
import 'package:incontext/features/project/presentation/providers/project_providers.dart';
import 'package:incontext/features/context/presentation/widgets/components/context_section.dart';
import 'package:incontext/features/output/presentation/providers/output_controller.dart';
import 'package:incontext/features/output/presentation/widgets/components/outputs_section.dart';
import 'package:incontext/features/prompts/presentation/widgets/prompts_section.dart';
import 'package:incontext/features/thought/presentation/providers/thought_controller.dart';
import 'package:incontext/features/thought/presentation/widgets/components/thoughts_section.dart';

class ProjectScreen extends ConsumerStatefulWidget {
  const ProjectScreen({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  late PageController _pageController;
  Offset _controlsOffset = Offset.zero;
  OverlayEntry? _overlayEntry;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuerySize = MediaQuery.of(context).size;
      setState(() {
        _controlsOffset = Offset(mediaQuerySize.width - 100, mediaQuerySize.height - 200);
      });
      // _showOverlay();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectProvider(widget.projectId));

    // Listen for thought controller errors
    ref.listen<ThoughtState>(thoughtControllerProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(thoughtControllerProvider.notifier).clearError();
      }
    });

    // Listen for context controller errors
    ref.listen<ContextState>(contextControllerProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(contextControllerProvider.notifier).clearError();
      }
    });

    // Listen for output controller errors
    ref.listen<OutputState>(outputControllerProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(outputControllerProvider.notifier).clearError();
      }
    });

    return projectAsync.when(
      data: (project) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(project.title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.menu_book_sharp),
                    onPressed: () => context.push(AppRoutes.prompts),
                    tooltip: 'Manage Prompts',
                  ),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    // Tab content
                    Expanded(
                      child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        controller: _pageController,
                        onPageChanged: (index) {
                          _currentIndex = index;
                          // Update overlay when page changes to update button states
                          _overlayEntry?.markNeedsBuild();
                          setState(() {});
                        },
                        children: [
                          // Thoughts tab
                          KeepAliveTab(
                            child: ThoughtsSection(
                              projectId: widget.projectId,
                              onChevronPressed: () => _pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
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
                                final contextAsync =
                                    ref.watch(contextStreamProvider(widget.projectId));
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
            ),
            Positioned(
              left: _controlsOffset.dx,
              top: _controlsOffset.dy,
              child: Listener(
                onPointerMove: (details) => setState(() {
                  _controlsOffset += details.delta;
                }),
                child: TweenAnimationBuilder(
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
                          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                          tooltip: 'Previous Section',
                          onPressed: _currentIndex > 0
                              ? () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                }
                              : null,
                        ),
                        IconButton(
                          constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                          tooltip: 'Next Section',
                          onPressed: _currentIndex < 2
                              ? () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  builder: (context, double value, child) => Opacity(
                    opacity: value,
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Scaffold(
        body: LoadingBody(loadingMessage: 'Loading project...'),
      ),
      error: (error, _) => Scaffold(
        body: ErrorBody(description: 'Failed to load project: $error'),
      ),
    );
  }
}
