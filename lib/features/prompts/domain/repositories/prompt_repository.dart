import 'package:incontext/core/utils/result.dart';
import 'package:incontext/features/prompts/domain/entities/prompt_entity.dart';

abstract class PromptRepository {
  Future<Result<List<PromptEntity>>> getPrompts();
  Future<Result<PromptEntity>> createPrompt({
    required String name,
    required String description,
    required String promptTemplate,
  });
  Future<Result<PromptEntity>> updatePrompt({
    required String id,
    required String name,
    required String description,
    required String promptTemplate,
  });
  Future<Result<void>> deletePrompt(String id);
  Stream<List<PromptEntity>> watchPrompts();
}
