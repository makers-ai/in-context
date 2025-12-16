import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incontext/features/prompts/domain/entities/prompt_entity.dart';

class PromptModel {
  const PromptModel({
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

  factory PromptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromptModel(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      version: data['version'] as String? ?? '1.0.0',
      promptTemplate: data['promptTemplate'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  PromptEntity toEntity() {
    return PromptEntity(
      id: id,
      name: name,
      description: description,
      version: version,
      promptTemplate: promptTemplate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
