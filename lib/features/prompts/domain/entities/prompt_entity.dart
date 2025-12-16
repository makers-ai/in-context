import 'package:equatable/equatable.dart';

class PromptEntity extends Equatable {
  const PromptEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.promptTemplate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String version;
  final String promptTemplate;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, name, description, version, promptTemplate, createdAt, updatedAt];

  @override
  String toString() => 'PromptEntity(id: $id, name: $name v$version)';
}
