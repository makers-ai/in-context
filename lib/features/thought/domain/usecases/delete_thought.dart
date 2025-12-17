import 'package:incontext/core/utils/result.dart';
import 'package:incontext/features/thought/domain/repositories/thought_repository.dart';

class DeleteThought {
  const DeleteThought(this._repository);

  final ThoughtRepository _repository;

  Future<Result<void>> call(String thoughtId) =>
      _repository.deleteThought(thoughtId);
}
