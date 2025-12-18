import 'package:incontext/features/thought/domain/entities/thought_entity.dart';
import 'package:incontext/features/thought/domain/repositories/thought_repository.dart';

class ListThoughtsForProject {
  const ListThoughtsForProject(this._repository);

  final ThoughtRepository _repository;

  Stream<List<ThoughtEntity>> call(String projectId) => _repository.watchThoughts(projectId);
}
