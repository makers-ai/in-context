import 'package:incontext/features/project/domain/entities/project_entity.dart';
import 'package:incontext/features/project/domain/repositories/project_repository.dart';

class ListProjects {
  const ListProjects(this._repository);

  final ProjectRepository _repository;

  Stream<List<ProjectEntity>> call() => _repository.watchProjects();
}
