import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/utils/result.dart';
import 'package:incontext/features/prompts/domain/entities/prompt_entity.dart';
import 'package:incontext/features/prompts/domain/repositories/prompt_repository.dart';
import 'package:incontext/features/prompts/presentation/providers/prompt_providers.dart';

final promptControllerProvider =
    StateNotifierProvider<PromptController, PromptState>((ref) {
  final repository = ref.watch(promptRepositoryProvider);
  return PromptController(repository);
});

class PromptController extends StateNotifier<PromptState> {
  PromptController(this._repository) : super(const PromptState());

  final PromptRepository _repository;

  Future<void> createPrompt({
    required String name,
    required String description,
    required String promptTemplate,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.createPrompt(
      name: name,
      description: description,
      promptTemplate: promptTemplate,
    );

    result.when(
      success: (prompt) {
        state = state.copyWith(isLoading: false, createdPrompt: prompt);
      },
      error: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }

  Future<void> updatePrompt({
    required String id,
    required String name,
    required String description,
    required String promptTemplate,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.updatePrompt(
      id: id,
      name: name,
      description: description,
      promptTemplate: promptTemplate,
    );

    result.when(
      success: (prompt) {
        state = state.copyWith(isLoading: false, updatedPrompt: prompt);
      },
      error: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }

  Future<void> deletePrompt(String id) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.deletePrompt(id);

    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
      },
      error: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCreatedPrompt() {
    state = state.copyWith(createdPrompt: null);
  }

  void clearUpdatedPrompt() {
    state = state.copyWith(updatedPrompt: null);
  }
}

class PromptState {
  const PromptState({
    this.isLoading = false,
    this.error,
    this.createdPrompt,
    this.updatedPrompt,
  });

  final bool isLoading;
  final String? error;
  final PromptEntity? createdPrompt;
  final PromptEntity? updatedPrompt;

  PromptState copyWith({
    bool? isLoading,
    String? error,
    PromptEntity? createdPrompt,
    PromptEntity? updatedPrompt,
  }) {
    return PromptState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      createdPrompt: createdPrompt ?? this.createdPrompt,
      updatedPrompt: updatedPrompt ?? this.updatedPrompt,
    );
  }
}
