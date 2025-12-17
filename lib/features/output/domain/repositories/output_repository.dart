import 'package:incontext/core/utils/result.dart';
import 'package:incontext/features/output/domain/entities/output_entity.dart';

abstract class OutputRepository {
  /// Stream of all outputs for a context
  Stream<List<OutputEntity>> watchOutputs(String projectId, String contextId);

  /// Create a new output
  Future<Result<OutputEntity>> createOutput({
    required String projectId,
    required String contextId,
    required String promptId,
    required String promptVersion,
    required String content,
  });

  /// Delete an output
  Future<Result<void>> deleteOutput(String projectId, String outputId);
}
