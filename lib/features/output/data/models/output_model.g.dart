// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputModel _$OutputModelFromJson(Map<String, dynamic> json) => OutputModel(
      id: json['id'] as String,
      contextId: json['contextId'] as String,
      promptId: json['promptId'] as String,
      promptVersion: json['promptVersion'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$OutputModelToJson(OutputModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contextId': instance.contextId,
      'promptId': instance.promptId,
      'promptVersion': instance.promptVersion,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };
