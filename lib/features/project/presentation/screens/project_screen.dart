import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incontext/core/routing/app_routes.dart';
import 'package:incontext/core/theme/app_colors.dart';
import 'package:incontext/core/theme/app_spacing.dart';
import 'package:incontext/core/widgets/custom_tab_bar.dart';
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

class _ProjectScreenState extends ConsumerState<ProjectScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        return Scaffold(
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
                // Custom tab bar
                CustomTabBar(
                  tabs: const ['Thoughts', 'Context', 'Outputs'],
                  controller: _tabController,
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Thoughts tab
                      KeepAliveTab(
                        child: ThoughtsSection(
                          projectId: widget.projectId,
                          onChevronPressed: () => _tabController.animateTo(1),
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
